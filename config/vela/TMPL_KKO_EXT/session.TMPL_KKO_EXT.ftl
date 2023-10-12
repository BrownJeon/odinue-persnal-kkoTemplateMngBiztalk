<#-- ���� �������� �ε�-->
<#include "include/request.include_function.ftl"/>

<#-- SQL��ü ���� -->
<#assign sqlConn = m1.new("sql")/>

<#--  ���μ��� ��������. TASKó�� �� ���� �߻��� ���μ��� ������ ���� flag  -->
<#assign isStop = false/>

<#--  �߽������������� ��ȸ�Ͽ� ������ �ʿ��� ���� ����  -->
<#assign profileKeyInfoMap = commonFunction_getProfileKeyInfoMap(sqlConn)/>

<#assign responseCode = profileKeyInfoMap.code!"999"/>
<#if responseCode == "200">
    <#assign channelList = profileKeyInfoMap.data!{}/>
    <#assign r = m1.shareput("channelList", channelList)/>
<#else>
    <#assign isStop = true/>
</#if>

<#assign r = sqlConn.close()/>


<#--  ��ū�߱� ó��  -->
<#--  �Լ������� ��ū������ �޸𸮿� ���ó�� ��  -->
<#assign authYn = m1.shareget("authYn")/>
<#if authYn?upper_case == "Y">
    <#assign r = commonFunction_getTokenInfo4Memory(channelList)/>

</#if>


<#-- ���ø� ����ȭ ��� -->
<#assign syncTemplateYn = m1.shareget("syncTemplateYn")/>
<#if syncTemplateYn?upper_case == "Y">
    <#assign r = commonFunction_templateSync2Database()/>

</#if>

<#assign r = m1.shareput("isStop", isStop)/>