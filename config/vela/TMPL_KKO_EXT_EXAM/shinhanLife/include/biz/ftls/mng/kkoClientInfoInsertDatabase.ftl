<#--  
    발신프로필값에 대한 DB 적재처리
    적재할 발신프로필정보는 실행쉘에 정의하여 불러옴
 -->

<#-- 발신프로필정보 정의 -->
<#assign channelId = m1.sysenv["CHANNEL_ID"]/>
<#assign clientId = m1.sysenv["CLIENT_ID"]/>
<#assign clientSecret = m1.sysenv["CLIENT_SECRET"]/>

<#assign r = m1.log("[INIT][START] 비즈톡 인증정보 DB처리 시작.", "INFO")/>

<#if !channelId?has_content && !clientId?has_content && !clientSecret?has_content>
    <#assign r = m1.log("[INIT][ERR] 발신프로필정보 없음. @발신프로필키=[${channelId}] @계정ID=[${clientId}] @계정인증키=[${clientSecret}]", "ERROR")/>

<#else>
    <#assign sqlConn = m1.new("sql")/>

    <#assign paramMap = {
        "발신프로필키": channelId
        , "계정ID": clientId
        , "계정인증키": clientSecret
        , "추가정보1": ""
        , "추가정보2": ""
        , "추가정보3": ""
        , "휴면여부": "N"
        , "차단여부": "N"
        , "등록일시": m1.now()?string("yyyyMMddHHmmss")
        , "등록직원": "odinue" <#-- 등록직원은 필요시 넣기 -->
    }/>

    <#assign r = m1.log("[INIT][DB][SELECT] 비즈톡 인증정보 DB조회. @발신프로필키=[${channelId}] @계정ID=[${clientId}]", "INFO")/>

    <#assign selectClientInfoQuery = m1.loadText("../../sql/mng/clientInfoSyncQuery/selectClientInfo.sql")!""/>
    <#assign selectRs = sqlConn.query2array(selectClientInfoQuery, paramMap)/>
    <#if !selectRs?has_content>
        <#assign insertClientInfoQuery = m1.loadText("../../sql/mng/clientInfoSyncQuery/insertClientInfo.sql")!""/>

        <#assign r = m1.log("[INIT][DB][INSERT] 비즈톡 인증정보 DB처리 시작. @발신프로필키=[${channelId}] @계정ID=[${clientId}]", "INFO")/>

        <#assign rs = sqlConn.execute(insertClientInfoQuery, paramMap)/>

        <#if (rs >= 0)>
            <#assign insertStatus = "성공"/>
            <#assign r = sqlConn.commit()/>

        <#else>
            <#assign insertStatus = "실패"/>
            <#assign r = sqlConn.rollback()/>

        </#if>
        
        <#assign r = m1.log("[INIT][END] 비즈톡 인증정보 DB처리 ${insertStatus}. ", "INFO")/>

    <#else>
        <#assign r = m1.log("[INIT][END] 비즈톡 인증정보 DB에 데이터 존재. DB처리 무시하고 처리종료.", "INFO")/>

    </#if> 

    <#assign r = sqlConn.close()/>

</#if>