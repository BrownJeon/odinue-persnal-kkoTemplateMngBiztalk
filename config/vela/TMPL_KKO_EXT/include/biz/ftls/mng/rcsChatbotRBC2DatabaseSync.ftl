<#--  RBC���� ��ȸ�Ͽ� ê��ID���� ����ȭó��  -->

<#-- �Լ� include -->
<#include "../../../request.include_function.ftl"/>

<#assign selectBrandIdQuery = m1.loadText("../../sql/common/selectBrandInfo.sql")!""/>

<#assign selectChatbotIdQuery = m1.loadText("../../sql/mng/chatbotIdSyncQuery/selectChatbotId.sql")!""/>
<#assign insertChatbotIdQuery =  m1.loadText("../../sql/mng/chatbotIdSyncQuery/insertChatbotId.sql")!""/>
<#assign updateChatbotIdQuery = m1.loadText("../../sql/mng//chatbotIdSyncQuery/updateChatbotId.sql")!""/>

<#assign sqlConn = m1.new("sql")/>

<#assign r = m1.log("[CONF][CHATBOT_ID][SYNC][START] �������ø� ����ȭó�� ����.", "INFO")/>

<#--  API-KEY ������ �����ٰ� �귣��ID��� ����  -->
<#assign clientInfoList = m1.shareget("clientInfoList")![]/>
<#if !clientInfoList?has_content>
    <#assign r = m1.log("[CONF][CHATBOT_ID][ERR] API-KEY���� ����.... ó�� ����.", "ERROR")/>

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
                <#assign r = m1.log("[ERR] ��ū���� ����. @��ū����=[${m1.toJsonBytes(tokenInfo)}]", "ERROR")/>

            <#else>
                <#--  ���̽�ID�� DB���� ��ȸ�Ͽ� �귣��ID����  -->
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

                        <#--  RBC���� ���̽�ID��ȸ  -->
                        <#assign resultMap = commonFunction_rbc2dbSync("CHATBOT_ID", chatbotIdSyncParamMap)/>

                        <#if resultMap?has_content && resultMap.code == "200">
                            <#assign r = m1.log("[CONF][CHATBOT_ID][SYNC][${row_index}][SUCC] �������ø� ����ȭ ����. @�귣��ID=[${brandId}]", "INFO")/>

                        <#else>
                            <#assign r = m1.log("[CONF][CHATBOT_ID][SYNC][${row_index}][FAIL] �������ø� ����ȭ ����. @�귣��ID=[${brandId}]", "ERROR")/>

                        </#if>
                    </#list>
                <#else>
                    <#assign r = m1.log("[CONF][CHATBOT_ID][DB][ERR] �귣��ID���� ����.", "ERROR")/>
                </#if>

                <#assign r = sqlConn.close()/>
            </#if>
        <#else>
            <#assign r = m1.log("[CONF][CHATBOT_ID][DB][ERR] API-KEY���� ����.", "ERROR")/>
        </#if>

    </#list>
</#if>