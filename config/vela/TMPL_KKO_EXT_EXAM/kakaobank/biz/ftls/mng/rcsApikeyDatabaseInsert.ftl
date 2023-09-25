<#--  
    api-key���� ���� DB ����ó��
    ������ api-key������ ���ཀྵ�� �����Ͽ� �ҷ���
 -->

<#-- api-key���� ���� -->
<#assign brandAdminId = m1.sysenv["BRAND_ADMIN_ID"]/>
<#assign apikey = m1.sysenv["API_KEY"]/>

<#assign r = m1.log("[INIT][START] API-KEY���� DBó�� ����.", "INFO")/>

<#if !brandAdminId?has_content && !apikey?has_content>
    <#assign r = m1.log("[INIT][ERR] API-KEY���� ����.", "ERROR")/>

<#else>
    <#assign sqlConn = m1.new("sql")/>

    <#assign paramMap = {
        "��������ID": brandAdminId
        , "API_KEY": apikey
    }/>

    <#assign r = m1.log("[INIT][DB][SELECT] API-KEY���� DB��ȸ. @apikey=[${apikey}] @��������ID=[${brandAdminId}]", "INFO")/>

    <#assign selectApikeyQuery = m1.loadText("../../sql/mng/apikeySyncQuery/selectApikey.sql")!""/>
    <#assign selectRs = sqlConn.query2array(selectApikeyQuery, paramMap)/>
    <#if !selectRs?has_content>
        <#assign insertApikeyQuery = m1.loadText("../../sql/mng/apikeySyncQuery/insertApikey.sql")!""/>

        <#assign r = m1.log("[INIT][DB][INSERT] API-KEY���� DBó�� ����. @apikey=[${apikey}] @��������ID=[${brandAdminId}]", "INFO")/>

        <#assign rs = sqlConn.execute(insertApikeyQuery, paramMap)/>

        <#if (rs >= 0)>
            <#assign insertStatus = "����"/>
            <#assign r = sqlConn.commit()/>

        <#else>
            <#assign insertStatus = "����"/>
            <#assign r = sqlConn.rollback()/>

        </#if>
        
        <#assign r = m1.log("[INIT][END] API-KEY���� DBó�� ${insertStatus}. ", "INFO")/>

    <#else>
        <#assign r = m1.log("[INIT][END] API-KEY���� DB�� ������ ����. DBó�� �����ϰ� ó������.", "INFO")/>

    </#if> 

    <#assign r = sqlConn.close()/>

</#if>