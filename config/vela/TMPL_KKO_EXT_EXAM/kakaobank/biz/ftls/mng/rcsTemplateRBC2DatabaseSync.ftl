<#--  RBC센터 조회하여 베이스폼ID정보 동기화처리  -->

<#-- 함수 include -->
<#include "../../../request.include_function.ftl"/>

<#assign m1props = m1.statics["com.odinues.m1.util.ClassProperties"].global/>

<#assign tmplMngrUrl = m1props.getProperty("templateManage.api.url", "")?trim/>

<#assign selectBrandIdInfoQuery = m1.loadText("../../sql/common/selectBrandInfo.sql")!""/>

<#assign selectRcsTemplateQuery = m1.loadText("../../sql/mng/rcsTemplateSyncQuery/selectRcsTemplate.sql")!""/>
<#assign insertRcsTemplateQuery =  m1.loadText("../../sql/mng/rcsTemplateSyncQuery/insertRcsTemplate.sql")!""/>
<#assign updateRcsTemplateQuery = m1.loadText("../../sql/mng/rcsTemplateSyncQuery/updateRcsTemplate.sql")!""/>

<#assign selectClientInfoQuery = m1.loadText("../../sql/common/selectClientInfo.sql")!""/>

<#assign sqlConn = m1.new("sql")/>

<#assign r = m1.log("[CONF][RCS_TMPL][SYNC][START] 승인템플릿 동기화처리 시작.", "INFO")/>

<#--  API-KEY 정보를 가져다가 브랜드ID목록 세팅  -->
<#assign clientInfoList = m1.shareget("clientInfoList")![]/>
<#if !clientInfoList?has_content>
    <#assign r = m1.log("[CONF][RCS_TMPL][ERR] API-KEY정보 없음.... 처리 종료.", "ERROR")/>

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
                <#--  베이스ID를 DB에서 조회하여 브랜드ID세팅  -->
                <#assign brandIdRs = sqlConn.query2array(selectBrandIdInfoQuery, {})/>
                <#if (brandIdRs?size > 0)>

                    <#list brandIdRs as row>
                        <#assign brandId = row["BR_ID"]!""/>

                        <#assign brandIdSyncParamMap = {
                            "token": token
                            ,"sqlConn": sqlConn
                            , "query": {
                                "selectQuery": selectRcsTemplateQuery
                                , "updateQuery": updateRcsTemplateQuery
                                , "insertQuery": insertRcsTemplateQuery
                            }
                            , "requestUrl": "${tmplMngrUrl}/brand/${brandId}/messagebase"
                        }/>

                        <#--  RBC센터 베이스ID조회  -->
                        <#assign resultMap = commonFunction_rbc2dbSync("RCS_TMPL", brandIdSyncParamMap)/>

                        <#if resultMap?has_content && resultMap.code == "200">
                            <#assign r = m1.log("[CONF][RCS_TMPL][SYNC][${row_index}][SUCC] 승인템플릿 동기화 성공. @브랜드ID=[${brandId}]", "INFO")/>

                        <#else>
                            <#assign r = m1.log("[CONF][RCS_TMPL][SYNC][${row_index}][FAIL] 승인템플릿 동기화 실패. @브랜드ID=[${brandId}]", "ERROR")/>

                        </#if>
                    </#list>
                <#else>
                    <#assign r = m1.log("[CONF][RCS_TMPL][DB][ERR] 브랜드ID정보 없음.", "ERROR")/>
                </#if>

                <#assign r = sqlConn.close()/>
            </#if>
        <#else>
            <#assign r = m1.log("[CONF][RCS_TMPL][DB][ERR] API-KEY정보 없음.", "ERROR")/>

        </#if>

    </#list>
</#if>