<#--  RBC센터 조회하여 챗봇ID정보 동기화처리  -->

<#-- 함수 include -->
<#include "../../../request.include_function.ftl"/>

<#assign selectBrandIdQuery = m1.loadText("../../sql/common/selectBrandInfo.sql")!""/>

<#assign selectChatbotIdQuery = m1.loadText("../../sql/mng/chatbotIdSyncQuery/selectChatbotId.sql")!""/>
<#assign insertChatbotIdQuery =  m1.loadText("../../sql/mng/chatbotIdSyncQuery/insertChatbotId.sql")!""/>
<#assign updateChatbotIdQuery = m1.loadText("../../sql/mng//chatbotIdSyncQuery/updateChatbotId.sql")!""/>

<#assign sqlConn = m1.new("sql")/>

<#assign r = m1.log("[CONF][CHATBOT_ID][SYNC][START] 승인템플릿 동기화처리 시작.", "INFO")/>

<#--  API-KEY 정보를 가져다가 브랜드ID목록 세팅  -->
<#assign clientInfoList = m1.shareget("clientInfoList")![]/>
<#if !clientInfoList?has_content>
    <#assign r = m1.log("[CONF][CHATBOT_ID][ERR] API-KEY정보 없음.... 처리 종료.", "ERROR")/>

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
                <#assign brandIdRs = sqlConn.query2array(selectBrandIdQuery, {})/>
                <#if brandIdRs?has_content>

                    <#list brandIdRs as row>
                        <#assign brandId = row["BR_ID"]!""/>

                        <#assign chatbotIdSyncParamMap = {
                            "token": token
                            , "sqlConn": sqlConn
                            , "query": {
                                "selectQuery": selectChatbotIdQuery
                                , "updateQuery": updateChatbotIdQuery
                                , "insertQuery": insertChatbotIdQuery
                            }
                            , "requestUrl": "${tmplMngrUrl}/brand/${brandId}/chatbot?limit=10"
                        }/>

                        <#--  RBC센터 베이스ID조회  -->
                        <#assign resultMap = commonFunction_rbc2dbSync("CHATBOT_ID", chatbotIdSyncParamMap)/>

                        <#if resultMap?has_content && resultMap.code == "200">
                            <#assign r = m1.log("[CONF][CHATBOT_ID][SYNC][${row_index}][SUCC] 승인템플릿 동기화 성공. @브랜드ID=[${brandId}]", "INFO")/>

                        <#else>
                            <#assign r = m1.log("[CONF][CHATBOT_ID][SYNC][${row_index}][FAIL] 승인템플릿 동기화 실패. @브랜드ID=[${brandId}]", "ERROR")/>

                        </#if>
                    </#list>
                <#else>
                    <#assign r = m1.log("[CONF][CHATBOT_ID][DB][ERR] 브랜드ID정보 없음.", "ERROR")/>
                </#if>

                <#assign r = sqlConn.close()/>
            </#if>
        <#else>
            <#assign r = m1.log("[CONF][CHATBOT_ID][DB][ERR] API-KEY정보 없음.", "ERROR")/>
        </#if>

    </#list>
</#if>