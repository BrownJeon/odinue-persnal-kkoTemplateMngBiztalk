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
                본 페이지 자체를 <a href="javascript:edit('${M1_HOME + "/webapp/install.ftl"}')">편집</a>합니다.
<br/><h2>주요설치 파일들</h2>
$M1_HOME/bin <a href="javascript:list('${M1_HOME + "/bin"}','*.sh,*.env')">보기</a> <br/>
$M1_HOME/lib/*.properties <a href="javascript:list('${M1_HOME + "/lib"}','*.properties')">보기</a> <br/>
$M1_HOME/lib/*.jar <a href="javascript:list('${M1_HOME + "/lib"}','*.jar')">보기</a> <br/>
$M1_HOME/config/vela <a href="javascript:list('${M1_HOME + "/config/vela"}','*.ftl,*.sql,*.json')">보기</a> <br/>
$M1_HOME/webapp <a href="javascript:list('${M1_HOME + "/webapp"}','*.ftl)">보기</a> <br/>


<br/><h2>bin/host.env 설치 환경 변수 설정</h2>
설치환경변수 파일을 편집합니다. 
 <div class="code-wrapper"><pre class="code-block code-unspecified">bin/host.env </pre>  <a href="javascript:edit('${M1_HOME + "/bin/host.env"}')">편집</a> </div>
 M1_HOME을 설정합니다. <a href="javascript:runshell('grep M1_HOME= ./host.env' )">현재설정</a><br/>
 M1_HOSTNO를 설정합니다. <a href="javascript:runshell('grep M1_HOSTNO= ./host.env' )">현재설정</a><br/>
 M1_DATA를 설정합니다. <a href="javascript:runshell('grep M1_DATA= ./host.env' )">현재설정</a><br/>
 M1_LOG를 설정합니다. <a href="javascript:runshell('grep M1_LOG= ./host.env' )">현재설정</a><br/>
 
M1 자체 시퀀스키를 초기화합니다(운영중절대 변경금지!!)
 <div class="code-wrapper"><pre class="code-block code-unspecified">lib/sms.seq </pre>  <a href="javascript:runshell('cat ../lib/sms.seq' )">보기</a> </div>

<hr/>

<br/><h2>데이터베이스 연결</h2>
  $M1_HOME/lib/m1_unix.properties 에 DB연결설정을 합니다.<br/>
  jdbcURL, userid, password를 설정합니다.<br/>
 <div class="code-wrapper"><pre class="code-block code-unspecified">lib/m1_unix.properties </pre>  <a href="javascript:edit('${M1_HOME + "/lib/m1_unix.properties"}')">편집</a> <a href="javascript:runshell('grep SMSConnectionFactory ../lib/m1_unix.properties' )">현재설정</a></div>
  
  연결내용을 암호화하고 자 하는 경우에는 아래와 같이 실행합니다. 
<div class="code-wrapper"><pre class="code-block code-unspecified"> encrypt.sh [암호화할문자열] </pre>  <a href="javascript:runshell('encrypt.sh ' + window.prompt('암호화대상문자열','userid/password') )">실행</a></div>
 
  설정이 되었다면 다음을 실행하여 연결을 검사합니다.<br/>
  
<hr/>

<br/><h2>큐생성/이름지정/모니터 표시 설정</h2>
 IPC큐가 생성됐는지 확인합니다. 유저명의 세마포어와 메모리가 있는지 시스템명령 ipcs로 검사합니다.
  <div class="code-wrapper"><pre class="code-block code-unspecified">ipcs </pre>  <a href="javascript:runshell('ipcs' )">실행</a></div>

 IPC큐를 생성합니다.
  <div class="code-wrapper"><pre class="code-block code-unspecified">smsqm.sh install </pre>  <a href="javascript:runshell('smsqm.sh install' )">실행</a></div>

 또는  IPC큐를 삭제합니다. 주의! 장애 유발 가능성 있음.
   <div class="code-wrapper"><pre class="code-block code-unspecified">smsqm.sh 0 del </pre>  <a href="javascript:runshell('smsqm.sh 0 del' )">실행</a></div>



 큐 생성 이후에는 큐의 이름을 변경하는 bin/rename.sh 을 편집하여 실행합니다.
 <div class="code-wrapper"><pre class="code-block code-unspecified">rename.sh </pre><a href="javascript:edit('${M1_HOME + "/bin/rename.sh"}')">편집</a>  <a href="javascript:runshell('rename.sh')">실행</a></div>
 
 큐의 이름 확인하기 위해  아래와 같이 실행합니다.
 <div class="code-wrapper"><pre class="code-block code-unspecified">smsqm.sh stat a </pre>  <a href="javascript:runshell('smsqm.sh stat a')">실행</a></div>
 
 모니터링 할 큐설정을 위해 아래 파일을 편집합니다.  <br/>
 <div class="code-wrapper"><pre class="code-block code-unspecified">bin/smsqm.display </pre>  <a href="javascript:edit('${M1_HOME + "/bin/smsqm.display"}')">편집</a></div>

이를  확인하기 위해  아래와 같이 실행합니다.
 <div class="code-wrapper"><pre class="code-block code-unspecified">smsqm.sh stat s </pre>  <a href="javascript:runshell('smsqm.sh stat s' )">실행</a></div>

주의!! 본 페이지에서 위 명령을 실행하면 좀비 smsqm 이 남을 수 있습니다. 아래 명령으로 확인합니다.<br/>
터미널에서 실행시에는 문제없습니다.
 <div class="code-wrapper"><pre class="code-block code-unspecified">smsqm.sh psme </pre>  <a href="javascript:runshell('smsqm.sh psme' )">실행</a></div>
smsqm이 실행되고 있다면 아래 명령으로 제거합니다.
 <div class="code-wrapper"><pre class="code-block code-unspecified">smsqm.sh killme </pre>  <a href="javascript:runshell('smsqm.sh killme' )">실행</a></div>



<hr/>
<br/><h2>전문정의 (config/vela-mdefs)</h2>
<!-- vela 하위 디렉토리 구하기 모든파일을 리스팅한 다음 vela 자식 디렉토리만 리스트 -->

           <#assign filelist = m1.filelist(M1_HOME + "/config/vela-mdefs",".*\\.def")/>
           <#list filelist as fileinfo>
                        <#assign pos=fileinfo?index_of(",") />
                        <#assign pos2=fileinfo?index_of(",",pos+1) />
                        <#assign file=fileinfo?substring(0,pos) />
                        <#assign filesz=fileinfo?substring(pos+1,pos2) />
                        <#assign filedt=fileinfo?substring(pos2+1) />


                        <div class="code-wrapper"><pre class="code-block code-unspecified">${file?replace(M1_HOME+"/","")} </pre>  <a href="javascript:edit('${file}')">편집</a></div>

           </#list>
<hr/>
<br/><h2>발송프레임워크 개발 (config/vela)</h2>

<!-- vela 하위 디렉토리 구하기 모든파일을 리스팅한 다음 vela 자식 디렉토리만 리스트 -->
<#assign taskdirs = m1.filelist(M1_HOME + "/config/vela",".*")/>
<#list taskdirs as taskdir>
        <#assign pos=taskdir?index_of(",") />
        <#assign pos2=taskdir?index_of(",",pos+1) />
        <#assign filesz=taskdir?substring(pos+1,pos2) />
        <#assign taskhome=taskdir?substring(0,pos) />
        <!-- vela 하위 디렉토리 구하기 모든파일을 리스팅한 다음 vela 자식 디렉토리만 리스트 -->
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


                        <div class="code-wrapper"><pre class="code-block code-unspecified">${file?replace(M1_HOME+"/","")} </pre>  <a href="javascript:edit('${file}')">편집</a></div>

           </#list>
           
           <#if task?starts_with("SCH") >
            스케줄러 TASK: ${task}를 검증합니다. 
            <div class="code-wrapper"><pre class="code-block code-unspecified">velatask.sh -sch ${task} vela-tools/ftls/velatask.sch.ftl </pre>  <a href="javascript:runshell('${M1_HOME + "/vela-tools/velatask.sh -sch " + task + " vela-tools/ftls/velatask.sch.ftl"}' )">검증</a>   <a href="javascript:edit('${M1_HOME +"/vela-tools/ftls/velatask.sch.ftl"}')">편집</a></div>
           <#elseif task?starts_with("XCN") >
            스케줄러 TASK: ${task}를 검증합니다. 
            <div class="code-wrapper"><pre class="code-block code-unspecified">velatask.sh -xcn ${task} vela-tools/ftls/velatask.sch.ftl </pre>  <a href="javascript:runshell('${M1_HOME + "/vela-tools/velatask.sh -xcn " + task + " vela-tools/ftls/velatask.sch.ftl"}' )">검증</a>    <a href="javascript:edit('${M1_HOME +"/vela-tools/ftls/velatask.sch.ftl"}')">편집</a></div>
           <#elseif task?starts_with("DBX") >
            스케줄러 TASK: ${task}를 검증합니다. 
            <div class="code-wrapper"><pre class="code-block code-unspecified">velatask.sh -dbx ${task} vela-tools/ftls/velatask.sch.ftl </pre>  <a href="javascript:runshell('${M1_HOME + "/vela-tools/velatask.sh -dbx " + task + " vela-tools/ftls/velatask.sch.ftl"}' )">검증</a>    <a href="javascript:edit('${M1_HOME +"/vela-tools/ftls/velatask.sch.ftl"}')">편집</a></div>
           </#if>
           
   </#if>
 </#list>  
<hr/>
<br/><h2>발송사(KT 등 ) 에이전트 설치/설정 (config/vela)</h2>
   이제 발송사의 에이전트를 설정합니다.
<hr/>

<br/><h2>XCenter의 모니터링 설정</h2>
큐감시<br/>

 <div class="code-wrapper"><pre class="code-block code-unspecified">config/vela/XCENTR_0000/domonitor.XCENTR_0000.ftl </pre>  <a href="javascript:edit('${M1_HOME + "/config/vela/XCENTR_0000/domonitor.XCENTR_0000.ftl"}')">편집</a></div>

프로세스감시/큐걸림감시 주의! 이 파일은 수정 즉시 XCENTER에 의해 반영 됩니다.<br/>
 <div class="code-wrapper"><pre class="code-block code-unspecified">lib/m1crontab.properties </pre>  <a href="javascript:edit('${M1_HOME + "/lib/m1crontab.properties"}')">편집</a></div>


<hr/>
<br/><h2> 알람발송모듈(KT) 설치/설정</h2>
   KT발송모듈을 설정합니다.
<hr/>

<br/><h2> 사용자웹 설치/설정</h2>
   tomcat설정<br/>
   

<hr/>

<br/><h2> 주요 모듈 실행</h2>
        <!-- vela 하위 디렉토리 구하기 모든파일을 리스팅한 다음 vela 자식 디렉토리만 리스트 -->
           
           <#assign filelist = m1.filelist(M1_HOME + "/bin",".*[A-Z1-9_]+\\.sh")/>
           <#list filelist as fileinfo>
                        <#assign pos=fileinfo?index_of(",") />
                        <#assign pos2=fileinfo?index_of(",",pos+1) />
                        <#assign file=fileinfo?substring(0,pos) />
                        <#assign filesz=fileinfo?substring(pos+1,pos2) />
                        <#assign filedt=fileinfo?substring(pos2+1) />

                        <#assign sh=file?replace(M1_HOME+"/bin/","") />
                        <div class="code-wrapper"><pre class="code-block code-unspecified">${file?replace(M1_HOME+"/","")} </pre>  <a href="javascript:runshell('${sh + " start f"}' )">시작</a>   <a href="javascript:runshell('${sh + " stop f"}' )">중지</a>   <a href="javascript:runshell('${sh + " restart f"}' )">재시작</a> </div>

           </#list>

<hr/>

<br/><h2> 유틸리티 모듈</h2>
        <!-- vela 하위 디렉토리 구하기 모든파일을 리스팅한 다음 vela 자식 디렉토리만 리스트 -->
           
           <#assign filelist = m1.filelist(M1_HOME + "/bin",".*[a-z_]+\\.sh")/>
           <#list filelist as fileinfo>
                        <#assign pos=fileinfo?index_of(",") />
                        <#assign pos2=fileinfo?index_of(",",pos+1) />
                        <#assign file=fileinfo?substring(0,pos) />
                        <#assign filesz=fileinfo?substring(pos+1,pos2) />
                        <#assign filedt=fileinfo?substring(pos2+1) />

                        <#assign sh=file?replace(M1_HOME+"/bin/","") />
                        <div class="code-wrapper"><pre class="code-block code-unspecified">${file?replace(M1_HOME+"/","")} </pre>  <a href="javascript:runshell('${sh}' )">실행</a>   </div>

           </#list>

<hr/>

<br/><h2> 테스트 발송</h2>
   SMS발송<br/>
   LMS발송<br/>
   MMS발송<br/>
   
<hr/>

<br/><h2> DB 조회</h2>

<form action="sql.ftl" method="post" target="sql">
                                db tag: <input type="text" name="db" value=""><br/>
                                파라미터값 hash(json): <input type="text" name="params" size="40" value="{&quot;TABLE&quot;:&quot;tsumssu00&quot;, &quot;rownum&quot;:20}"><br/>
                sql쿼리: <input type="text" name="sql" size="80" value="select * from ${"$\{TABLE}"} where rownum < @rownum"><br/>
                <input type="submit" name="query" value="select">
                <input type="submit" name="query" value="update"><br/>
</form>
   41번조회<br/>
   00조회<br/>
   21/26/28 조회<br/>
   
<hr/>



                </div>
</div>
</div></body>
</html>