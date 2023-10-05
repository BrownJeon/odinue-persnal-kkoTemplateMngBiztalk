<#include "../TMPL_KKO_EXT/include/request.include_function.ftl"/>

<#assign ymdhmss = m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms = ymdhmss?substring(0,14)/>
<#assign ymd = ymdhms?substring(0,8)/>

<#assign requestCountFetch = m1.shareget("requestCountFetch")/>

<#assign requestFileQueueName = m1.shareget("requestFileQueueName")/>
<#assign fileQueueObj = m1.shareget("fileQueueObj")/>

<#assign m1host = m1.sysenv["M1_HOST"]/>

<#assign sql = m1.new("sql")/>

<#assign stackValue = doTask()/>
<#assign r = m1.stack("return", stackValue)/>

<#assign r = sql.close()/>

<#function doTask>
	<#--return 0:���, -9:�ý�������-->
	<#local clear = 0/>
	<#local systemExit = -9/>

	<#-- ����Ű ä�� -->
	<#local pollkeyQuery = m1.session("pollkeyQuery")/>
	<#local pollkey = sql.query2array(pollkeyQuery, {})[0]["POLLKEY"]/>

	<#-- ó���� ������ marking -->
	<#attempt>
		<#local pollUpdateQuery = m1.session("pollUpdateQuery")/>

		<#local queryResult = sql.executep(pollUpdateQuery, {
			"����Ű": pollkey
			, "�����Ͻ�": m1.now()?string("yyyyMMddHHmmss")
			, "countFetch": requestCountFetch
		})/>

		<#if (queryResult < 0)>
			<#-- marking ����-->
			<#return clear/>
		</#if>

	<#recover>
		<#local r = sqlRollback()/>
		<#return clear/>
	</#attempt>

	<#-- marking�� ������ polling -->
	<#attempt>
		<#local pollingCnt = 0/>

		<#local selectPollQuery = m1.session("selectPollQuery")/>
		<#local requestList = sql.query2list(selectPollQuery, {"pollkey":pollkey})/>

		<#list requestList as request>
			<#local seqLocal = request.TM_SEQ/>

			<#local r = m1.log("[REQ][POLL] ������ ����. @SEQ=[${seqLocal}]", "INFO")/>
			<#local r = m1.log(request, "DEBUG")/>

			<#-- polling������ ����ť ���� -->
			<#--  <#local fret = commonFunction_writeFileQueue4N(fileQueueObj, request, "PL_REQ", requestFileQueueName)/>  -->
			<#local fret = commonFunction_writeFileQueue4one(fileQueueObj, request, "PL_REQ", requestFileQueueName)/>

			<#if (fret < 0)>
				<#local r = m1.log("[REQ][WRITE][ERR] ����ť ���� ����. ���μ�������... r=[${fret}]","FATAL")/>

				<#return fret/>
			<#else>
				<#local r = m1.log("[REQ][POLL][SUCC] ���������� ����ť ����Ϸ�. @SEQ=[${seqLocal}]", "INFO")/>

			</#if>

			<#local pollingCnt += 1/>

		</#list>

		<#if pollingCnt == 0>
			<#local r = m1.log("[REQ][POLL] ������ ����.", "INFO")/>
		</#if>
	<#recover>
		<#local r = sqlRollback()/>
		<#local r = m1.log("[REQ][POLL][ERR] ���������� ó���� �����߻�. @error=[${.error}]", "ERROR")/>

		<#return clear/>
	</#attempt>
		

	<#return clear/>
</#function>

<#function sqlRollback>
	<#attempt>
		<#return sql.rollback()/>
	<#recover>
		<#return -1/>
	</#attempt>
</#function>