<#--
    ��ū����(���� �� ����)
-->

<#-- ���ø���û �����Լ� -->
<#include "include/request.include_function.ftl"/>

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>

<#--  do nothing.  -->

<#--  �������� �Ǵ��Ͽ� �������ÿ� ��ū����ó��  -->
<#assign authYn = m1.shareget("authYn")/>
<#if authYn?upper_case == "Y">
    <#--  �������� ��� ��ū�� ������� �ʰ� ������ �߱޹��� ���������� ����Ͽ� api��û���� ���� ��ū���� ���ʿ�  -->
</#if>

