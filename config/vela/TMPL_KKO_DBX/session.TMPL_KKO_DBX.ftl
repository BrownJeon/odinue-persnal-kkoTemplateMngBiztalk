<#-- ���� �԰� �ε� (Load FFDMessage) -->
<#assign m1home = m1.sysenv["M1_HOME"]/>
<#assign r = m1.loadffdef("${m1home}/config/vela-mdefs/M1.def") />

<#-- VelaFIleQTask���� �д� Target ���� -->
<#assign dbxFileQueueName = m1.shareget("dbxFileQueueName")/>
<#assign r = m1.session("fileq", dbxFileQueueName)/>

<#assign includeExtFtlPath = "../TMPL_KKO_EXT/include"/>

<#-- ���ø����� DBó�� ���� �ε� -->
<#assign updateTemplateStatusQuery = m1.loadText("${includeExtFtlPath}/biz/sql/task/dbxMngQuery/updateTemplateStatus.sql")/>
<#assign r = m1.session("updateTemplateStatusQuery", updateTemplateStatusQuery)/>
