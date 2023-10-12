<#-- 공통 설정파일 로딩-->
<#include "include/request.include_function.ftl"/>

<#-- SQL객체 정의 -->
<#assign sqlConn = m1.new("sql")/>

<#--  프로세스 중지여부. TASK처리 중 에러 발생시 프로세스 중지를 위한 flag  -->
<#assign isStop = false/>

<#--  발신프로필정보를 조회하여 인증에 필요한 정보 세팅  -->
<#assign profileKeyInfoMap = commonFunction_getProfileKeyInfoMap(sqlConn)/>

<#assign responseCode = profileKeyInfoMap.code!"999"/>
<#if responseCode == "200">
    <#assign channelList = profileKeyInfoMap.data!{}/>
    <#assign r = m1.shareput("channelList", channelList)/>
<#else>
    <#assign isStop = true/>
</#if>

<#assign r = sqlConn.close()/>


<#--  토큰발급 처리  -->
<#--  함수내에서 토큰정보를 메모리에 등록처리 함  -->
<#assign authYn = m1.shareget("authYn")/>
<#if authYn?upper_case == "Y">
    <#assign r = commonFunction_getTokenInfo4Memory(channelList)/>

</#if>


<#-- 템플릿 동기화 기능 -->
<#assign syncTemplateYn = m1.shareget("syncTemplateYn")/>
<#if syncTemplateYn?upper_case == "Y">
    <#assign r = commonFunction_templateSync2Database()/>

</#if>

<#assign r = m1.shareput("isStop", isStop)/>