<#assign sqlScan=m1.loadText("stat/sql/scan_days.sql")/>
<#assign sqlClear=m1.loadText("stat/sql/delete_day_stats.sql")/>
<#assign sqlInsert=m1.loadText("stat/sql/insert_day_stats.sql")/>

<#assign stat=m1.new("java:com.odinues.m1vela.ftl.obj.TObjStatDays")/>

<#assign r=stat.scan(sqlScan)/>
<#assign r=m1.log("scan"+r,"INFO")/>
<#assign x=m1.print("SCANNED")/>

<#assign r=stat.exec(sqlClear)/>
<#assign r=m1.log("clear"+r,"INFO")/>
<#assign x=m1.print("CLEARED")/>

<#assign r=stat.insert(sqlInsert)/>
<#assign r=m1.log("insert"+r,"INFO")/>
<#assign x=m1.print("INSERTED")/>