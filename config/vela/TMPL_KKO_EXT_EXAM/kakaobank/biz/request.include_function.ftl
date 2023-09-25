<#-- 공통 변수 include -->
<#include "config.include_variable.ftl"/>

<#--
함수목록
	- commonFunction_writeFileQueue4one : 파일큐에 1건 적재하는 함수
	- commonFunction_writeFileQueue4N : 파일큐에 다건 적재하는 함수
	- commonFunction_error2writeFileQ : 에러큐에 전문을 쓰는 함수
		- innerFunction_flattenFileQueueData : 파일큐에 적재할 전문 생성하는 함수
	- commonFunction_requestGet4ResultList : RBC센터 GET요청 후 결과전문 목록 파싱 함수
		- innerFunction_requestGetResponseMap : RBC센터 GET요청 함수
	- commonFunction_requestGet4ResultMap : RBC센터 GET요청 후 결과전문 단건 파싱 함수
	- commonFunction_getRequestHeaderMap : HTTP요청을 위한 전문헤더 생성하는 함수
	- commonFunction_getCreateTemplateUrl : 버전정보별로 템플릿등록 API url 체크
	- commonFunction_requestTokenInfo : 토큰 요청 함수
	- commonFunction_parseCreateTemplatePayloadMap : 템플릿등록 전문바디 파싱
		- innerFunction_getParseImagePayloadMap : 이미지템플릿 요청전문 파싱 (only v2 API로 요청)
			- innerFunction_uploadImage : 이미지업로드 요청
		- innerFunction_createTemplateId : custTmpltId 생성 함수(영문/숫자 25자 이내)
	- commonFunction_rbc2dbSync: RBC 동기화처리 함수
		- innerFunction_formIdInfoDetail2DB: 베이스폼ID 상세내역을 조회하여 조회결과 DB처리
		- innerFunction_commonTemplateInfoDetail2DB : 공통템플릿 상세내역을 조회하여 조회결과 DB처리
		- innerFunction_rcsTemplateInfoDetail2DB : 승인/승인대기 템플릿 상세내역을 조회하여 조회결과 DB처리
		- innerFunction_rcsBrandIdSimple2DB : 브랜드ID 조회된 값에 대한 정보를 DB처리
		- innerFunction_chatbotIdDetail2DB : 챗봇ID 조회된 값에 대한 정보를 DB처리
-->
<#--  범용성을 위해서 SQL쿼리에 DBMS 전용 쿼리는 사용하지 않도록 한다.  -->

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>


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


<#-- RBC센터 GET요청 후 결과전문 단건 파싱 함수 -->
<#function commonFunction_requestGet4ResultMap _token _requestUrl>

    <#-- RBC센터 GET request요청 함수 -->
    <#local responseBody = innerFunction_requestGetResponseMap(_token, _requestUrl)/>

    <#local responseCode = responseBody.code!""/>
	<#if responseCode == "20000000">
        <#local requestStatus = "성공"/>

		<#local apiResult = responseBody.result![]/>
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

	<#local r = m1.log("[RBC][REQ][END] RBC센터 요청처리 완료. @처리결과=[${requestStatus}]", "INFO")/>
	<#local r = m1.log("@요청URL=[${_requestUrl}]", "DEBUG")/>
    <#local r = m1.log(responseBody, "DEBUG")/>

	<#return resultMap/>
</#function>

<#-- RBC센터 GET요청 함수 -->
<#function innerFunction_requestGetResponseMap _token _requestUrl>
	<#if !_requestUrl?has_content>
		<#local r = m1.log("[RBC][REQ][ERR] 요청URL 없음. @요청URL=[${_requestUrl}] @method=[GET]", "ERROR")/>

		<#return []/>
	</#if>

	<#local r = m1.log("[RBC][REQ][START] RBC센터 요청처리 시작. @method=[GET]", "INFO")/>
	<#local r = m1.log("@요청URL=[${_requestUrl}]", "DEBUG")/>

	<#-- 요청 headerMap 정의 -->
	<#assign headerMap = commonFunction_getRequestHeaderMap(_token, {})/>

	<#-- 템플릿목록 조회 API -->
	<#local httpResponseCode=httpObj.get(_requestUrl, headerMap)!-1/>
    <#if httpResponseCode != 200>
		<#local r = m1.log("[RBC][REQ][FAIL] RBC센터 요청 실패. @응답코드=[${httpResponseCode}]", "ERROR")/>

		<#return {}/>
	</#if>

    <#local httpResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>

    <#local responseBody = m1.parseJsonValue(httpResponseBody)/>

	<#if httpResponseCode == 200>
		<#local r = m1.log("[RBC][REQ][SUCC] RBC센터 HTTP요청 성공. @응답코드=[${httpResponseCode}]", "DEBUG")/>
	<#else>
		<#local r = m1.log("[RBC][REQ][ERR] RBC센터 HTTP요청 실패. @응답코드=[${httpResponseCode}]", "ERROR")/>
	</#if>

    <#return responseBody/>
</#function>


<#-- RBC센터 GET요청 후 결과전문 목록 파싱 함수 -->
<#--  RBC요청시 pagination처리에 대한 로직 -->
<#function commonFunction_requestGet4ResultList _token _requestUrl>

	<#local resultList = m1.editable([])/>

    <#-- RBC센터 GET request요청 함수 -->
	<#local r = m1.log("[RBC][REQ][0] RBC센터 요청처리... @요청URL=[${_requestUrl}]", "INFO")/>
	
    <#local responseBody = innerFunction_requestGetResponseMap(_token, _requestUrl)/>

    <#local responseCode = responseBody.code!""/>
	<#if responseCode == "20000000">
        <#local requestStatus = "성공"/>

		<#local apiResult = responseBody.result![]/>
        <#if apiResult?has_content>
			<#list apiResult as resultMap>
            	<#local r = resultList.put(resultMap)/>
			</#list>

        </#if>

		<#-- 다음 요청데이터가 있는지 판단할 수 있는 utl -->
		<#local requestLinks = responseBody.links!{}/>
		<#local nextRequestUrl = requestLinks.next!""/>

		<#local pagination = responseBody.pagination!{}/>
		<#local pageOffset = pagination.offset!0/>
		<#local pageTotal = pagination.total!0/>
		<#local pageLimit = pagination.limit!0/>

		<#--  추가 요청할지에 대한 여부 체크  -->
		<#if nextRequestUrl?has_content && (pageLimit + pageOffset < pageTotal)>
			<#local requestLoopCnt = ((pageTotal - (pageOffset + pageLimit)) / pageLimit)?ceiling/>
			<#list 1..requestLoopCnt as cnt>

				<#local nextOffSet = 0/>

				<#--  next로 넘어온 값이 http:// 이기에 요청시 301에러 발생. https:// 로 변경하여 요청하는 것으로 URL변경  -->
				<#local nextRequestUrl = nextRequestUrl?replace("http://", "https://")/>
				<#--  <#local nextRequestUrl = "${_requestUrl}&offset=${nextOffSet}"/>  -->

				<#local r = m1.log("[RBC][REQ][${cnt}] 다음 데이터 요청처리... @다음요청URL=[${nextRequestUrl}]", "INFO")/>
				<#local nextResponseBody = innerFunction_requestGetResponseMap(_token, nextRequestUrl)/>
				<#local responseCode = nextResponseBody.code!""/>
				<#if responseCode == "20000000">
					<#local requestStatus = "성공"/>

					<#local apiResult = nextResponseBody.result![]/>
					<#if apiResult?has_content>
						<#list apiResult as resultMap>
							<#local r = resultList.put(resultMap)/>
						</#list>

					</#if>

					<#local nextRequestLinks = nextResponseBody.links!{}/>
					<#local nextRequestUrl = nextRequestLinks.next!""/>

					<#if !nextRequestUrl?has_content>
						<#break/>
					</#if>

				<#else>
					<#local requestStatus = "실패"/>
				</#if>

				<#local r = m1.log("[RBC][REQ][END] 다음 데이터 요청처리 완료. @처리결과=[${requestStatus}] @요청URL=[${nextRequestUrl}]", "INFO")/>
			</#list>

		</#if>

	<#else>
        <#local requestStatus = "실패"/>
		<#local r = m1.log(responseBody, "ERROR")/>

	</#if>

	<#local r = m1.log("[RBC][REQ][END] RBC센터 요청처리 완료. @처리결과=[${requestStatus}] @요청URL=[${_requestUrl}]", "INFO")/>
    <#local r = m1.log(resultList, "DEBUG")/>

	<#return resultList/>
</#function>


<#-- HTTP요청을 위한 전문헤더 생성 함수 -->
<#function commonFunction_getRequestHeaderMap _token _extraParamMap>

    <#-- 기본 헤더정보 정의  -->
    <#local headerMap = m1.editable({
        "Content-Type" : "application/json; charset=utf-8",
        "Accept" : "application/json, text/plain, */*",
        "Authorization" : "Bearer ${_token}"
    })/>

    <#-- 추가되는 정보 추가 정의 -->
    <#list _extraParamMap as extField, extValue>
        <#if extField?has_content && extValue?has_content>
            <#local r = headerMap.put(extField, extValue)/>
        <#else>
            <#local r = m1.log("[ERR] 추가정보 값 없음. @extField=[${extField}] @extValue=[${extValue}]", "ERROR")/>
        </#if>
    </#list>

    <#return headerMap/>
</#function>


<#-- 토큰 요청 함수 -->
<#-- 메모리에 토큰이 존재하며 만료시간도 정상일 경우 해당 토큰을 그대로 사용 -->
<#-- 메모리에 토큰정도가 없거나 만료되었을 경우 다시 토큰을 발급받아서 메모리에 저장 -->
<#function commonFunction_requestTokenInfo _channelInfo>
	<#if !_channelInfo?has_content>
		<#local r = m1.log("채널정보 없음...", "ERROR")/>
		<#return {
			"code": 500
		}/>
	</#if>

    <#local header = {
        "Content-Type" : "application/json; charset=utf-8",
        "Accept" : "application/json, text/plain, */*"
    }/>

    <#local payloadMap = {
        "clientId" : _channelInfo.clientId
        , "clientSecret" : _channelInfo.clientSecret
    }/>

	<#local payload = m1.toJsonBytes(payloadMap)?string/>
	<#local bcbytes = m1.getBytes(payload, "UTF-8")/>
	
	<#local httpResponseCode = httpObj.post("${tmplMngrUrl}/token", bcbytes, 0, bcbytes?size, header)!-1/>
	<#if httpResponseCode != 200>
		<#local r = m1.log("[RBC][REQ][FAIL] 토큰발급 요청 실패. @응답코드=[${httpResponseCode}]", "ERROR")/>
		<#local r = m1.log(httpObj.responseData, "ERROR")/>

		<#return clear/>
	</#if>

	<#local httpResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>

	<#local body=m1.parseJsonValue(httpResponseBody)/>

    <#return {
        "code": httpResponseCode
        , "accessToken": body.accessToken!""
        , "expiresIn": body.expiresIn!"0"
    }/>

</#function>


<#-- 
	템플릿등록 요청 URL생성 함수 
		- 이미지템플릿: v2 api를 항상 사용
		- 나머지 템플릿의 경우 apiVersion의 버전을 판단하여 url을 판단
-->
<#function commonFunction_getCreateTemplateUrl _messagebaseformId _brandId _apiVersion>
	<#if 
		_messagebaseformId == "ITHIMS"
		|| _messagebaseformId == "ITHIMV"
		|| _messagebaseformId == "ITTBNV"
		|| _messagebaseformId == "ITTBNH"
		|| _messagebaseformId == "ITSNSS"
		|| _messagebaseformId == "ITSNSH"
		|| _messagebaseformId == "ITHITS"
		|| _messagebaseformId == "ITHITV"
	>
		<#-- 이미지템플릿의 경우 v2 api로만 요청 -->
		<#assign createTemplateUrl = "${tmplMngrUrl}/brand/${_brandId}/v2/messagebase"/>
	<#else>
		<#-- desc,cell템플릿의 경우 설정된 api버전에 따라서 템플릿등록 url설정 -->
		<#if _apiVersion == "v2">
			<#assign createTemplateUrl = "${tmplMngrUrl}/brand/${_brandId}/v2/messagebase"/>
			
		<#else>
			<#assign createTemplateUrl = "${tmplMngrUrl}/brand/${_brandId}/messagebase"/>
		</#if>
	</#if>

	<#return createTemplateUrl/>
</#function>



<#--  
	임의의 custTmpltId 값 생성: 현재시간 14자리 + uuid 10자리
	영문/숫자 25자 이내로 생성해야함.
-->
<#function innerFunction_createTemplateId>
	<#local ymdhmss=m1.now()?string("yyyyMMddHHmmss")/>

	<#local extUuid = m1.uuid()?replace("-","")[1..10]/>

	<#return ymdhmss + extUuid/>

</#function>


<#-- 
	description/cell 템플릿 전문바디 파싱 함수
		- API버전을 체크하여 전문규격을 파싱
		- 이미지템플릿: v2버전의 전문규격으로 파싱
		
		템플릿등록 API v1
			- v1의 경우 이미지템플릿등록이 미지원이기에 이미지템플릿 등록요청은 v2버전의 템플릿등록을 사용
			- 템플릿등록에 필요한 전문내용은 formattedString의 규격에 맞추어 발송해야 함
			- 기존 RCS템플릿 등록화면이 구축되어 있는 고객사의 경우 구버전(v1)을 지원하야하므로 formattedString으로 넘어온 전문내용을 사용하여 전문을 파싱하는 작업이 필요
		템플릿등록 API v2 
			- 이미지템플릿 등록요청도 해당 API로 함께 사용
			- body전문에 템플릿등록에 필요한 내용을 파싱
-->
<#function commonFunction_parseCreateTemplatePayloadMap _requestMap _apiVersion>
	<#if !_requestMap??>
		<#local r = m1.log("[REQ][DO][ERR] 데이터 파싱 중 에러발생. 유입데이터 없음.", "ERROR")/>
		<#return {}/>
	</#if>

	<#local _seqLocal = _requestMap.TM_SEQ!""/>
	<#local messagebaseformId = _requestMap.MESSAGEBASE_FORM_ID!""/>

	<#local resultMap = m1.editable({})/>

	<#if _apiVersion == "v1">

		<#-- 전문바디 파싱 -->
		<#attempt>
			<#local formattedStringMap = m1.parseJsonValue(_requestMap.FORM_PARAM)!{}/>
		<#recover>
			<#local r = m1.log("[REQ][DO][ERR] 전문내용 데이터 파싱중 에러발생. @전문내용=[${m1.toJsonBytes(_requestMap.FORM_PARAM!{})?string}]", "ERROR")/>
			<#local r = m1.log(.error, "ERROR")/>

			<#return {}/>
		</#attempt>

		<#-- TODO. custTmpltId(templateId) 값 입력여부 검토필요  -->
		<#local regMessagebasesMap = {
			"brandId": _requestMap.CHANNEL_ID!""
			, "messagebaseformId": messagebaseformId
			, "agencyId": _requestMap.AGENCY_ID!""
			, "tmpltName": _requestMap.TEMPLATE_NAME!""
			, "custTmpltId": innerFunction_createTemplateId()
			, "formattedString": formattedStringMap
		}/>

		<#local r = resultMap.put("regMessagebases", [regMessagebasesMap])/>

	<#else>
		<#-- v2버전 템플릿 전문바디 파싱 -->

		<#-- 공통 전문내용 파싱 -->
		<#-- TODO. custTmpltId(templateId) 값 입력여부 검토필요  -->
		<#local r = resultMap.merge({
			"brandId": _requestMap.CHANNEL_ID!""
			, "messagebaseformId": messagebaseformId
			, "agencyId": _requestMap.AGENCY_ID!""
			, "tmpltName": _requestMap.TEMPLATE_NAME!""
			, "custTmpltId": innerFunction_createTemplateId()
		}, "true")/>

		<#if 
			messagebaseformId == "ITHIMS"
			|| messagebaseformId == "ITHIMV"
			|| messagebaseformId == "ITHITS"
			|| messagebaseformId == "ITHITV"
			|| messagebaseformId == "ITTBNV"
			|| messagebaseformId == "ITTBNH"
			|| messagebaseformId == "ITSNSS"
			|| messagebaseformId == "ITSNSH"
		>
			<#--
				이미지 템플릿
					"ITHIMS": "이미지-타이틍강조형_정방형"
					"ITHIMV": "이미지-타이틍강조형_세로형"
					"ITHITS": "이미지강조형_정방형"
					"ITHITV": "이미지강조형_세로형"
				썸네일
					"ITTBNV": "쌈네일형_세로형"
					"ITTBNH": "쌈네일형_가로형"
				SNS
					"ITSNSS": "SNS형_하단버튼형"
					"ITSNSH": "SNS형_중간버튼형"
			-->
			<#local r = m1.log("[REQ][DO][DATA] 템플릿 전문내용 파싱시작. @SEQ=[${_seqLocal}] @템플릿ID=[${_requestMap.TEMPLATE_ID!''}] @템플릿폼ID=[${messagebaseformId}]", "INFO")/>
			<#local r = m1.log(_requestMap, "DEBUG")/>

			<#-- 전문바디 매핑처리 -->
			<#local imagePayloadMap = innerFunction_getParseImagePayloadMap(messagebaseformId, _requestMap)/>
			<#if imagePayloadMap?has_content>
				<#local r = resultMap.put("body", imagePayloadMap)/>

			<#else>
				<#local r = m1.log("[REQ][DO][DATA][ERR] 이미지템플릿 요청전문 파싱 실패. @SEQ=[${_seqLocal}]", "ERROR")/>

				<#return {}/>
			</#if>

		<#else>
			<#-- 
				타이틀 선택형
					"FF003D": "출금(Description)"
					"GG001D": "회원가입(Description)"
					"FF005D": "명세서(Description)"
					"FF004D": "취소(Description)"
					"GG003D": "안내(Description)"
					"CC003D": "배송(Description)"
					"CC002D": "주문(Description)"
					"CC001D": "출고(Description)"
					"FF002D": "입금(Description)"
					"GG002D": "인증(Description)"
					"EE001D": "예약(Description)"
					"FF001D": "승인(Description)"
					"FF003C": "출금(Cell)"
					"GG001C": "회원가입(Cell)"
					"FF005C": "명세서(Cell)"
					"FF004C": "취소(Cell)"
					"GG003C": "안내(Cell)"
					"CC003C": "배송(Cell)"
					"CC002C": "주문(Cell)"
					"CC001C": "출고(Cell)"
					"FF002C": "입금(Cell)"
					"GG002C": "인증(Cell)"
					"EE001C": "예약(Cell)"
					"FF001C": "승인(Cell)"
				타이틀 자유형
					"TATA001D": "타이틀자유형(Description)"
					"TATA001C": "타이틀자유형(Cell)"
			-->
			<#local r = m1.log("[REQ][DO][DATA] 템플릿 전문내용 파싱시작. @SEQ=[${_seqLocal}] @템플릿ID=[${_requestMap.TEMPLATE_ID!''}] @템플릿폼ID=[${messagebaseformId}]", "INFO")/>
			<#local r = m1.log(_requestMap, "DEBUG")/>

			<#-- 전문내용 매핑처리 -->
			<#attempt>
				<#local r = resultMap.put("body", m1.parseJsonValue(_requestMap.REQ_FORM_PARAM)![])/>
			<#recover>
				<#local r = m1.log("[REQ][DO][ERR] 전문내용 데이터 파싱중 에러발생. @전문내용=[${m1.toJsonBytes(_requestMap.REQ_FORM_PARAM![])?string}]", "ERROR")/>
				<#local r = m1.log(.error, "ERROR")/>

				<#return {}/>
			</#attempt>

			<#-- 버튼정보 매핑처리 -->
			<#local parameterButtonList = m1.parseJsonValue(_requestMap.BUTTON_INFO![])![]/>
			<#if parameterButtonList?has_content>
				<#attempt>
					<#local r = resultMap.put("buttons", parameterButtonList)/>
				<#recover>
					<#local r = m1.log("[REQ][DO][ERR] 버튼내용 데이터 파싱중 에러발생. @버튼내용=[${m1.toJsonBytes(_requestMap.BUTTON_INFO!{})?string}]", "ERROR")/>
					<#local r = m1.log(.error, "ERROR")/>

					<#return {}/>
				</#attempt>
			</#if>

		</#if>
	</#if>

	<#local r = m1.log("[REQ][DO] 데이터 파싱처리 완료. @SEQ=[${_seqLocal}] @템플릿ID=[${_requestMap.TEMPLATE_ID!''}]", "INFO")/>
	<#local r = m1.log(resultMap, "DEBUG")/>

	<#return resultMap/>

</#function>


<#--
	이미지템플릿 전문바디 파싱 함수
		이미지강조형
			"ITHIMS": "이미지-타이틍강조형_정방형" (900x900)
			"ITHIMV": "이미지-타이틍강조형_세로형" (900x1200)
			"ITHITS": "이미지강조형_정방형" (900x900)
			"ITHITV": "이미지강조형_세로형" (900x1200)
		썸네일
			"ITTBNV": "쌈네일형_세로형" (메인:900x560, 셈네일:300x300)
			"ITTBNH": "쌈네일형_가로형" (메인:900x560, 셈네일:300x300)
		SNS
			"ITSNSS": "SNS형_하단버튼형" (900x900)
			"ITSNSH": "SNS형_중간버튼형" (900x560)
-->
<#function innerFunction_getParseImagePayloadMap _messagebaseformId _requestMap>
	<#local msgFormIdMapper = {
		"ITHIMS": "타이틍강조형_정방형"
		, "ITHIMV": "타이틍강조형_세로형"
		, "ITHITS": "이미지강조형_정방형"
		, "ITHITV": "이미지강조형_세로형"
		, "ITTBNV": "쌈네일형_세로형"
		, "ITTBNH": "쌈네일형_가로형"
		, "ITSNSS": "SNS형_하단버튼형"
		, "ITSNSH": "SNS형_중간버튼형"
	}/>

	<#local imgPathInfo = _requestMap.IMAGE_PATH_INFO!{}/>
	<#if !imgPathInfo?has_content>
		<#local r = m1.log("[REQ][DO][DATA][ERR] 이미지템플릿 등록을 위해서는 이미지정보가 필수입니다. @요청전문=[${m1.toJsonBytes(_requestMap)}]", "ERROR")/>

		<#return []/>
	</#if>

	<#local _seqLocal = _requestMap.TM_SEQ!""/>

	<#local r = m1.log("[REQ][DO][DATA][${msgFormIdMapper[_messagebaseformId]}] 이미지템플릿 전문내용 파싱시작. @SEQ=[${_seqLocal}] @템플릿ID=[${_requestMap.TEMPLATE_ID!''}] @템플릿폼ID=[${_messagebaseformId}]", "INFO")/>
	<#local r = m1.log(_requestMap, "DEBUG")/>

	<#local bodyPayloadArr = m1.parseJsonValue("[]")/>

	<#-- 요청전문 정보 추가 -->
	<#local formParamList = m1.parseJsonValue(_requestMap.REQ_FORM_PARAM!"[]")![]/>
	<#list formParamList as value>
		<#local r = m1.arrayAdd(bodyPayloadArr, value)/>
	</#list>

	<#-- 이미지업로드 요청 및 업로드한 이미지정보 추가 -->
	<#local imageInfoList = innerFunction_uploadImage(_requestMap)/>
	<#list imageInfoList as value>
		<#local r = m1.arrayAdd(bodyPayloadArr, value)/>
	</#list>

	<#local r = m1.log(bodyPayloadArr, "DEBUG")/>

    <#return bodyPayloadArr/>
</#function>


<#-- RBC센터 이미지파일 업로드 요청 함수 -->
<#function innerFunction_uploadImage _requestMap>
	<#local imgPathInfo = m1.parseJsonValue(_requestMap.IMAGE_PATH_INFO!"{}")/>
	<#if !imgPathInfo?has_content>
		<#local r = m1.log("[ERR] 이미지정보 없음.", "ERROR")/>

		<#return {
			"code": "79999"	
		}/>
	</#if>

	<#local brandId = _requestMap.CHANNEL_ID!""/>

	<#local token = (m1.shareget(brandId)).accessToken!""/>
	<#local brandKey = (brandInfoMap[brandId]!{}).brandKey!""/>

	<#local resultUploadList = m1.parseJsonValue("[]")/>

	<#list imgPathInfo as key,filePath>
		<#-- 이미지파일정보 중에  -->
		<#if 
			key?has_content
			|| key == "media"
			|| key?starts_with("subMedia")
		>
			<#if !filePath?starts_with("maapfile")>
				<#-- 검수요청 header 정의 -->

				<#assign boundary = httpObj.getBoundary() />

				<#assign headerMap = commonFunction_getRequestHeaderMap(token, {
					"Content-Type" : "multipart/form-data; boundary=${boundary}",
					"X-RCS-Brandkey": brandKey,
					"brandId": brandId,
					"charsetName": "UTF-8"
				})/>

				<#local fileList = [filePath]/>

				<#local r = m1.log("[IMG][UPD] 이미지파일 업로드. @브랜드ID=[${brandId}] @업로드파일=[${filePath}]", "INFO")/>

				<#local httpResponseCode = httpObj.uploadImage("${tmplMngrUrl}/brand/${brandId}/v2/messagebase/file", headerMap, {}, fileList)!-1/>
				<#local httpResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>
				<#local r = m1.log(httpResponseBody, "DEBUG")/>

				<#local responseBody = m1.parseJsonValue(httpResponseBody)/>
				
				<#if httpResponseCode != 200>
					<#local r = m1.log("[IMG][UPD][FAIL] 이미지파일 업로드 실패. @브랜드ID=[${brandId}] @업로드파일=[${filePath}]", "ERROR")/>
					
					<#local uploadMap = responseBody.error!{}/>

					<#--  TODO. 이미지실패에 대한 실패처리 로직 추가  -->

					<#local r = m1.log(uploadMap, "ERROR")/>

				<#else>
					<#local r = m1.log("[IMG][UPD][SUCC] 이미지파일 업로드 성공. @브랜드ID=[${brandId}] @업로드파일=[${filePath}]", "INFO")/>
					
					<#local uploadMap = responseBody.result![]/>

					<#local r = m1.log(uploadMap, "DEBUG")/>
					<#if (uploadMap?size > 0)>
						<#local resultMap = {
							"param": key
							, "value": "maapfile://" + uploadMap[0].fileId!""
						}/>

						<#local r = m1.arrayAdd(resultUploadList, resultMap)/>

					</#if>

					<#local r = m1.log(resultMap, "DEBUG")/>
				</#if>
			<#elseif filePath?starts_with("maapfile")>
				<#-- 이미지파일ID 형식일 경우 그대로 사용 -->
				<#local r = m1.log("[IMG][UPD] 이미지파일ID 형식이므로 경우 그대로 사용. @브랜드ID=[${brandId}] @업로드파일=[${filePath}]", "INFO")/>

				<#local resultMap = {
					"param": key
					, "value": filePath
				}/>

				<#local r = m1.arrayAdd(resultUploadList, resultMap)/>
			</#if>
		</#if>
	</#list>

    <#return resultUploadList/>

</#function>


<#--
	1. rbc센터에 동기화처리 정보 목록조회
	2. 목록을 loop돌면서 각 정보에 대한 rbc 상세정보 조회
	3. 상세내역조회 값에 대해 데이터 파싱
	4. 상세내역조회 결과에 따른 DB처리 (insert / update)

-->
<#--
	RBC 동기화처리 객체 spec
	{
		"token": 토큰정보
		, "sqlConn": SQL객체
		, "query": {
			"selectQuery": 조회쿼리
			, "updateQuery": update쿼리
			, "insertQuery": 적재쿼리
		}
		, "requestUrl": 요청 베이스URL (ex: "${tmplMngrUrl}/brand/${brandId}/messagebase")
	}
-->
<#function commonFunction_rbc2dbSync _syncType _syncParamMap>
	<#if !_syncParamMap?has_content>
		<#local r = m1.log("[RBC][SYNC][ERR] RBC센터 동기화처리 파라미터 데이터 없음.", "ERROR")/>

		<#return {}/>
	<#elseif 
		!_syncParamMap.sqlConn?has_content
		|| !_syncParamMap.query?has_content
		|| !_syncParamMap.requestUrl?has_content
	>
		<#local r = m1.log("[RBC][SYNC][ERR] RBC센터 동기화처리 파라미터 데이터 없음. @요청타입=[${_syncType}]", "ERROR")/>
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
	<#assign clientInfoList = m1.shareget("clientInfoList")![]/>
	<#if !clientInfoList?has_content>
		<#assign r = m1.log("[CONF][BRAND_ID][ERR] API-KEY정보 없음.... 처리 종료.", "ERROR")/>

		<#return {
			"code": "301"
			, "message": "API-KEY정보 없음"
		}/>

	<#else>
		<#list clientInfoList as clientInfo>
			<#assign clientId = clientInfo.clientId!""/>
			<#assign clientSecret = clientInfo.clientSecret!""/>

			<#if clientId?has_content && clientSecret?has_content>
				<#assign tokenInfo = commonFunction_requestTokenInfo({
					"clientId": clientId
					, "clientSecret": clientSecret
				})/>

				<#assign token = tokenInfo.accessToken!""/>
				<#if !token?has_content>
					<#assign r = m1.log("[ERR] 토큰정보 없음. @토큰정보=[${m1.toJsonBytes(tokenInfo)}]", "ERROR")/>

				<#else>
					<#-- rbc센터에 동기화처리 정보 목록조회 -->
					<#local r = m1.log("[RBC][SYNC][REQ] RBC센터 동기화정보 목록 조회.", "DEBUG")/>

					<#local rbcSearchApiResultList = commonFunction_requestGet4ResultList(token, requestBaseUrl)/>
					<#local r = m1.log(rbcSearchApiResultList, "DEBUG")/>

					<#if rbcSearchApiResultList?has_content>
						<#list rbcSearchApiResultList as rbcSearchApiResult>
							<#-- RBC에서 조회된 베이스폼ID 목록을 돌며 상세내역 api조회하여 DB에 동기화처리 -->
							<#switch _syncType?upper_case>
								<#case "FORM_ID">
									<#--  베이스폼ID 동기화 DB처리  -->
									<#local procMap = innerFunction_formIdInfoDetail2DB(sqlConn, token, queryMap, rbcSearchApiResult, requestBaseUrl, procMap)/>
									<#break>
								<#case "COMMON_TMPL">
									<#--  공통템플릿 동기화 DB처리  -->
									<#local procMap = innerFunction_commonTemplateInfoDetail2DB(sqlConn, token, queryMap, rbcSearchApiResult, requestBaseUrl, procMap)/>
									<#break>
								<#case "RCS_TMPL">
									<#--  승인템플릿 동기화 DB처리  -->
									<#local procMap = innerFunction_rcsTemplateInfoDetail2DB(sqlConn, token, queryMap, rbcSearchApiResult, requestBaseUrl, procMap)/>
									<#break>
								<#case "BRAND_ID">
									<#--  브랜드ID 동기화 DB처리  -->
									<#local procMap = innerFunction_rcsBrandIdSimple2DB(sqlConn, token, queryMap, rbcSearchApiResult, requestBaseUrl, procMap)/>
									<#break>
								<#case "CHATBOT_ID">
									<#--  챗봇ID 동기화 DB처리  -->
									<#local procMap = innerFunction_chatbotIdDetail2DB(sqlConn, token, queryMap, rbcSearchApiResult, requestBaseUrl, procMap)/>
									<#break>
								<#default>
									<#local r = m1.log("정의되지 않은 DB처리 타입. @타입=[${_syncType}]", "ERROR")/>
							</#switch>
							
						</#list>
					
						<#local r = m1.log("[RBC][SYNC][END] RBC센터 동기화처리 완료. @적재건수=[${procMap.insertCnt}] @갱신건수=[${procMap.updateCnt}] @무시건수=[${procMap.passCnt}] @실패건수=[${procMap.failCnt}] @총건수=[${procMap.insertCnt + procMap.updateCnt + procMap.passCnt + procMap.failCnt}]", "INFO")/>

						<#return {
							"code": "200"
							, "message": "성공"
						}/>

					<#else>
						<#local r = m1.log("[RBC][SYNC][END] RBC센터 동기화처리 정보 없음으로 인한 처리 무시.", "INFO")/>

						<#return {
							"code": "401"
							, "message": "RBC센터 조회데이터 없음"
						}/>

					</#if>

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
			<#-- RBC 브랜드ID 규격 변경으로 인해 데이터 update -->
			<#local executeQuery = _queryMap.updateQuery>
			<#local executeType = "UPDATE"/>

		</#if>

		<#-- RBC 상세내역조회 값에 대해 데이터 파싱 -->
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
		<#local r = m1.log("[BRAND_ID][SYNC][REQ][ERR] RBC센터 브랜드ID 조회결과 없음.", "ERROR")/>
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
			<#-- RBC 브랜드ID 규격 변경으로 인해 데이터 update -->
			<#local executeQuery = _queryMap.updateQuery>
			<#local executeType = "UPDATE"/>

		</#if>

		<#-- RBC 상세내역조회 값에 대해 데이터 파싱 -->
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
		<#local r = m1.log("[CHATBOT_ID][SYNC][REQ][ERR] RBC센터 챗봇ID 조회결과 없음.", "ERROR")/>
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

		<#local r = m1.log("[FORM_ID][RBC][REQ][DETAIL][SELECT] RBC센터 베이스폼ID 상세내역 조회. @베이스폼ID=[${messagebaseformId}]", "INFO")/>
		<#local detailApiResultMap = commonFunction_requestGet4ResultMap(_token, "${_requestUrl}/${messagebaseformId}")/>
		<#local r = m1.log(detailApiResultMap, "DEBUG")/>

		<#if detailApiResultMap?has_content>
			<#-- RBC 베이스폼ID 상세조회 -->
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
				<#-- RBC 베이스폼ID 규격 변경으로 인해 데이터 update -->
				<#local executeQuery = _queryMap.updateQuery>
				<#local executeType = "UPDATE"/>

			</#if>

			<#-- RBC 상세내역조회 값에 대해 데이터 파싱 -->
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
		<#local r = m1.log("[FORM_ID][SYNC][REQ][ERR] RBC센터 베이스폼ID 조회결과 없음.", "ERROR")/>
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

		<#local r = m1.log("[COMMON_TMPL][SYNC][RBC][REQ][DETAIL][SELECT] RBC센터 공통템플릿 상세내역 조회. @베이스ID=[${messagebaseId}]", "DEBUG")/>
		<#local detailApiResultMap = commonFunction_requestGet4ResultMap(_token, "${_requestUrl}/${messagebaseId}")/>
		<#local r = m1.log(detailApiResultMap, "DEBUG")/>

		<#if detailApiResultMap?has_content>
			<#-- RBC 공통템플릿 상세조회 -->
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
				<#-- RBC 공통템플릿 규격 변경으로 인해 데이터 update -->
				<#local executeQuery = _queryMap.updateQuery>
				<#local executeType = "UPDATE"/>

			</#if>

			<#-- RBC 상세내역조회 값에 대해 데이터 파싱 -->
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
		<#local r = m1.log("[COMMON_TMPL][SYNC][REQ][ERR] RBC센터 공통템플릿 조회결과 없음.", "ERROR")/>
		<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>
	</#if>

	<#return _procMap/>
</#function>

<#-- 승인/승인대기 템플릿 상세내역을 조회하여 조회결과 DB처리 -->
<#function innerFunction_rcsTemplateInfoDetail2DB _sqlConn, _token, _queryMap, _apiResultMap, _requestUrl, _procMap>
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
					RBC센터에서 조회된 베이스ID로 전문내용 조회를 위해 템플릿상세API호출
						- 템플릿상새조회 API의 경우 api버전에 관계없이 formattedString규격으로 응답해주는 이슈로 인해서 이미지템플릿 및 api버전에 관계없이 formattedString규격으로 동기화
				-->
				<#local r = m1.log("[RCS_TMPL][RBC][REQ][DETAIL][SELECT] RBC센터 승인/승인대기 템플릿 상세내역 조회. @베이스ID=[${messagebaseId}]", "DEBUG")/>
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

				<#-- RBC 상세내역조회 값에 대해 데이터 파싱 -->
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
			<#local r = m1.log("[RCS_TMPL][SYNC][REQ][ERR] RBC센터 승인/승인대기 템플릿 조회결과 없음.", "ERROR")/>
			<#local r = _procMap.put("passCnt", _procMap.passCnt + 1)/>
		</#if>
	<#else>
		<#-- 승인/승인대기가 아닌 건의 경우 DB처리 제외 -->
	</#if>


	<#return _procMap/>
</#function>