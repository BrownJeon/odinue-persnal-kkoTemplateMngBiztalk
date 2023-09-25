<#--  RBC센터 조회하여 공통템플릿정보 동기화처리  -->

<#-- 함수 include -->
<#include "../../../request.include_function.ftl"/>

<#assign m1props = m1.statics["com.odinues.m1.util.ClassProperties"].global/>

<#assign tmplMngrUrl = m1props.getProperty("templateManage.api.url", "")?trim/>

<#assign selectCommonTemplateQuery = m1.loadText("../../sql/mng/commonTemplateSyncQuery/selectCommonTemplate.sql")!""/>
<#assign insertCommonTemplateQuery =  m1.loadText("../../sql/mng/commonTemplateSyncQuery/insertCommonTemplate.sql")!""/>
<#assign updateCommonTemplateQuery = m1.loadText("../../sql/mng/commonTemplateSyncQuery/updateCommonTemplate.sql")!""/>

<#assign sqlConn = m1.new("sql")/>

<#assign r = m1.log("[CONF][COMMON_TMPL][SYNC][START] 공통템플릿 동기화처리 시작.", "INFO")/>

<#--  API-KEY 정보를 가져다가 브랜드ID목록 세팅  -->
<#assign clientInfoList = m1.shareget("clientInfoList")![]/>
<#if !clientInfoList?has_content>
    <#assign r = m1.log("[CONF][COMMON_TMPL][ERR] API-KEY정보 없음.... 처리 종료.", "ERROR")/>

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
                <#assign commonTemplateSyncParamMap = {
                    "token": token
                    , "sqlConn": sqlConn
                    , "query": {
                        "selectQuery": selectCommonTemplateQuery
                        , "updateQuery": updateCommonTemplateQuery
                        , "insertQuery": insertCommonTemplateQuery
                    }
                    , "requestUrl": "${tmplMngrUrl}/messagebase/common"
                }/>

                <#--  RBC센터 베이스ID조회  -->
                <#assign resultMap = commonFunction_rbc2dbSync("COMMON_TMPL", commonTemplateSyncParamMap)/>

                <#if resultMap?has_content && resultMap.code == "200">
                    <#assign r = m1.log("[CONF][COMMON_TMPL][SYNC][SUCC] 공통템플릿 동기화 성공.", "INFO")/>

                <#else>
                    <#assign r = m1.log("[CONF][COMMON_TMPL][SYNC][FAIL] 공통템플릿 동기화 실패.", "ERROR")/>

                </#if>

                <#assign r = sqlConn.close()/>
            </#if>
        <#else>
            <#assign r = m1.log("[CONF][COMMON_TMPL][DB][ERR] API-KEY정보 없음.", "ERROR")/>
        </#if>

    </#list>
</#if>