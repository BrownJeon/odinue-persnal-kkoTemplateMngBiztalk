<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
<#include "run_shell_conf.ftl"/>
<html lang="ko">
<head>
<title>M1 RUN SHELL</title>
<script src="monit.jquery.min.js"></script>
<script language="JavaScript" >
<!--//
var sessionid = "192-168-0-5-55382-1435818932588" ;
var scope = "session";
//-->

function stop(name, command) {
	var ok = confirm("정말로 "+name+"을 중지 하시겟습니까?");
	if (ok) {
		window.open("b.cmd?cmd=" + command + " stop log");
	}
}

function start(name, command) {
	var ok = confirm("정말로 "+name+"을 시작 하시겟습니까?");
	if (ok) {
		window.open("b.cmd?cmd=" + command + " start log");
	}
}

function restart(name, command) {
	var ok = confirm("정말로 "+name+"을 재시작 하시겟습니까?");
	if (ok) {
		window.open("b.cmd?cmd=" + command + " restart log");
	}
}
</script>
<link rel="stylesheet" type="text/css" href="run_shell.light.css" />
</head>
<body>
	<div id="content">
		<div id="head">
			<div class="logoshell"></div>
		</div>
		<div id="sbtt">
			<div id="smsqm-sbtt">
				<span>SHELL</span>
			</div>			
		</div>
		<div id="body">
			<div id="smsqm-area">
<#list run_shell_conf?keys as key >
				<div class="qmbox r5">
					<div class="qmtl">
						<span>${key}</span>
					</div>
					<div class="qmtr">
						<table class="qmtrtbl" id="">
						<thead>
						<tr>
							<th width="20%" class="q">모듈명</th>
							<th >수행 쉘</th>
							<th width="20%">명령</th>
						</tr>
						</thead>
						<tbody>
	<#list run_shell_conf[key]?keys as qkey>
		<#assign q=run_shell_conf[key][qkey] />
		<#if qkey_index/2 == 1 >
			<#assign oddevn="odd" />
		<#else>
			<#assign oddevn="evn" />
		</#if>
							<tr class="${oddevn}">
								<td class="q">${qkey}</td>
								<td>${q['shell']}</td>
								<td>
									<a href="javascript:restart('${qkey}', '${q['shell']}')">[재시작]</a>&nbsp;
									<a href="javascript:start('${qkey}', '${q['shell']}')">[시작]</a>&nbsp;
									<a href="javascript:stop('${qkey}', '${q['shell']}')">[정지]</a>
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


