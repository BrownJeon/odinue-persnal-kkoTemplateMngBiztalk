<#--  
    함수목록
        - taskPollResultFunction_requestPollingResult4BizCenter: biz센터 검수결과 조회 함수
        - taskPollResultFunction_templateStatus2Db: RBC에서 조회된 결과에 대한 DB처리 함수
-->

<#--  biz센터 검수결과 조회 함수  -->
<#function taskPollResultFunction_requestPollingResult4BizCenter _seqLocal _request>

    <#-- 필수값 체크 -->
    <#local senderKey = _request.CHANNEL_ID!""/>
    <#local templateCode = _request.TEMPLATE_ID!""/>
    <#if !senderKey?has_content>
        <#local r= m1.log("[RPT][POLL][ERR] 발신프로필키 없음으로 인한 처리 무시. @SEQ=[${_seqLocal}] @발신프로필키=[${senderKey}]", "ERROR")/>

        <#return {}/>
    <#elseif !templateCode?has_content>
        <#local r= m1.log("[RPT][POLL][ERR] 템플릿ID 없음으로 인한 처리 무시. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#local token = ""/>
    
    <#-- 인증사용여부 토큰정보 조회 -->
    <#local authYn = m1.shareget("authYn")/>
    <#if authYn?upper_case == "Y">
        <#local r = m1.log("[RPT][POLL] 토큰정보 조회. @SEQ=[${_seqLocal}] @발신프로필키=[${senderKey}] @템플릿ID=[${templateCode}]", "INFO")/>
        
        <#local tokenInfo = m1.shareget(senderKey)!{}/>
        <#if !tokenInfo?has_content && !tokenInfo.accessToken?has_content>
            <#local r = m1.log("[RPT][POLL][ERR] 토큰정보 없음으로 인한 처리 무시. @SEQ=[${_seqLocal}] @발신프로필키=[${senderKey}]", "ERROR")/>
            <#local r = m1.log(tokenInfo, "ERROR")/>

            <#return {}/>
        <#else>
            <#local token = tokenInfo.accessToken/>

        </#if>
    <#else>
    </#if>

    <#-- 검수결과 header 정의 -->
    <#local createHeaderResponseMap = commonFunction_getRequestHeaderMap(senderKey, {})/>
    <#local createHeaderResponseCode = createHeaderResponseMap.code/>

    <#if createHeaderResponseCode != "200">
        <#return {
            "code": createHeaderResponseCode
            , "message": createHeaderResponseMap.message
        }/>
    </#if>
    <#local headerMap = createHeaderResponseMap.header/>

    <#local headerParamMap = {
        "senderKey": senderKey
        , "templateCode": templateCode
    }/>

    <#local r = m1.log("[RPT][POLL] 검수결과 조회 요청. @SEQ=[${_seqLocal}] @템플릿코드=[${templateCode}]", "INFO")/>

    <#local httpResponse = httpRequest.requestHttp("${tmplMngrUrl}/template/search", "GET", headerMap, headerParamMap, {}, {})/>
    <#local httpResponseCode = httpResponse.getResponseCode()/>

    <#if httpResponseCode != 200>
        <#assign httpResponseBody = httpResponse.getErrorBody()/>

        <#local r = m1.log("[RPT][POLL][FAIL] 검수결과 조회 실패. @SEQ=[${_seqLocal}] @응답코드=[${httpResponseCode}]", "ERROR")/>
        <#local r = m1.log(httpResponseBody, "ERROR")/>

        <#return {}/>
    </#if>

    <#-- HTTP요청 성공 -->
    <#local httpResponseBody = httpResponse.getBody()/>

    <#return m1.parseJsonValue(httpResponseBody)/>

</#function>

<#--  biz센터에서 조회된 결과에 대한 DBX파일큐 쓰기 함수  -->
<#function taskPollResultFunction_templateStatus2Db _seqLocal _apiResult>

    <#local templateResultStatusMapper = m1.session("templateResultStatusMapper")/>

    <#local r = m1.log("[RPT][POLL] 검수결과 응답전문 파일큐 쓰기 시작. @SEQ=[${_seqLocal}] ", "INFO")/>
    <#local r = m1.log(_apiResult, "DEBUG")/>

    <#local code = _apiResult.code!""/>
    <#if code == "200">
        <#local responseBody = _apiResult.data!{}/>

        <#local templateCode = responseBody.templateCode!""/>
        <#local templateResultStatus = responseBody.inspectionStatus!""/>

        <#local templateStatusVal = templateResultStatusMapper[templateResultStatus]!"기타"/>


        <#-- 검수조회시 승인,반려상태인 템플릿에 대하여 결과처리 -->
        <#if 
            templateStatusVal == "승인" || templateStatusVal == "반려"
        >
            <#--  검수상태가 COM(승인), REJ(반려) 의 경우  -->
            <#local r = m1.log("[RPT][POLL] 검수결과 조회 완료. @베이스ID=[${templateCode}] @검수상태=[${templateStatusVal}]", "INFO")/>
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
                <#local r = m1.log("[REQ][POLL][SUCC] 검수결과 파일큐 쓰기 완료. @SEQ=[${_seqLocal}]", "INFO")/>

            </#if>

        <#elseif 
            templateStatusVal == "접수" 
            || templateStatusVal == "등록"
            || templateStatusVal == "검수중"
        >
            <#--  검수상태가 REG(접수), APL(등록), INS(검수중) 의 경우  -->
            <#local r = m1.log("[RPT][POLL] 검수결과 조회 없음. @SEQ=[${_seqLocal}] @베이스ID=[${templateCode}] @검수상태=[${templateStatusVal}]", "INFO")/>
            <#local r = m1.log("@응답데이터=[${m1.toJsonBytes(_apiResult)?string}]", "DEBUG")/>
        <#else>
            <#local r = m1.log("[RPT][POLL] 검수처리상태의 템플릿가 아님. @SEQ=[${_seqLocal}] @베이스ID=[${templateCode}] @검수상태=[${templateStatusVal}] @응답데이터=[${m1.toJsonBytes(_apiResult)?string}]", "ERROR")/>
        </#if>
    
    <#else>
        <#local message = _apiResult.message!""/>
        <#local r = m1.log("[RPT][ERR] 검수결과 조회 실패. @결과코드=[${code}] @결과내용=[${message}]", "ERROR")/>
    </#if>

    <#return 1/>

</#function>