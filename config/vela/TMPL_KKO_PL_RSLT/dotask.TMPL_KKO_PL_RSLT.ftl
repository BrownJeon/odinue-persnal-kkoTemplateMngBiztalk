<#-- ���ø���û �����Լ� -->
<#include "../TMPL_KKO_EXT/include/request.include_function.ftl"/>
<#--  TASK ��� �Լ�  -->
<#include "../TMPL_KKO_EXT/include/biz/ftls/task/pollingResultFunction.ftl"/>

<#assign tmplMngrUrl = m1.shareget("tmplMngrUrl")/>
<#assign resultCountFetch = m1.shareget("resultCountFetch")/>

<#assign dbxFileQueueName = m1.shareget("dbxFileQueueName")/>
<#assign fileQueueObj = m1.shareget("fileQueueObj")/>

<#assign sqlConn = m1.new("sql")/>

<#--  ���μ��� ��������  -->
<#assign isStop = m1.shareget("isStop")!false/>

<#--  �ʱ� ���� ���н� ���μ��� ������ ���ؼ� TASK ���� ó��.  -->
<#if !isStop>
	<#assign stackValue = doTask()/>
<#else>
    <#assign stackValue = -9/>
</#if>

<#assign r = m1.stack("return", stackValue)/>

<#assign r = sqlConn.close()/>

<#function doTask>
	<#--return 0:���, -9:�ý��� ����-->
	<#local clear = 0/>
	<#local retry = -1/>
	<#local systemExit = -9/>

	<#attempt>
		<#--��ȸ-->
		<#local selectPollResultQuery = m1.session("selectPollResultQuery")/>

		<#local requestList = sqlConn.query2arrayp(selectPollResultQuery, {
			"countFetch": resultCountFetch
			, "staus": "3"
			, "approvalCode": "200"
			, "approvalReason": "���δ��"
			, "searchInterval": 7
		})/>

		<#if requestList?size == 0>
			<#--��ȸ�� ������ ����-->
			<#local r= m1.log("[RPT][POLL] ������ ����.", "INFO")/>

			<#return clear/>
		<#else>
			<#local r= m1.log("[RPT][POLL] �����û ������ ����. @��ȸ�Ǽ�=[${requestList?size}]", "INFO")/>
		</#if>

		<#--�˼� ��� ��ȸ-->
		<#list requestList as request>
			<#local seqLocal = request.TM_SEQ?c/>

			<#local r= m1.log("[RPT][POLL][${request_index}] biz���� �����û. @SEQ=[${seqLocal}]", "INFO")/>
			<#local r= m1.log(request, "DEBUG")/>

			<#--  �˼���û���� ���� RBC��û �Լ�  -->
			<#local apiResult = taskPollResultFunction_requestPollingResult4BizCenter(seqLocal, request)/>
			<#if !apiResult?has_content>
				<#local r = m1.log("[RPT][POLL][ERR] RBC���� �˼���û �� ���� �߻�. @SEQ=[${seqLocal}]", "ERROR")/>

				<#return clear/>
			</#if>

			<#--  �˼���� ��ȸ api ���������� ���� ���ó�� �Լ�  -->
			<#local r = taskPollResultFunction_templateStatus2Db(seqLocal, apiResult)/>

		</#list>

	<#recover>
		<#local r = m1.log("[RPT][POLL][ERR] �˼���� ó���� �����߻�.", "ERROR")/>

	</#attempt>

	<#return clear/>
</#function>
