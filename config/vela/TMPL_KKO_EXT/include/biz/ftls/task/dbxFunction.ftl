<#-- 템플릿요청 공통함수 -->
<#--  <#include "../../../request.include_function.ftl"/>  -->

<#--
    함수목록
        - taskDbxFunction_parseRequest2ExecuteParamMap: 검수요청 DB처리 전문 파싱 함수
        - taskDbxFunction_parseResponse2ExecuteParamMap: 검수결과 DB처리 전문 파싱 함수
-->


<#function taskDbxFunction_parseRequest2ExecuteParamMap _seqLocal _apiResult>

    <#local r = m1.log("[DBX][REQUEST] 검수요청 DB처리 전문 파싱. @SEQ=[${_seqLocal}]", "INFO")/>
    <#local r = m1.log(_apiResult, "DEBUG")/>

	<#local executeParamMap = m1.editable({})/>

    <#local templateUseYn = "N"/>

    <#local resultCode = _apiResult.code!""/>
    <#local resultReason = _apiResult.message!"기타에러"/>

    <#--  API 응답전문 파싱  -->
    <#if
        _apiResult?has_content
        && resultCode?has_content
        && resultCode == "200"
    >
        <#--  성공건에 대한 데이터 파싱  -->

        <#local step = "3">
        <#local resultReason = "승인대기"/>

        <#local r = executeParamMap.put("승인요청일시", ymdhms)/>
    <#else>
        <#--검수 요청 실패-->
        <#if _apiResult.error?has_content>
            <#local errorBody = _apiResult.error!{}/>

            <#local resultCode = errorBody.code!"9999"/>
            <#local resultReason = errorBody.message!"기타에러"/>

        </#if>

        <#local step = "5">

        <#local r = executeParamMap.merge({
            "승인요청일시": ymdhms
            , "처리일시": ymdhms
        }, "true")/>

    </#if>

    <#--  검수요청 전문 추가 파싱  -->
    <#return executeParamMap.merge({
		"SEQ": _seqLocal
		, "처리결과내용": resultReason
		, "검수결과코드": resultCode
		, "검수처리단계": step
		, "템플릿사용여부": "N"
	}, "true")/>

    <#local r = m1.log("[DBX][REQUEST] 검수요청 DB처리 전문 파싱 완료. @SEQ=[${_seqLocal}]", "INFO")/>
    <#local r = m1.log(executeParamMap, "INFO")/>

</#function>

<#function taskDbxFunction_parseResponse2ExecuteParamMap _seqLocal _apiResult _responseBody>

    <#local r = m1.log("[DBX][RESULT] 검수결과 DB처리 전문 파싱. @SEQ=[${_seqLocal}]", "INFO")/>
    <#local r = m1.log(_apiResult, "DEBUG")/>

    <#local executeParamMap = m1.editable({})/>

    <#local resultCode = _apiResult.code!"799999"/>
    <#local apiResultReason = m1.decode(_apiResult.approvalResult!"", "", "기타에러", _apiResult.approvalResult)/>
    
    <#local step = m1.decode(resultCode, "200", "4", "5")/>
    <#local templateUseYn = m1.decode(resultCode, "200", "Y", "N")/>

    <#if _apiResult.approvalDate?has_content>
        <#local approvalDate = m1.replaceAll(_apiResult.approvalDate, "[-T:]", "")?keep_before_last(".") />

    <#else>
        <#local approvalDate = ymdhms/>
    </#if>

    <#--  검수결과 전문 추가 파싱  -->
    <#return executeParamMap.merge({
		"SEQ": _seqLocal
		, "처리결과내용": apiResultReason
		, "검수결과코드": resultCode
		, "검수처리단계": step
		, "템플릿사용여부": templateUseYn
		, "처리일시": approvalDate
	}, "true")/>

    <#local r = m1.log("[DBX][RESULT] 검수요청 DB처리 전문 파싱 완료. @SEQ=[${_seqLocal}]", "INFO")/>
    <#local r = m1.log(executeParamMap, "INFO")/>

</#function>