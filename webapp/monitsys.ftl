<#assign r=m1.stack("Content-type","text/xml; charset=euc-kr")/>
<#compress>


<#assign rootpathes=m1.parseJsonValue(m1.loadText(m1.sysenv["M1_HOME"] + "/webapp/diskVolumes.json"))/>

<#assign diskVolumes=[]/>

<#assign vol=m1.new("java:com.odinues.m1vela.ftl.obj.TObjDiskVolumes")/>
<#list rootpathes as p >
	<#assign diskVolumes=diskVolumes+[vol.df(p)]/>
</#list>

</#compress>
<?xml version="1.0" encoding="euc-kr"?>
<rusage>
		<!--시스템 사용정보-->
		<#assign usage=m1.new("java:com.odinues.m1vela.ftl.obj.TObjSystemUsage").usage()/>
		
		<system>
			<#list usage?keys as k >
				<#if k == "NotificationInfo">  	
					<resource name="${k}" desc=""/>
				<#else>
					<resource name="${k}" desc="${usage[k]}"/>
				</#if>
			</#list>
			
			<#assign szFree=usage["FreePhysicalMemorySize"]!0/>
			<#assign szTotal=usage["TotalPhysicalMemorySize"]!1/>
			<resource name="Memory" desc=""
				free="${szFree}"
				total="${szTotal}" 
				fpct="${((szFree/szTotal*10000)?int)/100}"
				upct="${100-((szFree/szTotal*10000)?int)/100}"
			/>

			<#assign szSystemCpuLoad=usage["SystemCpuLoad"]!1/>
			<resource name="Cpu" desc="${((szSystemCpuLoad*10000)?int)/100}" />
		</system>
	

	
		<!--디스크 사용정보-->
		<disk>
			<#list diskVolumes as v >
				<#if (v.totalSpace) == 0>  	
					<#assign totalSpace=1/>
				<#else>
					<#assign totalSpace=v.totalSpace/>
				</#if>
				<resource name="${v.path}"
					desc="" 
					free="${v.freeSpace}"
					total="${totalSpace}" 
					fpct="${((v.freeSpace/totalSpace*10000)?int)/100}"
					upct="${100-((v.freeSpace/totalSpace*10000)?int)/100}"
				/>
			</#list>
		</disk>
	
    <!--DB 사용정보-->
	<db>
			<resource name="unknown"
				desc="0MB/0MB=0% free"
				free="0"
				total="0" 
				fpercent="0"
				upercent="0" />

		</db>
		
<#--
		
	<#assign db=m1.new("sql")/>
	<#assign sql=m1.loadText(m1.sysenv["M1_HOME"] + "/webapp/tablespace.ora.sql")/>
	<#assign tsps=db.query2array(sql)/>
		
		<db>
			<#list tsps as t >
				<resource name="${t.TABLESPACE_NAME}"
				desc="${t.USED}MB/${t.TOTAL_SIZE}MB=${t.USED_P}% free"
				free="${(t.TOTAL_SIZE-t.USED)?int}"
				total="${t.TOTAL_SIZE?int}" 
				fpercent="${100-((t.TOTAL_SIZE-t.USED)/t.TOTAL_SIZE*100)?int}"
				upercent="${((t.TOTAL_SIZE-t.USED)/t.TOTAL_SIZE*100)?int}"
				/>
			</#list>
		</db>
-->
</rusage>
