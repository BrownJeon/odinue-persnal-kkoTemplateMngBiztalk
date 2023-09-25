<#--  RBC���� ��ȸ�Ͽ� �귣��ID���� ����ȭó��  -->

<#-- �Լ� include -->
<#include "../../../request.include_function.ftl"/>

<#assign m1props = m1.statics["com.odinues.m1.util.ClassProperties"].global/>

<#assign tmplMngrUrl = m1props.getProperty("templateManage.api.url", "")?trim/>

<#assign selectBrandIdQuery = m1.loadText("../../sql/mng/brandIdSyncQuery/selectBrandId.sql")!""/>
<#assign insertBrandIdQuery =  m1.loadText("../../sql/mng/brandIdSyncQuery/insertBrandId.sql")!""/>
<#assign updateBrandIdQuery = m1.loadText("../../sql/mng/brandIdSyncQuery/updateBrandId.sql")!""/>

<#assign sqlConn = m1.new("sql")/>

<#assign r = m1.log("[CONF][BRAND_ID][SYNC][START] �귣��ID ����ȭó�� ����.", "INFO")/>

<#--  API-KEY ������ �����ٰ� �귣��ID��� ����  -->
<#assign clientInfoList = m1.shareget("clientInfoList")![]/>
<#if !clientInfoList?has_content>
    <#assign r = m1.log("[CONF][BRAND_ID][ERR] API-KEY���� ����.... ó�� ����.", "ERROR")/>

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
                <#assign brandIdSyncParamMap = {
                    "sqlConn": sqlConn
                    , "query": {
                        "selectQuery": selectBrandIdQuery
                        , "updateQuery": updateBrandIdQuery
                        , "insertQuery": insertBrandIdQuery
                    }
                    , "requestUrl": "${tmplMngrUrl}/corp/${clientId}/brand"
                }/>

                <#--  RBC���� ���̽�ID��ȸ  -->
                <#assign resultMap = commonFunction_rbc2dbSync("BRAND_ID", brandIdSyncParamMap)/>

                <#if resultMap?has_content && resultMap.code == "200">
                    <#assign r = m1.log("[CONF][BRAND_ID][SYNC][SUCC] �귣��ID ����ȭ ����.", "INFO")/>

                <#else>
                    <#assign r = m1.log("[CONF][BRAND_ID][SYNC][FAIL] �귣��ID ����ȭ ����.", "ERROR")/>

                </#if>

                <#assign r = sqlConn.close()/>
            </#if>
        <#else>
            <#assign r = m1.log("[CONF][DB][ERR] API-KEY���� ����.", "ERROR")/>
        </#if>

    </#list>
</#if>