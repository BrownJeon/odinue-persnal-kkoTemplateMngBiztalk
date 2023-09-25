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
	//document.location.href="webshell_popup.ftl?file=" + file;
	window.open("webshell_popup.ftl?file=" + file, "_EDITOR", "toolbar=no, scrollbars=yes, resizable=yes, top=100, left=100, width=850, height=500");
}

</script>
<link rel="stylesheet" type="text/css" href="run_shell.light.css" />
</head>
<body>

            <#assign rootpath = request.ROOT!m1.sysenv["M1_HOME"]/>
            <#assign pattern = request.PATTERN!"*.sh,*.sql,*.properties,*.ftl,*.env"/>
            <#assign grep= request.GREP!""/>
            <#assign replace= request.REPLACE!""/>
            <#assign match= request.match!""/>
            <#assign change= request.change!""/>
            <#assign query= request.query!"list"/>


    


			<div id="smsqm-area">

				<div class="qmbox r5">
					<div class="qmtl">
						<span>${rootpath}</span>
					</div>
					<div class="qmtr">
						<table class="qmtrtbl" id="">
						<thead>
						<tr>
							<th class="q">파일명</th>
							<th class="q">크기</th>
							<th class="q">변경일</th>
							<th width="20%">명령</th>
						</tr>
						</thead>
						<tbody>
	
	<#if query == "list" >
		<#assign filelist = m1.filelist(rootpath,pattern?replace(".","\\.")?replace("*",".*"))/>
	<#elseif query == "grep" && grep!="" >
		<#assign filelist = m1.filelist(rootpath,pattern?replace(".","\\.")?replace("*",".*"),grep)/>
	<#elseif query == "replace">
		<#assign filelist = m1.filelist(rootpath,pattern?replace(".","\\.")?replace("*",".*"),grep,replace)/>
	<#elseif query == "rename" && match != "">
	
		<#assign filelist = m1.renamefiles(rootpath,pattern?replace(".","\\.")?replace("*",".*"),match,change)/>
	<#else>
		<#assign filelist = m1.filelist(rootpath,pattern?replace(".","\\.")?replace("*",".*"))/>

	</#if>
	
	<#if query == "list" >
	<#assign filelist = filelist?sort/>
	</#if>
	
	<#assign fileno = 0/>
	
	<#list filelist as fileinfo>
	    <#assign pos=fileinfo?index_of(",") />
	    
	    
		<#if 0<=pos >
		    <#assign pos2=fileinfo?index_of(",",pos+1) />
			<#assign file=fileinfo?substring(0,pos) />
			<#assign filesz=fileinfo?substring(pos+1,pos2) />
			<#assign filedt=fileinfo?substring(pos2+1) />
		<#else>
			<#assign file=fileinfo />
			<#assign filesz="" />
			<#assign filedt="" />
		</#if>
	
		<#if fileinfo_index%2 == 1 >
			<#assign oddevn="odd" />
		<#else>
			<#assign oddevn="evn" />
		</#if>
							<tr class="${oddevn}">
								<#if file?starts_with(":") >
									<td class="q">${file}</td>
									<td class="q" halign="right">${filesz}줄</td>
									<td class="q">${filedt?html}</td>
									<td>
									</td>

								<#else>
								  <#assign fileno = fileno+1/>
	
									<td class="q">${fileno}&nbsp;<a href="javascript:edit('${file}')">${file}</a></td>
									<td class="q" halign="right">${filesz}</td>
									<td class="q">${filedt}</td>
									<td>
										<a href="javascript:edit('${file}')">[편집]</a>
									</td>
								</#if>
								

							</tr>
	</#list>
						</tbody>
						</table>
					</div>
				</div>

			</div>

	
</body>
</html>


