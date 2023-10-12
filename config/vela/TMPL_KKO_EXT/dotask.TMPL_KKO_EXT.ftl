<#--
    토큰관리(생성 및 갱신)
-->

<#-- 템플릿요청 공통함수 -->
<#include "include/request.include_function.ftl"/>

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>

<#--  프로세스 중지여부  -->
<#assign isStop = m1.shareget("isStop")!false/>

<#--  0:정상, -1: 재기동, -9:중지  -->
<#assign returnCode = 0/>

<#if !isStop>

    <#--  인증여부 판단하여 인증사용시에 토큰갱신처리  -->
    <#assign authYn = m1.shareget("authYn")/>
    <#if authYn?upper_case == "Y">
        <#assign channelList = m1.shareget("channelList")/>

        <#list channelList as senderKey, channelInfo>
            <#assign r = m1.log("[CONF][TOKEN][CHECK] 토큰발급 조회 체크. @발신프로필키=[${senderKey}]", "DEBUG")/>

            <#assign tokenInfo = m1.shareget(senderKey)!{}/>
            <#if 
                tokenInfo?has_content
            >
                <#assign interval = 30*60*1000/> <#-- 만료일시 30분전에 갱신처리 -->
                <#assign expiresIn = tokenInfo.expiresIn!"0"/>
                <#assign expiresTimeMillis = expiresIn?number - m1.ymdhms2millis() - interval/>
                <#--  만료시간이 존재하고 만료시간 30분 전일 경우 토큰갱신처리  -->
                <#if (expiresIn > 0) && (expiresTimeMillis < 0)>
                    <#assign r = m1.log("[CONF][TOKEN][UPDATE] 토큰 만료로 인한 갱신처리. @발신프로필키=[${senderKey}]", "INFO")/>

                    <#assign tokenInfo = commonFunction_requestTokenInfo(channelInfo)/>

                    <#if tokenInfo?has_content && tokenInfo.code == 200>
                        <#assign r = m1.shareput(senderKey, tokenInfo)/>

                        <#assign r = m1.log("[CONF][TOKEN][CREATE] 토큰정보 갱신. @발신프로필키=[${senderKey}]", "INFO")/>
                        <#assign r = m1.log(tokenInfo, "DEBUG")/>  
                    <#else>
                        <#assign isStop = true/>
                    </#if>
                </#if>
            <#else>
                <#assign r = m1.log("[CONF][TOKEN][CREATE] 토큰발급 시작. @발신프로필키=[${senderKey}]", "INFO")/>

                <#assign tokenInfo = commonFunction_requestTokenInfo(channelInfo)/>

                <#if tokenInfo?has_content && tokenInfo.code == "200">
                    <#assign r = m1.shareput(senderKey, tokenInfo)/>

                    <#assign r = m1.log("[CONF][TOKEN][CREATE] 토큰정보 발급완료. @발신프로필키=[${senderKey}]", "INFO")/>
                    <#assign r = m1.log(tokenInfo, "DEBUG")/>
                <#else>
                    <#assign isStop = true/>
                </#if>

            </#if>
        </#list>

    </#if>
    
</#if>

<#if isStop>
    <#--  TASK처리 이상발생시 프로세스중지하도록 상태변경  -->
    <#assign r = m1.shareput("isStop", isStop)/>
    <#assign returnCode = -9/>
</#if>

<#assign r = m1.stack("return", returnCode)/>