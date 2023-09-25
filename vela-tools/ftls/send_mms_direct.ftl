
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
"�޽�������":"M",
"������ȭ��ȣ":"01048024049",
"�߽���ȭ��ȣ":"15776825",
"ȸ����ȭ��ȣ":"",
"��û�Ͻ�":ymdhms,
"�����Ͻ�":ymdhms,
"�켱����":5,
"��ȿ�߼����߽ð�":"000000000000",
"�����߼۰��ĺ���":"",
"�޽�������":"SMS�����Դϴ�.",

"MMS÷������Base���":"/Users/jhyang/",
"MMS÷������1�����":"vm_share/video.k3g",
"MMS÷������2�����":"",
"MMS÷������3�����":"",
"MMS���ø����ϻ����":"",
"MMS�޽�������":"MMS �޽��� �����Դϴ�."
}/>


<#assign mapSMS=mapSMS+ {
"MMS÷������1�����":"Downloads/Sequence 01_2.k3g",
"MMS�޽�������":"Sequence 01_2.k3g MMS �޽��� �����Դϴ�."
}/>


<#assign mapSMS=mapSMS+ {
"MMS÷������1�����":"vm_share/KB_CEO_0m20s.k3g",
"�޽�������":"KB_CEO_0m20s k3g ������ �����Դϴ�.",
"MMS�޽�������":"KB_CEO_0m20s.k3g MMS �޽��� �����Դϴ�."
}/>


<#assign rcvs=["01048024049","01053820148","01072757911","01027339358","01040515758"]/>

<#assign rcvs=["01048024049","01083970312","01075763675","01084906190"]/>

<#--assign rcvs=["01084906190"]/-->


<#list rcvs as rcv>
<#assign mapSMS=mapSMS+ {
"�߼ۼ��������ĺ���":ymdhmss + (rcv_index?string),
"������ȭ��ȣ":rcv
}/>

 <#assign r=m1.flatten(mapHeader,"FWXHEADER",mapped)/>
 <#assign r=m1.flattenNext(mapSMS,"FWXREQUEST",mapped)/>
 <#assign r=m1.flattenNext(mapSMS,"FWXREQUEST_EXT_MMS",mapped)/>

 <#assign r=q.write1(qnm,mapped,0,m1.sizeof("FWXHEADER","FWXREQUEST","FWXREQUEST_EXT_MMS"))/>

</#list>
