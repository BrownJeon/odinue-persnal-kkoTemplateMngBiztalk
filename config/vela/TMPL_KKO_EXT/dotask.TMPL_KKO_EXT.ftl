<#--
    토큰관리(생성 및 갱신)
-->

<#-- 템플릿요청 공통함수 -->
<#include "include/request.include_function.ftl"/>

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>

<#--  인증여부 판단하여 인증사용시에 토큰갱신처리 로직 시작  -->
<#assign authYn = m1.shareget("authYn")/>
<#if authYn?upper_case == "Y">
    <#-- 발신프로필정보 목록 -->
    <#assign channelList = m1.shareget("channelList")/>

    <#-- 
        발신프로필정보 목록의 발신프로필키 별로 토큰갱신처리
    -->
    <#list channelList as profileKey, clientInfo>
        <#assign r = m1.log("[CONF][TOKEN][CHECK] 토큰발급 조회 체크. @발신프로필키=[${profileKey}]", "DEBUG")/>

        <#assign tokenInfo = m1.shareget(profileKey)!{}/>
        <#if 
            tokenInfo?has_content
        >
            <#assign interval = 30*60*1000/> <#-- 만료일시 30분전에 갱신처리 -->
            <#assign expiresTimeMillis = tokenInfo.expiresIn?number - m1.ymdhms2millis() - interval/>
            <#if (expiresTimeMillis < 0)>
                <#assign r = m1.log("[CONF][TOKEN][UPDATE] 토큰 만료로 인한 갱신처리. @발신프로필키=[${profileKey}]", "INFO")/>

                <#assign tokenInfo = commonFunction_requestTokenInfo(clientInfo)/>

                <#if tokenInfo?has_content && tokenInfo.code == 200>
                    <#assign r = m1.shareput(profileKey, tokenInfo)/>

                    <#assign r = m1.log("[CONF][TOKEN][CREATE] 토큰정보 갱신. @발신프로필키=[${profileKey}]", "INFO")/>
                    <#assign r = m1.log(tokenInfo, "DEBUG")/>  
                </#if>
            </#if>
        <#else>
            <#assign r = m1.log("[CONF][TOKEN][CREATE] 토큰발급 시작. @발신프로필키=[${profileKey}]", "INFO")/>

            <#assign tokenInfo = commonFunction_requestTokenInfo(clientInfo)/>

            <#if tokenInfo?has_content && tokenInfo.code == 200>
                <#assign r = m1.shareput(profileKey, tokenInfo)/>

                <#assign r = m1.log("[CONF][TOKEN][CREATE] 토큰정보 발급완료. @발신프로필키=[${profileKey}]", "INFO")/>
                <#assign r = m1.log(tokenInfo, "DEBUG")/>
            </#if>

        </#if>

    </#list>
</#if>




