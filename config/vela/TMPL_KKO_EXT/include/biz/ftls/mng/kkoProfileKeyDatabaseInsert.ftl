<#--  
    �߽������ʰ��� ���� DB ����ó��
    ������ �߽������������� ���ཀྵ�� �����Ͽ� �ҷ���
 -->

<#-- �߽����������� ���� -->
<#assign channelId = m1.sysenv["CHANNEL_ID"]/>
<#assign channelInfo = m1.sysenv["CHANNEL_INFO"]/>
<#assign categoryCode = m1.sysenv["CATEGORY_CODE"]/>
<#assign channelKey = m1.sysenv["CHANNEL_KEY"]/>

<#assign r = m1.log("[INIT][START] �߽����������� DBó�� ����.", "INFO")/>

<#if !channelId?has_content && !channelInfo?has_content>
    <#assign r = m1.log("[INIT][ERR] �߽����������� ����. @�߽�������Ű=[${channelId}] @ä������=[${channelInfo}]", "ERROR")/>

<#else>
    <#assign sqlConn = m1.new("sql")/>

    <#assign paramMap = {
        "�߽�������Ű": channelId
        , "ä������": channelInfo
        , "ī�װ��ڵ�": categoryCode
        , "�������ä��": channelKey
    }/>

    <#assign r = m1.log("[INIT][DB][SELECT] �߽����������� DB��ȸ. @�߽�������Ű=[${channelId}] @ä������=[${channelInfo}]", "INFO")/>

    <#assign selectprofileKeyQuery = m1.loadText("../../sql/mng/profileKeySyncQuery/selectProfileKey.sql")!""/>
    <#assign selectRs = sqlConn.query2array(selectprofileKeyQuery, paramMap)/>
    <#if !selectRs?has_content>
        <#assign insertProfileKeyQuery = m1.loadText("../../sql/mng/profileKeySyncQuery/insertProfileKey.sql")!""/>

        <#assign r = m1.log("[INIT][DB][INSERT] �߽����������� DBó�� ����. @�߽�������Ű=[${channelId}] @ä������=[${channelInfo}]", "INFO")/>

        <#assign rs = sqlConn.execute(insertProfileKeyQuery, paramMap)/>

        <#if (rs >= 0)>
            <#assign insertStatus = "����"/>
            <#assign r = sqlConn.commit()/>

        <#else>
            <#assign insertStatus = "����"/>
            <#assign r = sqlConn.rollback()/>

        </#if>
        
        <#assign r = m1.log("[INIT][END] �߽����������� DBó�� ${insertStatus}. ", "INFO")/>

    <#else>
        <#assign r = m1.log("[INIT][END] �߽����������� DB�� ������ ����. DBó�� �����ϰ� ó������.", "INFO")/>

    </#if> 

    <#assign r = sqlConn.close()/>

</#if>