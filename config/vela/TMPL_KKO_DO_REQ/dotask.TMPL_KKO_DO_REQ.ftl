<#-- ���ø���û �����Լ� -->
<#include "../TMPL_KKO_EXT/include/request.include_function.ftl"/>
<#--  TASK ��� �Լ�  -->
<#include "../TMPL_KKO_EXT/include/biz/ftls/task/doRequestFunction.ftl"/>

<#assign httpRequest = m1.shareget("httpRequest")/>

<#assign tmplMngrUrl = m1.shareget("tmplMngrUrl")/>

<#assign dbxFileQueueName = m1.shareget("dbxFileQueueName")/>
<#assign fileQueueObj = m1.shareget("fileQueueObj")/>


<#assign result = doTask()/>
<#assign r = m1.stack("return",result)/>


<#function doTask>
	<#--return(1: ó��, -1: ��õ�, -9:�ý��� ����)-->
	<#local clear = 1/>
	<#local retry = -1/>
	<#local systemExit = -9/>

	<#local isSucc = true/>
	<#attempt>
		<#--���� �Ľ�-->
		<#local rcvHeader = m1.parseNext(received, "FWXHEADER")/>
		<#local r = m1.log(rcvHeader, "DEBUG")/>

		<#if !rcvHeader["������������"]??>
			<#local r = m1.log("[REQ][DO][ERR] ���� ����. @����=[${received?string}]", "ERROR")/>
			<#return clear/>
		</#if>

		<#local seqLocal = rcvHeader.�߼ۼ��������ĺ���!""/>

		<#local rcvBodyStr = m1.subbytes(received, m1.sizeof(["FWXHEADER"]), rcvHeader["������������"])?string/>

		<#local r = m1.log("[REQ][DO][RCV] ���ø��˼���û ó������. @SEQ=[${seqLocal}]", "INFO")/>
		<#local r = m1.log(rcvBodyStr, "DEBUG")/>

		<#attempt>
			<#local rcvBody = m1.parseJsonValue(rcvBodyStr)!{}/>
		<#recover>
			<#local rcvBody = {}/>
		</#attempt>

		<#local requestUrl = taskDoRequestFunction_getCreateTemplateUrl()/>

		<#--  �˼���û ���� �Ľ� �Լ�  -->
		<#local requestDataMap = taskDoRequestFunction_parseRequestData(seqLocal, rcvBody)/>
		<#if 
			!requestDataMap?has_content 
			|| (!requestDataMap.headerMap?has_content || !requestDataMap.payloadMap?has_content)
		>
			<#local r = m1.log("[REQ][DO][ERR] @��������=[${received?string}]", "ERROR")/>
			
			<#local isSucc = false/>

			<#-- ����ó��  -->
			<#local rs = commonFunction_error2writeFileQ(
				fileQueueObj
				,rcvHeader.�߼ۼ��������ĺ���!""
				, "501"
				, "[M1] ���ø����ó�� �� �˼���û ���� �Ľ� ���� �߻�."
				, "DO_REQ"
				, dbxFileQueueName
			)/>
			<#if (rs < 0)>
				<#return rs/>
			</#if>
		</#if>

	<#recover>
		<#local isSucc = false/>

		<#local r = m1.log("[REQ][DO][FAIL] ������ �Ľ�ó�� �� ����. @SEQ=[${seqLocal}] @��������=[${received?string}]", "ERROR")/>
		<#local r = m1.log(.error, "ERROR")/>

		<#local errorMsg = .error />
		<#if (errorMsg?length > 200)>
			<#local errorMsg = errorMsg?substring(0,200)/>
		</#if>

		<#-- ����ó��  -->
		<#local rs = commonFunction_error2writeFileQ(
			fileQueueObj
			,rcvHeader.�߼ۼ��������ĺ���!""
			, "501"
			, "[M1] ���ø����ó�� �� ������ �Ľ� ���� �߻�. @�����޽���=[${errorMsg}]"
			, "DO_REQ"
			, dbxFileQueueName
		)/>
		<#if (rs < 0)>
			<#return rs/>
		</#if>
	</#attempt>

	<#-- ������ �Ľ��� �Ϸ�Ǿ��ٸ� ���ø�ó�� Ÿ�Կ� ���� ó�� ���� -->
	<#if isSucc>
		<#-- ���ø���� ó�� -->
		<#attempt>
			<#-- �˼���û ���� ���� -->
			<#local headerMap = requestDataMap.headerMap!{}/>
			<#local payloadMap = requestDataMap.payloadMap!{}/>
			
			<#--  <#local headerMap = {
					"Content-Type" : "application/json; charset=utf-8",
					"Accept" : "application/json",
					"siteid": "shLife1",
					"auth_key" : "N2IzZTljNmUwMGFjMzk0NzFjMzU4ZTJmYmY1N2RjZmMwOWM2ZTM4NzIzYzYxOGY3OTMxNzllMDU2Zjc2ZjIwMQ=="
			}/>
			<#local payloadMap = {"senderKey":"d556109269a3158ee278ca371662efeffb081b93",
				"templateCode":"ODI010009",
				"templateName":"���ø�����׽�Ʈ009",
				"templateMessageType":"BA",
				"senderKeyType":"S",
				"categoryCode":"001001",
				"templateContent":"[�����] ���� �׽�Ʈ(test)\r\n������ ��������",
				"templateEmphasizeType":"NONE",
				"buttons":[]}/>  -->
			
			<#local r = m1.log("[REQ][DO][CREATE] ���ø��˼� ��û. @SEQ=[${seqLocal}] @�߽�������Ű=[${rcvBody.CHANNEL_ID!''}] @���ø�ID=[${rcvBody.TEMPLATE_ID!''}] @��ûURL=[${requestUrl}]", "INFO")/>
			<#local r = m1.log(headerMap, "DEBUG")/>
			<#local r = m1.log(payloadMap, "DEBUG")/>

			<#--  �������� ��� POST -->
			<#assign httpResponse = httpRequest.requestHttp(requestUrl, "POST", headerMap, payloadMap, {}, {})/>

			<#assign responseCode = httpResponse.getResponseCode()/>
			<#assign succBody = httpResponse.getBody()/>
			<#assign errBody = httpResponse.getErrorBody()/>

			<#if responseCode != 200 && errBody != "">
				<#assign httpResponseBody = errBody/>
			<#else>
				<#assign httpResponseBody = succBody/>
			</#if>

			<#--  RBC���� ������� ������ �Ľ�  -->
			<#local values = taskDoRequestFunction_parseResponseData(seqLocal, payloadMap, httpResponseBody)/>

			<#local r = m1.log("[REQ][DO][CREATE][SUCC] ���ø� �˼���û �Ϸ�. @SEQ=[${seqLocal}]", "INFO")/>
			<#local r = m1.log(values, "DEBUG")/>

			<#local fret = commonFunction_writeFileQueue4one(fileQueueObj, values, "DO_REQ", dbxFileQueueName)/>
			<#if (fret >= 0)>
				<#return clear/>
			<#else>
				<#local r = m1.log("[REQ][DO][CREATE][ERR] ����ť ���� ����. r=[${fret}]", "FATAL")/>
				<#return systemExit/>
			</#if>

		<#recover>
			<#local r = m1.log("[REQ][DO][CREATE][REQ][FAIL] ���ø����ó�� �� ����. @SEQ=[${seqLocal}]", "FATAL")/>
			<#local r = m1.log(.error, "ERROR")/>

			<#local errorMsg = .error />
			<#if (errorMsg?length > 200)>
				<#local errorMsg = errorMsg?substring(0,200)/>
			</#if>

			<#-- ����ó��  -->
			<#local rs = commonFunction_error2writeFileQ(
				fileQueueObj
				, rcvHeader.�߼ۼ��������ĺ���!""
				, "501"
				, "[M1]���ø����ó�� �� ����. @�����޽���=[${errorMsg}]"
				, "DO_REQ"
				, dbxFileQueueName
			)/>
			<#if (rs < 0)>
				<#return rs/>
			</#if>
		</#attempt>
		
	</#if>
</#function>
