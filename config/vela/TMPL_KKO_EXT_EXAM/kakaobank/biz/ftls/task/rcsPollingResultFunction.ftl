<#--  RBC �˼���� ��ȸ �Լ�  -->
<#function taskPollResultFunction_requestPollingResult4Rbc _seqLocal _request>

    <#-- �ʼ��� üũ -->
    <#local brandId = _request.CHANNEL_ID!""/>
    <#local messagebaseId = _request.TEMPLATE_ID!""/>
    <#if !brandId?has_content>
        <#local r= m1.log("[RPT][POLL][ERR] �귣��ID �������� ���� ó�� ����. @SEQ=[${_seqLocal}] @brandId=[${brandId}]", "ERROR")/>

        <#return {}/>
    <#elseif !messagebaseId?has_content>
        <#local r= m1.log("[RPT][POLL][ERR] ���̽�ID �������� ���� ó�� ����. @SEQ=[${_seqLocal}] @messagebaseId=[${messagebaseId}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#local r = m1.log("[RPT][POLL] ��ū���� ��ȸ. @SEQ=[${_seqLocal}] @brandId=[${brandId}] @messagebaseId=[${messagebaseId}]", "INFO")/>

    <#-- ��ū���� ��ȸ -->
    <#local tokenInfo = m1.shareget(brandId)!{}/>
    <#if !tokenInfo?has_content && !tokenInfo.accessToken?has_content>
        <#local r= m1.log("[RPT][POLL][ERR] �귣��ID�������� ���� ó�� ����. @SEQ=[${_seqLocal}] @tokenInfo=[${m1.toJsonBytes(tokenInfo)}]", "ERROR")/>

        <#return {}/>
    <#else>
        <#local token = tokenInfo.accessToken/>

    </#if>

    <#-- �˼���� header ���� -->
    <#local headerMap = commonFunction_getRequestHeaderMap(token, {})/>

    <#local r = m1.log("[RPT][POLL] �˼���� ��ȸ ��û. @SEQ=[${_seqLocal}] @���̽�ID=[${messagebaseId}]", "INFO")/>

    <#local httpResponseCode = httpObj.get("${tmplMngrUrl}/brand/${brandId}/messagebase/${messagebaseId}", headerMap)!-1/>
    <#if httpResponseCode != 200>
        <#local r = m1.log("[RPT][POLL][FAIL] �˼���� ��ȸ ����. @SEQ=[${_seqLocal}] @�����ڵ�=[${httpResponseCode}]", "ERROR")/>
        <#local r = m1.log(httpObj.responseData, "ERROR")/>

        <#return {}/>
    </#if>

    <#-- HTTP��û ���� -->
    <#local httpResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>

    <#return m1.parseJsonValue(httpResponseBody)/>

</#function>

<#--  RBC���� ��ȸ�� ����� ���� DBó�� �Լ�  -->
<#function taskPollResultFunction_templateStatus2Db _seqLocal _apiResult>

    <#local messagebaseId = _apiResult.messagebaseId!""/>
    <#if (_apiResult.result?size > 0)>
        <#local messagebaseId = _apiResult.result[0].messagebaseId!""/>
    </#if>

    <#local code = _apiResult.code!""/>
    <#if code == "20000000">
        <#-- ���� -->
        <#local responseBodys = _apiResult.result![]/>
        <#if (responseBodys?size > 0)>
            <#-- �����ȸ�� 1�Ǿ��ϹǷ�  array���� 1�Ǹ� ���Ե� -->
            <#local responseBody = responseBodys[0]!{}/>
        <#else>
            <#local r = m1.log("[RPT][ERR] �˼���� ��ȸ������ ����. @���䵥����=[${m1.toJsonBytes(_apiResult)}]", "ERROR")/>
            <#local responseBody = {}/>

        </#if>
        <#local templateResultStatus = responseBody.approvalResult!""/>
        
    <#else>
        <#-- ���� -->
        <#local responseBody = _apiResult.error!{}/>
        <#local templateResultStatus = responseBody.message!""/>

        <#local code = responseBody.code!""/>
    </#if>

    <#-- �˼���ȸ�� ����,�ݷ������� ���ø��� ���Ͽ� ���ó�� -->
    <#if code == "20000000" && (templateResultStatus == "����" || templateResultStatus == "�ݷ�" || templateResultStatus == "����")>
        <#local r = m1.log("[RPT][POLL] �˼���� ��ȸ �Ϸ�. @���̽�ID=[${messagebaseId}] @�˼�����=[${templateResultStatus}]", "INFO")/>
        <#local r = m1.log("@���䵥����=[${m1.toJsonBytes(_apiResult)?string}]", "DEBUG")/>

        <#local writeFileQueueMap = m1.editable({})/>

        <#list request as key, value>
            <#local r = writeFileQueueMap.put(key, value)/>
        </#list> 
        <#local r = writeFileQueueMap.put("apiResult", {
            "code": code
            , "approvalResult": responseBody.approvalResult!""
            , "approvalReason": responseBody.approvalReason!""
            , "status": m1.decode(templateResultStatus, "����", "ready", "pause")
            , "approvalDate": responseBody.approvalDate!""
            , "updateDate": responseBody.updateDate!""
        })/>

        <#local writeFileQueueBytes=m1.toJsonBytes(writeFileQueueMap)/>

        <#--�����̳� �ݷ��ÿ� DBXť�� �����͸� ����-->
        <#local fret = commonFunction_writeFileQueue4N(fileQueueObj, writeFileQueueMap, "PL_RPT", dbxFileQueueName)/>

        <#if (fret < 0)>
            <#local r = m1.log("[REQ][WRITE][ERR] ����ť ���� ����. ���μ�������... r=[${fret}]","FATAL")/>

            <#return fret/>
        <#else>
            <#local r = m1.log("[REQ][POLL][SUCC] ���������� ����ť ����Ϸ�. @SEQ=[${_seqLocal}]", "INFO")/>

        </#if>

    <#elseif templateResultStatus == "���δ��">
        <#local r = m1.log("[RPT][POLL] �˼���� ��ȸ ����. @SEQ=[${_seqLocal}] @���̽�ID=[${messagebaseId}] @�˼�����=[${templateResultStatus}]", "INFO")/>
        <#local r = m1.log("@���䵥����=[${m1.toJsonBytes(_apiResult)?string}]", "DEBUG")/>
    <#else>
        <#local r = m1.log("[RPT][POLL] �˼�ó�� ���ø��� �ƴմϴ�. DBó�� ���� ����. @SEQ=[${_seqLocal}] @���̽�ID=[${messagebaseId}] @�˼�����=[${templateResultStatus}] @���䵥����=[${m1.toJsonBytes(_apiResult)?string}]", "ERROR")/>
    </#if>

    <#return 1/>

</#function>