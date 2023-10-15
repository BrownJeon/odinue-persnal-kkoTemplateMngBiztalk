<#-- 공통 변수 include -->
<#include "config.include_variable.ftl"/>

<#--
함수목록
	- commonFunction_getProfileKeyInfoMap: 인증정보 테이블에서 데이터를 조회하여 발신프로필정보 세팅하는 함수
	- commonFunction_getTokenInfo4Memory: biz센터에서 발급받은 토큰정보를 메모리에 등록하는 함수
	- commonFunction_requestTokenInfo: 채널정보를 받아서 biz센터에 토큰발급받는 함수
	- commonFunction_templateSync2Database: 템플릿동기화 처리 함수
	- commonFunction_writeFileQueue4one : 파일큐에 1건 적재하는 함수
	- commonFunction_error2writeFileQ : 에러큐에 전문을 쓰는 함수
		- innerFunction_flattenFileQueueData : 파일큐에 적재할 전문 생성하는 함수
	- commonFunction_parseErrorMassgeV200 : 에러큐에 쓰는 결과내용 파싱 함수 (200byte)
	- commonFunction_requestGet4ResultList : biz센터 GET요청 후 결과전문 목록 파싱 함수
		- innerFunction_requestGetResponseMap : biz센터 GET요청 함수
	- commonFunction_requestHttp4ResultMap : biz센터 요청 후 결과전문 반환해주는 함수
		- innerFunction_inputValidation: 함수 인자값에 대한 빈값체크 함수
	- commonFunction_getRequestHeaderMap : HTTP요청을 위한 전문헤더 생성하는 함수

-->
<#--  범용성을 위해서 SQL쿼리에 DBMS 전용 쿼리는 사용하지 않도록 한다.  -->

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>


<#--  인증정보 테이블에서 데이터를 조회하여 발신프로필정보 세팅  -->
<#function commonFunction_getProfileKeyInfoMap _sqlConn>

    <#--  발신프로필정보 조회 쿼리  -->
    <#local selecProfileKeyInfoQuery = m1.shareget("selecProfileKeyInfoQuery")!""/>

    <#local profileKeyInfoMap = m1.editable({})/>

	<#local resultCode = "200"/>
	<#local resultMessage = "성공"/>

    <#--  발신프로필정보를 조회하여 인증에 필요한 정보 세팅  -->
    <#local r = m1.log("[INIT][CHANNEL_ID] 발신프로필정보 DB조회.", "INFO")/>

    <#local profileKeyInfoRs = _sqlConn.query2array(selecProfileKeyInfoQuery, {})/>
    <#if (profileKeyInfoRs?size > 0)>
        <#list profileKeyInfoRs as profileKeyInfo>
            <#if !profileKeyInfo?has_content>
                <#local r = m1.log("[INIT][CHANNEL_ID][ERR] 조회된 데이터 없음.", "ERROR")/>
            </#if>
            
            <#local profileKey = profileKeyInfo["CHANNEL_ID"]/>
            <#local clientId = profileKeyInfo["AUTH_ID"]/>
            <#local clientSecret = profileKeyInfo["AUTH_KEY"]/>

            <#local expireYn = profileKeyInfo["EXPIRE_YN"]!"N"/>
            <#if expireYn?has_content && expireYn?upper_case == "Y">
                <#local r = m1.log("[INIT][CHANNEL_ID][EXPIRED] 차단상태의 발신프로필키. @발신프로필키=[${profileKey}]", "ERROR")/>
				<#local resultCode = "501"/>
				<#local resultMessage = "차단상태의 발신프로필키. 발신프로필키=[${profileKey}]"/>

                <#break/>
            </#if>

            <#local rejectYn = profileKeyInfo["REJECT_YN"]!"N"/>
            <#if  rejectYn?has_content && rejectYn?upper_case == "Y">
                <#local r = m1.log("[INIT][CHANNEL_ID][REJECT] 휴면상태의 발신프로필키. @발신프로필키=[${profileKey}]", "ERROR")/>
				<#local resultCode = "501"/>
				<#local resultMessage = "휴면상태의 발신프로필키. 발신프로필키=[${profileKey}]"/>

                <#break/>
            </#if>

            <#--  발신프로필키정보 세팅  -->
            <#local r = profileKeyInfoMap.put(profileKey, {
                "clientId": clientId
                , "clientSecret": clientSecret
            })/>

        </#list>
        <#local r = m1.log("[INIT][CHANNEL_ID] 발신프로필정보 세팅 완료. ", "INFO")/>

    <#else>
        <#local r = m1.log("[INIT][CHANNEL_ID] DB에 발신프로필정보 없음. properties파일에 설정된 인증정보로 발신프로필정보 세팅....", "INFO")/>

        <#local channelListString = m1props.getProperty("templateManage.api.channelList", "")?trim/>

        <#if channelListString != "">
            <#local channelInfoList = channelListString?split(",")/>
            <#list channelInfoList as channelString>
                <#local r = m1.log("[INIT] properties파일 설정 로딩. @채널목록=[${channelString}]","INFO")/>
                <#local channelInfo = channelString?split("*^*")/>

                <#local profileKey = channelInfo[0]!""/>
                <#if profileKey != "">
                    <#local r = profileKeyInfoMap.put(profileKey, {
                            "clientId": channelInfo[1]!"",
                            "clientSecret": channelInfo[2]!""
                        }
                    )/>
                </#if>

            </#list>

            <#local r = m1.log("[INIT][CHANNEL_ID] properties파일을 통한 발신프로필정보 세팅 완료.", "INFO")/>
        <#else>
            <#local r = m1.log("[INIT][ERR] properties파일 설정 없음.", "INFO")/>

			<#local resultCode = "501"/>
			<#local resultMessage = "properties파일 설정 없음"/>

        </#if>

    </#if>
    <#local r = m1.log(profileKeyInfoMap, "DEBUG")/>

	<#local r = _sqlConn.close(profileKeyInfoRs)/>

    <#return {
		"code": resultCode
		, "message": resultMessage
		, "data": profileKeyInfoMap
	}/> 
	
</#function>


<#--  
	biz센터에서 발급받은 토큰정보를 메모리에 등록하는 함수
	parameter
		- channelList: {
			발신프로필키: {
				"clientId": 인증정보
				, "clientSecret": 인증키
			}
		}
	return
		- {
			"code": 결과코드
			, "message": 결과내용
		}
-->
<#function commonFunction_getTokenInfo4Memory channelList>
	<#--  비즈톡의 경우 토큰을 사용하지 않고 사전에 발급받은 인증정보를 사용하여 api요청으로 인해 토큰발급 불필요  -->
	<#local result = {
		"code": "600"
		, "message": "미지원 함수"
	}/>

	<#return result/>
</#function>

<#--
	채널정보를 받아서 biz센터에 토큰발급받는 함수
	parameter
		- channelList: {
			"clientId": 인증정보
			, "clientSecret": 인증키
		}
	return
		- {
			"code": 결과코드
			, "message": 결과내용
			, "data": {
				"accessToken": 토큰정보
				, "expiredIn": 만료시간
			}
		}
-->
<#function commonFunction_requestTokenInfo channelInfo>
	<#--  비즈톡의 경우 토큰을 사용하지 않고 사전에 발급받은 인증정보를 사용하여 api요청으로 인해 토큰발급 불필요  -->
	<#local result = {
		"code": "600"
		, "message": "미지원 함수"
	}/>

	<#return result/>

</#function>

<#--  
	템플릿동기화 함수  
		- biz센터의 템플릿정보를 조회하여 DB처리하는 함수
	parameter
		- channelList: 
	return
		- {
			"code": 결과코드
			, "message": 결과내용
		}
-->
<#function commonFunction_templateSync2Database>
    <#--  비즈톡의 경우 템플릿목록 조회가 불가하여 비즈톡센터에 등록되어 있는 템플릿을 조회할 수 없어서 동기화기능 미지원  -->
	<#local result = {
		"code": "600"
		, "message": "미지원 함수"
	}/>

	<#return result/>
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


<#-- 에러큐에 전문을 쓰는 함수 -->
<#function commonFunction_error2writeFileQ _fq _seqLocal _errorCode _errorMsg _procName _targetFileQueueName>
    <#--return(1: 처리, -1: 재시도, -9:시스템 종료)-->
	<#local clear = 1/>
	<#local retry = -1/>
	<#local systemExit = -9/>

    <#-- 실패처리  -->
	<#--  결과내용은 컬럼사이즈를 고려하여 200byte까지 잘라서 적재  -->
    <#local fail_bodyMap = {
        "TM_SEQ": _seqLocal
        , "apiResult": {
            "error": {
                "code": _errorCode,
                "message": m1.byteLenString(_errorMsg, 200)
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

<#--  함수 인자값에 대한 빈값체크 함수  -->
<#function innerFunction_inputValidation _checkParamMap>

	<#list _checkParamMap as field, value>
		<#if
			((value?is_hash || value?is_hash_ex) && !value?has_content )
			|| 
			(value?is_string && value == "")
		>
			<#local r = m1.log("[BIZ][REQ][ERR] ${field} 없음. @${field}=[${m1.toJsonBytes(value)}]", "ERROR")/>

			<#return {
				"code": "750"
				, "message": "${field} 없음."
			}/>
		</#if>

	</#list>

	<#return {
		"code": "200"
		, "message": "성공"
	}/>
</#function>

<#--  biz센터 POST요청 함수  -->
<#function commonFunction_requestHttp4ResultMap _requestUrl _methodType _headerMap _urlParamMap _payloadMap _uploadFileMap>
	<#--  http요청시 필수값에 대한 인자값 체크 함수  -->
	<#local validationData =   innerFunction_inputValidation({
		"요청URL": _requestUrl
		, "요청method": _methodType
		, "요청헤더": _headerMap
		, "요청바디": _payloadMap
	})/>
	<#local validationCode = validationData.code!"999"/>

	<#if validationCode != "200">
		<#local validationMsg = validationData.message!"기타오류"/>
		<#return {
			"code": validationCode
			, "message": validationMsg
		}/>
	<#else>
	</#if>

	<#--
		비즈톡의 경우 POST메서드 요청
		- body부분의 경우 urlEncoding으로 parameter를 전달해야 정상적으로 처리 됨.
	-->
	<#assign httpResponse = httpRequest.requestHttp(_requestUrl, "POST", _headerMap, _urlParamMap, _payloadMap, _uploadFileMap, false)/>

	<#assign responseCode = httpResponse.getResponseCode()/>
	<#assign succBody = httpResponse.getBody()/>
	<#assign errBody = httpResponse.getErrorBody()/>

	<#if responseCode != 200 && errBody != "">
		<#assign httpResponseBody = errBody/>
	<#else>
		<#assign httpResponseBody = succBody/>
	</#if>

	<#return {
		"code": "200"
		, "message": "성공"
		, "data": httpResponseBody
	}/>

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

		<#return {
			"code": "719"
			, "message": "발신프로필키에 매핑되는 인증정보 없음."
		}/>
	</#if>

	<#local siteId = channelInfo.clientId!""/>
	<#local authKey = channelInfo.clientSecret!""/>
    
	<#-- 기본 헤더정보 정의  -->
	<#--  
		비즈톡의 경우 body에 값을 넣어서 요청할 경우의 Content-Type 정의
		- application/x-www-form-urlencoded
		- multipart/form-data
	-->
	<#local r = m1.put(headerMap, "Content-Type", "application/x-www-form-urlencoded; charset=utf-8")/>
	<#local r = m1.put(headerMap, "Accept", "application/json, */*")/>
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
	<#local r = m1.log(headerMap, "DEBUG")/>

    <#return {
		"code": "200"
		, "message": "성공"
		, "header": headerMap	
	}/>
</#function>
