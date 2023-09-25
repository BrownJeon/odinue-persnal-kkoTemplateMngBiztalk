
<#assign ymdhmss=m1.now()?string("yyyyMMddHHmmssSSS")/>
<#assign ymdhms=ymdhmss?substring(0,14)/>
<#assign ymd=ymdhms?substring(0,8)/>




<#assign defdir=m1.sysenv["M1_HOME"] + "/config/vela-mdefs"/>


<#assign r=m1.loadffdef( defdir + "/M1.def") />


<#assign q=m1.new("queue")/>
<#assign qnm="KTSMBZMMR9_ZZZ"/>

<#assign seq=ymdhms/>
<#--
	<#assign seq=m1.nextSequence()?string("0")?left_pad(20,"0")/>
-->
<#assign mapped=m1.new("bytes",1024*7)/>

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


착신전환 양준호 SK: 010-2035-7652,01020357652
{ "name": "최원영", "tel": "010-2467-0981","tmodel":"LG/피처"},
<#assign mapSMS={
"발송서버접수식별자":ymdhmss,
"배치고유번호":0,
"발송이력식별자":ymdhmss,
"전문ID":ymdhmss,
"업무식별자":"UMS1234567",
"메시지구분":"S",
"수신전화번호":"01024670981",
"발신전화번호":"15776825",
"회신전화번호":"",
"요청일시":ymdhms,
"접수일시":ymdhms,
"우선순위":5,
"유효발송일중시간":"000000000000",
"지정발송계약식별자":"kbstarxxxx",
"메시지내용":"보안 CID테스트를 위해, 본 메시지를 발송합니다."
}
/>


${m1.print(mapSMS)}

<#--mms

"MMS첨부파일Base경로":rcvHeader["MMS첨부파일Base경로"],
"MMS첨부파일1상대경로":rcvHeader["MMS첨부파일1상대경로"],
"MMS첨부파일2상대경로":rcvHeader["MMS첨부파일2상대경로"],
"MMS첨부파일3상대경로":rcvHeader["MMS첨부파일3상대경로"],
"MMS템플릿파일상대경로":rcvHeader["MMS템플릿파일상대경로"],
"MMS메시지내용":rcvHeader["MMS메시지내용"],
-->

<#assign r=m1.flatten(mapHeader,"FWXHEADER",mapped)/>
<#assign r=m1.flatten(mapSMS,"FWXREQUEST",mapped,100)/>
<#assign r=q.write1(qnm,mapped,0,430)/>
