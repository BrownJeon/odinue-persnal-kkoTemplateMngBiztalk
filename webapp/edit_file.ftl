<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
<#include "edit_file_conf.ftl"/>
<html lang="ko">
<head>
<title>M1 Edit Config</title>
<script src="monit.jquery.min.js"></script>
<script language="JavaScript" >
<!--//
var sessionid = "192-168-0-5-55382-1435818932588" ;
var scope = "session";
//-->

function edit(file) {
	document.location.href="edit_file_popup.ftl?file=" + file;
}

</script>
<link rel="stylesheet" type="text/css" href="run_shell.light.css" />
</head>
<body>
	<div id="content">
		<div id="head">
            <div class="logoconfig" onclick="history.back();"></div>
		</div>
		<div id="sbtt">
			<div id="smsqm-sbtt">
				<span>FILE</span>
			</div>			
		</div>
		<div id="body">
			<div id="smsqm-area">
<#list edit_file_conf?keys as key >
				<div class="qmbox r5">
					<div class="qmtl">
						<span>${key}</span>
					</div>
					<div class="qmtr">
						<table class="qmtrtbl" id="">
						<thead>
						<tr>
							<th width="20%" class="q">모듈명</th>
							<th >파일명</th>
							<th width="20%">명령</th>
						</tr>
						</thead>
						<tbody>
	<#list edit_file_conf[key]?keys as qkey>
		<#assign q=edit_file_conf[key][qkey] />
		<#if qkey_index/2 == 1 >
			<#assign oddevn="odd" />
		<#else>
			<#assign oddevn="evn" />
		</#if>
							<tr class="${oddevn}">
								<td class="q">${qkey}</td>
								<td><a href="javascript:edit('${q['file']}')">${q['file']}</a></td>
								<td>
									<a href="javascript:edit('${q['file']}')">[편집]</a>
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


