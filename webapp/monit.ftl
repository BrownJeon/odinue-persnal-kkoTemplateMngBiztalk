<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
<#include "qconf.ftl"/>
<html lang="ko">
<head>
<title>M1 MONIT</title>
<script src="monit.jquery.min.js"></script>
<script src="monit.js"></script>
<script language="JavaScript" >
<!--//
var sessionid = "${m1.session("sessionid")}" ;
var scope = "session";
//-->
</script>
<link rel="stylesheet" type="text/css" href="monit.light.css" />
</head>
<body>
	<div id="content">
		<div id="head">
			<div class="logo"></div>
			<div class="stat">
				<table>
				<tr>
					<td><span class="ky1">SSSND</span></td>
					<td><span class="vl1">${m1.session("sessionid")}</span></td>
					<td><span class="ky2">SRVRTM</span></td>
					<td><span class="vl2" id="lasttime"></span></td>
					<td><span class="ky3">LPTM</span></td>
					<td><span class="vl3" id="elapsed"></span></td>
					<td><span class="ky4">ALRT</span></td>
					<td><span class="vl4" id="comment"></span></td>
				</tr>
				</table>
			</div>
		</div>
		<div id="sbtt">
			<div id="smsqm-sbtt">
				<span>QUEUE</span>
				<span>
<label class="chkbox" style="margin-left:620px;"><input id="scopebox" type="checkbox"  onclick="scopeCheck()"/> 전체보기</label>
<!--
<input class="command" type="button" value="갱신" onclick="refreshStats()"/>
<input class="command" id="btnToggleRun" type="button" value="시작" onclick="toggleRun()"/>
-->
				</span>
			</div>
			<div id="systm-sbtt">
				<span>SYSTEM</span>
			</div>
		</div>
		<div id="body">
			<div id="smsqm-area">
<#list qconf?keys as key >
				<div class="qmbox r5">
					<div class="qmtl">
						<span>${key}</span>
					</div>
					<div class="qmtr">
						<table class="qmtrtbl" id="">
						<thead>
						<tr><th class="q">큐이름</th><th>큐#</th><th class="v">구성</th><th class="v">접속</th><th class="v">분배</th><th class="w">속도</th><th class="w">총잔량</th><th class="w">메잔량</th><th class="w">완료</th><th class="w">성공</th><th class="w">실패</th><th>최종입력</th><th>최종출력</th><th>입력PID</th><th>출력PID</th></tr>
						</thead>
						<tbody>
	<#list qconf[key]?keys as qkey>
		<#assign q=qconf[key][qkey] />
			<#if q["type"]=="xcn">
						<tr class="odd xcn" id="${qkey}"><td class="q"><input type="checkbox" id="chk_${qkey}"> ${qkey}</td><td></td><td></td><td class="${q['wrwr']}"></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
			<#else>
				<#if qkey_index/2 == 1 >
					<#assign oddevn="odd" />
				<#else>
					<#assign oddevn="evn" />
				</#if>
						<tr class="${oddevn}" id="${qkey}"><td class="q"><input type="checkbox" id="chk_${qkey}"> ${qkey}</td><td></td><td></td><td class="${q['wrwr']}"></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
						<!-- <tr class="odd"> -->
			</#if>
	</#list>
						</tbody>
						</table>
					</div>
				</div>
</#list>
			</div>
			<div id="systm-area">
				<div class="sysbox r5">
					<div class="grpbox" id="grpbox-xcn">
						<div class="chart-container">
							<div id="placeholder-xcn" class="chart-placeholder"></div>
						</div>
					</div>
					<div class="grpbox" id="grpbox-rsc">
						<div class="chart-container">
							<span class="sys-inf" id="rsc-cpu-pct">0</span>
							<span class="sys-inf" id="rsc-mem-pct">0</span>
							<div id="placeholder" class="chart-placeholder"></div>
						</div>
					</div>
					<div class="dskbox">

						<div class="dsktl">
							<span>MEMORY</span>
						</div>
						<div class="dsktr">
							<table class="dsktrtbl" id="">
							<tbody>
							<tr class=""><td class="d">Available</td><td class="dv"><span id="rsc-mem-fre">0</span></td><td></td></tr>
							<tr class=""><td class="d">Total</td><td class="dv"><span id="rsc-mem-tot">0</span></td><td></td></tr>
							</tbody>
							</table>
						</div>

						<div class="dsktl">
							<span>DISK VOLUME</span>
						</div>
						<div class="dsktr">
							<table class="dsktrtbl" id="">
							<tbody>
							<tr class=""><td class="d">Used / Size</td><td class="dv"><span id="rsc-d-usg"></span> / <span id="rsc-d-tot"></span></td></tr>
							<tr class=""><td class="d"></td><td><div class="bar-bg" id="bar-bg-home"><div class="bar" id="bar-d-usg"></div></div></td></tr>
<!--
							<tr class=""><td class="d">HOME</td><td class="dv">454,852KB / 14,159KB </td><td><div class="bar-bg" id="bar-bg-home"><div class="bar" id="bar-home"></div></div></td></tr>
							<tr class=""><td class="d">LOG </td><td class="dv">54,852KB / 1,159KB   </td><td><div class="bar-bg" id="bar-bg-log" ><div class="bar" id="bar-log" ></div></div></td></tr>
							<tr class=""><td class="d">DATA</td><td class="dv">154,852KB / 2,159KB  </td><td><div class="bar-bg" id="bar-bg-data"><div class="bar" id="bar-data"></div></div></td></tr>
-->
							</tbody>
							</table>
						</div>

					</div>
				</div>
			</div>
		</div>

	</div>
</body>
</html>

