<#-- 템플릿요청 공통함수 -->
<#include "../TMPL_KKO_EXT/include/request.include_function.ftl"/>
<#--  TASK 사용 함수  -->
<#include "../TMPL_KKO_EXT/include/biz/ftls/task/pollingResultFunction.ftl"/>

<#assign tmplMngrUrl = m1.shareget("tmplMngrUrl")/>
<#assign resultCountFetch = m1.shareget("resultCountFetch")/>

<#assign dbxFileQueueName = m1.shareget("dbxFileQueueName")/>
<#assign fileQueueObj = m1.shareget("fileQueueObj")/>

<#assign sqlConn = m1.new("sql")/>

<#--  프로세스 중지여부  -->
<#assign isStop = m1.shareget("isStop")!false/>

<#--  초기 설정 실패시 프로세스 중지를 위해서 TASK 중지 처리.  -->
<#if !isStop>
	<#assign stackValue = doTask()/>
<#else>
    <#assign stackValue = -9/>
</#if>

<#assign r = m1.stack("return", stackValue)/>

<#assign r = sqlConn.close()/>

<#function doTask>
	<#--return 0:통과, -9:시스템 종료-->
	<#local clear = 0/>
	<#local retry = -1/>
	<#local systemExit = -9/>

	<#attempt>
		<#--조회-->
		<#local selectPollResultQuery = m1.session("selectPollResultQuery")/>

		<#local requestList = sqlConn.query2arrayp(selectPollResultQuery, {
			"countFetch": resultCountFetch
			, "staus": "3"
			, "approvalCode": "200"
			, "approvalReason": "승인대기"
			, "searchInterval": 7
		})/>

		<#if requestList?size == 0>
			<#--조회된 데이터 없음-->
			<#local r= m1.log("[RPT][POLL] 데이터 없음.", "INFO")/>

			<#return clear/>
		<#else>
			<#local r= m1.log("[RPT][POLL] 결과요청 데이터 검출. @조회건수=[${requestList?size}]", "INFO")/>
		</#if>

		<#--검수 결과 조회-->
		<#list requestList as request>
			<#local seqLocal = request.TM_SEQ?c/>

			<#local r= m1.log("[RPT][POLL][${request_index}] biz센터 결과요청. @SEQ=[${seqLocal}]", "INFO")/>
			<#local r= m1.log(request, "DEBUG")/>

			<#--  검수요청값에 대한 RBC요청 함수  -->
			<#local apiResult = taskPollResultFunction_requestPollingResult4BizCenter(seqLocal, request)/>
			<#if !apiResult?has_content>
				<#local r = m1.log("[RPT][POLL][ERR] RBC센터 검수요청 중 에러 발생. @SEQ=[${seqLocal}]", "ERROR")/>

				<#return clear/>
			</#if>

			<#--  검수결과 조회 api 응답전문에 대한 결과처리 함수  -->
			<#local r = taskPollResultFunction_templateStatus2Db(seqLocal, apiResult)/>

		</#list>

	<#recover>
		<#local r = m1.log("[RPT][POLL][ERR] 검수결과 처리중 에러발생.", "ERROR")/>

	</#attempt>

	<#return clear/>
</#function>
