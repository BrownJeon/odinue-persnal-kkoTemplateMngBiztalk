<#-- 함수 include -->
<#include "../../../request.include_function.ftl"/>

<#assign selectMessagebaseIdQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectMessagebaseId.sql")!""/>
<#assign selectBrandIdQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectBrandId.sql")!""/>
<#assign selectRcsTemplateQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectRcsTemplate.sql")!""/>
<#assign deleteRcsTemplateQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/deleteRcsTemplate.sql")!""/>

<#assign sqlConn = m1.new("sql")/>


<#-- 베이스ID를 입력받으면 하나의 베이스ID를 처리 -->
<#assign msgbaseIdCommand = m1.sysenv["MESSAGEBASE_ID"]!"" />
<#if !msgbaseIdCommand?has_content>
    <#assign r = m1.log("[TMPL][DELETE][ERR] 인자값을 입력해야 합니다.", "ERROR")/>

<#else>
    <#assign r = m1.log("[TMPL][DELETE][START] RCS템플릿 삭제작업 시작....", "INFO")/>

    <#--  API-KEY 정보를 가져다가 브랜드ID목록 세팅  -->
    <#assign clientInfoList = m1.shareget("clientInfoList")![]/>
    <#if !clientInfoList?has_content>
        <#assign r = m1.log("[TMPL][DELETE][ERR] API-KEY정보 없음.... 처리 종료.", "ERROR")/>

    <#else>
        <#list clientInfoList as clientInfo>
            <#assign clientId = clientInfo.clientId!""/>
            <#assign clientSecret = clientInfo.clientSecret!""/>

            <#assign token = getToken(httpObj, tmplMngrUrl, clientId, clientSecret)/>

            <#assign header = {
                "Content-Type" : "application/json; charset=utf-8",
                "Accept" : "application/json, text/plain, */*",
                "Authorization" : "Bearer ${token}"
            }/>

            <#if msgbaseIdCommand?upper_case == "ALL">

                <#assign arrList = m1.editable([])/>

                <#assign selectMsgIdRs = sqlConn.query2array(selectMessagebaseIdQuery, {
                    "검수상태": "3"
                    , "검수결과코드": "20000000"
                })/>
                <#list selectMsgIdRs as row>
                    <#assign r = arrList.put(row.TEMPLATE_ID!"")/>
                </#list>

                <#assign r = sqlConn.close(selectMsgIdRs)/>

            <#else>
                <#assign arrList = [msgbaseIdCommand]/>

            </#if>

            <#list arrList as messagebaseId>
                <#--  베이스ID를 템플릿테이블에서 조회하여 브랜드ID를 가져오기  -->
                <#assign brandIdRs = sqlConn.query2array(selectBrandIdQuery, {
                    "베이스ID": messagebaseId
                })/>

                <#--  DB에서 조회한 데이터에서 브랜드ID를 세팅  -->
                <#if brandIdRs?has_content>
                    <#assign brandId = brandIdRs[0]["CHANNEL_ID"]!""/>
                <#else>
                    <#assign brandId = ""/>
                </#if>

                <#assign requestTemplateCancelUrl = "${tmplMngrUrl}/brand/${brandId}/messagebase/${messagebaseId}/cancel"/>

                <#assign r = m1.log("[TMPL][DELETE][RBC][CANCEL] 템플릿 검수취소 요청. @요청URL=[${requestTemplateCancelUrl}]", "INFO")/>

                <#assign httpTemplateCancelResponseCode = httpObj.request(requestTemplateCancelUrl, "PUT", "", header)!-1/>
                <#if httpObj.responseData?has_content>
                    <#assign httpTemplateCancelResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>
                <#else>
                    <#assign httpTemplateCancelResponseBody = ""/>
                </#if>

                <#if httpTemplateCancelResponseCode != 200>
                    <#assign r = m1.log("[TMPL][DELETE][RBC][CANCEL] 템플릿 검수취소 실패. @응답코드=[${httpTemplateCancelResponseCode}]", "ERROR")/>
                    <#assign r = m1.log(httpTemplateCancelResponseBody, "ERROR")/>

                <#else>
                    <#assign requestTemplateDeleteUrl = "${tmplMngrUrl}/brand/${brandId}/messagebase/${messagebaseId}"/>

                    <#assign r = m1.log("[TMPL][DELETE][RBC][DELETE] 템플릿 삭제 요청. @요청URL=[${requestTemplateDeleteUrl}]", "INFO")/>

                    <#assign httpTemplateDeleteResponseCode = httpObj.request(requestTemplateDeleteUrl, "DELETE", "", header)!-1/>
                    <#assign httpTemplateDeleteResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>

                    <#if httpTemplateDeleteResponseCode != 200>
                        <#assign r = m1.log("[TMPL][DELETE][RBC][DELETE] 템플릿삭제 실패. @응답코드=[${httpTemplateDeleteResponseCode}]" , "ERROR")/>
                        <#assign r = m1.log(httpTemplateDeleteResponseBody, "ERROR")/>
                    <#else>
                        <#-- 템플릿 검수요청 취소 & 삭제 완료되어 DB데이터 삭제처리 -->
                        <#assign r = m1.log("[TMPL][DELETE][BRC][DELETE] 템플릿삭제 성공. @응답코드=[${httpTemplateDeleteResponseCode}]", "INFO")/>
                        <#assign r = m1.log(httpTemplateDeleteResponseBody, "DEBUG")/>

                        <#-- 템플릿정보 조회 -->
                        <#assign selectRcsTemplateRs = sqlConn.query2array(selectRcsTemplateQuery, {
                            "베이스ID": messagebaseId
                        })/>

                        <#if (selectRcsTemplateRs?size > 0)>
                            <#assign r = m1.log("[TMPL][DELETE][DB][SELECT] 검수취소 템플릿 DB데이터 조회 완료. @베이스ID=[${messagebaseId}]", "INFO")/>
                            <#list selectRcsTemplateRs as row>
                                <#assign r = m1.log(row, "DEBUG")/>

                                <#assign seq = row["TM_SEQ"]!"-1"/>

                                <#--  조회된 템플릿정보가 있으면 템플릿삭제  -->
                                <#--  통합승인테이블의 경우 통합승인테이블, RCS승인테이블의 데이터를 삭제해야하므로 삭제쿼리를 여러번 실행할 수 있도록 처리  -->
                                <#assign deleteQueryList = deleteRcsTemplateQuery?split("#DELIM")/>

                                <#list deleteQueryList as deleteQuery>
                                    <#assign rs = sqlConn.execute(deleteQuery, {
                                        "SEQ": seq
                                    })/>

                                    <#if (rs >= 0)>
                                        <#assign r = m1.log("[TMPL][DELETE][DB][DELETE][${deleteQuery_index}][SUCC] DB데이터 삭제 성공. @SEQ=[${seq}]", "INFO")/>

                                    <#else>
                                        <#assign r = m1.log("[TMPL][DELETE][DB][DELETE][${deleteQuery_index}][FAIL] DB데이터 삭제 실패. @SEQ=[${seq}] @처리결과=[${rs}]", "ERROR")/>

                                        <#assign r = sqlConn.rollback()/>
                                        <#break/>

                                    </#if>

                                </#list>
                            </#list>

                        <#else>
                            <#assign r = m1.log("[TMPL][DELETE][DB][SELECT] DB데이터 없음. @베이스ID=[${messagebaseId}]", "INFO")/>
                        </#if>

                        <#assign r = sqlConn.close(selectRcsTemplateRs)/>

                        <#assign r = sqlConn.commit()/>
                    </#if>
                </#if>
            </#list>
            
        </#list>
    </#if>
</#if>

<#assign r = sqlConn.close()/>

<#assign r = m1.log("[TMPL][DELETE][END] RCS템플릿 삭제작업 종료....", "INFO")/>


<#-- 토큰정보 조회 -->
<#function getToken _httpObj _tmplMngrUrl _clientId _clientSecret>

    <#local token = ""/>

    <#local header = {
            "Content-Type" : "application/json; charset=utf-8",
            "Accept" : "application/json, text/plain, */*"
    }/>
    <#local payloadMap = {
            "clientId" : _clientId
            , "clientSecret" : _clientSecret
    }/>

    <#local r = m1.log("[TMPL][RBC][TOKEN] 토큰발급 요청. @clientId=[${_clientId}]", "INFO")/>

    <#local payload = m1.toJsonBytes(payloadMap)?string/>
    <#local bcbytes = m1.getBytes(payload, "UTF-8")/>
    
    <#local httpResponseCode=_httpObj.post("${_tmplMngrUrl}/token", bcbytes, 0, bcbytes?size, header)!-1/>
    <#local httpResponseBody = m1.getString(_httpObj.responseData, "UTF-8")/>

    <#local r = m1.log("[TMPL][RBC][TOKEN] 토큰발급 완료. @응답코드=[${httpResponseCode}]", "INFO")/>
    <#local r = m1.log(httpResponseBody, "DEBUG")/>
    
    <#local responseBody = m1.parseJsonValue(httpResponseBody)/>
    
    <#local token = responseBody.accessToken/>

    <#return token/>
    
</#function>