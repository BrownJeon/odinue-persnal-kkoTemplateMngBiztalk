<#-- ���� �������� �ε�-->
<#include "include/request.include_function.ftl"/>

<#-- ���� �԰� �ε� (Load FFDMessage) -->
<#assign m1home = m1.sysenv["M1_HOME"]/>
<#assign r = m1.loadffdef("${m1home}/config/vela-mdefs/M1.def") />

<#--  �߽����������� ��ȸ ����  -->
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

<#assign r = sqlConn.close()/>


<#--  ��ū�߱� ó��  -->
<#assign authYn = m1.shareget("authYn")/>
<#if authYn?upper_case == "Y">
    <#--  �������� ��� ��ū�� ������� �ʰ� ������ �߱޹��� ���������� ����Ͽ� api��û���� ���� ��ū�߱� ���ʿ�  -->
</#if>


<#-- ���ø� ����ȭ ��� -->
<#assign syncTemplateYn = m1.shareget("syncTemplateYn")/>
<#if syncTemplateYn?upper_case == "Y">
    <#--  �������� ��� ���ø���� ��ȸ�� �Ұ��Ͽ� �����弾�Ϳ� ��ϵǾ� �ִ� ���ø��� ��ȸ�� �� ��� ����ȭ��� ������  -->
</#if>
