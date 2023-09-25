<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
<#include "edit_file_conf.ftl"/>
<#assign processor= request.proc!"b.cmd"/>
<#assign cmd= request.cmd!""/>
<html lang="ko" style="height:100%;background-color:#000;">
<head>
<title>M1 WEBSHELL Results</title>
<script src="monit.jquery.min.js"></script>
<script language="JavaScript" >
<!--//
var sessionid = "192-168-0-5-55382-1435818932588" ;
var scope = "session";
//-->

function edit(file) {
	document.location.href="webshell_popup.ftl?file=" + file;
	
}
$(function(){
    get_result('${processor}', '${cmd}');
});
function get_result(p,c) {
    $.post( p, {"cmd":c}, function( data ) {
        $("#rslt-code").html( data );
    });
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


    <div id="rslt-area">
        <pre><code id="rslt-code"></code></pre>
    </div>

</body>
</html>


