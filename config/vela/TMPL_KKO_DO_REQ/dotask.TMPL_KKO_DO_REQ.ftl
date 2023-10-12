<#-- 템플릿요청 공통함수 -->
<#include "../TMPL_KKO_EXT/include/request.include_function.ftl"/>
<#--  TASK 사용 함수  -->
<#include "../TMPL_KKO_EXT/include/biz/ftls/task/doRequestFunction.ftl"/>

<#assign dbxFileQueueName = m1.shareget("dbxFileQueueName")/>
<#assign fileQueueObj = m1.shareget("fileQueueObj")/>

<#--  프로세스 중지여부  -->
<#assign isStop = m1.shareget("isStop")!false/>

<#--  초기 설정 실패시 프로세스 중지를 위해서 TASK 중지 처리.  -->
<#if !isStop>
	<#assign stackValue = doTask()/>
<#else>
    <#assign stackValue = -9/>
</#if>

<#assign r = m1.stack("return", stackValue)/>


<#function doTask>
	<#--return(1: 처리, -1: 재시도, -9:시스템 종료)-->
	<#local clear = 1/>
	<#local retry = -1/>
	<#local systemExit = -9/>

	<#local isSucc = true/>
	<#attempt>
		<#--전문 파싱-->
		<#local rcvHeader = m1.parseNext(received, "FWXHEADER")/>
		<#local r = m1.log(rcvHeader, "DEBUG")/>

		<#if !rcvHeader["하위전문길이"]??>
			<#local r = m1.log("[REQ][DO][ERR] 전문 오류. @전문=[${received?string}]", "ERROR")/>
			<#return clear/>
		</#if>

		<#local seqLocal = rcvHeader.발송서버접수식별자!""/>

		<#local rcvBodyStr = m1.subbytes(received, m1.sizeof(["FWXHEADER"]), rcvHeader["하위전문길이"])?string/>

		<#local r = m1.log("[REQ][DO][RCV] 템플릿검수요청 처리시작. @SEQ=[${seqLocal}]", "INFO")/>
		<#local r = m1.log(rcvBodyStr, "DEBUG")/>

		<#attempt>
			<#local rcvBody = m1.parseJsonValue(rcvBodyStr)!{}/>
		<#recover>
			<#local rcvBody = {}/>
		</#attempt>

		<#local requestUrl = taskDoRequestFunction_getCreateTemplateUrl()/>

		<#--  검수요청 전문 파싱 함수  -->
		<#local requestDataMap = taskDoRequestFunction_parseRequestData(seqLocal, rcvBody)/>
		<#local rsCode = requestDataMap.code/>
		<#if rsCode != "200">
			<#local r = m1.log("[REQ][DO][ERR] 검수요청 전문 파싱 중 에러. @SEQ=[${seqLocal}] @유입전문=", "ERROR")/>
			<#local r = m1.log(received?string, "ERROR")/>
			
			<#local isSucc = false/>

			<#-- 실패처리  -->
			<#local rs = commonFunction_error2writeFileQ(
				fileQueueObj
				, seqLocal
				, rsCode
				, requestDataMap.message!"[M1] 템플릿등록처리 중 검수요청 전문 파싱 에러 발생."
				, "DO_REQ"
				, dbxFileQueueName
			)/>

			<#return clear/>
		</#if>

	<#recover>
		<#local isSucc = false/>

		<#local r = m1.log("[REQ][DO][FAIL] 데이터 파싱처리 중 에러. @SEQ=[${seqLocal}] @유입전문=[${received?string}]", "ERROR")/>
		<#local r = m1.log(.error, "ERROR")/>

		<#local errorMsg = .error />
		<#if (errorMsg?length > 200)>
			<#local errorMsg = errorMsg?substring(0,200)/>
		</#if>

		<#-- 실패처리  -->
		<#local rs = commonFunction_error2writeFileQ(
			fileQueueObj
			, seqLocal
			, "501"
			, "[M1] 템플릿등록처리 중 데이터 파싱 에러 발생. @에러메시지=[${errorMsg}]"
			, "DO_REQ"
			, dbxFileQueueName
		)/>

		<#return clear/>
	</#attempt>

	<#-- 데이터 파싱이 완료되었다면 템플릿처리 타입에 따라서 처리 진행 -->
	<#if isSucc>
		<#-- 템플릿등록 처리 -->
		<#attempt>
			<#-- 검수요청 전문 정의 -->
			<#local headerMap = requestDataMap.headerMap!{}/>
			<#local payloadMap = requestDataMap.payloadMap!{}/>

			<#local r = m1.log("[REQ][DO][CREATE] 템플릿검수 요청. @SEQ=[${seqLocal}] @발신프로필키=[${rcvBody.CHANNEL_ID!''}] @템플릿ID=[${rcvBody.TEMPLATE_ID!''}] @요청URL=[${requestUrl}]", "INFO")/>
			<#local r = m1.log(headerMap, "INFO")/>
			<#local r = m1.log(payloadMap, "INFO")/>

			<#--  
				biz센터 템플릿검수 요청
				- method: POST
				- header
					{
						siteid: 계정ID
						auth_key: 인증키
					}
				- payload
					{
						templateCode: 템플릿코드
						templateName: 템플릿명
						templateContent: 본문내용
						templateMessageType: 템플릿메시지 유형(BA: 기본형(default), EX: 부가 정보형, AD: 채널 추가형, MI: 복합형)
						templateEmphasizeType: 템플릿 강조 유형 (NONE: 선택안함(default), TEXT: 강조표기형)
						categoryCode: 카테고리 코드
						...
					}
				- 인자값
					commonFunction_requestHttp4ResultMap(_requestUrl, _methodType, _headerMap, _urlParamMap, _payloadMap, _uploadFileMap)
			-->
			<#local responseData = commonFunction_requestHttp4ResultMap(requestUrl, "POST", headerMap, {}, payloadMap, {})/>
			<#local responseCode = responseData.code/>
			<#if responseCode != "200">
				<#--  검수요청 실패. 실패에 대한 파일큐쓰기 처리  -->
				<#local rs = commonFunction_error2writeFileQ(
					fileQueueObj
					, seqLocal
					, responseCode
					, "템플릿등록처리 중 에이전트 에러. @에러메시지=[${responseData.message!''}]"
					, "DO_REQ"
					, dbxFileQueueName
				)/>

				<#return clear/>

			<#else>
				<#local httpResponseBody = responseData.data!{}/>
			</#if>

			<#--  biz센터에서 응답받은 전문을 파싱  -->
			<#local values = taskDoRequestFunction_parseResponseData(seqLocal, payloadMap, httpResponseBody)/>

			<#local r = m1.log("[REQ][DO][CREATE][SUCC] 템플릿 검수요청 완료. @SEQ=[${seqLocal}]", "INFO")/>
			<#local r = m1.log(values, "DEBUG")/>

			<#local fret = commonFunction_writeFileQueue4one(fileQueueObj, values, "DO_REQ", dbxFileQueueName)/>
			<#if (fret >= 0)>
				<#return clear/>
			<#else>
				<#local r = m1.log("[REQ][DO][CREATE][ERR] 파일큐 쓰기 실패. r=[${fret}]", "FATAL")/>
				<#return systemExit/>
			</#if>

		<#recover>
			<#local r = m1.log("[REQ][DO][CREATE][REQ][FAIL] 템플릿등록처리 중 에러. @SEQ=[${seqLocal}]", "FATAL")/>
			<#local r = m1.log(.error, "ERROR")/>

			<#local errorMsg = .error />
			<#if (errorMsg?length > 200)>
				<#local errorMsg = errorMsg?substring(0,200)/>
			</#if>

			<#-- 실패처리  -->
			<#local rs = commonFunction_error2writeFileQ(
				fileQueueObj
				, seqLocal
				, "501"
				, "[M1]템플릿등록처리 중 에러. @에러메시지=[${errorMsg}]"
				, "DO_REQ"
				, dbxFileQueueName
			)/>

			<#return clear/>
		</#attempt>
		
	</#if>
</#function>

