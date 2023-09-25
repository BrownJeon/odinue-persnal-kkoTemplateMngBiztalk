<#--  RBC���� ��ȸ�Ͽ� �������ø����� ����ȭó��  -->

<#-- �Լ� include -->
<#include "../../../request.include_function.ftl"/>

<#assign m1props = m1.statics["com.odinues.m1.util.ClassProperties"].global/>

<#assign tmplMngrUrl = m1props.getProperty("templateManage.api.url", "")?trim/>

<#assign selectCommonTemplateQuery = m1.loadText("../../sql/mng/commonTemplateSyncQuery/selectCommonTemplate.sql")!""/>
<#assign insertCommonTemplateQuery =  m1.loadText("../../sql/mng/commonTemplateSyncQuery/insertCommonTemplate.sql")!""/>
<#assign updateCommonTemplateQuery = m1.loadText("../../sql/mng/commonTemplateSyncQuery/updateCommonTemplate.sql")!""/>

<#assign sqlConn = m1.new("sql")/>

<#assign r = m1.log("[CONF][COMMON_TMPL][SYNC][START] �������ø� ����ȭó�� ����.", "INFO")/>

<#--  API-KEY ������ �����ٰ� �귣��ID��� ����  -->
<#assign clientInfoList = m1.shareget("clientInfoList")![]/>
<#if !clientInfoList?has_content>
    <#assign r = m1.log("[CONF][COMMON_TMPL][ERR] API-KEY���� ����.... ó�� ����.", "ERROR")/>

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

                <#--  RBC���� ���̽�ID��ȸ  -->
                <#assign resultMap = commonFunction_rbc2dbSync("COMMON_TMPL", commonTemplateSyncParamMap)/>

                <#if resultMap?has_content && resultMap.code == "200">
                    <#assign r = m1.log("[CONF][COMMON_TMPL][SYNC][SUCC] �������ø� ����ȭ ����.", "INFO")/>

                <#else>
                    <#assign r = m1.log("[CONF][COMMON_TMPL][SYNC][FAIL] �������ø� ����ȭ ����.", "ERROR")/>

                </#if>

                <#assign r = sqlConn.close()/>
            </#if>
        <#else>
            <#assign r = m1.log("[CONF][COMMON_TMPL][DB][ERR] API-KEY���� ����.", "ERROR")/>
        </#if>

    </#list>
</#if>