

<#--  RBC 요청전문을 api버전에 맞게 파싱  -->
<#function taskDoRequestFunction_parseRbcRequestData _seqLocal _rcvBody _apiVersion>

    <#if _rcvBody?size == 0>
        <#local r = m1.log("[REQ][DO][ERR] 전문 변환오류. 처리무시. @SEQ=[${_seqLocal}] @변환요청전문=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#local brandId = _rcvBody.CHANNEL_ID!""/>
    <#if !brandId?has_content>
        <#local r = m1.log("[REQ][DO][ERR] 전문 내 브랜드ID 없음. 처리무시. @SEQ=[${_seqLocal}] @변환요청전문=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#local messagebaseformId = _rcvBody.MESSAGEBASE_FORM_ID!""/>
    <#if !messagebaseformId?has_content>
        <#local r = m1.log("[REQ][DO][ERR] 전문 내 베이스폼ID 없음. 처리무시. @SEQ=[${_seqLocal}] @변환요청전문=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#local token = (m1.shareget(brandId)).accessToken!""/>
    <#local brandKey = (brandInfoMap[brandId]!{}).brandKey!""/>

    <#-- 검수요청 URL설정. 버전설정에 따라서 요청URL 구분하여 설정 -->
    <#local createTemplateUrl = commonFunction_getCreateTemplateUrl(messagebaseformId, brandId, apiVersion)/>

    <#-- 검수요청 payload 정의 -->
    <#-- 요청전문 파싱 실패시 빈값처리 -->
    <#local payloadMap = commonFunction_parseCreateTemplatePayloadMap(_rcvBody, apiVersion)/>

    <#-- 검수요청 header 정의 -->
    <#local headerMap = commonFunction_getRequestHeaderMap(token, {"X-RCS-Brandkey": brandKey})/>

    <#return {
        "headerMap": headerMap
        , "payloadMap": payloadMap
    }/>

</#function>

<#--  RBC에서 응답받은 전문을 파싱  -->
<#function taskDoRequestFunction_parseRbcResponseData _seqLocal _payloadMap, _httpResponseBody>
    <#local templateCreateResponseJson = m1.editable(m1.parseJsonValue(_httpResponseBody)!{})/>

    <#local templateCreateResCode = templateCreateResponseJson.status!-999/>

    <#local messagebaseId = ""/>

    <#if templateCreateResCode != 200>
        <#if templateCreateResponseJson?has_content && templateCreateResponseJson.error?has_content>
            <#local templateCreateResMessage = templateCreateResponseJson.error.message!"실패"/>

            <#local code = templateCreateResponseJson.error.code!"79999"/>
        <#else>
            <#local templateCreateResMessage = "실패"/>
            <#local code = "79999"/>
        </#if>

        <#local r = m1.log("[REQ][DO][REQUEST][FAIL] 검수요청 실패. @SEQ=[${_seqLocal}] @검수결과코드=[${code}] @HTTP응답코드=[${templateCreateResCode}]", "ERROR")/>
        <#local r = m1.log(templateCreateResponseJson, "ERROR")/>
    <#else>
        <#local templateCreateResMessage = "성공"/>
        <#local code = templateCreateResponseJson.code!"79999"/>
        <#if (templateCreateResponseJson.result?size > 0)>
            <#local messagebaseId = templateCreateResponseJson.result[0].messagebaseId!""/>
        </#if>

        <#local r = m1.log("[REQ][DO][REQUEST][SUCC] 검수요청 성공. @SEQ=[${_seqLocal}] @템플릿ID=[${messagebaseId}] @검수결과코드=[${code}] @HTTP응답코드=[${templateCreateResCode}]", "INFO")/>
        <#local r = m1.log(templateCreateResponseJson, "DEBUG")/>

    </#if>

    <#local r = templateCreateResponseJson.put("message", templateCreateResMessage)/>

    <#return _payloadMap.merge({
        "TM_SEQ": _seqLocal
        , "apiResult": templateCreateResponseJson
    }, "true")/>
</#function>
