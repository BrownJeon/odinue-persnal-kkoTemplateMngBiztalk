<#--  RBC 검수결과 조회 함수  -->
<#function taskPollResultFunction_requestPollingResult4Rbc _seqLocal _request>

    <#-- 필수값 체크 -->
    <#local brandId = _request.CHANNEL_ID!""/>
    <#local messagebaseId = _request.TEMPLATE_ID!""/>
    <#if !brandId?has_content>
        <#local r= m1.log("[RPT][POLL][ERR] 브랜드ID 없음으로 인한 처리 무시. @SEQ=[${_seqLocal}] @brandId=[${brandId}]", "ERROR")/>

        <#return {}/>
    <#elseif !messagebaseId?has_content>
        <#local r= m1.log("[RPT][POLL][ERR] 베이스ID 없음으로 인한 처리 무시. @SEQ=[${_seqLocal}] @messagebaseId=[${messagebaseId}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#local r = m1.log("[RPT][POLL] 토큰정보 조회. @SEQ=[${_seqLocal}] @brandId=[${brandId}] @messagebaseId=[${messagebaseId}]", "INFO")/>

    <#-- 토큰정보 조회 -->
    <#local tokenInfo = m1.shareget(brandId)!{}/>
    <#if !tokenInfo?has_content && !tokenInfo.accessToken?has_content>
        <#local r= m1.log("[RPT][POLL][ERR] 브랜드ID없음으로 인한 처리 무시. @SEQ=[${_seqLocal}] @tokenInfo=[${m1.toJsonBytes(tokenInfo)}]", "ERROR")/>

        <#return {}/>
    <#else>
        <#local token = tokenInfo.accessToken/>

    </#if>

    <#-- 검수결과 header 정의 -->
    <#local headerMap = commonFunction_getRequestHeaderMap(token, {})/>

    <#local r = m1.log("[RPT][POLL] 검수결과 조회 요청. @SEQ=[${_seqLocal}] @베이스ID=[${messagebaseId}]", "INFO")/>

    <#local httpResponseCode = httpObj.get("${tmplMngrUrl}/brand/${brandId}/messagebase/${messagebaseId}", headerMap)!-1/>
    <#if httpResponseCode != 200>
        <#local r = m1.log("[RPT][POLL][FAIL] 검수결과 조회 실패. @SEQ=[${_seqLocal}] @응답코드=[${httpResponseCode}]", "ERROR")/>
        <#local r = m1.log(httpObj.responseData, "ERROR")/>

        <#return {}/>
    </#if>

    <#-- HTTP요청 성공 -->
    <#local httpResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>

    <#return m1.parseJsonValue(httpResponseBody)/>

</#function>

<#--  RBC에서 조회된 결과에 대한 DB처리 함수  -->
<#function taskPollResultFunction_templateStatus2Db _seqLocal _apiResult>

    <#local messagebaseId = _apiResult.messagebaseId!""/>
    <#if (_apiResult.result?size > 0)>
        <#local messagebaseId = _apiResult.result[0].messagebaseId!""/>
    </#if>

    <#local code = _apiResult.code!""/>
    <#if code == "20000000">
        <#-- 성공 -->
        <#local responseBodys = _apiResult.result![]/>
        <#if (responseBodys?size > 0)>
            <#-- 결과조회는 1건씩하므로  array에서 1건만 유입됨 -->
            <#local responseBody = responseBodys[0]!{}/>
        <#else>
            <#local r = m1.log("[RPT][ERR] 검수결과 조회데이터 없음. @응답데이터=[${m1.toJsonBytes(_apiResult)}]", "ERROR")/>
            <#local responseBody = {}/>

        </#if>
        <#local templateResultStatus = responseBody.approvalResult!""/>
        
    <#else>
        <#-- 실패 -->
        <#local responseBody = _apiResult.error!{}/>
        <#local templateResultStatus = responseBody.message!""/>

        <#local code = responseBody.code!""/>
    </#if>

    <#-- 검수조회시 승인,반려상태인 템플릿에 대하여 결과처리 -->
    <#if code == "20000000" && (templateResultStatus == "승인" || templateResultStatus == "반려" || templateResultStatus == "저장")>
        <#local r = m1.log("[RPT][POLL] 검수결과 조회 완료. @베이스ID=[${messagebaseId}] @검수상태=[${templateResultStatus}]", "INFO")/>
        <#local r = m1.log("@응답데이터=[${m1.toJsonBytes(_apiResult)?string}]", "DEBUG")/>

        <#local writeFileQueueMap = m1.editable({})/>

        <#list request as key, value>
            <#local r = writeFileQueueMap.put(key, value)/>
        </#list> 
        <#local r = writeFileQueueMap.put("apiResult", {
            "code": code
            , "approvalResult": responseBody.approvalResult!""
            , "approvalReason": responseBody.approvalReason!""
            , "status": m1.decode(templateResultStatus, "승인", "ready", "pause")
            , "approvalDate": responseBody.approvalDate!""
            , "updateDate": responseBody.updateDate!""
        })/>

        <#local writeFileQueueBytes=m1.toJsonBytes(writeFileQueueMap)/>

        <#--승인이나 반려시에 DBX큐에 데이터를 적재-->
        <#local fret = commonFunction_writeFileQueue4N(fileQueueObj, writeFileQueueMap, "PL_RPT", dbxFileQueueName)/>

        <#if (fret < 0)>
            <#local r = m1.log("[REQ][WRITE][ERR] 파일큐 쓰기 실패. 프로세스종료... r=[${fret}]","FATAL")/>

            <#return fret/>
        <#else>
            <#local r = m1.log("[REQ][POLL][SUCC] 접수데이터 파일큐 쓰기완료. @SEQ=[${_seqLocal}]", "INFO")/>

        </#if>

    <#elseif templateResultStatus == "승인대기">
        <#local r = m1.log("[RPT][POLL] 검수결과 조회 없음. @SEQ=[${_seqLocal}] @베이스ID=[${messagebaseId}] @검수상태=[${templateResultStatus}]", "INFO")/>
        <#local r = m1.log("@응답데이터=[${m1.toJsonBytes(_apiResult)?string}]", "DEBUG")/>
    <#else>
        <#local r = m1.log("[RPT][POLL] 검수처리 템플릿이 아닙니다. DB처리 하지 않음. @SEQ=[${_seqLocal}] @베이스ID=[${messagebaseId}] @검수상태=[${templateResultStatus}] @응답데이터=[${m1.toJsonBytes(_apiResult)?string}]", "ERROR")/>
    </#if>

    <#return 1/>

</#function>