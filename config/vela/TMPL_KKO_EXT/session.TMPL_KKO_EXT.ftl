<#-- ���� �������� �ε�-->
<#include "include/request.include_function.ftl"/>

<#-- SQL��ü ���� -->
<#assign sqlConn = m1.new("sql")/>

<#--  �߽������������� ��ȸ�Ͽ� ������ �ʿ��� ���� ����  -->
<#assign channelList = commonFunction_getProfileKeyInfoMap(sqlConn)/>
<#assign r = m1.shareput("channelList", channelList)/>

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
