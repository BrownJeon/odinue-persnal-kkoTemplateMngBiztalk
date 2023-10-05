<#--
    �Լ����
        - taskDoRequestFunction_getCreateTemplateUrl: ���ø���Ͽ�û URL ���� �Լ�
        - taskDoRequestFunction_parseRequestData: �����弾�� ��û���� �Ľ� �Լ�
        - taskDoRequestFunction_parseResponseData: �����弾�Ϳ��� ������� ������ �Ľ� �Լ�
-->

<#--  ���ø���Ͽ�û URL ���� �Լ�  -->
<#function taskDoRequestFunction_getCreateTemplateUrl>

    <#--  API������ �и��Ǿ� ���� �ʾƼ� �������� URL����  -->
    <#local tmplMngrUrl = m1.shareget("tmplMngrUrl")!""/>
    <#local createTemplateUrl = "${tmplMngrUrl}/template/create"/>

    <#return createTemplateUrl/>
</#function>

<#--  �����弾�� ��û���� �Ľ� �Լ�  -->
<#function taskDoRequestFunction_parseRequestData _seqLocal _rcvBody>

    <#if _rcvBody?size == 0>
        <#local r = m1.log("[REQ][DO][ERR] ���� ��ȯ����. ó������. @SEQ=[${_seqLocal}] @��ȯ��û����=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#local senderKey = _rcvBody.CHANNEL_ID!""/>
    <#if !senderKey?has_content>
        <#local r = m1.log("[REQ][DO][ERR] ���� �� �߽�������Ű ����. ó������. @SEQ=[${_seqLocal}] @��ȯ��û����=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#local formParam = m1.parseJsonValue(_rcvBody.FORM_PARAM!"{}")/>
    <#if !formParam?has_content>
        <#local r = m1.log("[REQ][DO][ERR] �ʼ���û ���� ����. ó������. @SEQ=[${_seqLocal}] @��ȯ��û����=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#-- �˼���û payload ���� -->
    <#-- ��û���� �Ľ� ���н� ��ó�� -->
    <#local createPayloadResponseMap = commonFunction_parseCreateTemplatePayloadMap(_rcvBody)/>
    <#local createPayloadResponseCode = createPayloadResponseMap.code/>
    <#if createPayloadResponseCode != "200">
        <#return {
            "code": createPayloadResponseCode
            , "message": createPayloadResponseMap.message
        }/>
    </#if>
    <#local payloadMap = createPayloadResponseMap.payload/>

    <#-- �˼���û header ���� -->
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

<#--  �����弾�Ϳ��� ������� ������ �Ľ� �Լ�  -->
<#--
    ����
{
    "code": "200",
    "data": {
        "senderKey": "d556109269a3158ee278ca371662efeffb081b93",
        "senderKeyType": "S",
        "templateCode": "ODI010001",
        "templateName": "���ø�����׽�Ʈ001",
        "templateContent": "[�����]���� �׽�Ʈ(test)\\r\\n��������������",
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

    ����
{
    "code": "504",
    "message": "�ϳ��� �߽������ʿ� ������ ���ø��ڵ带 �ߺ��ؼ� ����� �� �����ϴ�."
}

-->
<#function taskDoRequestFunction_parseResponseData _seqLocal _payloadMap, _httpResponseBody>
    <#local templateCreateResponseJson = m1.editable(m1.parseJsonValue(_httpResponseBody)!{})/>

    <#local templateCreateResCode = templateCreateResponseJson.code!-999/>

    <#local messagebaseId = ""/>

    <#if templateCreateResCode != "200">
        <#local templateCreateResMessage = templateCreateResponseJson.message!"��Ÿ����"/>

        <#local r = m1.log("[REQ][DO][REQUEST][FAIL] ���ø��˼� ��û ����. @SEQ=[${_seqLocal}] @�˼�����ڵ�=[${templateCreateResCode}]", "ERROR")/>
        <#local r = m1.log(templateCreateResponseJson, "ERROR")/>
    <#else>
        <#local templateCreateResMessage = "����"/>
        <#local templateCode = templateCreateResponseJson.data.templateCode!""/>

        <#local r = m1.log("[REQ][DO][REQUEST][SUCC] ���ø��˼� ��û ����. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}] @�˼�����ڵ�=[${templateCreateResCode}]", "INFO")/>
        <#local r = m1.log(templateCreateResponseJson, "DEBUG")/>

    </#if>

    <#local r = templateCreateResponseJson.put("message", templateCreateResMessage)/>

    <#local r = m1.put(_payloadMap, "TM_SEQ", _seqLocal)/>
    <#local r = m1.put(_payloadMap, "apiResult", templateCreateResponseJson)/>

    <#return _payloadMap/>
</#function>
