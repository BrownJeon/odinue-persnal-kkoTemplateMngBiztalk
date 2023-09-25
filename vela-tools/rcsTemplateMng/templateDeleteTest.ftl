<#assign sqlConn = m1.new("sql")/>

<#assign deleteQuery>
    DELETE FROM M1_TEMPLATE_MST
    WHERE
        SEQ = @SEQ

    #DELIM

    DELETE FROM RCS_TMPL_EXT
    WHERE
        SEQ = @SEQ
</#assign>

<#assign deleteQueryList = deleteQuery?split("#DELIM")/>

<#list deleteQueryList as deleteQuery>
    <#assign rs = sqlConn.execute(deleteQuery, {
        "SEQ": 2
    })/>
    <#if (rs < 0)>
        <#assign r = m1.print("DBó�� ����...")/>
        <#assign r = sqlConn.rollback()/>

        <#break/>
    <#else>
        <#assign r = m1.print("DBó�� ����!!")/>

    </#if>
</#list>

<#assign r = m1.print("������ ����ó�� �Ϸ�.")/>

<#assign r = sqlConn.commit()/>
<#assign r = sqlConn.close()/>