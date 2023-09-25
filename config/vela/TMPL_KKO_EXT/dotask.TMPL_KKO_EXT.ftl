<#--
    ��ū����(���� �� ����)
-->

<#-- ���ø���û �����Լ� -->
<#include "include/request.include_function.ftl"/>

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>

<#--  �������� �Ǵ��Ͽ� �������ÿ� ��ū����ó�� ���� ����  -->
<#assign authYn = m1.shareget("authYn")/>
<#if authYn?upper_case == "Y">
    <#-- �߽����������� ��� -->
    <#assign channelList = m1.shareget("channelList")/>

    <#-- 
        �߽����������� ����� �߽�������Ű ���� ��ū����ó��
    -->
    <#list channelList as profileKey, clientInfo>
        <#assign r = m1.log("[CONF][TOKEN][CHECK] ��ū�߱� ��ȸ üũ. @�߽�������Ű=[${profileKey}]", "DEBUG")/>

        <#assign tokenInfo = m1.shareget(profileKey)!{}/>
        <#if 
            tokenInfo?has_content
        >
            <#assign interval = 30*60*1000/> <#-- �����Ͻ� 30������ ����ó�� -->
            <#assign expiresTimeMillis = tokenInfo.expiresIn?number - m1.ymdhms2millis() - interval/>
            <#if (expiresTimeMillis < 0)>
                <#assign r = m1.log("[CONF][TOKEN][UPDATE] ��ū ����� ���� ����ó��. @�߽�������Ű=[${profileKey}]", "INFO")/>

                <#assign tokenInfo = commonFunction_requestTokenInfo(clientInfo)/>

                <#if tokenInfo?has_content && tokenInfo.code == 200>
                    <#assign r = m1.shareput(profileKey, tokenInfo)/>

                    <#assign r = m1.log("[CONF][TOKEN][CREATE] ��ū���� ����. @�߽�������Ű=[${profileKey}]", "INFO")/>
                    <#assign r = m1.log(tokenInfo, "DEBUG")/>  
                </#if>
            </#if>
        <#else>
            <#assign r = m1.log("[CONF][TOKEN][CREATE] ��ū�߱� ����. @�߽�������Ű=[${profileKey}]", "INFO")/>

            <#assign tokenInfo = commonFunction_requestTokenInfo(clientInfo)/>

            <#if tokenInfo?has_content && tokenInfo.code == 200>
                <#assign r = m1.shareput(profileKey, tokenInfo)/>

                <#assign r = m1.log("[CONF][TOKEN][CREATE] ��ū���� �߱޿Ϸ�. @�߽�������Ű=[${profileKey}]", "INFO")/>
                <#assign r = m1.log(tokenInfo, "DEBUG")/>
            </#if>

        </#if>

    </#list>
</#if>




