<#--  
    �Լ����
        - taskPollResultFunction_requestPollingResult4BizCenter: biz���� �˼���� ��ȸ �Լ�
        - taskPollResultFunction_templateStatus2Db: RBC���� ��ȸ�� ����� ���� DBó�� �Լ�
-->

<#--  biz���� �˼���� ��ȸ �Լ�  -->
<#function taskPollResultFunction_requestPollingResult4BizCenter _seqLocal _request>

    <#-- �ʼ��� üũ -->
    <#local senderKey = _request.CHANNEL_ID!""/>
    <#local templateCode = _request.TEMPLATE_ID!""/>
    <#if !senderKey?has_content>
        <#local r= m1.log("[RPT][POLL][ERR] �߽�������Ű �������� ���� ó�� ����. @SEQ=[${_seqLocal}] @�߽�������Ű=[${senderKey}]", "ERROR")/>

        <#return {}/>
    <#elseif !templateCode?has_content>
        <#local r= m1.log("[RPT][POLL][ERR] ���ø�ID �������� ���� ó�� ����. @SEQ=[${_seqLocal}] @���ø�ID=[${templateCode}]", "ERROR")/>

        <#return {}/>
    </#if>

    <#local token = ""/>
    
    <#-- ������뿩�� ��ū���� ��ȸ -->
    <#local authYn = m1.shareget("authYn")/>
    <#if authYn?upper_case == "Y">
        <#local r = m1.log("[RPT][POLL] ��ū���� ��ȸ. @SEQ=[${_seqLocal}] @�߽�������Ű=[${senderKey}] @���ø�ID=[${templateCode}]", "INFO")/>
        
        <#local tokenInfo = m1.shareget(senderKey)!{}/>
        <#if !tokenInfo?has_content && !tokenInfo.accessToken?has_content>
            <#local r = m1.log("[RPT][POLL][ERR] ��ū���� �������� ���� ó�� ����. @SEQ=[${_seqLocal}] @�߽�������Ű=[${senderKey}]", "ERROR")/>
            <#local r = m1.log(tokenInfo, "ERROR")/>

            <#return {}/>
        <#else>
            <#local token = tokenInfo.accessToken/>

        </#if>
    <#else>
    </#if>

    <#-- �˼���� header ���� -->
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

    <#local r = m1.log("[RPT][POLL] �˼���� ��ȸ ��û. @SEQ=[${_seqLocal}] @���ø��ڵ�=[${templateCode}]", "INFO")/>

    <#local httpResponse = httpRequest.requestHttp("${tmplMngrUrl}/template/search", "GET", headerMap, headerParamMap, {}, {})/>
    <#local httpResponseCode = httpResponse.getResponseCode()/>

    <#if httpResponseCode != 200>
        <#assign httpResponseBody = httpResponse.getErrorBody()/>

        <#local r = m1.log("[RPT][POLL][FAIL] �˼���� ��ȸ ����. @SEQ=[${_seqLocal}] @�����ڵ�=[${httpResponseCode}]", "ERROR")/>
        <#local r = m1.log(httpResponseBody, "ERROR")/>

        <#return {}/>
    </#if>

    <#-- HTTP��û ���� -->
    <#local httpResponseBody = httpResponse.getBody()/>

    <#return m1.parseJsonValue(httpResponseBody)/>

</#function>

<#--  biz���Ϳ��� ��ȸ�� ����� ���� DBX����ť ���� �Լ�  -->
<#function taskPollResultFunction_templateStatus2Db _seqLocal _apiResult>

    <#local templateResultStatusMapper = m1.session("templateResultStatusMapper")/>

    <#local r = m1.log("[RPT][POLL] �˼���� �������� ����ť ���� ����. @SEQ=[${_seqLocal}] ", "INFO")/>
    <#local r = m1.log(_apiResult, "DEBUG")/>

    <#local code = _apiResult.code!""/>
    <#if code == "200">
        <#local responseBody = _apiResult.data!{}/>

        <#local templateCode = responseBody.templateCode!""/>
        <#local templateResultStatus = responseBody.inspectionStatus!""/>

        <#local templateStatusVal = templateResultStatusMapper[templateResultStatus]!"��Ÿ"/>


        <#-- �˼���ȸ�� ����,�ݷ������� ���ø��� ���Ͽ� ���ó�� -->
        <#if 
            templateStatusVal == "����" || templateStatusVal == "�ݷ�"
        >
            <#--  �˼����°� COM(����), REJ(�ݷ�) �� ���  -->
            <#local r = m1.log("[RPT][POLL] �˼���� ��ȸ �Ϸ�. @���̽�ID=[${templateCode}] @�˼�����=[${templateStatusVal}]", "INFO")/>
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
                <#local r = m1.log("[REQ][POLL][SUCC] �˼���� ����ť ���� �Ϸ�. @SEQ=[${_seqLocal}]", "INFO")/>

            </#if>

        <#elseif 
            templateStatusVal == "����" 
            || templateStatusVal == "���"
            || templateStatusVal == "�˼���"
        >
            <#--  �˼����°� REG(����), APL(���), INS(�˼���) �� ���  -->
            <#local r = m1.log("[RPT][POLL] �˼���� ��ȸ ����. @SEQ=[${_seqLocal}] @���̽�ID=[${templateCode}] @�˼�����=[${templateStatusVal}]", "INFO")/>
            <#local r = m1.log("@���䵥����=[${m1.toJsonBytes(_apiResult)?string}]", "DEBUG")/>
        <#else>
            <#local r = m1.log("[RPT][POLL] �˼�ó�������� ���ø��� �ƴ�. @SEQ=[${_seqLocal}] @���̽�ID=[${templateCode}] @�˼�����=[${templateStatusVal}] @���䵥����=[${m1.toJsonBytes(_apiResult)?string}]", "ERROR")/>
        </#if>
    
    <#else>
        <#local message = _apiResult.message!""/>
        <#local r = m1.log("[RPT][ERR] �˼���� ��ȸ ����. @����ڵ�=[${code}] @�������=[${message}]", "ERROR")/>
    </#if>

    <#return 1/>

</#function>