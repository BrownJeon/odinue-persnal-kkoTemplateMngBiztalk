<#-- 공통 변수 include -->
<#include "config.include_variable.ftl"/>

<#--
함수목록
	- commonFunction_getClientInfo: DB에서 조회한 발신프로필키정보를 통해서 인증에 필요한 정보 세팅
	- commonFunction_writeFileQueue4one : 파일큐에 1건 적재하는 함수
	- commonFunction_writeFileQueue4N : 파일큐에 다건 적재하는 함수
	- commonFunction_error2writeFileQ : 에러큐에 전문을 쓰는 함수
		- innerFunction_flattenFileQueueData : 파일큐에 적재할 전문 생성하는 함수
	- commonFunction_requestGet4ResultList : biz센터 GET요청 후 결과전문 목록 파싱 함수
		- innerFunction_requestGetResponseMap : biz센터 GET요청 함수
	- commonFunction_requestGet4ResultMap : biz센터 GET요청 후 결과전문 단건 파싱 함수
	- commonFunction_getRequestHeaderMap : HTTP요청을 위한 전문헤더 생성하는 함수
	- commonFunction_getCreateTemplateUrl : 버전정보별로 템플릿등록 API url 체크
	- commonFunction_requestTokenInfo : 토큰 요청 함수
	- commonFunction_parseCreateTemplatePayloadMap : 템플릿등록 전문바디 파싱
		- innerFunction_getParseImagePayloadMap : 이미지템플릿 요청전문 파싱 (only v2 API로 요청)
			- innerFunction_uploadImage : 이미지업로드 요청
		- innerFunction_createTemplateId : custTmpltId 생성 함수(영문/숫자 25자 이내)
	- commonFunction_kko2dbSync: biz센터 동기화처리 함수
		- innerFunction_formIdInfoDetail2DB: 베이스폼ID 상세내역을 조회하여 조회결과 DB처리
		- innerFunction_commonTemplateInfoDetail2DB : 공통템플릿 상세내역을 조회하여 조회결과 DB처리
		- innerFunction_kkoTemplateInfoDetail2DB : 승인/승인대기 템플릿 상세내역을 조회하여 조회결과 DB처리
		- innerFunction_rcsBrandIdSimple2DB : 브랜드ID 조회된 값에 대한 정보를 DB처리
		- innerFunction_chatbotIdDetail2DB : 챗봇ID 조회된 값에 대한 정보를 DB처리
-->
<#--  범용성을 위해서 SQL쿼리에 DBMS 전용 쿼리는 사용하지 않도록 한다.  -->

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>


<#--  발신프로필키정보 세팅  -->
<#function commonFunction_getClientInfo _profileKeyInfo _authInfo>
    <#local profileKey = _profileKeyInfo["PROFILE_KEY"]!""/>

    <#return {  
		"clientId": _authInfo.clientId!""
		, "clientSecret": _authInfo.clientSecret!""
    }/>

</#function>

<#-- 파일큐에 1건 적재하는 함수 -->
<#function commonFunction_writeFileQueue4one _fq _bodyMap _procName _targetFileQueueName>
    <#--return(1: 처리, -1: 재시도, -9:시스템 종료)-->
    <#local clear = 1/>
    <#local retry = -1/>
    <#local systemExit = -9/>

    <#if !_bodyMap?has_content>
	    <#local r = m1.log("[FQ][WRITE][ERROR] 처리전문 없음. ", "ERROR")/>
	    <#local r = m1.log(_bodyMap, "ERROR")/>

        <#return systemExit/>
    </#if>

    <#local rsByteSequence = innerFunction_flattenFileQueueData(_bodyMap, _procName, _targetFileQueueName)/>

	<#local fret = _fq.write1(_targetFileQueueName, 0, rsByteSequence)/>
    <#if (fret == 0)>
        <#local r = m1.log("[FQ][WRITE][SUCC] 파일큐 쓰기 완료. @발송서버접수식별자=[${_bodyMap.TM_SEQ}]", "INFO")/>
    	<#local r = m1.log(header, "DEBUG")/>
        <#local r = m1.log(bytes, "DEBUG")/>

        <#return clear/>

    <#else>
        <#local r = m1.log("[FQ][WRITE][ERR] 파일큐 쓰기 실패. 프로세스종료... r=[${fret}]","FATAL")/>

        <#return systemExit/>
    </#if>
</#function>

<#--  파일큐에 다건 적재하는 함수  -->
<#function commonFunction_writeFileQueue4N _fq _bodyMap _procName _targetFileQueueName>
    <#--return(1: 처리, -9:시스템 종료)-->
    <#local clear = 1/>
    <#local systemExit = -9/>

    <#if !_bodyMap?has_content>
	    <#local r = m1.log("[FQ][WRITE][ERROR] 처리전문 없음. ", "ERROR")/>
	    <#local r = m1.log(_bodyMap, "ERROR")/>

        <#return systemExit/>
    </#if>

    <#local rsByteSequence = innerFunction_flattenFileQueueData(_bodyMap, _procName, _targetFileQueueName)/>

	<#local fret = _fq.writeN(_targetFileQueueName, 0, [rsByteSequence])/>
    <#if (fret == 0)>
        <#local r = m1.log("[FQ][WRITE][SUCC] 파일큐 쓰기 완료. @발송서버접수식별자=[${_bodyMap.TM_SEQ}]", "INFO")/>
    	<#local r = m1.log(header, "DEBUG")/>
        <#local r = m1.log(rsByteSequence, "DEBUG")/>

        <#local r = _fq.readCommit()/>

        <#return clear/>

    <#else>
        <#local r = m1.log("[FQ][WRITE][ERR] 파일큐 쓰기 실패. 프로세스종료... r=[${fret}]","FATAL")/>

        <#local r = _fq.readRollback()/>

        <#return systemExit/>
    </#if>
</#function>


<#-- 에러큐에 전문을 쓰는 함수 -->
<#function commonFunction_error2writeFileQ _fq _seqLocal _errorCode _errorMsg _procName _targetFileQueueName>
    <#--return(1: 처리, -1: 재시도, -9:시스템 종료)-->
	<#local clear = 1/>
	<#local retry = -1/>
	<#local systemExit = -9/>

    <#-- 실패처리  -->
    <#local fail_bodyMap = {
        "TM_SEQ": _seqLocal
        , "apiResult": {
            "error": {
                "code": _errorCode,
                "message": _errorMsg
            }
        }
    }/>

    <#local rsByteSequence = innerFunction_flattenFileQueueData(fail_bodyMap, _procName, _targetFileQueueName)/>

    <#local fret = _fq.write1(_targetFileQueueName, 0, rsByteSequence)/>
    <#if fret == 0>
        <#local r = m1.log("[FQ][WRITE][SUCC] 파일큐 쓰기 완료. @발송서버접수식별자=[${_seqLocal}]", "INFO")/>
    	<#local r = m1.log(header, "DEBUG")/>
        <#local r = m1.log(bytes, "DEBUG")/>

        <#return clear/>

    <#else>
        <#local r = m1.log("[FQ][WRITE][ERR] 파일큐 쓰기 실패. 프로세스종료... r=[${fret}]","FATAL")/>

        <#return systemExit/>
    </#if>
</#function>

<#-- 파일큐에 적재할 전문 생성하는 함수 -->
<#function innerFunction_flattenFileQueueData _dataMap _procName _targetFileQueueName>
	<#local bytes=m1.toJsonBytes(_dataMap)/>

	<#local r = m1.log("[FQ][FLAT][START] 파일큐 쓰기전문 처리 시작.", "INFO")/>

	<#local _seqLocal = _dataMap.TM_SEQ/>

	<#local header = {
		"발송서버접수식별자": _seqLocal,
		"내부전문구분":"",
		"전문버전":"20",
		"보낸프로그램참고":_procName,
		"거래구분":"",
		"생성일시":ymdhms,
		"오류코드":"00",
		"할당발송계약식별자":_targetFileQueueName,
		"여분":"",
		"하위전문길이":bytes?size
	} />

	<#local resultBs=m1.new("bytes",100+bytes?size)/>

	<#local r=m1.flatten(header,"FWXHEADER",resultBs)/>
	<#local r=m1.arraycopy(bytes, 0, resultBs, 100, bytes?size)/>

	<#local r = m1.log("[FQ][FLAT][SUCC] 파일큐 쓰기전문 처리완료. @발송서버접수식별자=[${_seqLocal}]", "INFO")/>
	<#local r = m1.log(header, "DEBUG")/>
	<#local r = m1.log(_dataMap, "DEBUG")/>

	<#return resultBs/>
</#function>


<#-- biz센터 GET요청 함수 -->
<#function innerFunction_requestGetResponseMap _token _requestUrl>
	<#if !_requestUrl?has_content>
		<#local r = m1.log("[BIZ][REQ][ERR] 요청URL 없음. @요청URL=[${_requestUrl}] @method=[GET]", "ERROR")/>

		<#return []/>
	</#if>

	<#local r = m1.log("[BIZ][REQ][START] biz센터 요청처리 시작. @method=[GET]", "INFO")/>
	<#local r = m1.log("@요청URL=[${_requestUrl}]", "DEBUG")/>

	<#-- 요청 headerMap 정의 -->
	<#assign headerMap = commonFunction_getRequestHeaderMap({})/>

	<#-- 템플릿목록 조회 API -->
	<#local httpResponseCode=httpObj.get(_requestUrl, headerMap)!-1/>
    <#if httpResponseCode != 200>
		<#local r = m1.log("[BIZ][REQ][FAIL] biz센터 요청 실패. @응답코드=[${httpResponseCode}]", "ERROR")/>

		<#return {}/>
	</#if>

    <#local httpResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>

    <#local responseBody = m1.parseJsonValue(httpResponseBody)/>

	<#if httpResponseCode == 200>
		<#local r = m1.log("[BIZ][REQ][SUCC] biz센터 HTTP요청 성공. @응답코드=[${httpResponseCode}]", "DEBUG")/>
	<#else>
		<#local r = m1.log("[BIZ][REQ][ERR] biz센터 HTTP요청 실패. @응답코드=[${httpResponseCode}]", "ERROR")/>
	</#if>

    <#return responseBody/>
</#function>

<#-- biz센터 GET요청 후 결과전문 단건 파싱 함수 -->
<#function commonFunction_requestGet4ResultMap _token _requestUrl>

    <#-- biz센터 GET request요청 함수 -->
    <#local responseBody = innerFunction_requestGetResponseMap(_token, _requestUrl)/>

    <#local responseCode = responseBody.code!""/>
	<#if responseCode == "API_200">
        <#local requestStatus = "성공"/>

		<#local apiResult = responseBody.data![]/>
        <#if apiResult?has_content>
            <#local resultMap = apiResult[0]/>

        <#else>
            <#local resultMap = {}/>
        </#if>

	<#else>
        <#local requestStatus = "실패"/>
		<#local r = m1.log(responseBody, "ERROR")/>

        <#local resultMap = {}/>
	</#if>

	<#local r = m1.log("[BIZ][REQ][END] biz센터 요청처리 완료. @처리결과=[${requestStatus}]", "INFO")/>
	<#local r = m1.log("@요청URL=[${_requestUrl}]", "DEBUG")/>
    <#local r = m1.log(responseBody, "DEBUG")/>

	<#return resultMap/>
</#function>

<#-- biz센터 GET요청 후 결과전문 목록 파싱 함수 -->
<#--  BIZ요청시 pagination처리에 대한 로직 -->
<#function commonFunction_requestGet4ResultList _token _requestUrl>

	<#local resultList = m1.editable([])/>

    <#-- biz센터 GET request요청 함수 -->
	<#local r = m1.log("[BIZ][REQ][0] biz센터 요청처리... @요청URL=[${_requestUrl}]", "INFO")/>
	
    <#local responseBody = innerFunction_requestGetResponseMap(_token, _requestUrl)/>

    <#local responseCode = responseBody.code!""/>
	<#if responseCode == "API_200">
        <#local requestStatus = "성공"/>

		<#local apiResult = responseBody.data![]/>
        <#if apiResult?has_content>
			<#list apiResult as resultMap>
            	<#local r = resultList.put(resultMap)/>
			</#list>

        </#if>

		<#-- pagination관련 정보 -->
		<#local responsePage = responseBody.page!-1/>
		<#local responseTotalPage = responseBody.totalPage!-1/>

		<#local hasNext = responseBody.hasNext!false/>

		<#--  추가 요청할지에 대한 여부 체크  -->
		<#if hasNext && (responsePage < responseTotalPage)>
			<#local requestLoopCnt = responseTotalPage - responsePage/>
			<#list 1..requestLoopCnt as cnt>

				<#local currentPage = responsePage/>

				<#--
					템플릿조회시 페이징 조건값
						startDate : 검색 시작날짜
						endDate : 검색 종료날짜
						~~ inspectionStatus : 검수 상태 (REG:등록, REQ:심사요청, APR:승인, REJ: 반려) ~~
						kepStatus : 검수 상태(N:Not Yet 아직진행하지않음, I:검수 진행중, O:OK 통과, R:Reject 반려)
						rows : 페이지당 row수
						limit : 검색 제한 수
						page : page번호
				-->

				<#--  next로 넘어온 값이 http:// 이기에 요청시 301에러 발생. https:// 로 변경하여 요청하는 것으로 URL변경  -->
				<#local nextRequestUrl = _requestUrl + "?rows=100&page=${currentPage}"/>

				<#local r = m1.log("[BIZ][REQ][${cnt}] 다음 데이터 요청처리... @다음요청URL=[${nextRequestUrl}]", "INFO")/>
				<#local nextResponseBody = innerFunction_requestGetResponseMap(_token, nextRequestUrl)/>
				<#local responseCode = nextResponseBody.code!""/>
				<#if responseCode == "API_200">
					<#local requestStatus = "성공"/>

					<#local apiResult = nextResponseBody.data![]/>
					<#if 
						apiResult?has_content 
						&& (apiResult.kepStatus == "O" || apiResult.kepStatus == "I")
						&& (apiResult.templateStatus == "A" || apiResult.templateStatus == "R")
					>
						<#--  biz센터의 템플릿 중에 검수완료(O), 검수중(I) 상태의 템플릿만 목록에 추가  -->
						<#list apiResult as resultMap>
							<#local r = resultList.put(resultMap)/>
						</#list>

					</#if>

					<#local nextResponsePage = nextResponseBody.page!-1/>

					<#local hasNext = nextResponseBody.hasNext!false/>
					<#if !hasNext>
						<#break/>
					</#if>

				<#else>
					<#local requestStatus = "실패"/>
				</#if>

				<#local r = m1.log("[BIZ][REQ][END] 다음 데이터 요청처리 완료. @처리결과=[${requestStatus}] @요청URL=[${nextRequestUrl}]", "INFO")/>
			</#list>

		</#if>

	<#else>
        <#local requestStatus = "실패"/>
		<#local r = m1.log(responseBody, "ERROR")/>

	</#if>

	<#local r = m1.log("[BIZ][REQ][END] biz센터 요청처리 완료. @처리결과=[${requestStatus}] @요청URL=[${_requestUrl}]", "INFO")/>
    <#local r = m1.log(resultList, "DEBUG")/>

	<#return resultList/>
</#function>


<#-- HTTP요청을 위한 전문헤더 생성 함수 -->
<#function commonFunction_getRequestHeaderMap _senderKey _extraParamMap>

	<#local r = m1.log("[REQ][DO] 요청전문 헤더정보 파싱시작. @발신프로필키=[${_senderKey}]", "DEBUG")/>

	<#local headerMap = m1.new("hash")/>

	<#local channelList = m1.shareget("channelList")/>
	<#local channelInfo = channelList[_senderKey]!{}/>
	<#if !channelInfo?has_content>
		<#local r = m1.log("[ERR] 발신프로필키에 매핑되는 인증정보 없음. @계정정보=", "ERROR")/>
		<#local r = m1.log(channelList, "ERROR")/>
	</#if>

	<#local siteId = channelInfo.clientId!""/>
	<#local authKey = channelInfo.clientSecret!""/>
    
	<#-- 기본 헤더정보 정의  -->
	<#local r = m1.put(headerMap, "Content-Type", "application/json; charset=utf-8")/>
	<#local r = m1.put(headerMap, "Accept", "application/json, text/plain, */*")/>
	<#local r = m1.put(headerMap, "siteid", siteId)/>
	<#local r = m1.put(headerMap, "auth_key", authKey)/>

    <#-- 추가되는 정보 추가 정의 -->
    <#list _extraParamMap as extField, extValue>
        <#if extField?has_content && extValue?has_content>
			<#local r = m1.put(headerMap, extField, extValue)/>
        <#else>
            <#local r = m1.log("[ERR] 추가정보 값 없음. @extField=[${extField}] @extValue=[${extValue}]", "ERROR")/>
        </#if>
    </#list>

	<#local r = m1.log("[REQ][DO] 요청전문 헤더정보 파싱완료. @발신프로필키=[${_senderKey}]", "INFO")/>
	<#local r = m1.log(headerMap, "INFO")/>


    <#return headerMap/>
</#function>

<#-- 토큰 요청 함수 -->
<#-- 메모리에 토큰이 존재하며 만료시간도 정상일 경우 해당 토큰을 그대로 사용 -->
<#-- 메모리에 토큰정도가 없거나 만료되었을 경우 다시 토큰을 발급받아서 메모리에 저장 -->
<#-- 
	TODO. 비즈톡이 경우 인증없이 사용 
	해당 로직은 카카오뱅크의 토큰발급 로직
-->
<#function commonFunction_requestTokenInfo _channelInfo>
	<#if !_channelInfo?has_content>
		<#local r = m1.log("채널정보 없음...", "ERROR")/>
		<#return {
			"code": 500
		}/>
	</#if>

    <#local header = {
        "Content-Type" : "application/json; charset=utf-8",
        "Accept" : "application/json, text/plain, */*",
		"Authorization": "Basic ${_channelInfo.clientId} ${_channelInfo.clientSecret}"
    }/>

    <#local payloadMap = {}/>

	<#local payload = m1.toJsonBytes(payloadMap)?string/>
	<#local bcbytes = m1.getBytes(payload, "UTF-8")/>
	
	<#local httpResponseCode = httpObj.post("${tmplMngrUrl}/oauth/token", bcbytes, 0, bcbytes?size, header)!-1/>
	<#if httpResponseCode != 200>
		<#local r = m1.log("[BIZ][REQ][FAIL] 토큰발급 요청 실패. @응답코드=[${httpResponseCode}]", "ERROR")/>
		<#local r = m1.log(httpObj.responseData, "ERROR")/>

		<#return clear/>
	</#if>

	<#local httpResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>

	<#local body=m1.parseJsonValue(httpResponseBody)/>

	<#if httpResponseCode?starts_with("API_")>
		<#local responseCode = httpResponseCode?substring(3)/>
	</#if>

    <#return {
        "code": responseCode
        , "accessToken": body.access_token!""
        , "expiresIn": body.expires_in!0
    }/>

</#function>


<#-- 
	템플릿 전문바디 파싱 함수
		- 필수전문 데이터 파싱 후 부가옵션 파싱 및 이미지업로드처리 데이터 파싱
		- 버튼전문의 경우 BUTTON_INFO컬럼의 값을 체크하여 파싱.
		
		
-->
<#function commonFunction_parseCreateTemplatePayloadMap _requestMap>
	<#if !_requestMap??>
		<#local r = m1.log("[REQ][DO][ERR] 데이터 파싱 중 에러발생. 유입데이터 없음.", "ERROR")/>
		<#return {}/>
	</#if>

	<#local _seqLocal = _requestMap.TM_SEQ!""/>
	<#local templateCode = _requestMap.TEMPLATE_ID!""/>

	<#local r = m1.log("[REQ][DO] 요청전문 파싱시작. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "DEBUG")/>
	<#local r = m1.log(_requestMap, "DEBUG")/>

	<#local resultMap = m1.new("hash")/>

	<#-- 전문바디 파싱 -->
	<#attempt>
		<#local formParam = m1.parseJsonValue(_requestMap.FORM_PARAM)!{}/>
	<#recover>
		<#local r = m1.log("[REQ][DO][ERR] 필수정보 전문내용 데이터 파싱중 에러발생. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "ERROR")/>
		<#local r = m1.log(formParam, "ERROR")/>

		<#return {}/>
	</#attempt>

	<#--  필수전문 데이터 파싱  -->
	<#local r = m1.put(resultMap, "senderKey", _requestMap.CHANNEL_ID!"")/>
	<#local r = m1.put(resultMap, "templateCode", templateCode)/>
	<#local r = m1.put(resultMap, "templateName", _requestMap.TEMPLATE_NAME!"")/>
	<#local r = m1.put(resultMap, "templateMessageType",_requestMap.MESSAGE_TYPE!"BA")/>
	<#local r = m1.put(resultMap, "senderKeyType", "S")/>
	<#local r = m1.put(resultMap, "categoryCode", _requestMap.CATEGORY_CODE!"")/>

	<#local templateContent = formParam.templateContent!""/>
	<#if !templateContent?has_content>
		<#local r = m1.log("[REQ][DO][ERR] 필수값 [템플릿내용] 없음. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "ERROR")/>
		<#local r = m1.log(formParam, "ERROR")/>

		<#return {}/>
	</#if>
	<#local templateEmphasizeType = formParam.templateEmphasizeType!""/>
	<#if !templateEmphasizeType?has_content>
		<#local r = m1.log("[REQ][DO][ERR] 필수값 [강조유형] 없음. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "ERROR")/>
		<#local r = m1.log(formParam, "ERROR")/>
		
		<#return {}/>
	<#else>
		<#local templateImageUrl = formParam.templateImageUrl!""/>
		
		<#if (templateEmphasizeType == "IMAGE" || templateEmphasizeType == "ITEM_LIST") && !templateImageUrl?has_content>
			<#--  템플릿 강조유형이 IMAGE / ITEM_LIST일 경우 이미지업로드처리  -->
			<#--  TODO. 비즈톡측에 이미지업로드 기능이 미구현으로 인한 확인필요  -->
			<#local imageParamMap = innerFunction_getParseImagePayloadMap(templateImageUrl)/>

		<#elseif templateEmphasizeType == "TEXT">
			<#local templateTitle = formParam.templateTitle!""/>
			<#if !templateTitle?has_content>
				<#local r = m1.log("[REQ][DO][ERR] 강조유형이 'TEXT'일경우 templateTitle값 필수. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "ERROR")/>
				<#local r = m1.log(formParam, "ERROR")/>

				<#return {}/>
			</#if>
			<#local templateSubtitle = formParam.templateSubtitle!""/>
			<#if !templateSubtitle?has_content>
				<#local r = m1.log("[REQ][DO][ERR] 강조유형이 'TEXT'일경우 templateSubtitle값 필수. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "ERROR")/>
				<#local r = m1.log(formParam, "ERROR")/>

				<#return {}/>
			</#if>
		<#else>

		</#if>

	</#if>

	<#list formParam as key, value>
		<#local r = m1.put(resultMap, key, value)/>
	</#list>

	<#--  버튼정보 파싱  -->
	<#attempt>
		<#local buttonInfo = m1.parseJsonValue(_requestMap.BUTTON_INFO)!{}/>
	<#recover>
		<#local r = m1.log("[REQ][DO][ERR] 버튼정보 전문내용 데이터 파싱중 에러발생. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "ERROR")/>
		<#local r = m1.log(buttonInfo, "ERROR")/>

		<#return {}/>
	</#attempt>
	<#local r = m1.put(resultMap, "buttons", buttonInfo)/>

	<#--  부가옵션정보 파싱  -->
	<#attempt>
		<#local optionInfo = m1.parseJsonValue(_requestMap.OPTION_INFO)!{}/>
	<#recover>
		<#local r = m1.log("[REQ][DO][ERR] 옵션내용 전문내용 데이터 파싱중 에러발생. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}] @전문내용=", "ERROR")/>
		<#local r = m1.log(optionInfo, "ERROR")/>

		<#return {}/>
	</#attempt>
	<#list optionInfo as key, value>
		<#local r = m1.put(resultMap, key, value)/>
	</#list>

	<#local r = m1.log("[REQ][DO] 데이터 파싱처리 완료. @SEQ=[${_seqLocal}] @템플릿ID=[${templateCode}]", "INFO")/>
	<#local r = m1.log(resultMap, "INFO")/>

	<#return resultMap/>

</#function>


<#--
	이미지업로드 및 전문 파싱 함수
-->
<#function innerFunction_getParseImagePayloadMap _messagebaseformId _requestMap>

    <#return 1/>
</#function>


<#-- biz센터 이미지파일 업로드 요청 함수 -->
<#function innerFunction_uploadImage _requestMap>
	

    <#return 1/>

</#function>


<#--
	1. biz센터에 동기화처리 정보 목록조회
	2. 목록을 loop돌면서 각 정보에 대한 BIZ 상세정보 조회
	3. 상세내역조회 값에 대해 데이터 파싱
	4. 상세내역조회 결과에 따른 DB처리 (insert / update)

-->
<#--
	BIZ 동기화처리 객체 spec
	{
		"token": 토큰정보 (인증이 없을 경우 해당 필드 없음)
		, "sqlConn": SQL객체
		, "query": {
			"selectQuery": 조회쿼리
			, "updateQuery": update쿼리
			, "insertQuery": 적재쿼리
		}
		, "requestUrl": 요청 베이스URL (ex: "${tmplMngrUrl}/brand/${brandId}/messagebase")
	}
-->
<#function commonFunction_kko2dbSync _syncType _syncParamMap>
	<#if !_syncParamMap?has_content>
		<#local r = m1.log("[BIZ][SYNC][ERR] biz센터 동기화처리 파라미터 데이터 없음.", "ERROR")/>

		<#return {}/>
	<#elseif 
		!_syncParamMap.sqlConn?has_content
		|| !_syncParamMap.query?has_content
		|| !_syncParamMap.requestUrl?has_content
	>
		<#local r = m1.log("[BIZ][SYNC][ERR] biz센터 동기화처리 파라미터 데이터 없음. @요청타입=[${_syncType}]", "ERROR")/>
    	<#local r = m1.log(_syncParamMap, "DEBUG")/>

		<#return {}/>
	</#if>

	<#local requestBaseUrl = _syncParamMap.requestUrl!""/>
	<#local sqlConn = _syncParamMap.sqlConn!""/>
	<#local queryMap = _syncParamMap.query!{}/>

	<#local procMap = m1.editable({
		"insertCnt": 0
		, "updateCnt": 0
		, "passCnt": 0
		, "failCnt": 0
	})/>

	<#--  API-KEY 정보를 가져다가 브랜드ID목록 세팅  -->
	<#assign profileKeyInfoMap = m1.shareget("profileKeyInfoMap")![]/>
	<#if !profileKeyInfoMap?has_content>
		<#assign r = m1.log("[CONF][BRAND_ID][ERR] API-KEY정보 없음.... 처리 종료.", "ERROR")/>

		<#return {
			"code": "301"
			, "message": "API-KEY정보 없음"
		}/>

	<#else>
		<#list profileKeyInfoMap as profileKey, clientInfo>
			<#assign clientId = clientInfo.clientId!""/>
			<#assign clientSecret = clientInfo.clientSecret!""/>

			<#if clientId?has_content && clientSecret?has_content>
				<#assign token = _syncParamMap.token!""/>
				
				<#-- biz센터에 동기화처리 정보 목록조회 -->
				<#local r = m1.log("[BIZ][SYNC][REQ] biz센터 동기화정보 목록 조회.", "DEBUG")/>

				<#local BizSearchApiResultList = commonFunction_requestGet4ResultList(token, requestBaseUrl)/>
				<#local r = m1.log(BizSearchApiResultList, "DEBUG")/>

				<#if BizSearchApiResultList?has_content>
					<#list BizSearchApiResultList as BizSearchApiResult>
						<#-- BIZ에서 조회된 베이스폼ID 목록을 돌며 상세내역 api조회하여 DB에 동기화처리 -->
						<#switch _syncType?upper_case>
							<#case "PROFILE_KEY">
								<#--  발신프로필키 동기화 DB처리  -->
								<#local procMap = innerFunction_formIdInfoDetail2DB(sqlConn, token, queryMap, BizSearchApiResult, requestBaseUrl, procMap)/>
								<#break>
							<#case "KKO_TMPL">
								<#--  승인템플릿 동기화 DB처리  -->
								<#local procMap = innerFunction_kkoTemplateInfoDetail2DB(sqlConn, token, queryMap, BizSearchApiResult, requestBaseUrl, procMap)/>
								<#break>
							<#default>
								<#local r = m1.log("정의되지 않은 DB처리 타입. @타입=[${_syncType}]", "ERROR")/>
						</#switch>
						
					</#list>
				
					<#local r = m1.log("[BIZ][SYNC][END] biz센터 동기화처리 완료. @적재건수=[${procMap.insertCnt}] @갱신건수=[${procMap.updateCnt}] @무시건수=[${procMap.passCnt}] @실패건수=[${procMap.failCnt}] @총건수=[${procMap.insertCnt + procMap.updateCnt + procMap.passCnt + procMap.failCnt}]", "INFO")/>

					<#return {
						"code": "200"
						, "message": "성공"
					}/>

				<#else>
					<#local r = m1.log("[BIZ][SYNC][END] biz센터 동기화처리 정보 없음으로 인한 처리 무시.", "INFO")/>

					<#return {
						"code": "401"
						, "message": "biz센터 조회데이터 없음"
					}/>

				</#if>

			<#else>
				<#assign r = m1.log("[CONF][DB][ERR] API-KEY정보 없음.", "ERROR")/>
			</#if>

		</#list>
	</#if>

</#function>

<#-- 브랜드ID 조회된 값에 대한 기본정보를 DB처리: 상세내역을 DB처리하는 것은 우선 보류 -->
<#function innerFunction_rcsBrandIdSimple2DB _sqlConn, _token, _queryMap, _apiResultMap, _requestUrl, _procMap>
	<#if !_apiResultMap?has_content>
		<#local r = m1.log("[BRAND_ID][SYNC][ERR] api전문 내용 없음. 브랜드ID 템플릿 처리무시...", "ERROR")/>

		<#return _procMap/>
	</#if>

	<#local brandId = _apiResultMap.brandId!""/>

	<#local r = m1.log("[BRAND_ID][SYNC][DB][SELECT] 브랜드ID 적재여부 조회. @브랜드ID=[${brandId}]", "INFO")/>
	<#if brandId?has_content>

		<#local registerDate = _apiResultMap.registerDate!""/>
		<#if registerDate?has_content>
			<#local registerDate = m1.replaceAll(registerDate, "[-T:]", "")?keep_before_last(".") />
		</#if>
		<#local updateDate = _apiResultMap.updateDate!""/>
		<#if updateDate?has_content>
			<#local updateDate = m1.replaceAll(updateDate, "[-T:]", "")?keep_before_last(".") />
		</#if>
		<#local approvalYmd = _apiResultMap.approvalDate!""/>
		<#if approvalYmd?has_content>
			<#local approvalYmd = m1.replaceAll(approvalYmd, "[-T:]", "")?substring(0,8) />
		</#if>

		<#local brandIdStatus = _apiResultMap.status!""/>
		<#local useYn = m1.decode(brandIdStatus, "승인", "Y", "N")/>

		<#local selectBrandIdQuery = _queryMap.selectQuery>

		<#local selectFormRs = _sqlConn.query2array(selectBrandIdQuery, {
			"브랜드ID": brandId
		})/>


		<#-- 상세내역조회 결과에 따른 DB처리 (insert / update) -->
		<#if (selectFormRs?size == 0)>
			<#-- 테이블 조회하여 없는 베이스폼 정보는 insert -->
			<#local executeQuery = _queryMap.insertQuery>
			<#local executeType = "INSERT"/>

		<#else>
			<#-- BIZ 브랜드ID 규격 변경으로 인해 데이터 update -->
			<#local executeQuery = _queryMap.updateQuery>
			<#local executeType = "UPDATE"/>

		</#if>

		<#-- BIZ 상세내역조회 값에 대해 데이터 파싱 -->
		<#local rs = _sqlConn.execute(executeQuery, {
			"브랜드ID": brandId
			, "브랜드명": _apiResultMap.name!""
			, "브랜드키": _apiResultMap.brandKey!""
			, "사용여부": useYn
			, "브랜드상태": brandIdStatus
			, "등록일시": registerDate
			, "수정일시": updateDate
			, "승인날짜": approvalYmd
		})/>

		<#if (rs >= 0)>
			<#local r = m1.log("[BRAND_ID][SYNC][DB][${executeType}][SUCC] 브랜드ID 동기화 DB처리 성공. @브랜드ID=[${brandId}]", "INFO")/>

			<#if executeType == "INSERT">
				<#local r = _procMap.put("insertCnt", _procMap.insertCnt + 1)/>
			<#elseif executeType == "UPDATE">
				<#local r = _procMap.put("updateCnt", _procMap.updateCnt + 1)/>
			</#if>

			<#local r = _sqlConn.commit()/>

		<#else>
			<#local r = m1.log("[BRAND_ID][SYNC][DB][${executeType}][FAIL] 브랜드ID 동기화 DB처리 실패. @브랜드ID=[${brandId}]", "ERROR")/>

			<#local r = _procMap.put("failCnt", _procMap.failCnt + 1)/>

		</#if>

	<#else>
		<#local r = m1.log("[BRAND_ID][SYNC][REQ][ERR] biz센터 브랜드ID 조회결과 없음.", "ERROR")/>
		<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>
	</#if>

	<#return _procMap/>
</#function>

<#-- 챗봇ID 조회된 값에 대한 정보를 DB처리. DB에 데이터가 있으면 update, 데이터가 없다면 insert -->
<#function innerFunction_chatbotIdDetail2DB _sqlConn, _token, _queryMap, _apiResultMap, _requestUrl, _procMap>
	<#if !_apiResultMap?has_content>
		<#local r = m1.log("[CHATBOT_ID][SYNC][ERR] api전문 내용 없음. 챗봇ID 템플릿 처리무시...", "ERROR")/>

		<#return _procMap/>
	</#if>

	<#local brandId = _apiResultMap.brandId!""/>

	<#local r = m1.log("[CHATBOT_ID][SYNC][DB][SELECT] 챗봇ID 적재여부 조회. @브랜드ID=[${brandId}]", "INFO")/>
	<#if brandId?has_content>

		<#assign approvalDate = m1.replaceAll(_apiResultMap.approvalDate!"", "[-T:]", "")?keep_before_last(".") />
		<#assign updateDate = m1.replaceAll(_apiResultMap.updateDate!"", "[-T:]", "")?keep_before_last(".") />
		<#assign registerDate = m1.replaceAll(_apiResultMap.registerDate!"", "[-T:]", "")?keep_before_last(".") />

		<#local selectChatbotIdQuery = _queryMap.selectQuery>

		<#local chatbotId = _apiResultMap.chatbotId!""/>

		<#local selectChatbotRs = _sqlConn.query2array(selectChatbotIdQuery, {
			"챗봇ID": chatbotId
		})/>

		<#if _apiResultMap.isMainNum == true>
			<#assign isMainNum = "Y">
		<#elseif _apiResultMap.isMainNum == false>
			<#assign isMainNum = "N">
		<#else>
			<#assign isMainNum = "">
		</#if>


		<#-- 상세내역조회 결과에 따른 DB처리 (insert / update) -->
		<#if (selectChatbotRs?size == 0)>
			<#-- 테이블 조회하여 없는 베이스폼 정보는 insert -->
			<#local executeQuery = _queryMap.insertQuery>
			<#local executeType = "INSERT"/>

		<#else>
			<#-- BIZ 브랜드ID 규격 변경으로 인해 데이터 update -->
			<#local executeQuery = _queryMap.updateQuery>
			<#local executeType = "UPDATE"/>

		</#if>

		<#-- BIZ 상세내역조회 값에 대해 데이터 파싱 -->
		<#local rs = _sqlConn.execute(executeQuery, {
			"brandId" : _apiResultMap.brandId!"",
			"subNum" : _apiResultMap.subNum!"",
			"subTitle" : _apiResultMap.subTitle!"",
			"display" : _apiResultMap.display!"",
			"groupId" : _apiResultMap.groupId!"",
			"approvalDate" : approvalDate,
			"approvalResult" : _apiResultMap.approvalResult!"",
			"updateId" : _apiResultMap.updateId!"",
			"updateDate" : updateDate,
			"registerId" : _apiResultMap.registerId!"",
			"registerDate" : registerDate,
			"isMainNum" : isMainNum,
			"service" : _apiResultMap.approvalResult!"",
			"chatbotId" : chatbotId
		})/>

		<#if (rs >= 0)>
			<#local r = m1.log("[CHATBOT_ID][SYNC][DB][${executeType}][SUCC] 챗봇ID 동기화 DB처리 성공. @브랜드ID=[${brandId}] @챗봇ID=[${chatbotId}]", "INFO")/>

			<#if executeType == "INSERT">
				<#local r = _procMap.put("insertCnt", _procMap.insertCnt + 1)/>
			<#elseif executeType == "UPDATE">
				<#local r = _procMap.put("updateCnt", _procMap.updateCnt + 1)/>
			</#if>

			<#local r = _sqlConn.commit()/>

		<#else>
			<#local r = m1.log("[CHATBOT_ID][SYNC][DB][${executeType}][FAIL] 챗봇ID 동기화 DB처리 실패. @브랜드ID=[${brandId}] @챗봇ID=[${chatbotId}]", "ERROR")/>

			<#local r = _procMap.put("failCnt", _procMap.failCnt + 1)/>

		</#if>

	<#else>
		<#local r = m1.log("[CHATBOT_ID][SYNC][REQ][ERR] biz센터 챗봇ID 조회결과 없음.", "ERROR")/>
		<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>
	</#if>

	<#return _procMap/>
</#function>

<#-- 베이스폼ID 상세내역을 조회하여 조회결과 DB처리 -->
<#function innerFunction_formIdInfoDetail2DB _sqlConn, _token, _queryMap, _apiResultMap, _requestUrl, _procMap>
	<#if !_apiResultMap?has_content>
		<#local r = m1.log("[FORM_ID][SYNC][ERR] api전문 내용 없음. 베이스폼ID 템플릿 처리무시...", "ERROR")/>

		<#return _procMap/>
	</#if>

	<#local messagebaseformId = _apiResultMap.messagebaseformId!""/>

	<#local r = m1.log("[FORM_ID][SYNC][DB][SELECT] 베이스폼ID 적재여부 조회. @베이스폼ID=[${messagebaseformId}]", "INFO")/>
	<#if messagebaseformId?has_content>
		<#local selectFormIdQuery = _queryMap.selectQuery>

		<#local selectFormRs = _sqlConn.query2array(selectFormIdQuery, {
			"베이스폼ID": messagebaseformId
		})/>

		<#local r = m1.log("[FORM_ID][BIZ][REQ][DETAIL][SELECT] biz센터 베이스폼ID 상세내역 조회. @베이스폼ID=[${messagebaseformId}]", "INFO")/>
		<#local detailApiResultMap = commonFunction_requestGet4ResultMap(_token, "${_requestUrl}/${messagebaseformId}")/>
		<#local r = m1.log(detailApiResultMap, "DEBUG")/>

		<#if detailApiResultMap?has_content>
			<#-- BIZ 베이스폼ID 상세조회 -->
			<#local mediaInfo = detailApiResultMap.mediaUrl![]/>
			<#if (mediaInfo?size > 0)>
				<#local mediaFileId = mediaInfo[0].fileId!""/>
				<#local mediaFileUrl = mediaInfo[0].url!""/>
			</#if>

			<#local registerDate = detailApiResultMap.registerDate!""/>
			<#if registerDate?has_content>
				<#local registerDate = m1.replaceAll(registerDate, "[-T:]", "")?keep_before_last(".") />

			</#if>
			<#local updateDate = detailApiResultMap.updateDate!""/>
			<#if updateDate?has_content>
				<#local updateDate = m1.replaceAll(updateDate, "[-T:]", "")?keep_before_last(".") />
			</#if>

			<#-- 상세내역조회 결과에 따른 DB처리 (insert / update) -->
			<#if (selectFormRs?size == 0)>
				<#-- 테이블 조회하여 없는 베이스폼 정보는 insert -->
				<#local executeQuery = _queryMap.insertQuery>
				<#local executeType = "INSERT"/>

			<#else>
				<#-- BIZ 베이스폼ID 규격 변경으로 인해 데이터 update -->
				<#local executeQuery = _queryMap.updateQuery>
				<#local executeType = "UPDATE"/>

			</#if>

			<#-- BIZ 상세내역조회 값에 대해 데이터 파싱 -->
			<#local rs = _sqlConn.execute(executeQuery, {
				"베이스폼ID": messagebaseformId
				, "베이스명": detailApiResultMap.formName!""
				, "템플릿타입": detailApiResultMap.productCode!""
				, "스펙": detailApiResultMap.spec!""
				, "카드타입": detailApiResultMap.cardType!""
				, "업태": detailApiResultMap.bizCondition!""
				, "유형그룹": detailApiResultMap.bizCategory!""
				, "유형서비스": detailApiResultMap.bizService!""
				, "검증정보": detailApiResultMap.policyInfo!{}
				, "가이드정보": detailApiResultMap.guideInfo!{}
				, "검수파라미터": detailApiResultMap.params!{}
				, "RCS규격": detailApiResultMap.formattedString!{}
				, "미디어파일ID": mediaFileId!""
				, "미디어URL": mediaFileUrl!""
				, "등록일시": registerDate!""
				, "수정일시": updateDate!""
			})/>

			<#if (rs >= 0)>
				<#local r = m1.log("[FORM_ID][SYNC][DB][${executeType}][SUCC] 베이스폼ID 동기화 DB처리 성공. @베이스폼ID=[${messagebaseformId}]", "INFO")/>

				<#if executeType == "INSERT">
					<#local r = _procMap.put("insertCnt", _procMap.insertCnt + 1)/>
				<#elseif executeType == "UPDATE">
					<#local r = _procMap.put("updateCnt", _procMap.updateCnt + 1)/>
				</#if>

				<#local r = _sqlConn.commit()/>

			<#else>
				<#local r = m1.log("[FORM_ID][SYNC][DB][${executeType}][FAIL] 베이스폼ID 동기화 DB처리 실패. @베이스폼ID=[${messagebaseformId}]", "ERROR")/>

				<#local r = _procMap.put("failCnt", _procMap.failCnt + 1)/>

			</#if>
		<#else>
			<#local r = m1.log("[FORM_ID][SYNC][DB][FAIL] 베이스폼ID 동기화 DB처리 실패. @베이스폼ID=[${messagebaseformId}]", "ERROR")/>
			<#local r = _procMap.put("failCnt", _procMap.failCnt + 1)/>

		</#if>

	<#else>
		<#local r = m1.log("[FORM_ID][SYNC][REQ][ERR] biz센터 베이스폼ID 조회결과 없음.", "ERROR")/>
		<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>
	</#if>

	<#return _procMap/>
</#function>

<#-- 공통템플릿 상세내역을 조회하여 조회결과 DB처리 -->
<#function innerFunction_commonTemplateInfoDetail2DB _sqlConn, _token, _queryMap, _apiResultMap, _requestUrl, _procMap>
	<#if !_apiResultMap?has_content>
		<#local r = m1.log("[COMMON_TMPL][SYNC][ERR] api전문 내용 없음. 공통템플릿 템플릿 처리무시...", "ERROR")/>

		<#return _procMap/>
	</#if>

	<#local messagebaseId = _apiResultMap.messagebaseId!""/>

	<#local r = m1.log("[COMMON_TMPL][SYNC][DB][SELECT] 공통템플릿 적재여부 조회. @베이스ID=[${messagebaseId}]", "DEBUG")/>
	<#if messagebaseId?has_content>
		<#local selectFormIdQuery = _queryMap.selectQuery>

		<#local selectFormRs = _sqlConn.query2array(selectFormIdQuery, {
			"베이스ID": messagebaseId
		})/>

		<#local r = m1.log("[COMMON_TMPL][SYNC][BIZ][REQ][DETAIL][SELECT] biz센터 공통템플릿 상세내역 조회. @베이스ID=[${messagebaseId}]", "DEBUG")/>
		<#local detailApiResultMap = commonFunction_requestGet4ResultMap(_token, "${_requestUrl}/${messagebaseId}")/>
		<#local r = m1.log(detailApiResultMap, "DEBUG")/>

		<#if detailApiResultMap?has_content>
			<#-- BIZ 공통템플릿 상세조회 -->
			<#local mediaInfo = detailApiResultMap.mediaUrl![]/>
			<#if (mediaInfo?size > 0)>
				<#local mediaFileId = mediaInfo[0].fileId!""/>
				<#local mediaFileUrl = mediaInfo[0].url!""/>
			</#if>

			<#local registerDate = detailApiResultMap.registerDate!""/>
			<#if registerDate?has_content>
				<#local registerDate = m1.replaceAll(registerDate, "[-T:]", "")?keep_before_last(".") />
			</#if>
			<#local updateDate = detailApiResultMap.updateDate!""/>
			<#if updateDate?has_content>
				<#local updateDate = m1.replaceAll(updateDate, "[-T:]", "")?keep_before_last(".") />
			</#if>
			<#local approvalDate = detailApiResultMap.approvalDate!""/>
			<#if approvalDate?has_content>
				<#local approvalDate = m1.replaceAll(approvalDate, "[-T:]", "")?keep_before_last(".") />
			</#if>

			<#-- 상세내역조회 결과에 따른 DB처리 (insert / update) -->
			<#if (selectFormRs?size == 0)>
				<#-- 테이블 조회하여 없는 베이스폼 정보는 insert -->
				<#local executeQuery = _queryMap.insertQuery>
				<#local executeType = "INSERT"/>

				<#--  적재를 위한 시퀀스 채번  -->
				<#local createSeqQuery>
					SELECT 
						TMPL_MNG_SEQ.nextval AS SEQ
					FROM DUAL
				</#local>
				<#local seq = _sqlConn.query2array(createSeqQuery,{})[0]["SEQ"] />

			<#else>
				<#-- BIZ 공통템플릿 규격 변경으로 인해 데이터 update -->
				<#local executeQuery = _queryMap.updateQuery>
				<#local executeType = "UPDATE"/>

			</#if>

			<#-- BIZ 상세내역조회 값에 대해 데이터 파싱 -->
			<#local executeParamMap = {
				"시퀀스": seq!""
				, "베이스ID": detailApiResultMap.messagebaseId!""
				, "브랜드ID": detailApiResultMap.brandId!""
				, "템플릿폼ID": detailApiResultMap.messagebaseformId!""
				, "그룹ID": detailApiResultMap.agencyId!""
				, "베이스타입": detailApiResultMap.productCode!""
				, "템플릿명": detailApiResultMap.tmpltName!""
				, "템플릿ID": "common"
				, "전문내용": detailApiResultMap.formattedString!{}
				, "검수상태": detailApiResultMap.status!"parse"
				, "승인결과내용": detailApiResultMap.approvalReason!""
				, "등록자": detailApiResultMap.registerId!""
				, "등록일시": registerDate
				, "상태구분": "4"
				, "결과코드": "20000000"
				, "수정자": detailApiResultMap.updateId!""
				, "수정일시": updateDate
				, "승인일시": approvalDate
				, "템플릿사용여부":"Y"
			}/>

			<#local isSucc = true/>

			<#local executeQueryList = executeQuery?split("#DELIM")/>
			<#list executeQueryList as executeQuery>
				<#local rs = _sqlConn.execute(executeQuery, executeParamMap)/>
				<#if (rs < 0)>
					<#local isSucc = false/>

					<#break/>
				</#if>

			</#list>


			<#if isSucc>
				<#local r = m1.log("[COMMON_TMPL][SYNC][DB][${executeType}][SUCC] 공통템플릿 동기화 DB처리 성공. @베이스ID=[${messagebaseId}]", "INFO")/>

				<#if executeType == "INSERT">
					<#local r = _procMap.put("insertCnt", _procMap.insertCnt + 1)/>
				<#elseif executeType == "UPDATE">
					<#local r = _procMap.put("updateCnt", _procMap.updateCnt + 1)/>
				</#if>

				<#local r = _sqlConn.commit()/>

			<#else>
				<#local r = m1.log("[COMMON_TMPL][SYNC][DB][${executeType}][FAIL] 공통템플릿 동기화 DB처리 실패. @베이스ID=[${messagebaseId}]", "ERROR")/>

				<#local r = _procMap.put("failCnt", _procMap.failCnt + 1)/>
			</#if>
		<#else>
			<#local r = m1.log("[COMMON_TMPL][SYNC][DB][${executeType}][FAIL] 공통템플릿 동기화 DB처리 실패. @베이스ID=[${messagebaseId}]", "ERROR")/>
			<#local r = _procMap.put("failCnt", _procMap.failCnt + 1)/>

		</#if>

	<#else>
		<#local r = m1.log("[COMMON_TMPL][SYNC][REQ][ERR] biz센터 공통템플릿 조회결과 없음.", "ERROR")/>
		<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>
	</#if>

	<#return _procMap/>
</#function>

<#-- 승인/승인대기 템플릿 상세내역을 조회하여 조회결과 DB처리 -->
<#function innerFunction_kkoTemplateInfoDetail2DB _sqlConn, _token, _queryMap, _apiResultMap, _requestUrl, _procMap>
	<#if !_apiResultMap?has_content>
		<#local r = m1.log("[RCS_TMPL][SYNC][ERR] api전문 내용 없음. 승인/승인대기 템플릿 처리무시...", "ERROR")/>

		<#return _procMap/>
	</#if>

	<#assign approvalResult = _apiResultMap.approvalResult!""/>
	<#if 
		approvalResult == "승인"
		|| approvalResult == "승인대기"
	>
		<#local messagebaseId = _apiResultMap.messagebaseId!""/>

		<#local r = m1.log("[RCS_TMPL][SYNC][DB][SELECT] 승인/승인대기 템플릿 적재여부 조회. @베이스ID=[${messagebaseId}]", "INFO")/>
		<#if messagebaseId?has_content>
			<#local selectRcsTemplateQuery = _queryMap.selectQuery>

			<#local selectRcsTemplateRs = _sqlConn.query2array(selectRcsTemplateQuery, {
				"브랜드ID": brandId
				, "베이스ID": messagebaseId
			})/>

			<#if (selectRcsTemplateRs?size == 0)>
				<#-- 
					biz센터에서 조회된 베이스ID로 전문내용 조회를 위해 템플릿상세API호출
						- 템플릿상새조회 API의 경우 api버전에 관계없이 formattedString규격으로 응답해주는 이슈로 인해서 이미지템플릿 및 api버전에 관계없이 formattedString규격으로 동기화
				-->
				<#local r = m1.log("[RCS_TMPL][BIZ][REQ][DETAIL][SELECT] biz센터 승인/승인대기 템플릿 상세내역 조회. @베이스ID=[${messagebaseId}]", "DEBUG")/>
				<#assign detailApiResultMap = commonFunction_requestGet4ResultMap(_token, "${_requestUrl}/${messagebaseId}")/>
				<#if detailApiResultMap?has_content && detailApiResultMap.formattedString?has_content>
					<#assign formParam = detailApiResultMap.formattedString!{}/>
				<#else>
					<#assign formParam = {}/>
				</#if>

				<#local registerDate = detailApiResultMap.registerDate!""/>
				<#if registerDate?has_content>
					<#local registerDate = m1.replaceAll(registerDate, "[-T:]", "")?keep_before_last(".") />
				</#if>
				<#local updateDate = detailApiResultMap.updateDate!""/>
				<#if updateDate?has_content>
					<#local updateDate = m1.replaceAll(updateDate, "[-T:]", "")?keep_before_last(".") />
				</#if>
				<#local approvalDate = detailApiResultMap.approvalDate!""/>
				<#if approvalDate?has_content>
					<#local approvalDate = m1.replaceAll(approvalDate, "[-T:]", "")?keep_before_last(".") />
				</#if>

				<#local executeQuery = _queryMap.insertQuery>
				
				<#--  적재를 위한 시퀀스 채번  -->
				<#local createSeqQuery>
					SELECT 
						TMPL_MNG_SEQ.nextval AS SEQ
					FROM DUAL
				</#local>
				<#local seq = _sqlConn.query2array(createSeqQuery,{})[0]["SEQ"] />

				<#-- BIZ 상세내역조회 값에 대해 데이터 파싱 -->
				<#local executeParamMap = {
					"시퀀스": seq!""
					, "브랜드ID": brandId
					, "베이스ID": messagebaseId
					, "베이스타입": "tmplt"
					, "그룹ID": detailApiResultMap.agencyId!""
					, "템플릿폼ID": detailApiResultMap.messagebaseformId!""
					, "템플릿명": detailApiResultMap.tmpltName!""
					, "템플릿ID": messagebaseId?string?keep_after_last('-')
					, "전문내용": formParam
					, "검수상태": detailApiResultMap.status!"parse"
					, "승인결과": detailApiResultMap.approvalResult!""
					, "승인결과내용": detailApiResultMap.approvalReason!"성공"
					, "상태구분": m1.decode(approvalResult, "승인", "4", "3")
					, "등록자": detailApiResultMap.registerId!""
					, "수정자": detailApiResultMap.updateId!""
					, "등록일시": registerDate
					, "승인일시": approvalDate
					, "수정일시": updateDate
					, "결과코드": "20000000"
					, "템플릿사용여부": m1.decode(approvalResult, "승인", "Y", "N")
				}/>

				<#local isSucc = true/>

				<#local executeQueryList = executeQuery?split("#DELIM")/>
				<#list executeQueryList as executeQuery>
					<#local rs = _sqlConn.execute(executeQuery, executeParamMap)/>
					<#if (rs < 0)>
						<#local isSucc = false/>

						<#break/>
					</#if>

				</#list>


				<#if isSucc>
				
					<#assign r = m1.log("[RCS_TMPL][SYNC][INSERT][SUCC] 승인/승인대기 템플릿 동기화 DB처리 성공. @브랜드ID=[${brandId}] @베이스ID=[${messagebaseId}]", "INFO")/>

					<#local r = _procMap.put("insertCnt", _procMap.insertCnt + 1)/>

					<#assign r = _sqlConn.commit()/>

				<#else>
					<#assign r = m1.log("[RCS_TMPL][SYNC][INSERT][FAIL] 승인/승인대기 템플릿 동기화 DB처리 실패. @브랜드ID=[${brandId}] @베이스ID=[${messagebaseId}]", "ERROR")/>

					<#local r = _procMap.put("failCnt", _procMap.failCnt + 1)/>
				</#if>

			<#else>
				<#assign r = m1.log("[RCS_TMPL][SYNC][INSERT][PASS] 등록된 템플릿으로 인한 DB처리 무시. @브랜드ID=[${brandId}] @베이스ID=[${messagebaseId}]", "INFO")/>

				<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>

			</#if>

		<#else>
			<#local r = m1.log("[RCS_TMPL][SYNC][REQ][ERR] biz센터 승인/승인대기 템플릿 조회결과 없음.", "ERROR")/>
			<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>
		</#if>
	<#else>
		<#-- 승인/승인대기가 아닌 건의 경우 DB처리 제외 -->
	</#if>


	<#return _procMap/>
</#function>