<#--  ����� ��ȸ�Ͽ� �߽�������Ű ���� ����ȭó��  -->

<#-- �Լ� include -->
<#include "../../../request.include_function.ftl"/>

<#assign m1props = m1.statics["com.odinues.m1.util.ClassProperties"].global/>

<#assign tmplMngrUrl = m1props.getProperty("templateManage.api.url", "")?trim/>

<#assign selectProfileKeyQuery = m1.loadText("../../sql/mng/profileKeySyncQuery/selectProfileKey.sql")!""/>
<#assign insertProfileKeyQuery =  m1.loadText("../../sql/mng/profileKeySyncQuery/insertProfileKey.sql")!""/>
<#assign updateProfileKeyQuery = m1.loadText("../../sql/mng/profileKeySyncQuery/updateProfileKey.sql")!""/>

<#assign sqlConn = m1.new("sql")/>

<#assign r = m1.log("[CONF][PROFILE_KEY][SYNC][START] �߽�������Ű ����ȭó�� ����.", "INFO")/>

<#--  API-KEY ������ �����ٰ� �߽�������Ű ��� ����  -->
<#assign clientInfoList = m1.shareget("clientInfoList")![]/>
<#if !clientInfoList?has_content>
    <#assign r = m1.log("[CONF][PROFILE_KEY][ERR] API-KEY���� ����.... ó�� ����.", "ERROR")/>

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
                <#assign profileKeySyncParamMap = {
                    "sqlConn": sqlConn
                    , "query": {
                        "selectQuery": selectProfileKeyQuery
                        , "updateQuery": updateProfileKeyQuery
                        , "insertQuery": insertProfileKeyQuery
                    }
                    , "requestUrl": "${tmplMngrUrl}/corp/${clientId}/brand"
                }/>

                <#--  RBC���� ���̽�ID��ȸ  -->
                <#assign resultMap = commonFunction_rbc2dbSync("PROFILE_KEY", profileKeySyncParamMap)/>

                <#if resultMap?has_content && resultMap.code == "200">
                    <#assign r = m1.log("[CONF][PROFILE_KEY][SYNC][SUCC] �߽�������Ű ����ȭ ����.", "INFO")/>

                <#else>
                    <#assign r = m1.log("[CONF][PROFILE_KEY][SYNC][FAIL] �߽�������Ű ����ȭ ����.", "ERROR")/>

                </#if>

                <#assign r = sqlConn.close()/>
            </#if>
        <#else>
            <#assign r = m1.log("[CONF][DB][ERR] API-KEY���� ����.", "ERROR")/>
        </#if>

    </#list>
</#if>