<#-- 공통 설정파일 로딩-->
<#include "include/request.include_function.ftl"/>

<#-- SQL객체 정의 -->
<#assign sqlConn = m1.new("sql")/>

<#--  발신프로필정보를 조회하여 인증에 필요한 정보 세팅  -->
<#assign channelList = commonFunction_getProfileKeyInfoMap(sqlConn)/>
<#assign r = m1.shareput("channelList", channelList)/>

<#assign r = sqlConn.close()/>


<#--  토큰발급 처리  -->
<#assign authYn = m1.shareget("authYn")/>
<#if authYn?upper_case == "Y">
    <#--  비즈톡의 경우 토큰을 사용하지 않고 사전에 발급받은 인증정보를 사용하여 api요청으로 인해 토큰발급 불필요  -->
</#if>


<#-- 템플릿 동기화 기능 -->
<#assign syncTemplateYn = m1.shareget("syncTemplateYn")/>
<#if syncTemplateYn?upper_case == "Y">
    <#--  비즈톡의 경우 템플릿목록 조회가 불가하여 비즈톡센터에 등록되어 있는 템플릿을 조회할 수 없어서 동기화기능 미지원  -->
</#if>
