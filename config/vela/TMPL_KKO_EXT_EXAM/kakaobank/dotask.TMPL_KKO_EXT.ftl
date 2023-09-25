<#--
    ��ū����(���� �� ����)
-->

<#-- ���ø���û �����Լ� -->
<#include "include/request.include_function.ftl"/>

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>

<#-- �귣��ID��� -->
<#assign brandInfoMap = m1.shareget("brandInfoMap")/>

<#-- 
    �귣��ID����� �귣��ID���� ��ū����ó��
-->
<#list brandInfoMap as brandId, brandInfo>
    <#assign r = m1.log("[CONF][TOKEN][CHECK] ��ū�߱� ��ȸ üũ. @�귣��ID=[${brandId}]", "DEBUG")/>

    <#assign tokenInfo = m1.shareget(brandId)!{}/>
    <#if 
        tokenInfo?has_content
    >
        <#assign interval = 30*60*1000/> <#-- �����Ͻ� 30������ ����ó�� -->
        <#assign expiresTimeMillis = tokenInfo.expiresIn?number - m1.ymdhms2millis() - interval/>
        <#if (expiresTimeMillis < 0)>
            <#assign r = m1.log("[CONF][TOKEN][UPDATE] ��ū ����� ���� ����ó��. @�귣��ID=[${brandId}]", "INFO")/>

            <#assign tokenInfo = commonFunction_requestTokenInfo(brandInfo)/>

            <#if tokenInfo?has_content && tokenInfo.code == 200>
                <#assign r = m1.shareput(brandId, tokenInfo)/>

                <#assign r = m1.log("[CONF][TOKEN][CREATE] ��ū���� ����. @�귣��ID=[${brandId}]", "INFO")/>
                <#assign r = m1.log(tokenInfo, "DEBUG")/>  
            </#if>
        </#if>
    <#else>
        <#assign r = m1.log("[CONF][TOKEN][CREATE] ��ū�߱� ����. @�귣��ID=[${brandId}]", "INFO")/>

        <#assign tokenInfo = commonFunction_requestTokenInfo(brandInfo)/>

        <#if tokenInfo?has_content && tokenInfo.code == 200>
            <#assign r = m1.shareput(brandId, tokenInfo)/>

            <#assign r = m1.log("[CONF][TOKEN][CREATE] ��ū���� �߱޿Ϸ�. @�귣��ID=[${brandId}]", "INFO")/>
            <#assign r = m1.log(tokenInfo, "DEBUG")/>
        </#if>

    </#if>

</#list>





