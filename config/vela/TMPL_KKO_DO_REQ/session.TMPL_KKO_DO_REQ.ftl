<#-- VelaFIleQTask에서 읽는 Target 설정 -->
<#assign requestFileQueueName = m1.shareget("requestFileQueueName")/>
<#assign r=m1.session("fileq",requestFileQueueName)/>

