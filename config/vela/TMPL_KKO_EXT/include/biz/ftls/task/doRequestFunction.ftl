<#--
    함수목록
        - taskDoRequestFunction_getCreateTemplateUrl: 템플릿등록요청 URL 정의 함수
        - taskDoRequestFunction_parseRequestData: 비즈톡센터 요청전문 파싱 함수
        - taskDoRequestFunction_parseResponseData: 비즈톡센터에서 응답받은 전문을 파싱 함수
-->

<#--  템플릿등록요청 URL 정의 함수  -->
<#function taskDoRequestFunction_getCreateTemplateUrl>

    <#--  API버전이 분리되어 있지 않아서 고정으로 URL정의  -->
    <#local tmplMngrUrl = m1.shareget("tmplMngrUrl")!""/>
    <#local createTemplateUrl = "${tmplMngrUrl}/template/create"/>

    <#return createTemplateUrl/>
</#function>

<#--  비즈톡센터 요청전문 파싱 함수  -->
<#function taskDoRequestFunction_parseRequestData _seqLocal _rcvBody>

    <#if _rcvBody?size == 0>
        <#local r = m1.log("[REQ][DO][ERR] 전문 변환오류. 처리무시. @SEQ=[${_seqLocal}] @변환요청전문=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#local senderKey = _rcvBody.CHANNEL_ID!""/>
    <#if !senderKey?has_content>
        <#local r = m1.log("[REQ][DO][ERR] 전문 내 발신프로필키 없음. 처리무시. @SEQ=[${_seqLocal}] @변환요청전문=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#local formParam = m1.parseJsonValue(_rcvBody.FORM_PARAM!"{}")/>
    <#if !formParam?has_content>
        <#local r = m1.log("[REQ][DO][ERR] 필수요청 전문 없음. 처리무시. @SEQ=[${_seqLocal}] @변환요청전문=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#-- 검수요청 payload 정의 -->
    <#-- 요청전문 파싱 실패시 빈값처리 -->
    <#local createPayloadResponseMap = commonFunction_parseCreateTemplatePayloadMap(_rcvBody)/>
    <#local createPayloadResponseCode = createPayloadResponseMap.code/>
    <#if createPayloadResponseCode != "200">
        <#return {
            "code": createPayloadResponseCode
            , "message": createPayloadResponseMap.message
        }/>
    </#if>
    <#local payloadMap = createPayloadResponseMap.payload/>

    <#-- 검수요청 header 정의 -->
    <#local createHeaderResponseMap = commonFunction_getRequestHeaderMap(senderKey, {})/>
    <#local createHeaderResponseCode = createHeaderResponseMap.code/>

    <#if createHeaderResponseCode != "200">
        <#return {
            "code": createHeaderResponseCode
            , "message": createHeaderResponseMap.message
        }/>
    </#if>
    <#local headerMap = createHeaderResponseMap.header/>

    <#return {
        "code": "200"
        , "headerMap": headerMap
        , "payloadMap": payloadMap
    }/>

</#function>

<#--  비즈톡센터에서 응답받은 전문을 파싱 함수  -->
<#--
    성공
{
    "code": "200",
    "data": {
        "senderKey": "d556109269a3158ee278ca371662efeffb081b93",
        "senderKeyType": "S",
        "templateCode": "ODI010001",
        "templateName": "템플릿등록테스트001",
        "templateContent": "[어다인]내부 테스트(test)\\r\\n전직원공지사항",
        "inspectionStatus": "REG",
        "createdAt": "2023-09-1316:24:53",
        "modifiedAt": "",
        "status": "K",
        "buttonType": "N",
        "buttonName": "",
        "buttonUrl": "",
        "templateMessageType": "BA",
        "templateEmphasizeType": "NONE",
        "templateExtra": "",
        "templateAd": "",
        "templateTitle": "",
        "templateSubtitle": "",
        "securityFlag": "false",
        "categoryCode": "001001",
        "templateHeader": "",
        "templateImageName": "",
        "templateImageUrl": "",
        "buttons": [],
        "quickReplies": [],
        "templateItemHighlight": {},
        "templateItem": [],
        "templateRepresentLink": [],
        "commentsList": []
    }
}

    실패
{
    "code": "504",
    "message": "하나의 발신프로필에 동일한 템플릿코드를 중복해서 등록할 수 없습니다."
}

-->
<#function taskDoRequestFunction_parseResponseData _seqLocal _payloadMap, _httpResponseBody>
    <#local templateCreateResponseJson = m1.editable(m1.parseJsonValue(_httpResponseBody)!{})/>

    <#local templateCreateResCode = templateCreateResponseJson.code!-999/>

    <#local messagebaseId = ""/>

    <#if templateCreateResCode != "200">
        <#local templateCreateResMessage = templateCreateResponseJson.message!"기타오류"/>

        <#local r = m1.log("[REQ][DO][REQUEST][FAIL] 템플릿검수 요청 실패. @SEQ=[${_seqLocal}] @검수결과코드=[${templateCreateResCode}]", "ERROR")/>
        <#local r = m1.log(templateCreateResponseJson, "ERROR")/>
    <#else>
        <#local templateCreateResMessage = "성공"/>
        <#local templateCode = templateCreateResponseJson.data.templateCode!""/>

        <#local r = m1.log("[REQ][DO][REQUEST][SUCC] 템플릿검수 요청 성공. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @검수결과코드=[${templateCreateResCode}]", "INFO")/>
        <#local r = m1.log(templateCreateResponseJson, "DEBUG")/>

    </#if>

    <#local r = templateCreateResponseJson.put("message", templateCreateResMessage)/>

    <#local r = m1.put(_payloadMap, "TM_SEQ", _seqLocal)/>
    <#local r = m1.put(_payloadMap, "apiResult", templateCreateResponseJson)/>

    <#return _payloadMap/>
</#function>
