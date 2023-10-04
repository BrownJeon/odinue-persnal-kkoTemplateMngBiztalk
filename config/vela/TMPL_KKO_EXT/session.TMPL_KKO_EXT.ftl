<#-- 공통 설정파일 로딩-->
<#include "include/request.include_function.ftl"/>

<#-- 전문 규격 로딩 (Load FFDMessage) -->
<#assign m1home = m1.sysenv["M1_HOME"]/>
<#assign r = m1.loadffdef("${m1home}/config/vela-mdefs/M1.def") />

<#-- api baseURL 설정 -->
<#assign tmplMngrUrl = m1.shareget("tmplMngrUrl")/>
<#--  템플릿 단건조회 api  -->
<#assign selectTemplateOne = m1.shareget("selectTemplateOne")/>


<#-- 승인템플릿 존재여부 조회 쿼리 -->
<#assign selectKkoTemplateQuery = m1.loadText("include/biz/sql/mng/kkoTemplateSyncQuery/selectKkoTemplate.sql")!""/>

<#-- 승인템플릿 동기화처리 쿼리 -->
<#assign insertKkoTemplateQuery =  m1.loadText("include/biz/sql/mng/kkoTemplateSyncQuery/insertKkoTemplate.sql")!""/>

<#--  브랜드정보 조회 쿼리  -->
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


<#-- 템플릿 동기화 기능 -->
<#list profileKeyInfoMap as profileKey, clientInfo>

    <#assign kkoTemplateSyncParamMap = m1.editable({})/>

    <#assign clientId = clientInfo.clientId!""/>
    <#assign clientSecret = clientInfo.clientSecret!""/>

    <#assign authYn = m1.shareget("authYn")!"n"/>
    <#if authYn?upper_case == "N">
        <#assign r = m1.log("[TMPL][INIT] 인증 미사용으로 인한 인증처리 없음.", "DEBUG")/>

    <#elseif authYn?upper_case == "Y">
        <#--
            프로세스 기동시 최초 토큰발급 처리
        -->
        <#assign r = m1.log("="?left_pad(80, "="), "INFO")/>
        <#assign r = m1.log("[INIT][TOKEN][CREATE][START] 토큰발급 시작. @발신프로필키=[${profileKey}] @clientId=[${clientId}] @clientSecret=[${clientSecret}]", "INFO")/>
        <#assign tokenInfo = commonFunction_requestTokenInfo({
            "clientId": clientId
            , "clientSecret": clientSecret
        })/>

        <#if tokenInfo?has_content && tokenInfo.code == "200">
            <#assign r = m1.shareput(profileKey, tokenInfo)/>

            <#assign r = m1.log("[INIT][TOKEN][CREATE][SUCC] 토큰정보 발급. @토큰정보=[${m1.toJsonBytes(tokenInfo!{})}]", "INFO")/>
        <#else>
            <#assign r = m1.log("[INIT][TOKEN][CREATE][ERR] 토큰정보 없음. 프로세스 종료.", "ERROR")/>

            <#break/>

        </#if>

        <#assign r = kkoTemplateSyncParamMap.put("token", tokenInfo.accessToken!"")/>

    <#else>
        <#assign r = m1.log("[INIT][ERR] 인증사용여부 비정상 값유입. 설정값은 Y / N으로 설정가능합니다. @suthYn=[${authYn}]", "ERROR")/>
    </#if>


    <#assign syncTemplateYn = m1.shareget("syncTemplateYn")!"n"/>
    <#if syncTemplateYn?upper_case == "N">
        <#assign r = m1.log("[TMPL][INIT] 동기화기능 미사용으로 인한 동기화처리 없음.", "DEBUG")/>

    <#elseif syncTemplateYn?upper_case == "Y">
        <#--  
            RBC 템플릿 동기화처리
                - 승인된 템플릿을 기준으로 동기화처리
        -->
        <#assign r = m1.log("="?left_pad(40, "=") + " 승인/승인대기 템플릿 동기화처리 시작." + "="?left_pad(40, "="), "INFO")/>

        <#assign r = kkoTemplateSyncParamMap.merge({
            "sqlConn": sqlConn
            , "query": {
                "selectQuery": selectKkoTemplateQuery
                , "insertQuery": insertKkoTemplateQuery
            }
            , "requestUrl": "${tmplMngrUrl}/${selectTemplateOne}"
        }, "true")/>

        <#assign resultMap = commonFunction_kko2dbSync("KKO_TMPL", kkoTemplateSyncParamMap)/>
        
        <#if resultMap?has_content && resultMap.code == "200">
            <#assign r = m1.log("[RBC][SYNC][TMPL][SUCC] 승인/승인대기 동기화 성공.", "INFO")/>
        
        <#else>
            <#assign r = m1.log("[RBC][SYNC][TMPL][FAIL] 승인/승인대기 동기화 실패.", "ERROR")/>

        </#if>

        <#assign r = m1.log("="?left_pad(40, "=") + " 승인/승인대기 템플릿 동기화처리 완료." + "="?left_pad(40, "="), "INFO")/>

    <#else>
        <#assign r = m1.log("[INIT][ERR] 동기화사용여부 비정상 값유입. 설정값은 Y / N으로 설정가능합니다. @syncTemplateYn=[${syncTemplateYn}]", "ERROR")/>
    </#if>

</#list>

<#assign r = sqlConn.close()/>