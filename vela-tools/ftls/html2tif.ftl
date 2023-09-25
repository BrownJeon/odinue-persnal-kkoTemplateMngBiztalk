


<#assign tif=m1.new("tiff")/>


	  String headerFormat = getMapValue(params,"headerFormat","").toString() ;
	  String bottomFormat = getMapValue(params,"bottomFormat","").toString() ;
	  double zoom = Double.parseDouble(getMapValue(params,"zoom","1.0").toString());
	  int moveX = Integer.parseInt(getMapValue(params,"moveX","").toString());
	  int moveY = Integer.parseInt(getMapValue(params,"moveY","").toString());
	  int resolutionX = Integer.parseInt(getMapValue(params,"resolutionX","204").toString());
	  int resolutionY = Integer.parseInt(getMapValue(params,"resolutionY","196").toString());
	  
	  int marginLeft = Integer.parseInt(getMapValue(params,"marginLeft","25").toString());
	  int marginRight = Integer.parseInt(getMapValue(params,"marginRight","0").toString());
	  int marginTop = Integer.parseInt(getMapValue(params,"marginTop","0").toString());//최초 페이지.
	  int marginTopNext = Integer.parseInt(getMapValue(params,"marginTopNext","25").toString());//연속된 페이
	  int marginBottom = Integer.parseInt(getMapValue(params,"marginBottom","25").toString());
	  
	  int imageWidth = Integer.parseInt(getMapValue(params,"imageWidth","1728").toString());
	  int imageHeight = Integer.parseInt(getMapValue(params,"imageHeight","2341").toString());

	  int pageWidth = Integer.parseInt(getMapValue(params,"pageWidth","729").toString());
	  int pageHeight = Integer.parseInt(getMapValue(params,"pageHeight","1032").toString());
	  
	  
	  
	  
	  <#assign param={
	  	"header":"환율동향정보 알림-수협은행 #page/#total",
	  	"headerFontSize":"40",
	  	"headerX":"0",
	  	"headerY":"40",
	  	

	  	"footer":"발신:02-0000-0000 #page/#total",
	  	"zoomX":2.0,
	  	"zoomY":1.6,
	  	"moveX":60,
	  	"pageWidth":1842,
	  	"pageHeight":2191}/>
<#--	  
<#assign r=tif.htmls2tiff(["/data/fax-images/00000000000519003611.html"],"/data/fax-images/00000000000519003611.tif",param)/>
-->
  <#assign param={
	  	"header":"입출금 알림-수협은행 #page/#total",
	  	"headerFontSize":"40",
	  	"headerX":"0",
	  	"headerY":"40",
	  	

	  	"footer":"발신:02-0000-0000 #page/#total",
	  	"zoomX":2.2,
	  	"zoomY":2.2,
	  	"moveX":20,
	  	"pageWidth":1842,
	  	"pageHeight":2191}/>
<#--	  	
<#assign r=tif.htmls2tiff(["/app/appdev/M1shb/vela-tools/fax/20110901/sub_07_2.html"],"/app/appdev/M1shb/vela-tools/fax/20110901/sub_07_2.tif",param)/>
-->
  <#assign param={
	  	"header":"인터넷뱅킹 알림-수협은행 #page/#total",
	  	"headerFontSize":"30",
	  	"headerX":"0",
	  	"headerY":"30",
	  	"footer":"발신:02-0000-0000 #page/#total",
	  	"zoomX":2,
	  	"zoomY":2,
	  	"moveX":-500,
	  	"moveY":20,
	  	
	  	"pageWidth":1842,
	  	"pageHeight":1092}/>

<#assign r=tif.htmls2tiff(["/data/fax-images/20110909/0116/INBX000211_20110826_131005_10305748.txt.html"],"/data/fax-images/20110909/0116/INBX000211_20110826_131005_10305748.txt.tif",param)/>
<#--
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000133.html"],"/data/fax-images/20110908/INBX/INBX000133.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000161.html"],"/data/fax-images/20110908/INBX/INBX000161.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000164.html"],"/data/fax-images/20110908/INBX/INBX000164.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000180.html"],"/data/fax-images/20110908/INBX/INBX000180.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000191.html"],"/data/fax-images/20110908/INBX/INBX000191.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000192.html"],"/data/fax-images/20110908/INBX/INBX000192.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000211.html"],"/data/fax-images/20110908/INBX/INBX000211.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000212.html"],"/data/fax-images/20110908/INBX/INBX000212.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000213.html"],"/data/fax-images/20110908/INBX/INBX000213.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000219.html"],"/data/fax-images/20110908/INBX/INBX000219.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000231.html"],"/data/fax-images/20110908/INBX/INBX000231.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000255.html"],"/data/fax-images/20110908/INBX/INBX000255.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000376.html"],"/data/fax-images/20110908/INBX/INBX000376.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000421.html"],"/data/fax-images/20110908/INBX/INBX000421.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000451.html"],"/data/fax-images/20110908/INBX/INBX000451.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000452.html"],"/data/fax-images/20110908/INBX/INBX000452.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000453.html"],"/data/fax-images/20110908/INBX/INBX000453.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000454.html"],"/data/fax-images/20110908/INBX/INBX000454.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000455.html"],"/data/fax-images/20110908/INBX/INBX000455.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000870.html"],"/data/fax-images/20110908/INBX/INBX000870.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000880.html"],"/data/fax-images/20110908/INBX/INBX000880.tif",param)/>
<#assign r=tif.htmls2tiff(["/data/fax-images/20110908/INBX/INBX000881.html"],"/data/fax-images/20110908/INBX/INBX000881.tif",param)/>
-->
