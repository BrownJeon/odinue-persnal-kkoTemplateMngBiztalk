<#--  
    �߽������ʰ��� ���� DB ����ó��
    ������ �߽������������� ���ཀྵ�� �����Ͽ� �ҷ���
 -->

<#-- �߽����������� ���� -->
<#assign channelId = m1.sysenv["CHANNEL_ID"]/>
<#assign profileKey = m1.sysenv["PROFILE_KEY"]/>
<#assign categoryCode = m1.sysenv["CATEGORY_CODE"]/>
<#assign channelKey = m1.sysenv["CHANNEL_KEY"]/>

<#assign r = m1.log("[INIT][START] �߽����������� DBó�� ����.", "INFO")/>

<#if !channelId?has_content && !profileKey?has_content>
    <#assign r = m1.log("[INIT][ERR] �߽����������� ����.", "ERROR")/>

<#else>
    <#assign sqlConn = m1.new("sql")/>

    <#assign paramMap = {
        "ä��ID": channelId
        , "�߽�������Ű": profileKey
        , "ī�װ��ڵ�": categoryCode
        , "�������ä��": channelKey
    }/>

    <#assign r = m1.log("[INIT][DB][SELECT] �߽����������� DB��ȸ. @�߽�������ũ=[${profileKey}] @ä��ID=[${channelId}]", "INFO")/>

    <#assign selectprofileKeyQuery = m1.loadText("../../sql/mng/profileKeySyncQuery/selectProfileKey.sql")!""/>
    <#assign selectRs = sqlConn.query2array(selectprofileKeyQuery, paramMap)/>
    <#if !selectRs?has_content>
        <#assign insertProfileKeyQuery = m1.loadText("../../sql/mng/profileKeySyncQuery/insertProfileKey.sql")!""/>

        <#assign r = m1.log("[INIT][DB][INSERT] �߽����������� DBó�� ����. @profileKey=[${profileKey}] @ä��ID=[${channelId}]", "INFO")/>

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