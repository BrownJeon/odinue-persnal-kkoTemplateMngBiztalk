<#assign r=m1.stack("Content-type","text/xml; charset=euc-kr")/>
<#compress>
<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign y1mdhms=ymdhmss?substring(3,17)/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>
<#assign qjson = m1.smsqm() />
<#assign qs = m1.parseJsonValue(qjson)!{"smsqm":[]} />
<#-- if qs.smsqm?size > 0 -->
<#assign t = m1.statics["java.lang.System"].currentTimeMillis()?string("0")?number/>
<#assign qs = qs+ {"time":t,"sessionid":m1.session("sessionid")} />
<#include "qconf.ftl"/>
<#if m1.session("qsStart")?? >
	<#assign qsStart=m1.session("qsStart")/>
	<#assign qsLast=m1.session("qsLast")/>
	<#list qs.smsqm as q >
		<#assign q0= qsLast.smsqm[q_index]/>
		<#assign q00= qsStart.smsqm[q_index]/>
		<#assign r= m1.put(q,"tps",((q.done-q0.done)*1000/(qs.time-qsLast.time))?int)/>
	</#list>
<#else>
	<#list qs.smsqm as q >
		<#assign r= m1.put(q,"tps",0)/>
	</#list>
	<#assign r=m1.session("qsStart",qs)/>
</#if>
<#assign r=m1.session("qsLast",qs)/>
<#assign qsStart= m1.session("qsStart")/>
<#assign times= ((qs.time-qsStart.time)/1000)?int/>
<#assign eHour= (times/3600)?int/>
<#assign eMin= ((times-eHour*3600)/60)?int/>
<#assign eSec= (times-eHour*3600-eMin*60)?int/>
</#compress><?xml version="1.0" encoding="euc-kr"?>
<smsqm time="${qs.time}" elapsed="${eHour?string("00")}:${eMin?string("00")}:${eSec?string("00")}" sessionid="${qs.sessionid}">
<#assign qlist = [] />
<#assign keys = qconf?keys />
<#list keys as key >
	<#assign qlist = qlist + qconf[key]?keys />
</#list>
<#-- 
<#list qlist as q >
${q} 
</#list>
${qlist?seq_index_of("XCN_SMS41")}
${qlist?seq_contains("XCN_SMS41")?string("true","false")}
${qlist?size}
${qjson}
-->
<#list qs.smsqm as q >
<#if qlist?seq_contains(q.name) >
  <q name="${q.name}" id="${q.id}" type="${q.type}" stat="${q.stat}" alloc="${q.alloc}" master="${q.master}" tpsmx="${q.tpsmx}" tps="${q.tps}" tot="${q.tot}" mem="${q.mem}" <#if (request.scope!"") == "all"

> done="${q.done}" edone="${q.edone}" ack="${q.ack}" eack="${q.eack}" rslt="${q.rslt}" erslt="${q.erslt}" <#else 

><#assign q00= m1.session("qsStart").smsqm[q_index]

/> done="${q.done - q00.done}" edone="${q.edone - q00.edone}" ack="${q.ack - q00.ack}" eack="${q.eack - q00.eack}" rslt="${q.rslt - q00.rslt}" erslt="${q.erslt - q00.erslt}" </#if
> rwrw="${q.rwrw}" last-in="${q.lastin}" last-out="${q.lastout}" pidp="${q.pidp}" pidpf="${q.pidpf}" pidg="${q.pidg}" pidgf="${q.pidgf}" />
</#if>
</#list>
</smsqm>
<#-- if -->