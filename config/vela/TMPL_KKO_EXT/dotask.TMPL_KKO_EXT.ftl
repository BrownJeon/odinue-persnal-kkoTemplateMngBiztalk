<#--
    토큰관리(생성 및 갱신)
-->

<#-- 템플릿요청 공통함수 -->
<#include "include/request.include_function.ftl"/>

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>

<#--  do nothing.  -->

<#--  인증여부 판단하여 인증사용시에 토큰갱신처리  -->
<#assign authYn = m1.shareget("authYn")/>
<#if authYn?upper_case == "Y">
    <#--  비즈톡의 경우 토큰을 사용하지 않고 사전에 발급받은 인증정보를 사용하여 api요청으로 인해 토큰갱신 불필요  -->
</#if>

