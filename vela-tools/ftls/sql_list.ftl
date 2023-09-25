<#assign r=m1.stack("return",false)/>
<#assign tot_count=0/>

<#assign ymdhms=m1.now()?string("yyyyMMddHHmmss")/>
<#assign ymd=ymdhms?substring(0,8)/>

<#assign defdir=m1.sysenv["M1_HOME"] + "/config/vela-mdefs"/>


<#assign tselect=m1.loadText("batch.t16.select.sql") />



<#assign sql=m1.new("sql") />
<#assign fw=m1.new("file") />

<#assign r=fw.open("./aaa.txt","w") />

<#assign rs=sql.query2list(tselect, {}) />

<#list rs as row>
   
 
   <#assign r=m1.log(row,"INFO") />
   <#assign r=fw.write( row["업무식별자"] + "," 
                       + row["업무명"] + "," 
                        +  row["부점코드"] + "\n" 
                ) />
	<#assign tot_count=row_index+1 /> 
</#list> 


<#assign r=fw.close() />
<#assign r=sql.close(rs) />

<#assign r=m1.print("tot_count " + tot_count ) /> 

<#assign r=m1.stack("return",true)/>