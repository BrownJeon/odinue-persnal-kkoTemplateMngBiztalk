<#assign includeExtFtlPath = "../TMPL_KKO_EXT/include"/>

<#-- ���� �������� �ε�-->
<#include "${includeExtFtlPath}/config.include_variable.ftl"/>

<#-- ���� �ε� -->
<#assign pollkeyQuery = m1.loadText("${includeExtFtlPath}/biz/sql/task/pollingReqestDataQuery/pollkey.sql")/>
<#assign r = m1.session("pollkeyQuery", pollkeyQuery)/>

<#assign pollUpdateQuery = m1.loadText("${includeExtFtlPath}/biz/sql/task/pollingReqestDataQuery/pollUpdate.sql")/>
<#assign r = m1.session("pollUpdateQuery", pollUpdateQuery)/>

<#assign selectPollQuery = m1.loadText("${includeExtFtlPath}/biz/sql/task/pollingReqestDataQuery/selectPoll.sql")/>
<#assign r = m1.session("selectPollQuery", selectPollQuery)/>