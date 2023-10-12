<#-- ���ø���û �����Լ� -->
<#include "../TMPL_KKO_EXT/include/request.include_function.ftl"/>
<#--  TASK ��� �Լ�  -->
<#include "../TMPL_KKO_EXT/include/biz/ftls/task/doRequestFunction.ftl"/>

<#assign dbxFileQueueName = m1.shareget("dbxFileQueueName")/>
<#assign fileQueueObj = m1.shareget("fileQueueObj")/>

<#--  ���μ��� ��������  -->
<#assign isStop = m1.shareget("isStop")!false/>

<#--  �ʱ� ���� ���н� ���μ��� ������ ���ؼ� TASK ���� ó��.  -->
<#if !isStop>
	<#assign stackValue = doTask()/>
<#else>
    <#assign stackValue = -9/>
</#if>

<#assign r = m1.stack("return", stackValue)/>


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
		<#local rsCode = requestDataMap.code/>
		<#if rsCode != "200">
			<#local r = m1.log("[REQ][DO][ERR] �˼���û ���� �Ľ� �� ����. @SEQ=[${seqLocal}] @��������=", "ERROR")/>
			<#local r = m1.log(received?string, "ERROR")/>
			
			<#local isSucc = false/>

			<#-- ����ó��  -->
			<#local rs = commonFunction_error2writeFileQ(
				fileQueueObj
				, seqLocal
				, rsCode
				, requestDataMap.message!"[M1] ���ø����ó�� �� �˼���û ���� �Ľ� ���� �߻�."
				, "DO_REQ"
				, dbxFileQueueName
			)/>

			<#return clear/>
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
			, seqLocal
			, "501"
			, "[M1] ���ø����ó�� �� ������ �Ľ� ���� �߻�. @�����޽���=[${errorMsg}]"
			, "DO_REQ"
			, dbxFileQueueName
		)/>

		<#return clear/>
	</#attempt>

	<#-- ������ �Ľ��� �Ϸ�Ǿ��ٸ� ���ø�ó�� Ÿ�Կ� ���� ó�� ���� -->
	<#if isSucc>
		<#-- ���ø���� ó�� -->
		<#attempt>
			<#-- �˼���û ���� ���� -->
			<#local headerMap = requestDataMap.headerMap!{}/>
			<#local payloadMap = requestDataMap.payloadMap!{}/>

			<#local r = m1.log("[REQ][DO][CREATE] ���ø��˼� ��û. @SEQ=[${seqLocal}] @�߽�������Ű=[${rcvBody.CHANNEL_ID!''}] @���ø�ID=[${rcvBody.TEMPLATE_ID!''}] @��ûURL=[${requestUrl}]", "INFO")/>
			<#local r = m1.log(headerMap, "INFO")/>
			<#local r = m1.log(payloadMap, "INFO")/>

			<#--  
				biz���� ���ø��˼� ��û
				- method: POST
				- header
					{
						siteid: ����ID
						auth_key: ����Ű
					}
				- payload
					{
						templateCode: ���ø��ڵ�
						templateName: ���ø���
						templateContent: ��������
						templateMessageType: ���ø��޽��� ����(BA: �⺻��(default), EX: �ΰ� ������, AD: ä�� �߰���, MI: ������)
						templateEmphasizeType: ���ø� ���� ���� (NONE: ���þ���(default), TEXT: ����ǥ����)
						categoryCode: ī�װ� �ڵ�
						...
					}
				- ���ڰ�
					commonFunction_requestHttp4ResultMap(_requestUrl, _methodType, _headerMap, _urlParamMap, _payloadMap, _uploadFileMap)
			-->
			<#local responseData = commonFunction_requestHttp4ResultMap(requestUrl, "POST", headerMap, {}, payloadMap, {})/>
			<#local responseCode = responseData.code/>
			<#if responseCode != "200">
				<#--  �˼���û ����. ���п� ���� ����ť���� ó��  -->
				<#local rs = commonFunction_error2writeFileQ(
					fileQueueObj
					, seqLocal
					, responseCode
					, "���ø����ó�� �� ������Ʈ ����. @�����޽���=[${responseData.message!''}]"
					, "DO_REQ"
					, dbxFileQueueName
				)/>

				<#return clear/>

			<#else>
				<#local httpResponseBody = responseData.data!{}/>
			</#if>

			<#--  biz���Ϳ��� ������� ������ �Ľ�  -->
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
				, seqLocal
				, "501"
				, "[M1]���ø����ó�� �� ����. @�����޽���=[${errorMsg}]"
				, "DO_REQ"
				, dbxFileQueueName
			)/>

			<#return clear/>
		</#attempt>
		
	</#if>
</#function>

