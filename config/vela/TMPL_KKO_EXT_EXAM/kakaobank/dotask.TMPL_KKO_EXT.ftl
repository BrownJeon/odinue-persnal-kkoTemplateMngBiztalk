<#--
    토큰관리(생성 및 갱신)
-->

<#-- 템플릿요청 공통함수 -->
<#include "include/request.include_function.ftl"/>

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>

<#-- 브랜드ID목록 -->
<#assign brandInfoMap = m1.shareget("brandInfoMap")/>

<#-- 
    브랜드ID목록의 브랜드ID별로 토큰갱신처리
-->
<#list brandInfoMap as brandId, brandInfo>
    <#assign r = m1.log("[CONF][TOKEN][CHECK] 토큰발급 조회 체크. @브랜드ID=[${brandId}]", "DEBUG")/>

    <#assign tokenInfo = m1.shareget(brandId)!{}/>
    <#if 
        tokenInfo?has_content
    >
        <#assign interval = 30*60*1000/> <#-- 만료일시 30분전에 갱신처리 -->
        <#assign expiresTimeMillis = tokenInfo.expiresIn?number - m1.ymdhms2millis() - interval/>
        <#if (expiresTimeMillis < 0)>
            <#assign r = m1.log("[CONF][TOKEN][UPDATE] 토큰 만료로 인한 갱신처리. @브랜드ID=[${brandId}]", "INFO")/>

            <#assign tokenInfo = commonFunction_requestTokenInfo(brandInfo)/>

            <#if tokenInfo?has_content && tokenInfo.code == 200>
                <#assign r = m1.shareput(brandId, tokenInfo)/>

                <#assign r = m1.log("[CONF][TOKEN][CREATE] 토큰정보 갱신. @브랜드ID=[${brandId}]", "INFO")/>
                <#assign r = m1.log(tokenInfo, "DEBUG")/>  
            </#if>
        </#if>
    <#else>
        <#assign r = m1.log("[CONF][TOKEN][CREATE] 토큰발급 시작. @브랜드ID=[${brandId}]", "INFO")/>

        <#assign tokenInfo = commonFunction_requestTokenInfo(brandInfo)/>

        <#if tokenInfo?has_content && tokenInfo.code == 200>
            <#assign r = m1.shareput(brandId, tokenInfo)/>

            <#assign r = m1.log("[CONF][TOKEN][CREATE] 토큰정보 발급완료. @브랜드ID=[${brandId}]", "INFO")/>
            <#assign r = m1.log(tokenInfo, "DEBUG")/>
        </#if>

    </#if>

</#list>





