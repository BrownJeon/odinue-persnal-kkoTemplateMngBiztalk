

<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>



<#assign defdir=m1.sysenv["M1_HOME"] + "/config/vela-mdefs"/>


<#assign r=m1.loadffdef( defdir + "/M1.def") />


<#assign q=m1.new("queue")/>
<#assign qnm="KTSMBZSMR1_ZZZ"/>

<#assign seq=ymdhms/>
<#--
	<#assign seq=m1.nextSequence()?string("0")?left_pad(20,"0")/>
-->
<#assign mapped=m1.new("bytes",1024*7)/>

	<#assign seq="000000111114"/>


<#assign mapHeader={
"발송서버접수식별자":seq,
"내부전문구분":"F_REQ",
"전문버전":"20",
"보낸프로그램참고":"TEST FTL",
"거래구분":"NOBZCODE00",
"생성일시": ymdhms,
"오류코드":"00",
"할당발송계약식별자":qnm,
"여분":"",
"하위전문길이":330
}/>

<#assign push={
	"RELATIONKEY":"01048024049",
    "DISPLAYMESSAGE" : "test",
    "COMPANYMESSAGEID": seq,
    "REMARK" : "",
    "REALTIME" : "true"
}/>
"발송서버접수식별자":ymdhmss,
<#assign mapSMS={
"발송서버접수식별자":seq,
"배치고유번호":0,
"발송이력식별자":ymdhmss,
"전문ID":ymdhmss,
"업무식별자":"UMS1234567",
"메시지구분":"P",
"수신전화번호":"01048024049",
"발신전화번호":"15776825",
"회신전화번호":"",
"요청일시":ymdhms,
"접수일시":ymdhms,
"우선순위":5,
"유효발송일중시간":"000000000000",
"지정발송계약식별자":"",
"메시지내용":"SMS내용입니다.",

"MMS첨부파일Base경로":"/Users/jhyang/",
"MMS첨부파일1상대경로":"vm_share/video.k3g",
"MMS첨부파일2상대경로":"",
"MMS첨부파일3상대경로":"",
"MMS템플릿파일상대경로":"",
"MMS메시지내용": m1.toJsonBytes(push)?string
}/>


 <#assign r=m1.flatten(mapHeader,"FWXHEADER",mapped)/>
 <#assign r=m1.flattenNext(mapSMS,"FWXREQUEST",mapped)/>
 <#assign r=m1.flattenNext(mapSMS,"FWXREQUEST_EXT_MMS",mapped)/>

 <#assign r=q.write1(qnm,mapped,0,m1.sizeof("FWXHEADER","FWXREQUEST","FWXREQUEST_EXT_MMS"))/>

<#assign r=m1.print(m1.toJsonBytes(push)?string)/>
