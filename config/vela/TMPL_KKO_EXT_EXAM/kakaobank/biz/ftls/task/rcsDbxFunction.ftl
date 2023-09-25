<#-- 템플릿요청 공통함수 -->
<#include "../../../request.include_function.ftl"/>

<#assign updateTemplateRbcFormParamQuery = m1.session("updateTemplateRbcFormParamQuery")/>

<#function taskDbxFunction_parseRequest2ExecuteParamMap _seqLocal _sqlConn _apiResult _responseBody>

	<#local executeParamMap = m1.editable({})/>

    <#local templateUseYn = ""/>
    <#local messagebaseId = ""/>

    <#local apiResultCode = _apiResult.code!"799999"/>
    <#if apiResultCode == "20000000">
        <#--성공-->
        <#local step = "3">
        <#local resultStatus = "승인대기"/>
        <#local resultCode = apiResultCode/>
        <#local apiResultReason = _apiResult.message!""/>
        <#local messagebaseId = _apiResult.result[0]["messagebaseId"]!""/>

        <#local r = executeParamMap.put("승인요청일시", ymdhms)/>
        
        <#-- 
            RBC센터에 검수요청 한 템플릿에 대해 상세조회 후 formattedString객체 생성
            api버전에 따라서 요청전문의 규격이 달라서 버전에 따라서 brandId파싱에 대한 로직 분리 
        -->
        <#local apiVersion = m1.shareget("apiVersion")/>
        <#if apiVersion == "v2">
            <#local brandId = _responseBody.brandId!""/>
        <#else>
            <#local regMessagebases = _responseBody.regMessagebases![]/>
            <#if regMessagebases?has_content>
                <#local brandId = regMessagebases[0].brandId!""/>
            <#else>
                <#local brandId = ""/>
            </#if>
            
        </#if>

        <#-- 
            RBC센터 템플릿상세조회 api요청
            브랜드ID가 세팅되지 않았을 경우 formmatedString처리 하지 않고 검수처리 결과만 DB처리 
        -->
        <#if brandId?has_content>
            <#local tokenInfoMap = m1.shareget(brandId)/>
            <#local token = tokenInfoMap.accessToken/>

            <#local r = m1.log("[DBX][REQ][TMPL][RBC][SELECT] formattedString전문 DB처리를 위한 RBC센터 템플릿상세조회 요청. @SEQ=[${_seqLocal}] @브랜드ID=[${brandId}] @베이스ID=[${messagebaseId}]", "INFO")/>
            
            <#local templateDetailResultMap = commonFunction_requestGet4ResultMap(token, "${tmplMngrUrl}/brand/${brandId}/messagebase/${messagebaseId}")!-1/>
            <#if templateDetailResultMap?has_content && templateDetailResultMap.formattedString?has_content>
                <#local rbcFormattedStringMap = templateDetailResultMap.formattedString!"{}"/>
                <#local r = m1.log(rbcFormattedStringMap, "DEBUG")/>

                <#-- formattedString규격 DB처리 -->
                <#if rbcFormattedStringMap?has_content>
                    <#-- CLOB 데이터 update시 CLOB컬럼만 update처리해야 함. 다른 컬럼과 함께 update시 에러 발생(java.io.FileNotFoundException) -->
                    <#local updateRs = _sqlConn.execute(updateTemplateRbcFormParamQuery, {
                        "SEQ": _seqLocal
                        , "전문바디": rbcFormattedStringMap
                    })/>

                    <#if (updateRs >= 0)>
                        <#local r= m1.log("[DBX][DB][RESULT] 베이스폼 데이터 UPDATE처리 성공. @SEQ=[${_seqLocal}]", "INFO")/>

                    <#else>
                        <#local r= m1.log("[DBX][DB][RESULT] 베이스폼 데이터 UPDATE처리 실패. @SEQ=[${_seqLocal}] ", "ERROR")/>
                        <#local r= m1.log(rbcFormattedStringMap, "ERROR")/>

                    </#if>
                </#if> 

            </#if>
        </#if>
    <#else>
        <#--검수 요청 실패-->
        <#local step = "5">
        <#local resultStatus = "반려"/>
        <#local resultCode = _apiResult.error.code!"799999"/>
        <#local apiResultReason = _apiResult.error.message/>
        <#local templateUseYn = "N"/>
        
        <#local r = executeParamMap.merge({
            "승인요청일시": ymdhms
            , "처리일시": ymdhms
        }, "true")/>

        <#-- 검수요청 실패의 경우 forrmatedString처리하지 않음 -->
    </#if>

    <#return executeParamMap.merge({
		"SEQ": _seqLocal
		, "베이스ID": messagebaseId
		, "처리결과내용": apiResultReason
		, "검수결과코드": resultCode
		, "검수처리단계": step
		, "템플릿사용여부": templateUseYn
        , "검수상태": resultStatus
	}, "true")/>

</#function>

<#function taskDbxFunction_parseResponse2ExecuteParamMap _seqLocal _apiResult _responseBody>

    <#local executeParamMap = m1.editable({})/>

    <#local messagebaseId = _responseBody.MESSAGEBASE_ID!""/>

    <#local resultCode = _apiResult.code!"799999"/>
    <#local apiResultReason = m1.decode(_apiResult.approvalResult!"", "", "기타에러", _apiResult.approvalResult)/>
    
    <#local step = m1.decode(resultCode, "20000000", "4", "5")/>
    <#local resultStatus = m1.decode(resultCode, "20000000", "승인", "반려")/>
    <#local templateUseYn = m1.decode(resultCode, "20000000", "Y", "N")/>

    <#if _apiResult.approvalDate?has_content>
        <#local approvalDate = m1.replaceAll(_apiResult.approvalDate, "[-T:]", "")?keep_before_last(".") />

    <#else>
        <#local approvalDate = ymdhms/>
    </#if>

    <#return executeParamMap.merge({
		"SEQ": _seqLocal
		, "베이스ID": messagebaseId
		, "처리결과내용": apiResultReason
		, "검수결과코드": resultCode
		, "검수처리단계": step
		, "템플릿사용여부": templateUseYn
		, "처리일시": approvalDate
		, "검수상태": resultStatus
	}, "true")/>

</#function>