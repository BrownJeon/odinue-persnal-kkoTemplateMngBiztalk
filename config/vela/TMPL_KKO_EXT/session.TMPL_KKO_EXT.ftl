<#-- 공통 설정파일 로딩-->
<#include "include/request.include_function.ftl"/>

<#-- 전문 규격 로딩 (Load FFDMessage) -->
<#assign m1home = m1.sysenv["M1_HOME"]/>
<#assign r = m1.loadffdef("${m1home}/config/vela-mdefs/M1.def") />

<#--  발신프로필정보 조회 쿼리  -->
<#assign selecProfileKeyInfoQuery = m1.loadText("include/biz/sql/common/selecProfileKeyInfo.sql")!""/>

<#-- SQL객체 정의 -->
<#assign sqlConn = m1.new("sql")/>

<#assign profileKeyInfoMap = m1.editable({})/>

<#--  발신프로필정보를 조회하여 인증에 필요한 정보 세팅  -->
<#assign r = m1.log("[INIT][CHANNEL_ID] 발신프로필정보 DB조회.", "INFO")/>

<#assign profileKeyInfoRs = sqlConn.query2array(selecProfileKeyInfoQuery, {})/>
<#if (profileKeyInfoRs?size > 0)>
    <#list profileKeyInfoRs as profileKeyInfo>
        <#if !profileKeyInfo?has_content>
            <#assign r = m1.log("[INIT][CHANNEL_ID][ERR] 조회된 데이터 없음.", "ERROR")/>
        </#if>
        
        <#assign profileKey = profileKeyInfo["CHANNEL_ID"]/>

        <#assign expireYn = profileKeyInfo["EXPIRE_YN"]!"N"/>
        <#if expireYn?has_content && expireYn?upper_case == "Y">
            <#assign r = m1.log("[INIT][CHANNEL_ID][EXPIRED] 차단상태의 발신프로필키. @발신프로필키=[${profileKey}]", "INFO")/>
            <#break/>
        </#if>
        <#assign rejectYn = profileKeyInfo["REJECT_YN"]!"N"/>
        <#if  rejectYn?has_content && rejectYn?upper_case == "Y">
            <#assign r = m1.log("[INIT][CHANNEL_ID][REJECT] 휴면상태의 발신프로필키. @발신프로필키=[${profileKey}]", "INFO")/>
            <#break/>
        </#if>

        <#--  conifg에서 로딩한 발신프로필정보에서 DB조회된 발신프로필키로 찾아서 인증정보 세팅  -->
        <#assign channelList = m1.shareget("channelList")/>
        <#assign authInfo = channelList[profileKey]!""/>
        <#if !authInfo?has_content>
            <#assign r = m1.log("[INIT][ERR] properties에 등록된 발송프로필정보가 없음. @발신프로필키=[${profileKey}]", "ERROR")/>
            <#break/>
        <#else>

            <#--  발신프로필키정보 세팅  -->
            <#assign clientInfoMap = commonFunction_getClientInfo(profileKeyInfo, authInfo)/>

            <#assign r = profileKeyInfoMap.put(profileKey, clientInfoMap)/>

        </#if>

    </#list>

    <#assign r = m1.log("[INIT][CHANNEL_ID] 발신프로필정보 세팅 완료. ", "INFO")/>
    <#assign r = m1.log(m1.toJsonBytes(profileKeyInfoMap), "DEBUG")/>

<#else>
    <#assign r = m1.log("[INIT][CHANNEL_ID] 발신프로필정보 없음.", "INFO")/>

</#if>

<#assign r = sqlConn.close(profileKeyInfoRs)/>

<#assign r = m1.shareput("profileKeyInfoMap", profileKeyInfoMap)/>

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
