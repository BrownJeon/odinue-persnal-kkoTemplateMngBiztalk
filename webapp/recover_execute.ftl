<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
<#assign params = m1.capturereg(request.sql, "@[^\\s,;\\(\\)\\*\\+\\-]+")/>
<html lang="ko">
<head>
<title>M1 RECOVER (${request.name})</title>
<script src="monit.jquery.min.js"></script>
<script language="JavaScript" >
<!--//
var sessionid = "192-168-0-5-55382-1435818932588" ;
var scope = "session";
//-->
function execute_sql() {
	var ok = confirm("정말로 ${request.name} 을 실행 하시겟습니까?");
	if (ok) {
		document.sql_exec.submit();
	}
}
</script>
<link rel="stylesheet" type="text/css" href="run_shell.light.css" />
</head>
<body>
	<div id="content">
		<div id="head">
			<div class="logorecover"></div>
		</div>
		<div id="sbtt">
			<div id="smsqm-sbtt">
				<span>EXECUTE</span>
			</div>			
		</div>
		<form name="sql_exec" action="recover_execute_iframe.ftl" method="post" target="ifr">
		<input type="hidden" name="name" value="${request.name}"/>
		<input type="hidden" name="type" value="${request.type}"/>
		<input type="hidden" name="sql" value="${request.sql}"/>
		<div id="body">
			<div id="smsqm-area">
				<div class="qmbox r5">
					<div class="qmtl">
						<span>${request.name}[${request.type}] <a href="javascript:execute_sql()">[실행]</a></span>
					</div>
					<table class="qmtrtbl" id="" width="100%">
					<tr class="odd"><th class="q" width="20px">파라메터</th><td class="q">
					<table>
<#list params as param >
					<tr><td>@${param}</td><td>&nbsp;<input type="text" name="param_${param}" value=""/><br/></td></tr>
</#list>
					</table>
					</td></tr>
					<tr class="evn"><th class="q" width="20px">쿼리</th><td class="q">${request.sql}</td></tr>
					</table>
					<div class="qmtl">
						<span>OUTPUT</span>
					</div>
					<table class="qmtrtbl" id="" width="99%">
					<tr><td align="center">
					<iframe id="ifr" name="ifr" width="100%" height="400px" src="" frameborder="0" scrolling="no"></iframe>
					</td></tr>
					</table>					
				</div>
			</div>
		</div>
		</form>
	</div>
	
</body>
</html>


