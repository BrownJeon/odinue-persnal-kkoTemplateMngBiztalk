
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
"�߼ۼ��������ĺ���":seq,
"������������":"F_REQ",
"��������":"20",
"�������α׷�����":"TEST FTL",
"�ŷ�����":"NOBZCODE00",
"�����Ͻ�": ymdhms,
"�����ڵ�":"00",
"�Ҵ�߼۰��ĺ���":qnm,
"����":"",
"������������":330
}/>

<#assign mapSMS={
"�߼ۼ��������ĺ���":ymdhmss,
"��ġ������ȣ":0,
"�߼��̷½ĺ���":ymdhmss,
"����ID":ymdhmss,
"�����ĺ���":"UMS1234567",
"�޽�������":"U",
"������ȭ��ȣ":"01048024049",
"�߽���ȭ��ȣ":"15881515",
"ȸ����ȭ��ȣ":"",
"��û�Ͻ�":ymdhms,
"�����Ͻ�":ymdhms,
"�켱����":5,
"��ȿ�߼����߽ð�":"000000000000",
"�����߼۰��ĺ���":"",
"�޽�������":"http://61.251.169.170/a/w?id=0m1 ��������VM�ٿ�ε�"
}
/>


${m1.print(mapSMS)}

<#--mms

"MMS÷������Base���":rcvHeader["MMS÷������Base���"],
"MMS÷������1�����":rcvHeader["MMS÷������1�����"],
"MMS÷������2�����":rcvHeader["MMS÷������2�����"],
"MMS÷������3�����":rcvHeader["MMS÷������3�����"],
"MMS���ø����ϻ����":rcvHeader["MMS���ø����ϻ����"],
"MMS�޽�������":rcvHeader["MMS�޽�������"],
-->

<#assign r=m1.flatten(mapHeader,"FWXHEADER",mapped)/>
<#assign r=m1.flatten(mapSMS,"FWXREQUEST",mapped,100)/>
<#assign r=q.write1(qnm,mapped,0,430)/>
