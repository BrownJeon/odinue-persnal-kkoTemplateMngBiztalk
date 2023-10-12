<#--  
    �߽������ʰ��� ���� DB ����ó��
    ������ �߽������������� ���ཀྵ�� �����Ͽ� �ҷ���
 -->

<#-- �߽����������� ���� -->
<#assign channelId = m1.sysenv["CHANNEL_ID"]/>
<#assign clientId = m1.sysenv["CLIENT_ID"]/>
<#assign clientSecret = m1.sysenv["CLIENT_SECRET"]/>

<#assign r = m1.log("[INIT][START] ������ �������� DBó�� ����.", "INFO")/>

<#if !channelId?has_content && !clientId?has_content && !clientSecret?has_content>
    <#assign r = m1.log("[INIT][ERR] �߽����������� ����. @�߽�������Ű=[${channelId}] @����ID=[${clientId}] @��������Ű=[${clientSecret}]", "ERROR")/>

<#else>
    <#assign sqlConn = m1.new("sql")/>

    <#assign paramMap = {
        "�߽�������Ű": channelId
        , "����ID": clientId
        , "��������Ű": clientSecret
        , "�߰�����1": ""
        , "�߰�����2": ""
        , "�߰�����3": ""
        , "�޸鿩��": "N"
        , "���ܿ���": "N"
        , "����Ͻ�": m1.now()?string("yyyyMMddHHmmss")
        , "�������": "odinue" <#-- ��������� �ʿ�� �ֱ� -->
    }/>

    <#assign r = m1.log("[INIT][DB][SELECT] ������ �������� DB��ȸ. @�߽�������Ű=[${channelId}] @����ID=[${clientId}]", "INFO")/>

    <#assign selectClientInfoQuery = m1.loadText("../../sql/mng/clientInfoSyncQuery/selectClientInfo.sql")!""/>
    <#assign selectRs = sqlConn.query2array(selectClientInfoQuery, paramMap)/>
    <#if !selectRs?has_content>
        <#assign insertClientInfoQuery = m1.loadText("../../sql/mng/clientInfoSyncQuery/insertClientInfo.sql")!""/>

        <#assign r = m1.log("[INIT][DB][INSERT] ������ �������� DBó�� ����. @�߽�������Ű=[${channelId}] @����ID=[${clientId}]", "INFO")/>

        <#assign rs = sqlConn.execute(insertClientInfoQuery, paramMap)/>

        <#if (rs >= 0)>
            <#assign insertStatus = "����"/>
            <#assign r = sqlConn.commit()/>

        <#else>
            <#assign insertStatus = "����"/>
            <#assign r = sqlConn.rollback()/>

        </#if>
        
        <#assign r = m1.log("[INIT][END] ������ �������� DBó�� ${insertStatus}. ", "INFO")/>

    <#else>
        <#assign r = m1.log("[INIT][END] ������ �������� DB�� ������ ����. DBó�� �����ϰ� ó������.", "INFO")/>

    </#if> 

    <#assign r = sqlConn.close()/>

</#if>