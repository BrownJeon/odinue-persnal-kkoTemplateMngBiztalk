<#--  
    api-key값에 대한 DB 적재처리
    적재할 api-key정보는 실행쉘에 정의하여 불러옴
 -->

<#-- api-key정보 정의 -->
<#assign brandAdminId = m1.sysenv["BRAND_ADMIN_ID"]/>
<#assign apikey = m1.sysenv["API_KEY"]/>

<#assign r = m1.log("[INIT][START] API-KEY정보 DB처리 시작.", "INFO")/>

<#if !brandAdminId?has_content && !apikey?has_content>
    <#assign r = m1.log("[INIT][ERR] API-KEY정보 없음.", "ERROR")/>

<#else>
    <#assign sqlConn = m1.new("sql")/>

    <#assign paramMap = {
        "기업담당자ID": brandAdminId
        , "API_KEY": apikey
    }/>

    <#assign r = m1.log("[INIT][DB][SELECT] API-KEY정보 DB조회. @apikey=[${apikey}] @기업담당자ID=[${brandAdminId}]", "INFO")/>

    <#assign selectApikeyQuery = m1.loadText("../../sql/mng/apikeySyncQuery/selectApikey.sql")!""/>
    <#assign selectRs = sqlConn.query2array(selectApikeyQuery, paramMap)/>
    <#if !selectRs?has_content>
        <#assign insertApikeyQuery = m1.loadText("../../sql/mng/apikeySyncQuery/insertApikey.sql")!""/>

        <#assign r = m1.log("[INIT][DB][INSERT] API-KEY정보 DB처리 시작. @apikey=[${apikey}] @기업담당자ID=[${brandAdminId}]", "INFO")/>

        <#assign rs = sqlConn.execute(insertApikeyQuery, paramMap)/>

        <#if (rs >= 0)>
            <#assign insertStatus = "성공"/>
            <#assign r = sqlConn.commit()/>

        <#else>
            <#assign insertStatus = "실패"/>
            <#assign r = sqlConn.rollback()/>

        </#if>
        
        <#assign r = m1.log("[INIT][END] API-KEY정보 DB처리 ${insertStatus}. ", "INFO")/>

    <#else>
        <#assign r = m1.log("[INIT][END] API-KEY정보 DB에 데이터 존재. DB처리 무시하고 처리종료.", "INFO")/>

    </#if> 

    <#assign r = sqlConn.close()/>

</#if>