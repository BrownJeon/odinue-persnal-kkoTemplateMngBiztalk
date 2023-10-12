<#-- ���ø���û �����Լ� -->
<#include "../TMPL_KKO_EXT/include/request.include_function.ftl"/>
<#--  TASK ��� �Լ�  -->
<#include "../TMPL_KKO_EXT/include/biz/ftls/task/dbxFunction.ftl"/>

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>

<#assign sqlConn = m1.new("sql")/>

<#assign updateTemplateStatusQuery = m1.session("updateTemplateStatusQuery")/>

<#--  ���μ��� ��������  -->
<#assign isStop = m1.shareget("isStop")!false/>

<#if !isStop>
	<#assign stackValue = doTask()/>
<#else>
    <#assign stackValue = -9/>
</#if>

<#assign r = m1.stack("return", stackValue)/>

<#assign r = sqlConn.close()/>

<#function doTask>
	<#--return 1:ó��, -1:��õ�, -9:�ý��� ����-->
	<#local clear = 1/>
	<#local retry = -1/>
	<#local systemExit = -9/>

	<#local r = m1.log("[DBX][RCV] DBó�� ������ ����.", "INFO")/>
	<#local r = m1.log(received, "DEBUG")/>

	<#--���� �Ľ�-->
	<#local rcvHeader = m1.parseNext(received, "FWXHEADER")/>

	<#if !rcvHeader["������������"]??>
		<#local r = m1.log("[DBX][ERR] ���� ���� @��������=[${received?string}]", "ERROR")/>

		<#return clear/>
	</#if>

	<#local rcvBodyStr = m1.subbytes(received, m1.sizeof(["FWXHEADER"]), rcvHeader["������������"])?string/>

	<#attempt>
		<#local rcvBody = m1.parseJsonValue(rcvBodyStr)!{}/>
	<#recover>
		<#local rcvBody = {}/>
	</#attempt>

	<#if rcvBody?size == 0>
		<#local r = m1.log("[DBX][ERR] ���� ����(body) @��������=[${received?string}]", "ERROR")/>

		<#return clear/>
	</#if>

	<#local seqLocal = rcvHeader.�߼ۼ��������ĺ���/>

	<#--API ���� Ȯ��-->
	<#local apiResult = rcvBody.apiResult!{}/>

	<#local sender = rcvHeader["�������α׷�����"]!""/>
	<#if sender == "DO_REQ">
		<#-- �˼���û ó�� -->
		
		<#if apiResult?has_content>
			<#local r = m1.log("[DBX][REQ] �˼���û ó�� ����. @SEQ=[${seqLocal}]", "INFO")/>
			<#local r = m1.log(rcvHeader, "DEBUG")/>
			<#local r = m1.log(rcvBody, "DEBUG")/>

			<#--  �˼���û ���������� ���� DBó�� ���� �Ľ� �Լ�  -->
			<#--  �˼���û ���� / ���п� ���� ������ ������ �Ľ���  -->
			<#local executeParamMap = taskDbxFunction_parseRequest2ExecuteParamMap(seqLocal, apiResult)/>

		<#else>
			<#local r = m1.log("[DBX][ACK] �˼���û ���䵥���Ͱ� �߸��Ǿ����ϴ�. @���䵥����=[${rcvBodyStr}]", "ERROR")/>

			<#return clear/>
		</#if>

	<#elseif sender == "PL_RPT">
		<#-- �˼� �Ϸ� ó�� -->

		<#if apiResult?has_content >
			<#local r = m1.log("[DBX][RPT] �˼��Ϸ� ���ó�� ����. @SEQ=[${seqLocal}]", "INFO")/>
			<#local r = m1.log(rcvHeader, "DEBUG")/>
			<#local r = m1.log(rcvBody, "DEBUG")/>

			<#--  �˼��Ϸ� ���������� ���� DBó�� ���� �Ľ� �Լ�  -->
			<#local executeParamMap = taskDbxFunction_parseResponse2ExecuteParamMap(seqLocal, apiResult)/>

		<#else>
			<#local r = m1.log("[DBX][RPT] �˼��Ϸ� ���䵥���Ͱ� �߸��Ǿ����ϴ�. @���䵥����=[${rcvBodyStr}]", "ERROR")/>

			<#return retry/>
		</#if>

	<#else>
		<#--������ ���� ���� ���α׷�, Ŭ����-->
		<#local r = m1.log("[DBX][ERR] ������ ���� ���� ���ø� ó��Ÿ��. @�������α׷�����=[${sender}]", "ERROR")/>

		<#return clear/>
	</#if>

	<#local r = m1.log("[DBX][DB][RESULT] DBó�� ����. @SEQ=[${seqLocal}]", "INFO")/>
	<#local r = m1.log(executeParamMap, "DEBUG")/>

	<#-- DBó�� -->
	<#local isSucc = true/>

	<#attempt>
		
		<#-- �˼���û / �����ȸ ��� DBó�� -->
		<#local executeQueryList = updateTemplateStatusQuery?split("#DELIM")/>
		<#list executeQueryList as executeQuery>
			<#local queryResult = sqlConn.execute(executeQuery, executeParamMap)/>
			<#if (queryResult < 0)>
				<#local isSucc = false/>

				<#break/>
			</#if>

		</#list>

	<#recover>
		<#--���� exception, ��õ�-->
		<#local r = m1.log("[DBX][DB][ERR] DB���� ���� �� �����߻� ��õ�... @��������=[${.error}]", "ERROR")/>

		<#return retry/>
	</#attempt>

	<#if isSucc>
		<#attempt>
			<#-- Ŀ�� -->
			<#local commiResult = sqlConn.commit()/>
		<#recover>
			<#attempt>
				<#local r = sqlConn.rollback()/>
			<#recover>
				<#local r = m1.log("[DBX][DB][ERR] Ŀ�� ó�� �� �����߻�. @��������=[${.error}]", "ERROR")/>
			</#attempt>

			<#return retry/>
		</#attempt>

		<#if commiResult != 0>
			<#local r = m1.log("[DBX][DB][ERR] DB commit ����. @SEQ=[${seqLocal}]", "ERROR")/>
			<#return retry/>
		</#if>

		<#local r = m1.log("[DBX][SUCC] DB ó�� �Ϸ�. @SEQ=[${seqLocal}] @�˼�����ڵ�=[${executeParamMap.�˼�����ڵ�!''}] @�˼��������=[${executeParamMap.ó���������!''}]", "INFO")/>
	<#else>
		<#-- update ��� ���� -->
		<#local r = m1.log("[DBX][DB][ERR] �̷� update ����. @SEQ=[${seqLocal}] @�˼�����ڵ�=[${executeParamMap.�˼�����ڵ�!''}] @�˼��������=[${executeParamMap.ó���������!''}]", "ERROR")/>

		<#local r = sqlConn.rollback()/>

		<#return clear/>
	</#if>

	<#return clear/>
</#function>
