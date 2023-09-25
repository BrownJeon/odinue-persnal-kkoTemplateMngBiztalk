
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

<#--
<#assign mapSMS={
"발송서버접수식별자":ymdhmss,
"배치고유번호":0,
"발송이력식별자":ymdhmss,
"전문ID":ymdhmss,
"업무식별자":"UMS1234567",
"메시지구분":"V",
"수신전화번호":"01048044049",
"발신전화번호":"15776825",
"회신전화번호":"",
"요청일시":ymdhms,
"접수일시":ymdhms,
"우선순위":5,
"유효발송일중시간":"000000000000",
"지정발송계약식별자":"",
"메시지내용":"VMS내용입니다.",

"MMS첨부파일Base경로":"/Users/jhyang/",
"MMS첨부파일1상대경로":"vm_share/vms.txt",
"MMS첨부파일2상대경로":"",
"MMS첨부파일3상대경로":"",
"MMS템플릿파일상대경로":"",
"MMS메시지내용":"MMS 메시지 내용입니다."
}/>
-->


<#assign mapSMS={
"발송서버접수식별자":ymdhmss,
"배치고유번호":0,
"발송이력식별자":ymdhmss,
"전문ID":ymdhmss,
"업무식별자":"UMS1234567",
"메시지구분":"V",
"수신전화번호":"01048044049",
"발신전화번호":"15776825",
"회신전화번호":"",
"요청일시":ymdhms,
"접수일시":ymdhms,
"우선순위":5,
"유효발송일중시간":"000000000000",
"지정발송계약식별자":"",
"메시지내용":"VMS내용입니다.",

"MMS첨부파일Base경로":"",
"MMS첨부파일1상대경로":"",
"MMS첨부파일2상대경로":"",
"MMS첨부파일3상대경로":"",
"MMS템플릿파일상대경로":"",
"MMS메시지내용":"MMS 메시지 내용입니다."
}/>



	{ "name": "황인영", "tel": "010-8397-0312","tmodel":"KT/iPhone3gs"},
		{ "name": "박병희", "tel": "010-2504-0564","tmodel":"SK/GalaxyS2"},

	{ "name": "양준호", "tel": "010-4802-4049","tmodel":"SK/SKY/ANDROID"},
	{ "name": "양주호", "tel": "010-9969-5060","tmodel":"KT/IPhone4"},
	
	{ "name": "스마트팀장님", "tel": "011-9115-2916","tmodel":"SK/GalaxyS"},
	
	{ "name": "이창호", "tel": "010-4051-5758","tmodel":"KT/iPhone4"},
	{ "name": "김성인", "tel": "010-2733-9358","tmodel":"SK/iPhone4"},
	{ "name": "김재연", "tel": "010-9989-0124","tmodel":"SK/iPhone4s"},
	{ "name": "최원영", "tel": "010-2467-0981","tmodel":"LG/피처"},
	{ "name": "박민규", "tel": "010-7141-2823","tmodel":"KT/iPhone3gs"},
	{ "name": "박은영", "tel": "010-8731-9489","tmodel":"SK/iPhone4"},
	
	
	{ "name": "임성재", "tel": "010-7424-8855","tmodel":"LG/GalaxyS2"},
	
    { "name": "안경호", "tel": "010-5382-0148","tmodel":"SK/GalaxyS2"},
	{ "name": "이소령", "tel": "010-8609-0867","tmodel":"단말기종모름"},		
	
	{ "name": "이태희", "tel": "010-7275-7911","tmodel":"KT/iPhone3gs"},
	{ "name": "이태희2", "tel": "010-2669-9421","tmodel":"KT/GalaxyNote"},
	{ "name": "이태희.김해미", "tel": "010-9052-1052","tmodel":"SK/Galaxy1"},
	{ "name": "이태희.송기철KB업무지원부", "tel": "011-9899-7515","tmodel":"SK/Galaxy1"}

	
	
	{ "name": "KT영업전략본부 총괄", "tel": "010-7274-7890","tmodel":"KT"},
	
	{ "name": "김지용 상무", "tel": "010-9777-2288","tmodel":"KT/iPhone3gs"}
	{ "name": "정영환", "tel": "010-9856-4416","tmodel":"KT/iPhone3gs"}
	{ "name": "최연호 부장", "tel": "010-9879-9922","tmodel":"KT/iPhone3gs"}
	{ "name": "김지일 과장", "tel": "010-2776-2636","tmodel":"KT/iPhone3gs"}
	{ "name": "이은아 과장", "tel": "010-7311-9789","tmodel":"KT/iPhone3gs"}
	
	{ "name": "정윤식 본부장", "tel": "010-7350-4779","tmodel":"KT/iPhone3gs"}
	
	
	
	
	
	{ "name": "황인영", "tel": "010-8397-0312","tmodel":"KT/iPhone3gs"},
	{ "name": "황초롱", "tel": "010-8490-6190","tmodel":"SK/Gal2"},
	
	{ "name": "이태희", "tel": "010-7275-7911","tmodel":"KT/iPhone3gs"},
	{ "name": "양준호", "tel": "010-4802-4049","tmodel":"SK/SKY/ANDROID"},
	{ "name": "양준호", "tel": "010-2035-7652","tmodel":"SK/SKY/ANDROID"},
	
	{ "name": "이창호", "tel": "010-4051-5758","tmodel":"KT/iPhone4"},
	{ "name": "김성인", "tel": "010-2733-9358","tmodel":"SK/iPhone4"},
	{ "name": "김재연", "tel": "010-9989-0124","tmodel":"SK/iPhone4s"},
	{ "name": "최원영", "tel": "010-2467-0981","tmodel":"LG/피처"},


{ "name": "장진익", "tel": "010-9945-2235","tmodel":"SK/OptimusLTE"}

<#assign rcvs=[
{ "name": "양준호", "tel": "010-4802-4049","tmodel":"SK/SKY/ANDROID"}
		]/>
	
	<#list rcvs as rcv>
		<#assign mapHeader=mapHeader+ {
		"발송서버접수식별자":ymdhmss + (rcv_index?string)
		}/>

		<#assign mapSMS=mapSMS+ {
		"발송서버접수식별자":ymdhmss + (rcv_index?string),
		"수신전화번호":rcv.tel?replace("-","")
		}/>
		
		
		${mapSMS["발송서버접수식별자"]}, ${mapSMS["수신전화번호"]}
		
 		<#assign r=m1.flatten(mapHeader,"FWXHEADER",mapped)/>
 		<#assign r=m1.flattenNext(mapSMS,"FWXREQUEST",mapped)/>
 		<#assign r=m1.flattenNext(mapSMS,"FWXREQUEST_EXT_MMS",mapped)/>

 		<#assign r=q.write1(qnm,mapped,0,m1.sizeof("FWXHEADER","FWXREQUEST","FWXREQUEST_EXT_MMS"))/>

	</#list>
