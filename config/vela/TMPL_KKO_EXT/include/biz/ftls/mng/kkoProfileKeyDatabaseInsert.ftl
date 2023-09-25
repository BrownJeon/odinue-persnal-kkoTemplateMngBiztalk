<#--  
    발신프로필값에 대한 DB 적재처리
    적재할 발신프로필정보는 실행쉘에 정의하여 불러옴
 -->

<#-- 발신프로필정보 정의 -->
<#assign channelId = m1.sysenv["CHANNEL_ID"]/>
<#assign profileKey = m1.sysenv["PROFILE_KEY"]/>
<#assign categoryCode = m1.sysenv["CATEGORY_CODE"]/>
<#assign channelKey = m1.sysenv["CHANNEL_KEY"]/>

<#assign r = m1.log("[INIT][START] 발신프로필정보 DB처리 시작.", "INFO")/>

<#if !channelId?has_content && !profileKey?has_content>
    <#assign r = m1.log("[INIT][ERR] 발신프로필정보 없음.", "ERROR")/>

<#else>
    <#assign sqlConn = m1.new("sql")/>

    <#assign paramMap = {
        "채널ID": channelId
        , "발신프로필키": profileKey
        , "카테고리코드": categoryCode
        , "결과수신채널": channelKey
    }/>

    <#assign r = m1.log("[INIT][DB][SELECT] 발신프로필정보 DB조회. @발신프로필크=[${profileKey}] @채널ID=[${channelId}]", "INFO")/>

    <#assign selectprofileKeyQuery = m1.loadText("../../sql/mng/profileKeySyncQuery/selectProfileKey.sql")!""/>
    <#assign selectRs = sqlConn.query2array(selectprofileKeyQuery, paramMap)/>
    <#if !selectRs?has_content>
        <#assign insertProfileKeyQuery = m1.loadText("../../sql/mng/profileKeySyncQuery/insertProfileKey.sql")!""/>

        <#assign r = m1.log("[INIT][DB][INSERT] 발신프로필정보 DB처리 시작. @profileKey=[${profileKey}] @채널ID=[${channelId}]", "INFO")/>

        <#assign rs = sqlConn.execute(insertProfileKeyQuery, paramMap)/>

        <#if (rs >= 0)>
            <#assign insertStatus = "성공"/>
            <#assign r = sqlConn.commit()/>

        <#else>
            <#assign insertStatus = "실패"/>
            <#assign r = sqlConn.rollback()/>

        </#if>
        
        <#assign r = m1.log("[INIT][END] 발신프로필정보 DB처리 ${insertStatus}. ", "INFO")/>

    <#else>
        <#assign r = m1.log("[INIT][END] 발신프로필정보 DB에 데이터 존재. DB처리 무시하고 처리종료.", "INFO")/>

    </#if> 

    <#assign r = sqlConn.close()/>

</#if>