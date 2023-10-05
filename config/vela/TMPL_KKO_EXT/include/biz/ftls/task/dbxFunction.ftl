<#-- ���ø���û �����Լ� -->
<#--  <#include "../../../request.include_function.ftl"/>  -->

<#--
    �Լ����
        - taskDbxFunction_parseRequest2ExecuteParamMap: �˼���û DBó�� ���� �Ľ� �Լ�
        - taskDbxFunction_parseResponse2ExecuteParamMap: �˼���� DBó�� ���� �Ľ� �Լ�
-->


<#function taskDbxFunction_parseRequest2ExecuteParamMap _seqLocal _apiResult>

    <#local r = m1.log("[DBX][REQUEST] �˼���û DBó�� ���� �Ľ�. @SEQ=[${_seqLocal}]", "INFO")/>
    <#local r = m1.log(_apiResult, "DEBUG")/>

	<#local executeParamMap = m1.editable({})/>

    <#local templateUseYn = "N"/>

    <#local resultCode = _apiResult.code!""/>
    <#local resultReason = _apiResult.message!"��Ÿ����"/>

    <#--  API �������� �Ľ�  -->
    <#if
        _apiResult?has_content
        && resultCode?has_content
        && resultCode == "200"
    >
        <#--  �����ǿ� ���� ������ �Ľ�  -->

        <#local step = "3">
        <#local resultReason = "���δ��"/>

        <#local r = executeParamMap.put("���ο�û�Ͻ�", ymdhms)/>
    <#else>
        <#--�˼� ��û ����-->
        <#if _apiResult.error?has_content>
            <#local errorBody = _apiResult.error!{}/>

            <#local resultCode = errorBody.code!"9999"/>
            <#local resultReason = errorBody.message!"��Ÿ����"/>

        </#if>

        <#local step = "5">

        <#local r = executeParamMap.merge({
            "���ο�û�Ͻ�": ymdhms
            , "ó���Ͻ�": ymdhms
        }, "true")/>

    </#if>

    <#--  �˼���û ���� �߰� �Ľ�  -->
    <#return executeParamMap.merge({
		"SEQ": _seqLocal
		, "ó���������": resultReason
		, "�˼�����ڵ�": resultCode
		, "�˼�ó���ܰ�": step
		, "���ø���뿩��": "N"
	}, "true")/>

    <#local r = m1.log("[DBX][REQUEST] �˼���û DBó�� ���� �Ľ� �Ϸ�. @SEQ=[${_seqLocal}]", "INFO")/>
    <#local r = m1.log(executeParamMap, "INFO")/>

</#function>

<#function taskDbxFunction_parseResponse2ExecuteParamMap _seqLocal _apiResult _responseBody>

    <#local r = m1.log("[DBX][RESULT] �˼���� DBó�� ���� �Ľ�. @SEQ=[${_seqLocal}]", "INFO")/>
    <#local r = m1.log(_apiResult, "DEBUG")/>

    <#local executeParamMap = m1.editable({})/>

    <#local resultCode = _apiResult.code!"799999"/>
    <#local apiResultReason = m1.decode(_apiResult.approvalResult!"", "", "��Ÿ����", _apiResult.approvalResult)/>
    
    <#local step = m1.decode(resultCode, "200", "4", "5")/>
    <#local templateUseYn = m1.decode(resultCode, "200", "Y", "N")/>

    <#if _apiResult.approvalDate?has_content>
        <#local approvalDate = m1.replaceAll(_apiResult.approvalDate, "[-T:]", "")?keep_before_last(".") />

    <#else>
        <#local approvalDate = ymdhms/>
    </#if>

    <#--  �˼���� ���� �߰� �Ľ�  -->
    <#return executeParamMap.merge({
		"SEQ": _seqLocal
		, "ó���������": apiResultReason
		, "�˼�����ڵ�": resultCode
		, "�˼�ó���ܰ�": step
		, "���ø���뿩��": templateUseYn
		, "ó���Ͻ�": approvalDate
	}, "true")/>

    <#local r = m1.log("[DBX][RESULT] �˼���û DBó�� ���� �Ľ� �Ϸ�. @SEQ=[${_seqLocal}]", "INFO")/>
    <#local r = m1.log(executeParamMap, "INFO")/>

</#function>