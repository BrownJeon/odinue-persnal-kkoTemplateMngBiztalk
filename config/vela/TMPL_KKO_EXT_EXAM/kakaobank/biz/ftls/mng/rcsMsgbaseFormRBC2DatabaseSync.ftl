<#--  RBC���� ��ȸ�Ͽ� ���̽���ID���� ����ȭó��  -->

<#-- �Լ� include -->
<#include "../../../request.include_function.ftl"/>

<#assign m1props = m1.statics["com.odinues.m1.util.ClassProperties"].global/>

<#assign tmplMngrUrl = m1props.getProperty("templateManage.api.url", "")?trim/>

<#assign selectFormIdQuery = m1.loadText("../../sql/mng/formIdSyncQuery/selectMessagebaseFormId.sql")!""/>
<#assign insertFormIdQuery =  m1.loadText("../../sql/mng/formIdSyncQuery/insertMessagebaseFormId.sql")!""/>
<#assign updateFormIdQuery = m1.loadText("../../sql/mng/formIdSyncQuery/updateMessagebaseFormId.sql")!""/>

<#assign sqlConn = m1.new("sql")/>

<#assign r = m1.log("[CONF][FORM_ID][SYNC][START] ���̽���ID ����ȭó�� ����.", "INFO")/>

<#--  API-KEY ������ �����ٰ� �귣��ID��� ����  -->
<#assign clientInfoList = m1.shareget("clientInfoList")![]/>
<#if !clientInfoList?has_content>
    <#assign r = m1.log("[CONF][FORM_ID][ERR] API-KEY���� ����.... ó�� ����.", "ERROR")/>

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
                <#assign formIdSyncParamMap = {
                    "token": token
                    , "sqlConn": sqlConn
                    , "query": {
                        "selectQuery": selectFormIdQuery
                        , "updateQuery": updateFormIdQuery
                        , "insertQuery": insertFormIdQuery
                    }
                    , "requestUrl": "${tmplMngrUrl}/messagebase/messagebaseform"
                }/>

                <#--  RBC���� ���̽�ID��ȸ  -->
                <#assign resultMap = commonFunction_rbc2dbSync("FORM_ID", formIdSyncParamMap)/>

                <#if resultMap?has_content && resultMap.code == "200">
                    <#assign r = m1.log("[CONF][FORM_ID][SYNC][SUCC] ���̽���ID ����ȭ ����.", "INFO")/>

                <#else>
                    <#assign r = m1.log("[CONF][FORM_ID][SYNC][FAIL] ���̽���ID ����ȭ ����.", "ERROR")/>

                </#if>

                <#assign r = sqlConn.close()/>
            </#if>
        <#else>
            <#assign r = m1.log("[CONF][FORM_ID][DB][ERR] API-KEY���� ����.", "ERROR")/>
        </#if>

    </#list>
</#if>