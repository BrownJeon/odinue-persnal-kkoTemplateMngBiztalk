<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
<html lang="ko">
<head>
<title>M1 Install</title>
<#--link rel="stylesheet" type="text/css" href="run_shell.light.css" /-->
<link rel="stylesheet" type="text/css" href="docgen/docgen.min.css" />

<script language="JavaScript" >
<!--//
var sessionid = "192-168-0-5-55382-1435818932588" ;
var scope = "session";
//-->

function edit(file) {
        window.open("webshell_popup.ftl?file=" + file,"new");

}
function runshell(cmd) {
        window.open("b.cmd?query=run&cmd=" + encodeURIComponent(cmd),"cmd");

}
function list(path,pattern) {
        window.open("webshellx.ftl?query=list&ROOT=" + path + "&PATTERN="+encodeURIComponent(pattern),"list");

}

</script>
</head>
<body >

<#assign M1_HOME = m1.sysenv["M1_HOME"]/>

<div class="col-right"><div class="page-content">
                �� ������ ��ü�� <a href="javascript:edit('${M1_HOME + "/webapp/install.ftl"}')">����</a>�մϴ�.
<br/><h2>�ֿ伳ġ ���ϵ�</h2>
$M1_HOME/bin <a href="javascript:list('${M1_HOME + "/bin"}','*.sh,*.env')">����</a> <br/>
$M1_HOME/lib/*.properties <a href="javascript:list('${M1_HOME + "/lib"}','*.properties')">����</a> <br/>
$M1_HOME/lib/*.jar <a href="javascript:list('${M1_HOME + "/lib"}','*.jar')">����</a> <br/>
$M1_HOME/config/vela <a href="javascript:list('${M1_HOME + "/config/vela"}','*.ftl,*.sql,*.json')">����</a> <br/>
$M1_HOME/webapp <a href="javascript:list('${M1_HOME + "/webapp"}','*.ftl)">����</a> <br/>


<br/><h2>bin/host.env ��ġ ȯ�� ���� ����</h2>
��ġȯ�溯�� ������ �����մϴ�. 
 <div class="code-wrapper"><pre class="code-block code-unspecified">bin/host.env </pre>  <a href="javascript:edit('${M1_HOME + "/bin/host.env"}')">����</a> </div>
 M1_HOME�� �����մϴ�. <a href="javascript:runshell('grep M1_HOME= ./host.env' )">���缳��</a><br/>
 M1_HOSTNO�� �����մϴ�. <a href="javascript:runshell('grep M1_HOSTNO= ./host.env' )">���缳��</a><br/>
 M1_DATA�� �����մϴ�. <a href="javascript:runshell('grep M1_DATA= ./host.env' )">���缳��</a><br/>
 M1_LOG�� �����մϴ�. <a href="javascript:runshell('grep M1_LOG= ./host.env' )">���缳��</a><br/>
 
M1 ��ü ������Ű�� �ʱ�ȭ�մϴ�(������� �������!!)
 <div class="code-wrapper"><pre class="code-block code-unspecified">lib/sms.seq </pre>  <a href="javascript:runshell('cat ../lib/sms.seq' )">����</a> </div>

<hr/>

<br/><h2>�����ͺ��̽� ����</h2>
  $M1_HOME/lib/m1_unix.properties �� DB���ἳ���� �մϴ�.<br/>
  jdbcURL, userid, password�� �����մϴ�.<br/>
 <div class="code-wrapper"><pre class="code-block code-unspecified">lib/m1_unix.properties </pre>  <a href="javascript:edit('${M1_HOME + "/lib/m1_unix.properties"}')">����</a> <a href="javascript:runshell('grep SMSConnectionFactory ../lib/m1_unix.properties' )">���缳��</a></div>
  
  ���᳻���� ��ȣȭ�ϰ� �� �ϴ� ��쿡�� �Ʒ��� ���� �����մϴ�. 
<div class="code-wrapper"><pre class="code-block code-unspecified"> encrypt.sh [��ȣȭ�ҹ��ڿ�] </pre>  <a href="javascript:runshell('encrypt.sh ' + window.prompt('��ȣȭ����ڿ�','userid/password') )">����</a></div>
 
  ������ �Ǿ��ٸ� ������ �����Ͽ� ������ �˻��մϴ�.<br/>
  
<hr/>

<br/><h2>ť����/�̸�����/����� ǥ�� ����</h2>
 IPCť�� �����ƴ��� Ȯ���մϴ�. �������� ��������� �޸𸮰� �ִ��� �ý��۸�� ipcs�� �˻��մϴ�.
  <div class="code-wrapper"><pre class="code-block code-unspecified">ipcs </pre>  <a href="javascript:runshell('ipcs' )">����</a></div>

 IPCť�� �����մϴ�.
  <div class="code-wrapper"><pre class="code-block code-unspecified">smsqm.sh install </pre>  <a href="javascript:runshell('smsqm.sh install' )">����</a></div>

 �Ǵ�  IPCť�� �����մϴ�. ����! ��� ���� ���ɼ� ����.
   <div class="code-wrapper"><pre class="code-block code-unspecified">smsqm.sh 0 del </pre>  <a href="javascript:runshell('smsqm.sh 0 del' )">����</a></div>



 ť ���� ���Ŀ��� ť�� �̸��� �����ϴ� bin/rename.sh �� �����Ͽ� �����մϴ�.
 <div class="code-wrapper"><pre class="code-block code-unspecified">rename.sh </pre><a href="javascript:edit('${M1_HOME + "/bin/rename.sh"}')">����</a>  <a href="javascript:runshell('rename.sh')">����</a></div>
 
 ť�� �̸� Ȯ���ϱ� ����  �Ʒ��� ���� �����մϴ�.
 <div class="code-wrapper"><pre class="code-block code-unspecified">smsqm.sh stat a </pre>  <a href="javascript:runshell('smsqm.sh stat a')">����</a></div>
 
 ����͸� �� ť������ ���� �Ʒ� ������ �����մϴ�.  <br/>
 <div class="code-wrapper"><pre class="code-block code-unspecified">bin/smsqm.display </pre>  <a href="javascript:edit('${M1_HOME + "/bin/smsqm.display"}')">����</a></div>

�̸�  Ȯ���ϱ� ����  �Ʒ��� ���� �����մϴ�.
 <div class="code-wrapper"><pre class="code-block code-unspecified">smsqm.sh stat s </pre>  <a href="javascript:runshell('smsqm.sh stat s' )">����</a></div>

����!! �� ���������� �� ����� �����ϸ� ���� smsqm �� ���� �� �ֽ��ϴ�. �Ʒ� ������� Ȯ���մϴ�.<br/>
�͹̳ο��� ����ÿ��� ���������ϴ�.
 <div class="code-wrapper"><pre class="code-block code-unspecified">smsqm.sh psme </pre>  <a href="javascript:runshell('smsqm.sh psme' )">����</a></div>
smsqm�� ����ǰ� �ִٸ� �Ʒ� ������� �����մϴ�.
 <div class="code-wrapper"><pre class="code-block code-unspecified">smsqm.sh killme </pre>  <a href="javascript:runshell('smsqm.sh killme' )">����</a></div>



<hr/>
<br/><h2>�������� (config/vela-mdefs)</h2>
<!-- vela ���� ���丮 ���ϱ� ��������� �������� ���� vela �ڽ� ���丮�� ����Ʈ -->

           <#assign filelist = m1.filelist(M1_HOME + "/config/vela-mdefs",".*\\.def")/>
           <#list filelist as fileinfo>
                        <#assign pos=fileinfo?index_of(",") />
                        <#assign pos2=fileinfo?index_of(",",pos+1) />
                        <#assign file=fileinfo?substring(0,pos) />
                        <#assign filesz=fileinfo?substring(pos+1,pos2) />
                        <#assign filedt=fileinfo?substring(pos2+1) />


                        <div class="code-wrapper"><pre class="code-block code-unspecified">${file?replace(M1_HOME+"/","")} </pre>  <a href="javascript:edit('${file}')">����</a></div>

           </#list>
<hr/>
<br/><h2>�߼������ӿ�ũ ���� (config/vela)</h2>

<!-- vela ���� ���丮 ���ϱ� ��������� �������� ���� vela �ڽ� ���丮�� ����Ʈ -->
<#assign taskdirs = m1.filelist(M1_HOME + "/config/vela",".*")/>
<#list taskdirs as taskdir>
        <#assign pos=taskdir?index_of(",") />
        <#assign pos2=taskdir?index_of(",",pos+1) />
        <#assign filesz=taskdir?substring(pos+1,pos2) />
        <#assign taskhome=taskdir?substring(0,pos) />
        <!-- vela ���� ���丮 ���ϱ� ��������� �������� ���� vela �ڽ� ���丮�� ����Ʈ -->
        <#if filesz == "DIR" && taskhome?matches( ".*[A-Z0-9]$") >
          
                vela task =  ${taskhome}<br/>
                <#assign task = taskhome?replace(M1_HOME + "/config/vela/","")/>
           
           <#assign filelist = m1.filelist(taskhome,".*\\.ftl,.*\\.sql")/>
           <#list filelist as fileinfo>
                        <#assign pos=fileinfo?index_of(",") />
                        <#assign pos2=fileinfo?index_of(",",pos+1) />
                        <#assign file=fileinfo?substring(0,pos) />
                        <#assign filesz=fileinfo?substring(pos+1,pos2) />
                        <#assign filedt=fileinfo?substring(pos2+1) />


                        <div class="code-wrapper"><pre class="code-block code-unspecified">${file?replace(M1_HOME+"/","")} </pre>  <a href="javascript:edit('${file}')">����</a></div>

           </#list>
           
           <#if task?starts_with("SCH") >
            �����ٷ� TASK: ${task}�� �����մϴ�. 
            <div class="code-wrapper"><pre class="code-block code-unspecified">velatask.sh -sch ${task} vela-tools/ftls/velatask.sch.ftl </pre>  <a href="javascript:runshell('${M1_HOME + "/vela-tools/velatask.sh -sch " + task + " vela-tools/ftls/velatask.sch.ftl"}' )">����</a>   <a href="javascript:edit('${M1_HOME +"/vela-tools/ftls/velatask.sch.ftl"}')">����</a></div>
           <#elseif task?starts_with("XCN") >
            �����ٷ� TASK: ${task}�� �����մϴ�. 
            <div class="code-wrapper"><pre class="code-block code-unspecified">velatask.sh -xcn ${task} vela-tools/ftls/velatask.sch.ftl </pre>  <a href="javascript:runshell('${M1_HOME + "/vela-tools/velatask.sh -xcn " + task + " vela-tools/ftls/velatask.sch.ftl"}' )">����</a>    <a href="javascript:edit('${M1_HOME +"/vela-tools/ftls/velatask.sch.ftl"}')">����</a></div>
           <#elseif task?starts_with("DBX") >
            �����ٷ� TASK: ${task}�� �����մϴ�. 
            <div class="code-wrapper"><pre class="code-block code-unspecified">velatask.sh -dbx ${task} vela-tools/ftls/velatask.sch.ftl </pre>  <a href="javascript:runshell('${M1_HOME + "/vela-tools/velatask.sh -dbx " + task + " vela-tools/ftls/velatask.sch.ftl"}' )">����</a>    <a href="javascript:edit('${M1_HOME +"/vela-tools/ftls/velatask.sch.ftl"}')">����</a></div>
           </#if>
           
   </#if>
 </#list>  
<hr/>
<br/><h2>�߼ۻ�(KT �� ) ������Ʈ ��ġ/���� (config/vela)</h2>
   ���� �߼ۻ��� ������Ʈ�� �����մϴ�.
<hr/>

<br/><h2>XCenter�� ����͸� ����</h2>
ť����<br/>

 <div class="code-wrapper"><pre class="code-block code-unspecified">config/vela/XCENTR_0000/domonitor.XCENTR_0000.ftl </pre>  <a href="javascript:edit('${M1_HOME + "/config/vela/XCENTR_0000/domonitor.XCENTR_0000.ftl"}')">����</a></div>

���μ�������/ť�ɸ����� ����! �� ������ ���� ��� XCENTER�� ���� �ݿ� �˴ϴ�.<br/>
 <div class="code-wrapper"><pre class="code-block code-unspecified">lib/m1crontab.properties </pre>  <a href="javascript:edit('${M1_HOME + "/lib/m1crontab.properties"}')">����</a></div>


<hr/>
<br/><h2> �˶��߼۸��(KT) ��ġ/����</h2>
   KT�߼۸���� �����մϴ�.
<hr/>

<br/><h2> ������� ��ġ/����</h2>
   tomcat����<br/>
   

<hr/>

<br/><h2> �ֿ� ��� ����</h2>
        <!-- vela ���� ���丮 ���ϱ� ��������� �������� ���� vela �ڽ� ���丮�� ����Ʈ -->
           
           <#assign filelist = m1.filelist(M1_HOME + "/bin",".*[A-Z1-9_]+\\.sh")/>
           <#list filelist as fileinfo>
                        <#assign pos=fileinfo?index_of(",") />
                        <#assign pos2=fileinfo?index_of(",",pos+1) />
                        <#assign file=fileinfo?substring(0,pos) />
                        <#assign filesz=fileinfo?substring(pos+1,pos2) />
                        <#assign filedt=fileinfo?substring(pos2+1) />

                        <#assign sh=file?replace(M1_HOME+"/bin/","") />
                        <div class="code-wrapper"><pre class="code-block code-unspecified">${file?replace(M1_HOME+"/","")} </pre>  <a href="javascript:runshell('${sh + " start f"}' )">����</a>   <a href="javascript:runshell('${sh + " stop f"}' )">����</a>   <a href="javascript:runshell('${sh + " restart f"}' )">�����</a> </div>

           </#list>

<hr/>

<br/><h2> ��ƿ��Ƽ ���</h2>
        <!-- vela ���� ���丮 ���ϱ� ��������� �������� ���� vela �ڽ� ���丮�� ����Ʈ -->
           
           <#assign filelist = m1.filelist(M1_HOME + "/bin",".*[a-z_]+\\.sh")/>
           <#list filelist as fileinfo>
                        <#assign pos=fileinfo?index_of(",") />
                        <#assign pos2=fileinfo?index_of(",",pos+1) />
                        <#assign file=fileinfo?substring(0,pos) />
                        <#assign filesz=fileinfo?substring(pos+1,pos2) />
                        <#assign filedt=fileinfo?substring(pos2+1) />

                        <#assign sh=file?replace(M1_HOME+"/bin/","") />
                        <div class="code-wrapper"><pre class="code-block code-unspecified">${file?replace(M1_HOME+"/","")} </pre>  <a href="javascript:runshell('${sh}' )">����</a>   </div>

           </#list>

<hr/>

<br/><h2> �׽�Ʈ �߼�</h2>
   SMS�߼�<br/>
   LMS�߼�<br/>
   MMS�߼�<br/>
   
<hr/>

<br/><h2> DB ��ȸ</h2>

<form action="sql.ftl" method="post" target="sql">
                                db tag: <input type="text" name="db" value=""><br/>
                                �Ķ���Ͱ� hash(json): <input type="text" name="params" size="40" value="{&quot;TABLE&quot;:&quot;tsumssu00&quot;, &quot;rownum&quot;:20}"><br/>
                sql����: <input type="text" name="sql" size="80" value="select * from ${"$\{TABLE}"} where rownum < @rownum"><br/>
                <input type="submit" name="query" value="select">
                <input type="submit" name="query" value="update"><br/>
</form>
   41����ȸ<br/>
   00��ȸ<br/>
   21/26/28 ��ȸ<br/>
   
<hr/>



                </div>
</div>
</div></body>
</html>