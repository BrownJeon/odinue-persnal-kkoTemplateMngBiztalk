<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
<#assign filetext = m1.loadText(request.file)/>
<html lang="ko">
<head>
	<title>M1 Edit (${request.file})</title>
    <link rel="stylesheet" type="text/css" href="run_shell.light.css" />
	<link rel="stylesheet" type="text/css" href="codemirror/lib/codemirror.css">
    <link rel="stylesheet" type="text/css" href="codemirror/addon/display/fullscreen.css">
    <style type="text/css">
        .CodeMirror { height: auto; /* min-height: 300px; */ padding-bottom: 30px; }
    </style>

    <script src="monit.jquery.min.js"></script>
    <script src="codemirror/lib/codemirror.js"></script>
    <script src="codemirror/mode/meta.js"></script>
    <script src="codemirror/addon/mode/loadmode.js"></script>
    <script src="codemirror/addon/display/fullscreen.js"></script>
    <script src="codemirror/addon/edit/matchbrackets.js"></script>
	<script>
	<!--//
	var sessionid = "192-168-0-5-55382-1435818932588" ;
	var scope = "session";
	//-->
	function savefile() {
		var ok = confirm("������ ${request.file} �� ���� �Ͻðڽ��ϱ�?");
		if (ok) {
			document.fileedit.submit();
            		//window.close();
		}
	}

	function goList() {
		var root = '${request.root}';
        var pattern = '${request.pattern}';
		if( root && pattern ) {
            document.location.href = 'webshellx.ftl?showme=&ROOT=' + root + '&PATTERN=' + pattern;
        } else {
            document.location.href = 'webshellx.ftl?showme=';
		}
	}
	</script>
	
	
	
	
<script language="JavaScript" >
<!--//
var sessionid = "192-168-0-5-55382-1435818932588" ;
var scope = "session";
//-->
function execute() {
	document.execute.name.value = document.fileedit.name.value;
	document.execute.type.value = "select";
	document.execute.sql.value = document.fileedit.text.value;
	document.execute.submit();
}
</script>

	
</head>
<body>
	<div id="content">

		<div id="sbtt">
			<div id="smsqm-sbtt">
				<span>EDIT - </span>
			</div>			
		</div>
		<form name="fileedit" action="webshell_diff.ftl" method="post">
		<input type="hidden" name="file" value="${request.file}"/>
		<div id="body">
			<div id="smsqm-area">
				<div class="qmbox r5">
					<div class="qmtl">
						<span>${request.file} <a href="javascript:savefile()">[����]</a></span>
					</div>
					<div>
						<textarea id="text" name="text" style="width:99%;">${filetext?html}</textarea>
					</div>
                    <script>
                        var editor = CodeMirror.fromTextArea(document.getElementById("text"), {
                            lineNumbers: true,
                            matchBrackets: true,
                            extraKeys: {
                                "F11": function(cm) {
                                    cm.setOption("fullScreen", !cm.getOption("fullScreen"));
                                },
                                "Esc": function(cm) {
                                    if (cm.getOption("fullScreen")) cm.setOption("fullScreen", false);
                                }
                            }
                        });

                        var mode = '${request.file}'.replace('.ftl', '').split('.').pop();
                        var info = CodeMirror.findModeByExtension(mode);
                        if( info ) {
                            editor.setOption("mode", info.mode);
							CodeMirror.autoLoadMode(editor, info.mode);
                        }
                    </script>
				</div>
			</div>
		</div>
		</form>


	<#if request.file?ends_with("sql") >
		<form name="execute" method="post" action="recover_execute.ftl">
			<input type="hidden" name="name" value=""/>
			<input type="hidden" name="type" value=""/>
			<input type="hidden" name="sql" value=""/>
		</form>
			<a href="javascript:execute()">[SQL����]</a>	
	</#if>
	
	</div>
	
</body>
</html>


