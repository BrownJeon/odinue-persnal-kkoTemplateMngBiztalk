<#-- ���� �������� �ε�-->
<#include "include/request.include_function.ftl"/>

<#-- ���� �԰� �ε� (Load FFDMessage) -->
<#assign m1home = m1.sysenv["M1_HOME"]/>
<#assign r = m1.loadffdef("${m1home}/config/vela-mdefs/M1.def") />

<#-- api baseURL ���� -->
<#assign tmplMngrUrl = m1.shareget("tmplMngrUrl")/>
<#--  ���ø� �ܰ���ȸ api  -->
<#assign selectTemplateOne = m1.shareget("selectTemplateOne")/>


<#-- �������ø� ���翩�� ��ȸ ���� -->
<#assign selectKkoTemplateQuery = m1.loadText("include/biz/sql/mng/kkoTemplateSyncQuery/selectKkoTemplate.sql")!""/>

<#-- �������ø� ����ȭó�� ���� -->
<#assign insertKkoTemplateQuery =  m1.loadText("include/biz/sql/mng/kkoTemplateSyncQuery/insertKkoTemplate.sql")!""/>

<#--  �귣������ ��ȸ ����  -->
<#assign selecProfileKeyInfoQuery = m1.loadText("include/biz/sql/common/selecProfileKeyInfo.sql")!""/>

<#-- SQL��ü ���� -->
<#assign sqlConn = m1.new("sql")/>

<#assign profileKeyInfoMap = m1.editable({})/>

<#--  �߽������������� ��ȸ�Ͽ� ������ �ʿ��� ���� ����  -->
<#assign r = m1.log("[INIT][CHANNEL_ID] �߽����������� DB��ȸ.", "INFO")/>

<#assign profileKeyInfoRs = sqlConn.query2array(selecProfileKeyInfoQuery, {})/>
<#if (profileKeyInfoRs?size > 0)>
    <#list profileKeyInfoRs as profileKeyInfo>
        <#if !profileKeyInfo?has_content>
            <#assign r = m1.log("[INIT][CHANNEL_ID][ERR] ��ȸ�� ������ ����.", "ERROR")/>
        </#if>
        
        <#assign profileKey = profileKeyInfo["CHANNEL_ID"]/>

        <#assign expireYn = profileKeyInfo["EXPIRE_YN"]!"N"/>
        <#if expireYn?has_content && expireYn?upper_case == "Y">
            <#assign r = m1.log("[INIT][CHANNEL_ID][EXPIRED] ���ܻ����� �߽�������Ű. @�߽�������Ű=[${profileKey}]", "INFO")/>
            <#break/>
        </#if>
        <#assign rejectYn = profileKeyInfo["REJECT_YN"]!"N"/>
        <#if  rejectYn?has_content && rejectYn?upper_case == "Y">
            <#assign r = m1.log("[INIT][CHANNEL_ID][REJECT] �޸������ �߽�������Ű. @�߽�������Ű=[${profileKey}]", "INFO")/>
            <#break/>
        </#if>

        <#--  conifg���� �ε��� �߽��������������� DB��ȸ�� �߽�������Ű�� ã�Ƽ� �������� ����  -->
        <#assign channelList = m1.shareget("channelList")/>
        <#assign authInfo = channelList[profileKey]!""/>
        <#if !authInfo?has_content>
            <#assign r = m1.log("[INIT][ERR] properties�� ��ϵ� �߼������������� ����. @�߽�������Ű=[${profileKey}]", "ERROR")/>
            <#break/>
        <#else>

            <#--  �߽�������Ű���� ����  -->
            <#assign clientInfoMap = commonFunction_getClientInfo(profileKeyInfo, authInfo)/>

            <#assign r = profileKeyInfoMap.put(profileKey, clientInfoMap)/>

        </#if>

    </#list>

    <#assign r = m1.log("[INIT][CHANNEL_ID] �߽����������� ���� �Ϸ�. ", "INFO")/>
    <#assign r = m1.log(m1.toJsonBytes(profileKeyInfoMap), "DEBUG")/>

<#else>
    <#assign r = m1.log("[INIT][CHANNEL_ID] �߽����������� ����.", "INFO")/>

</#if>

<#assign r = sqlConn.close(profileKeyInfoRs)/>

<#assign r = m1.shareput("profileKeyInfoMap", profileKeyInfoMap)/>


<#-- ���ø� ����ȭ ��� -->
<#list profileKeyInfoMap as profileKey, clientInfo>

    <#assign kkoTemplateSyncParamMap = m1.editable({})/>

    <#assign clientId = clientInfo.clientId!""/>
    <#assign clientSecret = clientInfo.clientSecret!""/>

    <#assign authYn = m1.shareget("authYn")!"n"/>
    <#if authYn?upper_case == "N">
        <#assign r = m1.log("[TMPL][INIT] ���� �̻������ ���� ����ó�� ����.", "DEBUG")/>

    <#elseif authYn?upper_case == "Y">
        <#--
            ���μ��� �⵿�� ���� ��ū�߱� ó��
        -->
        <#assign r = m1.log("="?left_pad(80, "="), "INFO")/>
        <#assign r = m1.log("[INIT][TOKEN][CREATE][START] ��ū�߱� ����. @�߽�������Ű=[${profileKey}] @clientId=[${clientId}] @clientSecret=[${clientSecret}]", "INFO")/>
        <#assign tokenInfo = commonFunction_requestTokenInfo({
            "clientId": clientId
            , "clientSecret": clientSecret
        })/>

        <#if tokenInfo?has_content && tokenInfo.code == "200">
            <#assign r = m1.shareput(profileKey, tokenInfo)/>

            <#assign r = m1.log("[INIT][TOKEN][CREATE][SUCC] ��ū���� �߱�. @��ū����=[${m1.toJsonBytes(tokenInfo!{})}]", "INFO")/>
        <#else>
            <#assign r = m1.log("[INIT][TOKEN][CREATE][ERR] ��ū���� ����. ���μ��� ����.", "ERROR")/>

            <#break/>

        </#if>

        <#assign r = kkoTemplateSyncParamMap.put("token", tokenInfo.accessToken!"")/>

    <#else>
        <#assign r = m1.log("[INIT][ERR] ������뿩�� ������ ������. �������� Y / N���� ���������մϴ�. @suthYn=[${authYn}]", "ERROR")/>
    </#if>


    <#assign syncTemplateYn = m1.shareget("syncTemplateYn")!"n"/>
    <#if syncTemplateYn?upper_case == "N">
        <#assign r = m1.log("[TMPL][INIT] ����ȭ��� �̻������ ���� ����ȭó�� ����.", "DEBUG")/>

    <#elseif syncTemplateYn?upper_case == "Y">
        <#--  
            RBC ���ø� ����ȭó��
                - ���ε� ���ø��� �������� ����ȭó��
        -->
        <#assign r = m1.log("="?left_pad(40, "=") + " ����/���δ�� ���ø� ����ȭó�� ����." + "="?left_pad(40, "="), "INFO")/>

        <#assign r = kkoTemplateSyncParamMap.merge({
            "sqlConn": sqlConn
            , "query": {
                "selectQuery": selectKkoTemplateQuery
                , "insertQuery": insertKkoTemplateQuery
            }
            , "requestUrl": "${tmplMngrUrl}/${selectTemplateOne}"
        }, "true")/>

        <#assign resultMap = commonFunction_kko2dbSync("KKO_TMPL", kkoTemplateSyncParamMap)/>
        
        <#if resultMap?has_content && resultMap.code == "200">
            <#assign r = m1.log("[RBC][SYNC][TMPL][SUCC] ����/���δ�� ����ȭ ����.", "INFO")/>
        
        <#else>
            <#assign r = m1.log("[RBC][SYNC][TMPL][FAIL] ����/���δ�� ����ȭ ����.", "ERROR")/>

        </#if>

        <#assign r = m1.log("="?left_pad(40, "=") + " ����/���δ�� ���ø� ����ȭó�� �Ϸ�." + "="?left_pad(40, "="), "INFO")/>

    <#else>
        <#assign r = m1.log("[INIT][ERR] ����ȭ��뿩�� ������ ������. �������� Y / N���� ���������մϴ�. @syncTemplateYn=[${syncTemplateYn}]", "ERROR")/>
    </#if>

</#list>

<#assign r = sqlConn.close()/>