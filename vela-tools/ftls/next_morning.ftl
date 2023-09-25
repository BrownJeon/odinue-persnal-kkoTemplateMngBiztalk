
 <#-- �����ε�.... --> 
<#assign daytimeTrancodes=m1.parseJsonValue(m1.loadText("daytime_trancodes.json")) />

 <#-- �Լ� validateSendTime(�����ڵ�,�����Ͻ�) , return ��ȿ�� �����Ͻ�  --> 
<#function validateSendTime trancode ymdhmsSend >

	<#assign ymdhms=ymdhmsSend/>
  <#if ymdhms == "00000000000000" >
       <#assign ymdhms=m1.ymdhms()/>
  </#if>
  
 <#-- ������ �����̸� --> 
  <#if daytimeTrancodes[trancode]?? >
     ��������
  	<#assign tSend=m1.ymdhms2millis(ymdhms) />
  	<#assign tNow= m1.ymdhms2millis() />
  	<#assign tDayAgo =tNow - 86400000 />
  	
  	<#-- ����ð��� ���ð� ����, 24�ð� �̳��� ���, ��� �߼۵ǹǷ�, 
  	       ���� �ð� �������� ���ؾ� �� -->
	  <#if tSend < tNow && tDayAgo < tSend >
	       <#assign ymdhms=m1.ymdhms()/>
	       <#-- 24�ð� ������ ���,�������.�̹߼� -->
	  <#elseif tSend < tDayAgo> 
	  			<#return ymdhmsSend  />		
	  </#if>
	  
  	
		<#assign hms = ymdhms?substring(8)?trim?number/>
		<#assign hmsBegin = daytimeTrancodes[trancode][0]?number * 100 />
		<#assign hmsEnd = daytimeTrancodes[trancode][1]?number * 100 />
		
		<#-- �߼۽ð��� �ɾ��̸� ������ ���۽ð����� ����.--> 
		<#if hmsEnd < hms    >
			<#assign nextday = m1.ymdhms( m1.ymdhms2millis(ymdhms) + 86400000 )?substring(0,8)/>
			<#return nextday + (hmsBegin?string("000000"))  />
		<#-- �߼۽ð��� �����̸� ���� ���۽ð����� ����.--> 
		<#elseif hms < hmsBegin    >
			<#assign theday = ymdhms?substring(0,8) />
			<#return theday + (hmsBegin?string("000000"))  />		
		</#if>
	</#if>
	
	<#return ymdhms/>

</#function>





<#-- TEST SET -->
����ð�: ${m1.ymdhms()}
		�ŷ��ڵ�,��û�ð�=>�����ð�, ���濩��, �ð��� 
<#list ["310124B","310124K" ] as tranid >
	<#list ["20150106010000","20150106090000","20150106230000",  
	          "20150107010000","20150107090000","20150107230000",   
	          "20150108010000","20150108090000","20150108230000",
	          "20150109010000","20150109090000","20150109230000"        ] as sendtime >
	         <#assign sendtime2=validateSendTime(tranid,sendtime)/>
		${tranid},${sendtime?substring(0,8)} ${sendtime?substring(8)}=>${sendtime2?substring(0,8)} ${sendtime2?substring(8)}, <#if sendtime!=sendtime2>����	<#else>  	</#if>, ${ (m1.ymdhms2millis(sendtime) - m1.ymdhms2millis())/1000/60/60 } 
	</#list>
</#list>



