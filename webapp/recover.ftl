<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
<#include "recover_conf.ftl"/>
<html lang="ko">
<head>
<title>M1 RECOVER</title>
<script src="monit.jquery.min.js"></script>
<script language="JavaScript" >
<!--//
var sessionid = "192-168-0-5-55382-1435818932588" ;
var scope = "session";
//-->
function execute(name, type, sql) {
	document.execute.name.value = name;
	document.execute.type.value = type;
	document.execute.sql.value = sql;
	document.execute.submit();
}
</script>
<link rel="stylesheet" type="text/css" href="run_shell.light.css" />
</head>
<body>
	<form name="execute" method="post" action="recover_execute.ftl">
		<input type="hidden" name="name" value=""/>
		<input type="hidden" name="type" value=""/>
		<input type="hidden" name="sql" value=""/>
	</form>
	<div id="content">
		<div id="head">
			<div class="logorecover"></div>
		</div>
		<div id="sbtt">
			<div id="smsqm-sbtt">
				<span>SQL</span>
			</div>			
		</div>
		<div id="body">
			<div id="smsqm-area">
<#list recover_conf?keys as key >
				<div class="qmbox r5">
					<div class="qmtl">
						<span>${key}</span>
					</div>
					<div class="qmtr">
						<table class="qmtrtbl" id="">
						<thead>
						<tr>
							<th width="20%" class="q">모듈명</th>
							<th width="20%">타입</th>
							<th >수행 쉘</th>
							<th width="20%">명령</th>
						</tr>
						</thead>
						<tbody>
	<#list recover_conf[key]?keys as qkey>
		<#assign q=recover_conf[key][qkey] />
		<#if qkey_index/2 == 1 >
			<#assign oddevn="odd" />
		<#else>
			<#assign oddevn="evn" />
		</#if>
							<tr class="${oddevn}">
								<td class="q">${qkey}</td>
								<td>${q['type']}</td>
								<td>${q['sql']}</td>
								<td>
									<a href="javascript:execute('${qkey}', '${q['type']}', '${q['sql']}')">[작업]</a>									
								</td>
							</tr>
	</#list>
						</tbody>
						</table>
					</div>
				</div>
</#list>
			</div>
		</div>
		
		

	</div>
	
</body>
</html>


