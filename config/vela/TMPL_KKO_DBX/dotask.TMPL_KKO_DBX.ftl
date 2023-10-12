<#-- 템플릿요청 공통함수 -->
<#include "../TMPL_KKO_EXT/include/request.include_function.ftl"/>
<#--  TASK 사용 함수  -->
<#include "../TMPL_KKO_EXT/include/biz/ftls/task/dbxFunction.ftl"/>

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>

<#assign sqlConn = m1.new("sql")/>

<#assign updateTemplateStatusQuery = m1.session("updateTemplateStatusQuery")/>

<#--  프로세스 중지여부  -->
<#assign isStop = m1.shareget("isStop")!false/>

<#if !isStop>
	<#assign stackValue = doTask()/>
<#else>
    <#assign stackValue = -9/>
</#if>

<#assign r = m1.stack("return", stackValue)/>

<#assign r = sqlConn.close()/>

<#function doTask>
	<#--return 1:처리, -1:재시도, -9:시스템 종료-->
	<#local clear = 1/>
	<#local retry = -1/>
	<#local systemExit = -9/>

	<#local r = m1.log("[DBX][RCV] DB처리 데이터 유입.", "INFO")/>
	<#local r = m1.log(received, "DEBUG")/>

	<#--전문 파싱-->
	<#local rcvHeader = m1.parseNext(received, "FWXHEADER")/>

	<#if !rcvHeader["하위전문길이"]??>
		<#local r = m1.log("[DBX][ERR] 전문 오류 @유입전문=[${received?string}]", "ERROR")/>

		<#return clear/>
	</#if>

	<#local rcvBodyStr = m1.subbytes(received, m1.sizeof(["FWXHEADER"]), rcvHeader["하위전문길이"])?string/>

	<#attempt>
		<#local rcvBody = m1.parseJsonValue(rcvBodyStr)!{}/>
	<#recover>
		<#local rcvBody = {}/>
	</#attempt>

	<#if rcvBody?size == 0>
		<#local r = m1.log("[DBX][ERR] 전문 오류(body) @유입전문=[${received?string}]", "ERROR")/>

		<#return clear/>
	</#if>

	<#local seqLocal = rcvHeader.발송서버접수식별자/>

	<#--API 상태 확인-->
	<#local apiResult = rcvBody.apiResult!{}/>

	<#local sender = rcvHeader["보낸프로그램참고"]!""/>
	<#if sender == "DO_REQ">
		<#-- 검수요청 처리 -->
		
		<#if apiResult?has_content>
			<#local r = m1.log("[DBX][REQ] 검수요청 처리 시작. @SEQ=[${seqLocal}]", "INFO")/>
			<#local r = m1.log(rcvHeader, "DEBUG")/>
			<#local r = m1.log(rcvBody, "DEBUG")/>

			<#--  검수요청 응답전문에 대한 DB처리 전문 파싱 함수  -->
			<#--  검수요청 성공 / 실패에 따라서 각각의 전문을 파싱함  -->
			<#local executeParamMap = taskDbxFunction_parseRequest2ExecuteParamMap(seqLocal, apiResult)/>

		<#else>
			<#local r = m1.log("[DBX][ACK] 검수요청 응답데이터가 잘못되었습니다. @응답데이터=[${rcvBodyStr}]", "ERROR")/>

			<#return clear/>
		</#if>

	<#elseif sender == "PL_RPT">
		<#-- 검수 완료 처리 -->

		<#if apiResult?has_content >
			<#local r = m1.log("[DBX][RPT] 검수완료 결과처리 시작. @SEQ=[${seqLocal}]", "INFO")/>
			<#local r = m1.log(rcvHeader, "DEBUG")/>
			<#local r = m1.log(rcvBody, "DEBUG")/>

			<#--  검수완료 응답전문에 대한 DB처리 전문 파싱 함수  -->
			<#local executeParamMap = taskDbxFunction_parseResponse2ExecuteParamMap(seqLocal, apiResult)/>

		<#else>
			<#local r = m1.log("[DBX][RPT] 검수완료 응답데이터가 잘못되었습니다. @응답데이터=[${rcvBodyStr}]", "ERROR")/>

			<#return retry/>
		</#if>

	<#else>
		<#--허용되지 않은 보낸 프로그램, 클리어-->
		<#local r = m1.log("[DBX][ERR] 허용되지 않은 보낸 템플릿 처리타입. @보낸프로그램참조=[${sender}]", "ERROR")/>

		<#return clear/>
	</#if>

	<#local r = m1.log("[DBX][DB][RESULT] DB처리 시작. @SEQ=[${seqLocal}]", "INFO")/>
	<#local r = m1.log(executeParamMap, "DEBUG")/>

	<#-- DB처리 -->
	<#local isSucc = true/>

	<#attempt>
		
		<#-- 검수요청 / 결과조회 결과 DB처리 -->
		<#local executeQueryList = updateTemplateStatusQuery?split("#DELIM")/>
		<#list executeQueryList as executeQuery>
			<#local queryResult = sqlConn.execute(executeQuery, executeParamMap)/>
			<#if (queryResult < 0)>
				<#local isSucc = false/>

				<#break/>
			</#if>

		</#list>

	<#recover>
		<#--쿼리 exception, 재시도-->
		<#local r = m1.log("[DBX][DB][ERR] DB쿼리 실행 중 에러발생 재시도... @에러내역=[${.error}]", "ERROR")/>

		<#return retry/>
	</#attempt>

	<#if isSucc>
		<#attempt>
			<#-- 커밋 -->
			<#local commiResult = sqlConn.commit()/>
		<#recover>
			<#attempt>
				<#local r = sqlConn.rollback()/>
			<#recover>
				<#local r = m1.log("[DBX][DB][ERR] 커밋 처리 중 에러발생. @에러내역=[${.error}]", "ERROR")/>
			</#attempt>

			<#return retry/>
		</#attempt>

		<#if commiResult != 0>
			<#local r = m1.log("[DBX][DB][ERR] DB commit 실패. @SEQ=[${seqLocal}]", "ERROR")/>
			<#return retry/>
		</#if>

		<#local r = m1.log("[DBX][SUCC] DB 처리 완료. @SEQ=[${seqLocal}] @검수결과코드=[${executeParamMap.검수결과코드!''}] @검수결과내용=[${executeParamMap.처리결과내용!''}]", "INFO")/>
	<#else>
		<#-- update 결과 없음 -->
		<#local r = m1.log("[DBX][DB][ERR] 이력 update 실패. @SEQ=[${seqLocal}] @검수결과코드=[${executeParamMap.검수결과코드!''}] @검수결과내용=[${executeParamMap.처리결과내용!''}]", "ERROR")/>

		<#local r = sqlConn.rollback()/>

		<#return clear/>
	</#if>

	<#return clear/>
</#function>
