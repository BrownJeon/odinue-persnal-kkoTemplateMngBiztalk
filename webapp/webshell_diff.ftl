<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
<#assign filetext = m1.loadText(request.file)/>
<html lang="ko">
<head>
<title>M1 Edit (${request.file})</title>
<style>
table.diff_text { border:1px solid #bbb; }
table.diff_text td.lineno {
  border-style:solid; border-color:#bbb; border-width:0 1px;
  background:#ddd;
  color:#999;
}
table.diff_text td { border:none; background:#FFFAFA; }
table.diff_text .add td.difftext { background:#DDFFDD; }
table.diff_text .del td.difftext { background:#FFDDDD; }
</style>
<script src="monit.jquery.min.js"></script>
<script src="diff.js"></script>
<script language="JavaScript" >
<!--//
var sessionid = "192-168-0-5-55382-1435818932588" ;
var scope = "session";
//-->
function savefile() {
	var ok = confirm("정말로 ${request.file} 을 저장 하시겟습니까?");
	if (ok) {
		document.fileedit.submit();
	}
}

function diff() {
	var orgText = $("#org").text().replace(/</g,"&lt;").replace(/>/g,"&gt;");
	var newText = $("#text").text().replace(/</g,"&lt;").replace(/>/g,"&gt;");
	$("#display").html(diff_text(orgText, newText));
	$("#display_new").html(line_text(newText));
}
</script>
<link rel="stylesheet" type="text/css" href="run_shell.light.css" />
</head>
<body onload="diff();">
	<div id="content">
		<div id="head">
			<div class="logoconfig"></div>
		</div>
		<div id="sbtt">
			<div id="smsqm-sbtt">
				<span>DIFF</span>
			</div>			
		</div>
		<form name="fileedit" action="webshell_save.ftl" method="post">
		<input type="hidden" name="file" value="${request.file}"/>
		<div id="body">
			<div id="smsqm-area">
				<div class="qmbox r5">
					<div class="qmtl">
						<span>${request.file} <a href="javascript:savefile()">[저장]</a></span>
					</div>
					<div class="qmtr" align="left">
						<table><tr><td></td></tr>
						<tr><td></td></tr></table>
						<pre id="display" style="border:2px solid Black;"></pre>
						<pre id="display_new" style="border:2px solid Black;"></pre>
					</div>
					<textarea name="text" id="text" style="display:none;">${request.text?replace("<","&lt;")?replace(">","&gt;")}</textarea>
					
				</div>
			</div>
		</div>
		</form>
	</div>
	<textarea name="org" id="org" style="display:none;">${filetext?replace("<","&lt;")?replace(">","&gt;")}</textarea>
</body>
</html>
