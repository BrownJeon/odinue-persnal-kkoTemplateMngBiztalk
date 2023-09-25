<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
<html lang="ko">
<head>
<link rel="stylesheet" type="text/css" href="run_shell.light.css" />
</head>
<body>

<#assign sql=m1.new("sql") />
<#assign params = m1.capturereg(request.sql, "@[^\\s,;\\(\\)\\*\\+\\-]+")/>
<#assign paramMap = {} />

<#list params as param >
	<#assign paramMap = paramMap + { param : request["param_"+param]} />
</#list>

<#assign r = m1.log(paramMap, "INFO")/>

<div id="contenta">
<div id="body">
<div id="smsqm-area">
<div class="qmbox r5">
<div class="qmtra">
<#if request.type == "select">
	<#assign reprs = sql.query2list(request.sql, paramMap)/>
	<#assign count = 0/>
	<table class="qmtrtbl" id="">
	<#list reprs as row>
		<#if row_index == 0>
			<thead>
			<tr>
				<#list row?keys as key>
				<th align="center">${key}</th>			
				</#list>
			</tr>
			</thead>
		<tbody>
		</#if>
		<#if row_index/2 == 1 >
			<#assign oddevn="odd" />
		<#else>
			<#assign oddevn="evn" />
		</#if>
		<tr class="${oddevn}">
		<#list row?keys as key>		
			<td align="center">${row[key]!"null"}
			</td>
		</#list>
		<#assign count = count + 1/>
		</tr>
	</#list>
	</tbody>
	</table>
	<#assign r=sql.close(reprs) />
<#else>
	<#assign ret = sql.update(request.sql, paramMap)/>
	
	update result ${ret}
</#if>
</div>
</div>
</div>
</div>
</div>
</body>
</html>