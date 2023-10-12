<#--
    ��ū����(���� �� ����)
-->

<#-- ���ø���û �����Լ� -->
<#include "include/request.include_function.ftl"/>

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>

<#--  ���μ��� ��������  -->
<#assign isStop = m1.shareget("isStop")!false/>

<#--  0:����, -1: ��⵿, -9:����  -->
<#assign returnCode = 0/>

<#if !isStop>

    <#--  �������� �Ǵ��Ͽ� �������ÿ� ��ū����ó��  -->
    <#assign authYn = m1.shareget("authYn")/>
    <#if authYn?upper_case == "Y">
        <#assign channelList = m1.shareget("channelList")/>

        <#list channelList as senderKey, channelInfo>
            <#assign r = m1.log("[CONF][TOKEN][CHECK] ��ū�߱� ��ȸ üũ. @�߽�������Ű=[${senderKey}]", "DEBUG")/>

            <#assign tokenInfo = m1.shareget(senderKey)!{}/>
            <#if 
                tokenInfo?has_content
            >
                <#assign interval = 30*60*1000/> <#-- �����Ͻ� 30������ ����ó�� -->
                <#assign expiresIn = tokenInfo.expiresIn!"0"/>
                <#assign expiresTimeMillis = expiresIn?number - m1.ymdhms2millis() - interval/>
                <#--  ����ð��� �����ϰ� ����ð� 30�� ���� ��� ��ū����ó��  -->
                <#if (expiresIn > 0) && (expiresTimeMillis < 0)>
                    <#assign r = m1.log("[CONF][TOKEN][UPDATE] ��ū ����� ���� ����ó��. @�߽�������Ű=[${senderKey}]", "INFO")/>

                    <#assign tokenInfo = commonFunction_requestTokenInfo(channelInfo)/>

                    <#if tokenInfo?has_content && tokenInfo.code == 200>
                        <#assign r = m1.shareput(senderKey, tokenInfo)/>

                        <#assign r = m1.log("[CONF][TOKEN][CREATE] ��ū���� ����. @�߽�������Ű=[${senderKey}]", "INFO")/>
                        <#assign r = m1.log(tokenInfo, "DEBUG")/>  
                    <#else>
                        <#assign isStop = true/>
                    </#if>
                </#if>
            <#else>
                <#assign r = m1.log("[CONF][TOKEN][CREATE] ��ū�߱� ����. @�߽�������Ű=[${senderKey}]", "INFO")/>

                <#assign tokenInfo = commonFunction_requestTokenInfo(channelInfo)/>

                <#if tokenInfo?has_content && tokenInfo.code == "200">
                    <#assign r = m1.shareput(senderKey, tokenInfo)/>

                    <#assign r = m1.log("[CONF][TOKEN][CREATE] ��ū���� �߱޿Ϸ�. @�߽�������Ű=[${senderKey}]", "INFO")/>
                    <#assign r = m1.log(tokenInfo, "DEBUG")/>
                <#else>
                    <#assign isStop = true/>
                </#if>

            </#if>
        </#list>

    </#if>
    
</#if>

<#if isStop>
    <#--  TASKó�� �̻�߻��� ���μ��������ϵ��� ���º���  -->
    <#assign r = m1.shareput("isStop", isStop)/>
    <#assign returnCode = -9/>
</#if>

<#assign r = m1.stack("return", returnCode)/>