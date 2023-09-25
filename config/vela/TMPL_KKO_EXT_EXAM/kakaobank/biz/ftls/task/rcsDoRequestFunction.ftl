

<#--  RBC ��û������ api������ �°� �Ľ�  -->
<#function taskDoRequestFunction_parseRbcRequestData _seqLocal _rcvBody _apiVersion>

    <#if _rcvBody?size == 0>
        <#local r = m1.log("[REQ][DO][ERR] ���� ��ȯ����. ó������. @SEQ=[${_seqLocal}] @��ȯ��û����=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#local brandId = _rcvBody.CHANNEL_ID!""/>
    <#if !brandId?has_content>
        <#local r = m1.log("[REQ][DO][ERR] ���� �� �귣��ID ����. ó������. @SEQ=[${_seqLocal}] @��ȯ��û����=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#local messagebaseformId = _rcvBody.MESSAGEBASE_FORM_ID!""/>
    <#if !messagebaseformId?has_content>
        <#local r = m1.log("[REQ][DO][ERR] ���� �� ���̽���ID ����. ó������. @SEQ=[${_seqLocal}] @��ȯ��û����=[${m1.toJsonBytes(_rcvBody)?string}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#local token = (m1.shareget(brandId)).accessToken!""/>
    <#local brandKey = (brandInfoMap[brandId]!{}).brandKey!""/>

    <#-- �˼���û URL����. ���������� ���� ��ûURL �����Ͽ� ���� -->
    <#local createTemplateUrl = commonFunction_getCreateTemplateUrl(messagebaseformId, brandId, apiVersion)/>

    <#-- �˼���û payload ���� -->
    <#-- ��û���� �Ľ� ���н� ��ó�� -->
    <#local payloadMap = commonFunction_parseCreateTemplatePayloadMap(_rcvBody, apiVersion)/>

    <#-- �˼���û header ���� -->
    <#local headerMap = commonFunction_getRequestHeaderMap(token, {"X-RCS-Brandkey": brandKey})/>

    <#return {
        "headerMap": headerMap
        , "payloadMap": payloadMap
    }/>

</#function>

<#--  RBC���� ������� ������ �Ľ�  -->
<#function taskDoRequestFunction_parseRbcResponseData _seqLocal _payloadMap, _httpResponseBody>
    <#local templateCreateResponseJson = m1.editable(m1.parseJsonValue(_httpResponseBody)!{})/>

    <#local templateCreateResCode = templateCreateResponseJson.status!-999/>

    <#local messagebaseId = ""/>

    <#if templateCreateResCode != 200>
        <#if templateCreateResponseJson?has_content && templateCreateResponseJson.error?has_content>
            <#local templateCreateResMessage = templateCreateResponseJson.error.message!"����"/>

            <#local code = templateCreateResponseJson.error.code!"79999"/>
        <#else>
            <#local templateCreateResMessage = "����"/>
            <#local code = "79999"/>
        </#if>

        <#local r = m1.log("[REQ][DO][REQUEST][FAIL] �˼���û ����. @SEQ=[${_seqLocal}] @�˼�����ڵ�=[${code}] @HTTP�����ڵ�=[${templateCreateResCode}]", "ERROR")/>
        <#local r = m1.log(templateCreateResponseJson, "ERROR")/>
    <#else>
        <#local templateCreateResMessage = "����"/>
        <#local code = templateCreateResponseJson.code!"79999"/>
        <#if (templateCreateResponseJson.result?size > 0)>
            <#local messagebaseId = templateCreateResponseJson.result[0].messagebaseId!""/>
        </#if>

        <#local r = m1.log("[REQ][DO][REQUEST][SUCC] �˼���û ����. @SEQ=[${_seqLocal}] @���ø�ID=[${messagebaseId}] @�˼�����ڵ�=[${code}] @HTTP�����ڵ�=[${templateCreateResCode}]", "INFO")/>
        <#local r = m1.log(templateCreateResponseJson, "DEBUG")/>

    </#if>

    <#local r = templateCreateResponseJson.put("message", templateCreateResMessage)/>

    <#return _payloadMap.merge({
        "TM_SEQ": _seqLocal
        , "apiResult": templateCreateResponseJson
    }, "true")/>
</#function>
