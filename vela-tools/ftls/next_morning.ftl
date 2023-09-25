
 <#-- 설정로딩.... --> 
<#assign daytimeTrancodes=m1.parseJsonValue(m1.loadText("daytime_trancodes.json")) />

 <#-- 함수 validateSendTime(업무코드,예약일시) , return 유효한 예약일시  --> 
<#function validateSendTime trancode ymdhmsSend >

	<#assign ymdhms=ymdhmsSend/>
  <#if ymdhms == "00000000000000" >
       <#assign ymdhms=m1.ymdhms()/>
  </#if>
  
 <#-- 설정된 업무이면 --> 
  <#if daytimeTrancodes[trancode]?? >
     설정업무
  	<#assign tSend=m1.ymdhms2millis(ymdhms) />
  	<#assign tNow= m1.ymdhms2millis() />
  	<#assign tDayAgo =tNow - 86400000 />
  	
  	<#-- 예약시간이 현시각 이전, 24시간 이내인 경우, 즉시 발송되므로, 
  	       현재 시각 기준으로 평가해야 함 -->
	  <#if tSend < tNow && tDayAgo < tSend >
	       <#assign ymdhms=m1.ymdhms()/>
	       <#-- 24시간 이전의 경우,변경없음.미발송 -->
	  <#elseif tSend < tDayAgo> 
	  			<#return ymdhmsSend  />		
	  </#if>
	  
  	
		<#assign hms = ymdhms?substring(8)?trim?number/>
		<#assign hmsBegin = daytimeTrancodes[trancode][0]?number * 100 />
		<#assign hmsEnd = daytimeTrancodes[trancode][1]?number * 100 />
		
		<#-- 발송시간이 심야이면 다음날 시작시간으로 설정.--> 
		<#if hmsEnd < hms    >
			<#assign nextday = m1.ymdhms( m1.ymdhms2millis(ymdhms) + 86400000 )?substring(0,8)/>
			<#return nextday + (hmsBegin?string("000000"))  />
		<#-- 발송시간이 새벽이면 당일 시작시간으로 설정.--> 
		<#elseif hms < hmsBegin    >
			<#assign theday = ymdhms?substring(0,8) />
			<#return theday + (hmsBegin?string("000000"))  />		
		</#if>
	</#if>
	
	<#return ymdhms/>

</#function>





<#-- TEST SET -->
현재시각: ${m1.ymdhms()}
		거래코드,요청시각=>조정시각, 변경여부, 시간차 
<#list ["310124B","310124K" ] as tranid >
	<#list ["20150106010000","20150106090000","20150106230000",  
	          "20150107010000","20150107090000","20150107230000",   
	          "20150108010000","20150108090000","20150108230000",
	          "20150109010000","20150109090000","20150109230000"        ] as sendtime >
	         <#assign sendtime2=validateSendTime(tranid,sendtime)/>
		${tranid},${sendtime?substring(0,8)} ${sendtime?substring(8)}=>${sendtime2?substring(0,8)} ${sendtime2?substring(8)}, <#if sendtime!=sendtime2>변경	<#else>  	</#if>, ${ (m1.ymdhms2millis(sendtime) - m1.ymdhms2millis())/1000/60/60 } 
	</#list>
</#list>



