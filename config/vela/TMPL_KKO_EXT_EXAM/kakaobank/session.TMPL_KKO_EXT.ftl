<#-- ���� �������� �ε�-->
<#include "include/request.include_function.ftl"/>

<#-- ���� �԰� �ε� (Load FFDMessage) -->
<#assign m1home = m1.sysenv["M1_HOME"]/>
<#assign r = m1.loadffdef("${m1home}/config/vela-mdefs/M1.def") />

<#-- api baseURL ���� -->
<#assign tmplMngrUrl = m1.shareget("tmplMngrUrl")/>

<#-- �������ø� ���翩�� ��ȸ ���� -->
<#assign selectRcsTemplateQuery = m1.loadText("include/biz/sql/mng/rcsTemplateSyncQuery/selectRcsTemplate.sql")!""/>

<#-- �������ø� ����ȭó�� ���� -->
<#assign insertRcsTemplateQuery =  m1.loadText("include/biz/sql/mng/rcsTemplateSyncQuery/insertRcsTemplate.sql")!""/>

<#--  �귣������ ��ȸ ����  -->
<#assign selectBrandInfoQuery = m1.loadText("include/biz/sql/common/selectBrandInfo.sql")!""/>

<#-- SQL��ü ���� -->
<#assign sqlConn = m1.new("sql")/>

<#-- 
    ��ū������ �޸𸮿� ���翩�� üũ 
    RCS �귣��ID�� ���ؼ� ��ȸ
-->
<#-- �귣��ID��� -->
<#assign brandInfoMap = m1.editable({})/>

<#--  API-KEY ������ �����ٰ� �귣��ID��� ����  -->
<#assign clientInfoList = m1.shareget("clientInfoList")![]/>
<#if !clientInfoList?has_content>
    <#assign r = m1.log("[INIT][ERR] API-KEY���� ����.... �ý��� ����.", "ERROR")/>

    <#assign r = m1.stack("return", -9)/>

<#else>
    <#assign r = m1.log("[INIT][BRAND] �귣������ DB��ȸ.", "INFO")/>
    
    <#list clientInfoList as clientInfo>
        <#assign clientId = clientInfo.clientId!""/>
        <#assign clientSecret = clientInfo.clientSecret!""/>

        <#--  �귣��ID ��ȸ ����  -->
        <#assign brandInfoRs = sqlConn.query2array(selectBrandInfoQuery, {})/>
        <#list brandInfoRs as brandInfo>

            <#assign brandId = brandInfo.BR_ID!""/>
            <#assign brandKey = brandInfo.BR_KEY!""/>
            <#if brandId?has_content>

                <#assign r = brandInfoMap.put(brandId, {
                    "brandKey": brandKey
                    , "clientId": clientId
                    , "clientSecret": clientSecret
                })/>
            </#if>
        </#list>
    </#list>

    <#assign r = sqlConn.close(brandInfoRs)/>

</#if>
<#assign r = m1.shareput("brandInfoMap", brandInfoMap)/>


<#assign token = ""/>

<#list brandInfoMap as brandId, brandInfo>

    <#assign clientId = brandInfo.clientId!""/>
    <#assign clientSecret = brandInfo.clientSecret!""/>

    <#--
        ���μ��� �⵿�� ���� ��ū�߱� ó��
    -->
    <#assign r = m1.log("="?left_pad(80, "="), "INFO")/>
    <#assign r = m1.log("[INIT][TOKEN][CREATE][START] ��ū�߱� ����. @�귣��ID=[${brandId}] @clientId=[${clientId}] @clientSecret=[${clientSecret}]", "INFO")/>
    <#assign tokenInfo = commonFunction_requestTokenInfo({
        "clientId": clientId
        , "clientSecret": clientSecret
    })/>

    <#if tokenInfo?has_content && tokenInfo.code == 200>
        <#assign r = m1.shareput(brandId, tokenInfo)/>

        <#assign r = m1.log("[INIT][TOKEN][CREATE][SUCC] ��ū���� �߱�. @��ū����=[${m1.toJsonBytes(tokenInfo!{})}]", "INFO")/>
    </#if>

    <#assign token = tokenInfo.accessToken!""/>
    <#if !token?has_content>
        <#assign r = m1.log("[INIT][TOKEN][CREATE][ERR] ��ū���� ����. ���μ��� ����.", "ERROR")/>

        <#break/>
    <#else>
        <#--  
            RBC ���ø� ����ȭó��
                - ���ε� ���ø��� �������� ����ȭó��
        -->
        <#assign r = m1.log("="?left_pad(40, "=") + " ����/���δ�� ���ø� ����ȭó�� ����." + "="?left_pad(40, "="), "INFO")/>

        <#assign rcsTemplateSyncParamMap = {
            "token": token
            , "sqlConn": sqlConn
            , "query": {
                "selectQuery": selectRcsTemplateQuery
                , "insertQuery": insertRcsTemplateQuery
            }
            , "requestUrl": "${tmplMngrUrl}/brand/${brandId}/messagebase"
        }/>

        <#assign resultMap = commonFunction_rbc2dbSync("RCS_TMPL", rcsTemplateSyncParamMap)/>
        
        <#if resultMap?has_content && resultMap.code == "200">
            <#assign r = m1.log("[RBC][FORM_ID][SUCC] ����/���δ�� ����ȭ ����.", "INFO")/>
        
        <#else>
            <#assign r = m1.log("[RBC][FORM_ID][FAIL] ����/���δ�� ����ȭ ����.", "ERROR")/>

        </#if>

        <#assign r = m1.log("="?left_pad(40, "=") + " ����/���δ�� ���ø� ����ȭó�� �Ϸ�." + "="?left_pad(40, "="), "INFO")/>
    </#if>

</#list>

<#assign r = sqlConn.close()/>