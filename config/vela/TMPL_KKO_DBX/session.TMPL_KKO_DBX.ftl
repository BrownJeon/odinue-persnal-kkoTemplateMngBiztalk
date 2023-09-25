<#-- 전문 규격 로딩 (Load FFDMessage) -->
<#assign m1home = m1.sysenv["M1_HOME"]/>
<#assign r = m1.loadffdef("${m1home}/config/vela-mdefs/M1.def") />

<#-- VelaFIleQTask에서 읽는 Target 설정 -->
<#assign dbxFileQueueName = m1.shareget("dbxFileQueueName")/>
<#assign r = m1.session("fileq", dbxFileQueueName)/>

<#assign includeExtFtlPath = "../TMPL_KKO_EXT/include"/>

<#-- 템플릿상태 DB처리 쿼리 로딩 -->
<#assign updateTemplateStatusQuery = m1.loadText("${includeExtFtlPath}/biz/sql/task/dbxMngQuery/updateTemplateStatus.sql")/>
<#assign r = m1.session("updateTemplateStatusQuery", updateTemplateStatusQuery)/>
