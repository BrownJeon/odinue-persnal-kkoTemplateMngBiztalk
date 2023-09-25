<#-- ���ø���û �����Լ� -->
<#include "../../../request.include_function.ftl"/>

<#assign updateTemplateRbcFormParamQuery = m1.session("updateTemplateRbcFormParamQuery")/>

<#function taskDbxFunction_parseRequest2ExecuteParamMap _seqLocal _sqlConn _apiResult _responseBody>

	<#local executeParamMap = m1.editable({})/>

    <#local templateUseYn = ""/>
    <#local messagebaseId = ""/>

    <#local apiResultCode = _apiResult.code!"799999"/>
    <#if apiResultCode == "20000000">
        <#--����-->
        <#local step = "3">
        <#local resultStatus = "���δ��"/>
        <#local resultCode = apiResultCode/>
        <#local apiResultReason = _apiResult.message!""/>
        <#local messagebaseId = _apiResult.result[0]["messagebaseId"]!""/>

        <#local r = executeParamMap.put("���ο�û�Ͻ�", ymdhms)/>
        
        <#-- 
            RBC���Ϳ� �˼���û �� ���ø��� ���� ����ȸ �� formattedString��ü ����
            api������ ���� ��û������ �԰��� �޶� ������ ���� brandId�Ľ̿� ���� ���� �и� 
        -->
        <#local apiVersion = m1.shareget("apiVersion")/>
        <#if apiVersion == "v2">
            <#local brandId = _responseBody.brandId!""/>
        <#else>
            <#local regMessagebases = _responseBody.regMessagebases![]/>
            <#if regMessagebases?has_content>
                <#local brandId = regMessagebases[0].brandId!""/>
            <#else>
                <#local brandId = ""/>
            </#if>
            
        </#if>

        <#-- 
            RBC���� ���ø�����ȸ api��û
            �귣��ID�� ���õ��� �ʾ��� ��� formmatedStringó�� ���� �ʰ� �˼�ó�� ����� DBó�� 
        -->
        <#if brandId?has_content>
            <#local tokenInfoMap = m1.shareget(brandId)/>
            <#local token = tokenInfoMap.accessToken/>

            <#local r = m1.log("[DBX][REQ][TMPL][RBC][SELECT] formattedString���� DBó���� ���� RBC���� ���ø�����ȸ ��û. @SEQ=[${_seqLocal}] @�귣��ID=[${brandId}] @���̽�ID=[${messagebaseId}]", "INFO")/>
            
            <#local templateDetailResultMap = commonFunction_requestGet4ResultMap(token, "${tmplMngrUrl}/brand/${brandId}/messagebase/${messagebaseId}")!-1/>
            <#if templateDetailResultMap?has_content && templateDetailResultMap.formattedString?has_content>
                <#local rbcFormattedStringMap = templateDetailResultMap.formattedString!"{}"/>
                <#local r = m1.log(rbcFormattedStringMap, "DEBUG")/>

                <#-- formattedString�԰� DBó�� -->
                <#if rbcFormattedStringMap?has_content>
                    <#-- CLOB ������ update�� CLOB�÷��� updateó���ؾ� ��. �ٸ� �÷��� �Բ� update�� ���� �߻�(java.io.FileNotFoundException) -->
                    <#local updateRs = _sqlConn.execute(updateTemplateRbcFormParamQuery, {
                        "SEQ": _seqLocal
                        , "�����ٵ�": rbcFormattedStringMap
                    })/>

                    <#if (updateRs >= 0)>
                        <#local r= m1.log("[DBX][DB][RESULT] ���̽��� ������ UPDATEó�� ����. @SEQ=[${_seqLocal}]", "INFO")/>

                    <#else>
                        <#local r= m1.log("[DBX][DB][RESULT] ���̽��� ������ UPDATEó�� ����. @SEQ=[${_seqLocal}] ", "ERROR")/>
                        <#local r= m1.log(rbcFormattedStringMap, "ERROR")/>

                    </#if>
                </#if> 

            </#if>
        </#if>
    <#else>
        <#--�˼� ��û ����-->
        <#local step = "5">
        <#local resultStatus = "�ݷ�"/>
        <#local resultCode = _apiResult.error.code!"799999"/>
        <#local apiResultReason = _apiResult.error.message/>
        <#local templateUseYn = "N"/>
        
        <#local r = executeParamMap.merge({
            "���ο�û�Ͻ�": ymdhms
            , "ó���Ͻ�": ymdhms
        }, "true")/>

        <#-- �˼���û ������ ��� forrmatedStringó������ ���� -->
    </#if>

    <#return executeParamMap.merge({
		"SEQ": _seqLocal
		, "���̽�ID": messagebaseId
		, "ó���������": apiResultReason
		, "�˼�����ڵ�": resultCode
		, "�˼�ó���ܰ�": step
		, "���ø���뿩��": templateUseYn
        , "�˼�����": resultStatus
	}, "true")/>

</#function>

<#function taskDbxFunction_parseResponse2ExecuteParamMap _seqLocal _apiResult _responseBody>

    <#local executeParamMap = m1.editable({})/>

    <#local messagebaseId = _responseBody.MESSAGEBASE_ID!""/>

    <#local resultCode = _apiResult.code!"799999"/>
    <#local apiResultReason = m1.decode(_apiResult.approvalResult!"", "", "��Ÿ����", _apiResult.approvalResult)/>
    
    <#local step = m1.decode(resultCode, "20000000", "4", "5")/>
    <#local resultStatus = m1.decode(resultCode, "20000000", "����", "�ݷ�")/>
    <#local templateUseYn = m1.decode(resultCode, "20000000", "Y", "N")/>

    <#if _apiResult.approvalDate?has_content>
        <#local approvalDate = m1.replaceAll(_apiResult.approvalDate, "[-T:]", "")?keep_before_last(".") />

    <#else>
        <#local approvalDate = ymdhms/>
    </#if>

    <#return executeParamMap.merge({
		"SEQ": _seqLocal
		, "���̽�ID": messagebaseId
		, "ó���������": apiResultReason
		, "�˼�����ڵ�": resultCode
		, "�˼�ó���ܰ�": step
		, "���ø���뿩��": templateUseYn
		, "ó���Ͻ�": approvalDate
		, "�˼�����": resultStatus
	}, "true")/>

</#function>