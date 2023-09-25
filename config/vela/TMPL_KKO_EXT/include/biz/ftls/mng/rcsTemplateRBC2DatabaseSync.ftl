<#--  RBC���� ��ȸ�Ͽ� ���̽���ID���� ����ȭó��  -->

<#-- �Լ� include -->
<#include "../../../request.include_function.ftl"/>

<#assign m1props = m1.statics["com.odinues.m1.util.ClassProperties"].global/>

<#assign tmplMngrUrl = m1props.getProperty("templateManage.api.url", "")?trim/>

<#assign selectBrandIdInfoQuery = m1.loadText("../../sql/common/selectBrandInfo.sql")!""/>

<#assign selectRcsTemplateQuery = m1.loadText("../../sql/mng/rcsTemplateSyncQuery/selectRcsTemplate.sql")!""/>
<#assign insertRcsTemplateQuery =  m1.loadText("../../sql/mng/rcsTemplateSyncQuery/insertRcsTemplate.sql")!""/>
<#assign updateRcsTemplateQuery = m1.loadText("../../sql/mng/rcsTemplateSyncQuery/updateRcsTemplate.sql")!""/>

<#assign selectClientInfoQuery = m1.loadText("../../sql/common/selectClientInfo.sql")!""/>

<#assign sqlConn = m1.new("sql")/>

<#assign r = m1.log("[CONF][RCS_TMPL][SYNC][START] �������ø� ����ȭó�� ����.", "INFO")/>

<#--  API-KEY ������ �����ٰ� �귣��ID��� ����  -->
<#assign clientInfoList = m1.shareget("clientInfoList")![]/>
<#if !clientInfoList?has_content>
    <#assign r = m1.log("[CONF][RCS_TMPL][ERR] API-KEY���� ����.... ó�� ����.", "ERROR")/>

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

                        <#--  RBC���� ���̽�ID��ȸ  -->
                        <#assign resultMap = commonFunction_rbc2dbSync("RCS_TMPL", brandIdSyncParamMap)/>

                        <#if resultMap?has_content && resultMap.code == "200">
                            <#assign r = m1.log("[CONF][RCS_TMPL][SYNC][${row_index}][SUCC] �������ø� ����ȭ ����. @�귣��ID=[${brandId}]", "INFO")/>

                        <#else>
                            <#assign r = m1.log("[CONF][RCS_TMPL][SYNC][${row_index}][FAIL] �������ø� ����ȭ ����. @�귣��ID=[${brandId}]", "ERROR")/>

                        </#if>
                    </#list>
                <#else>
                    <#assign r = m1.log("[CONF][RCS_TMPL][DB][ERR] �귣��ID���� ����.", "ERROR")/>
                </#if>

                <#assign r = sqlConn.close()/>
            </#if>
        <#else>
            <#assign r = m1.log("[CONF][RCS_TMPL][DB][ERR] API-KEY���� ����.", "ERROR")/>

        </#if>

    </#list>
</#if>