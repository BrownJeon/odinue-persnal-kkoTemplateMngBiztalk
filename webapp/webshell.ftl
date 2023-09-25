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
	document.location.href="webshell_popup.ftl?file=" + file;
	
}

</script>
<link rel="stylesheet" type="text/css" href="run_shell.light.css" />
</head>
<body>
	<div id="content" style="min-width:860px;">
		<div id="head">
			<div class="logowebshell"></div>
		</div>

		<div id="body">

            <#assign rootpath = request.ROOT!m1.sysenv["M1_HOME"]/>
            <#assign pattern = request.PATTERN!"*.sh,*.sql,*.properties,*.ftl,*.env"/>
            <#assign grep= request.GREP!""/>
            <#assign replace= request.REPLACE!""/>
            <#assign match= request.match!""/>
            <#assign change= request.change!""/>
            <#assign query= request.query!"list"/>


            <div id="option-area">

<form action="webshellx.ftl" method="post" enctype="multipart/form-data" target="ishell">
                <div class="option-grp">
                    <table style="width:860px;">
                    <thead>
                    <tr>
                        <th style="width:100px;"></th>
                        <th style="width:60px;"></th>
                        <th style="width:200px;"></th>
                        <th style="width:100px;"></th>
                        <th style="width:80px;"></th>
                        <th style="width:200px;"></th>
                        <th style="width:100px;"></th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td class="h">파일리스트</td>
                        <td>ROOT</td>
                        <td><input type="text" name="ROOT" value="${rootpath}"></td>
                        <td><br/></td>
                        <td>PATTERN</td>
                        <td><input type="text" name="PATTERN" value="${pattern}"></td>
                        <td><input type="submit" name="query" value="list"></td>
                    </tr>
                    <tr>
                        <td class="h">내용검색옵션</td>
                        <td>SEARCH</td>
                        <td><input type="text" name="GREP" value="${grep}"></td>
                        <td><input type="submit" name="query" value="grep"></td>
                        <td>REPLACE TO</td>
                        <td><input type="text" name="REPLACE" value="${replace}"></td>
                        <td><input type="submit" name="query" value="replace"></td>
                    </tr>
                    <tr>
                        <td class="h">파일명변경</td>
                        <td>MATCH</td>
                        <td><input type="text" name="match" value="${match}"></td>
                        <td><br/></td>
                        <td>CHANGE TO</td>
                        <td><input type="text" name="change" value="${change}"></td>
                        <td><input type="submit" name="query" value="rename"></td>
                    </tr>
                    </table>
                </div>

                <div class="option-grp">
                    <table style="width:860px;">
                    <thead>
                    <tr>
                        <th style="width:100px;"></th>
                        <th style="width:60px;"></th>
                        <th style="width:200px;"></th>
                        <th style="width:100px;"></th>
                        <th style="width:80px;"></th>
                        <th style="width:200px;"></th>
                        <th style="width:100px;"></th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td class="h">파일올리기</td>
                        <td>PATH</td>
                        <td><input type="text" name="filepath" value="${uploaddir}" disabled></td>
                        <td><br/></td>
                        <td>FILE</td>
                        <td><input type="file" name="upload" value="upload"></td>
                        <td>
                            <input type="submit" name="query" value="upload">
                            <input type="hidden" name="showme" value="themoney">
                        </td>
                    </tr>
                    </tbody>
                    </table>
                </div>

</form>
<form action="webshellcmd.ftl" method="post" target="ishell">
                <div class="option-grp">

                    <table style="width:860px;">
                    <thead>
                    <tr>
                        <th style="width:100px;"></th>
                        <th style="width:60px;"></th>
                        <th style="width:200px;"></th>
                        <th style="width:100px;"></th>
                        <th style="width:80px;"></th>
                        <th style="width:200px;"></th>
                        <th style="width:100px;"></th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td class="h">명령실행기</td>
                        <td><input type="hidden" name="proc" value="b.cmd"/><br/></td>
                        <td colspan="4"><input type="text" name="cmd" value="ls -al"></td>
                        <td><input type="submit" name="query" value="run"></td>
                    </tr>
                    </tbody>
                    </table>
                </div>
</form>
            </div>


		</div>
		<div id="sbtt">
			<div id="smsqm-sbtt">
				<span>RESULT</span>
			</div>			
		</div>
		<div id="rslt">

<iframe name="ishell" src="webshellx.ftl" width="100%" height="100%" scroll="yes" frameborder="0"/>

        </div>
		

	</div>
	
</body>
</html>


