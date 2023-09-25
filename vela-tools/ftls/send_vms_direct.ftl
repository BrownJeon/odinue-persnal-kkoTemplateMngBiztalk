
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

<#--
<#assign mapSMS={
"�߼ۼ��������ĺ���":ymdhmss,
"��ġ������ȣ":0,
"�߼��̷½ĺ���":ymdhmss,
"����ID":ymdhmss,
"�����ĺ���":"UMS1234567",
"�޽�������":"V",
"������ȭ��ȣ":"01048044049",
"�߽���ȭ��ȣ":"15776825",
"ȸ����ȭ��ȣ":"",
"��û�Ͻ�":ymdhms,
"�����Ͻ�":ymdhms,
"�켱����":5,
"��ȿ�߼����߽ð�":"000000000000",
"�����߼۰��ĺ���":"",
"�޽�������":"VMS�����Դϴ�.",

"MMS÷������Base���":"/Users/jhyang/",
"MMS÷������1�����":"vm_share/vms.txt",
"MMS÷������2�����":"",
"MMS÷������3�����":"",
"MMS���ø����ϻ����":"",
"MMS�޽�������":"MMS �޽��� �����Դϴ�."
}/>
-->


<#assign mapSMS={
"�߼ۼ��������ĺ���":ymdhmss,
"��ġ������ȣ":0,
"�߼��̷½ĺ���":ymdhmss,
"����ID":ymdhmss,
"�����ĺ���":"UMS1234567",
"�޽�������":"V",
"������ȭ��ȣ":"01048044049",
"�߽���ȭ��ȣ":"15776825",
"ȸ����ȭ��ȣ":"",
"��û�Ͻ�":ymdhms,
"�����Ͻ�":ymdhms,
"�켱����":5,
"��ȿ�߼����߽ð�":"000000000000",
"�����߼۰��ĺ���":"",
"�޽�������":"VMS�����Դϴ�.",

"MMS÷������Base���":"",
"MMS÷������1�����":"",
"MMS÷������2�����":"",
"MMS÷������3�����":"",
"MMS���ø����ϻ����":"",
"MMS�޽�������":"MMS �޽��� �����Դϴ�."
}/>



	{ "name": "Ȳ�ο�", "tel": "010-8397-0312","tmodel":"KT/iPhone3gs"},
		{ "name": "�ں���", "tel": "010-2504-0564","tmodel":"SK/GalaxyS2"},

	{ "name": "����ȣ", "tel": "010-4802-4049","tmodel":"SK/SKY/ANDROID"},
	{ "name": "����ȣ", "tel": "010-9969-5060","tmodel":"KT/IPhone4"},
	
	{ "name": "����Ʈ�����", "tel": "011-9115-2916","tmodel":"SK/GalaxyS"},
	
	{ "name": "��âȣ", "tel": "010-4051-5758","tmodel":"KT/iPhone4"},
	{ "name": "�輺��", "tel": "010-2733-9358","tmodel":"SK/iPhone4"},
	{ "name": "���翬", "tel": "010-9989-0124","tmodel":"SK/iPhone4s"},
	{ "name": "�ֿ���", "tel": "010-2467-0981","tmodel":"LG/��ó"},
	{ "name": "�ڹα�", "tel": "010-7141-2823","tmodel":"KT/iPhone3gs"},
	{ "name": "������", "tel": "010-8731-9489","tmodel":"SK/iPhone4"},
	
	
	{ "name": "�Ӽ���", "tel": "010-7424-8855","tmodel":"LG/GalaxyS2"},
	
    { "name": "�Ȱ�ȣ", "tel": "010-5382-0148","tmodel":"SK/GalaxyS2"},
	{ "name": "�̼ҷ�", "tel": "010-8609-0867","tmodel":"�ܸ�������"},		
	
	{ "name": "������", "tel": "010-7275-7911","tmodel":"KT/iPhone3gs"},
	{ "name": "������2", "tel": "010-2669-9421","tmodel":"KT/GalaxyNote"},
	{ "name": "������.���ع�", "tel": "010-9052-1052","tmodel":"SK/Galaxy1"},
	{ "name": "������.�۱�öKB����������", "tel": "011-9899-7515","tmodel":"SK/Galaxy1"}

	
	
	{ "name": "KT������������ �Ѱ�", "tel": "010-7274-7890","tmodel":"KT"},
	
	{ "name": "������ ��", "tel": "010-9777-2288","tmodel":"KT/iPhone3gs"}
	{ "name": "����ȯ", "tel": "010-9856-4416","tmodel":"KT/iPhone3gs"}
	{ "name": "�ֿ�ȣ ����", "tel": "010-9879-9922","tmodel":"KT/iPhone3gs"}
	{ "name": "������ ����", "tel": "010-2776-2636","tmodel":"KT/iPhone3gs"}
	{ "name": "������ ����", "tel": "010-7311-9789","tmodel":"KT/iPhone3gs"}
	
	{ "name": "������ ������", "tel": "010-7350-4779","tmodel":"KT/iPhone3gs"}
	
	
	
	
	
	{ "name": "Ȳ�ο�", "tel": "010-8397-0312","tmodel":"KT/iPhone3gs"},
	{ "name": "Ȳ�ʷ�", "tel": "010-8490-6190","tmodel":"SK/Gal2"},
	
	{ "name": "������", "tel": "010-7275-7911","tmodel":"KT/iPhone3gs"},
	{ "name": "����ȣ", "tel": "010-4802-4049","tmodel":"SK/SKY/ANDROID"},
	{ "name": "����ȣ", "tel": "010-2035-7652","tmodel":"SK/SKY/ANDROID"},
	
	{ "name": "��âȣ", "tel": "010-4051-5758","tmodel":"KT/iPhone4"},
	{ "name": "�輺��", "tel": "010-2733-9358","tmodel":"SK/iPhone4"},
	{ "name": "���翬", "tel": "010-9989-0124","tmodel":"SK/iPhone4s"},
	{ "name": "�ֿ���", "tel": "010-2467-0981","tmodel":"LG/��ó"},


{ "name": "������", "tel": "010-9945-2235","tmodel":"SK/OptimusLTE"}

<#assign rcvs=[
{ "name": "����ȣ", "tel": "010-4802-4049","tmodel":"SK/SKY/ANDROID"}
		]/>
	
	<#list rcvs as rcv>
		<#assign mapHeader=mapHeader+ {
		"�߼ۼ��������ĺ���":ymdhmss + (rcv_index?string)
		}/>

		<#assign mapSMS=mapSMS+ {
		"�߼ۼ��������ĺ���":ymdhmss + (rcv_index?string),
		"������ȭ��ȣ":rcv.tel?replace("-","")
		}/>
		
		
		${mapSMS["�߼ۼ��������ĺ���"]}, ${mapSMS["������ȭ��ȣ"]}
		
 		<#assign r=m1.flatten(mapHeader,"FWXHEADER",mapped)/>
 		<#assign r=m1.flattenNext(mapSMS,"FWXREQUEST",mapped)/>
 		<#assign r=m1.flattenNext(mapSMS,"FWXREQUEST_EXT_MMS",mapped)/>

 		<#assign r=q.write1(qnm,mapped,0,m1.sizeof("FWXHEADER","FWXREQUEST","FWXREQUEST_EXT_MMS"))/>

	</#list>
