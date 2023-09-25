<#assign r=m1.stack("Content-type","text/javascript; charset=euc-kr")/>
$(function(){
  if (!window.console) console = {log: function() {}};
  _init();
  //_chart();
});
function nmb(ns) {
  ns = ns  || 0;
  return Number(ns.replace(/\,/g,""));
}
function nmz(ns) {
  return (ns=="0"?"":ns);
}
function nmc(x) {
    var parts = x.toString().split(".");
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    return parts.join(".");
}
function scopeCheck() {
  if(scopebox.checked) scope="all"; else scope="session";
}
function _init(){
  setInterval(function(){
    getQueue();
    getSystem();
  }, 1000);
}
var queueAPI = "monitque.ftl";
var systemAPI ="monitsys.ftl";
var status_error = false;
function getQueue(){
  $.ajax({
    url: queueAPI,
	dataType: "xml",
    data: {"sessionid":escape(sessionid), "scope":scope},
    success: function(xml){
      //console.log("getQueue: success...");
      dispQueue(xml);
    }
  })
  .done(function(){
    //console.log("getQueue: done...");
    $("#comment").text("");
  })
  .fail(function(jqXHR, status, error){
    console.log("AJAX FAIL STATUS : " + status);
    console.log(error.stack);
    console.log("getQueue: fail...");
	  if( status == "error" ) {
      status_error = true;
      $("#comment").text("CHECK XCENTER STATUS").fadeToggle(500, "linear");
  	}
    else {
      if(status_error == true) {
        status_error = false;
        document.location.reload();
      }
    }
  })
  .always(function(){
    //console.log("getQueue: always...");
  })
  .complete(function(){
    //console.log("getQueue: complete...");
  });
}
var firsttimechart_xcn=true;
var xcn_cnt=0;
function dispQueue(xml) {
  var v_pct=0, rownum=0;
  var chrtarr=[];
  var tpsmx="";

//  if(firsttimechart_xcn) xcn_cnt=0;
  xcn_cnt=0;

  try {
    $smsqm = $(xml).find("smsqm");
    $("#lasttime").text($.format.date(nmb($smsqm.attr("time")), "yyyy-MM-dd hh:mm:ss"));
    $("#elapsed").text($smsqm.attr("elapsed"));

    $q = $(xml).find("q");
    $q.each(function(){
      var qname = $(this).attr("name");
      var qrows = $("#"+qname+" td");
/*
name     = "XCN_SMS41"
id       = "0"             
type     = "M"             
stat     = "____"          
alloc    = "7K*190"        
master   = "0"             
tpsmx    = "0"             
tps      = "0"             
tot      = "0"             
mem      = "0"             
done     = "0"             
edone    = "0"             
ack      = "0"             
eack     = "0"             
rslt     = "0"             
erslt    = "0"             
rwrw     = "__ __________" 
last-in  = "02-02:53"      
last-out = "02-02:53"      
pidp     = "6,868"         
pidpf    = "0"             
pidg     = "6,868"         
pidgf    = "0"             
*/
      //$($(qrows)[ 0]).text($(this).attr("id"));
      $($(qrows)[ 1]).text(      $(this).attr("id"      )   );
      $($(qrows)[ 2]).text(      $(this).attr("alloc"   )   );
      $($(qrows)[ 3]).text(      $(this).attr("stat"    )   );
        if($($(qrows)[3]).hasClass($(this).attr("stat"))) $(qrows).removeClass("alert"); else $(qrows).addClass("alert"); 
      $($(qrows)[ 4]).text( nmz( $(this).attr("master"  ) ) );
        if($(this).attr("tpsmx")=="0") tpsmx=""; else tpsmx="/"+$(this).attr("tpsmx");
      $($(qrows)[ 5]).text( nmz( $(this).attr("tps"     ) ) +tpsmx);
        if(Number($(this).attr("tps"))==0) $(qrows[5]).removeClass("run"); else $(qrows[5]).addClass("run"); 
      $($(qrows)[ 6]).text( nmz( $(this).attr("tot"     ) ) );
      $($(qrows)[ 7]).text( nmz( $(this).attr("mem"     ) ) );
      $($(qrows)[ 8]).text( nmz( $(this).attr("done"    ) ) );
      $($(qrows)[ 9]).text( nmz( $(this).attr("rslt"    ) ) );
      $($(qrows)[10]).text( nmz( $(this).attr("erslt"   ) ) );
      $($(qrows)[11]).text(      $(this).attr("last-in" )   );
      $($(qrows)[12]).text(      $(this).attr("last-out")   );
      $($(qrows)[13]).text( nmz( $(this).attr("pidp"    ) ).replace(",",""));
      $($(qrows)[14]).text( nmz( $(this).attr("pidg"    ) ).replace(",",""));
      if(rownum == 0 && v_pct == 0) {
        v_pct = $(this).attr("tps");
      }
//      if(firsttimechart_xcn && qname.substr(0,3)=="XCN" && $("#"+qname).length) {
//        xcn_cnt++;
//      }
      if(qname.substr(0,3)=="XCN" && $("#"+qname).length) {
        xcn_cnt++;
        v_pct = Number($(this).attr("tps"));
        chrtarr.push(v_pct);
      }
	    rownum++;	  
    });

    if(firsttimechart_xcn) {
      firsttimechart_xcn = false; 
      _chart_xcn(chrtarr);
    }
    updateChart_xcn(chrtarr);
  }
  catch(err){
    console.log(err);
  }

  //console.log($q.text());
}
function getSystem(){
  $.ajax({
    url: systemAPI,
	  dataType: "xml",
    data: {"sessionid":escape(sessionid), "scope":scope},
    success: function(xml){
      //console.log("getSystem: success...");
      dispSystem(xml);
    }
  })
  .done(function(){
    //console.log("getSystem: done...");
  })
  .fail(function(jqXHR, status, error){
    console.log("AJAX FAIL STATUS : " + status);
    console.log(error.stack);
    console.log("getSystem: fail...");
  })
  .always(function(){
    //console.log("getSystem: always...");
  })
  .complete(function(){
    //console.log("getSystem: complete...");
  });
}
var firsttimechart=true;
function dispSystem(xml) {
  try {
/*
Cpu     desc
Memory  free total fpct upct
D: free total fpct upct

*/
    $Cpu = $(xml).find("resource[name='Cpu']");
    $Memory = $(xml).find("resource[name='Memory']");
    $Drive = $(xml).find("resource[name='D:']");

    $("#rsc-cpu-pct").text( nmb($Cpu.attr("desc")).toFixed(2) + "%" );
    $("#rsc-mem-pct").text( nmb($Memory.attr("upct")).toFixed(2) + "%" );
    $("#rsc-mem-fre").text( $Memory.attr("free") + " bytes" );
    $("#rsc-mem-tot").text( $Memory.attr("total") + " bytes" );


    var rsc_d_usg = (nmb($Drive.attr("total")) - nmb($Drive.attr("free"))) / 1024 / 1024 / 1024;
    var rsc_d_tot = (nmb($Drive.attr("total"))) / 1024 / 1024 / 1024;
    var rsc_d_pct = rsc_d_usg / rsc_d_tot * 100;
    $("#rsc-d-usg").text( nmc(rsc_d_usg.toFixed(2)) + " GB" );
    $("#rsc-d-tot").text( nmc(rsc_d_tot.toFixed(2)) + " GB" );
    $("#bar-d-usg").width( rsc_d_pct.toFixed(1) + "%" );

    if(firsttimechart) {
      firsttimechart = false; 
      _chart();
    }
    updateChart( nmb($Cpu.attr("desc")), nmb($Memory.attr("upct")) );
    

  }
  catch(err){
    console.log(err);
  }

  //console.log($q.text());
}
var plot, plot_xcn;
var cdata1 = [], cdata2 = [], totalXPoints=30, totalPoints = 30;
var cdata_xcn = [];
function iniCData() {
  for(var i=0; i<totalXPoints; i++) {
    cdata1.push(0);
  }
  var res = [];
  for (var i = 0; i < cdata1.length; ++i) {
    res.push([i, cdata1[i]])
  }
  return res;
}
function iniCData2() {
  for(var i=0; i<totalXPoints; i++) {
    cdata2.push(0);
  }
  var res = [];
  for (var i = 0; i < cdata2.length; ++i) {
    res.push([i, cdata2[i]])
  }
  return res;
}
function iniCData_xcn() {
  for (var cnt = 0; cnt < xcn_cnt; ++cnt) {
    var res_in = [];
    for (var i = 0; i < 30; ++i) {
      //res_in.push(cnt*10)
      res_in.push(0)
    }
    cdata_xcn.push( {data:res_in} )
  }
  var res = [];
  for (var cnt = 0; cnt < xcn_cnt; ++cnt) {
    var res_in = [];
    for (var i = 0; i < 30; ++i) {
      res_in.push([i, cdata_xcn[cnt].data[i]]);
    }
    res.push( {data:res_in} )
  }
  return res;
}
function setCData(v) {
  if (cdata1.length != totalXPoints) iniCData();
  cdata1 = cdata1.slice(1);
  cdata1.push(v)

  var res = [];
  for (var i = 0; i < cdata1.length; ++i) {
    res.push([i, cdata1[i]])
  }
  return res;
}
function setCData2(v) {
  if (cdata2.length != totalXPoints) iniCData();
  cdata2 = cdata2.slice(1);
  cdata2.push(v)

  var res = [];
  for (var i = 0; i < cdata2.length; ++i) {
    res.push([i, cdata2[i]])
  }
  return res;
}
function setCData_xcn(chrtarr) {
  //  if (cdata_xcn.length != totalXPoints) iniCData_xcn();

  for (var cnt = 0; cnt < xcn_cnt; ++cnt) {
    cdata_xcn[cnt].data = cdata_xcn[cnt].data.slice(1);
    cdata_xcn[cnt].data.push(chrtarr[cnt]);
  }

  var res = [];
  for (var cnt = 0; cnt < xcn_cnt; ++cnt) {
    var res_in = [];
    for (var i = 0; i < 30; ++i) {
      res_in.push([i, cdata_xcn[cnt].data[i]]);
    }
    res.push( {data:res_in} )
  }
  return res;
}
function _chart() {
  plot = $.plot("#placeholder", [ iniCData(), iniCData2() ], {
    series: {
      shadowSize: 0	// Drawing is faster without shadows
    },
    yaxis: {
      min: 0,
      max: 100,
      show: false
    },
    xaxis: {
      show: false
    },
    grid: {
      borderWidth: 0
    }
  });
}
function _chart_xcn() {
  plot_xcn = $.plot("#placeholder-xcn", iniCData_xcn(), {
    series: {
      shadowSize: 0	// Drawing is faster without shadows
    },
    yaxis: {
      min: 0,
      max: 500,
      show: false
    },
    xaxis: {
      show: false
    },
    grid: {
      borderWidth: 0
    }
  });
}
function updateChart(v1, v2) {
  plot.setData([setCData(v1), setCData2(v2)]);
  // Since the axes don't change, we don't need to call plot.setupGrid()
  plot.draw();
}
function updateChart_xcn(chrtarr) {
//  plot_xcn.setData( iniCData_xcn() );
  plot_xcn.setData( setCData_xcn(chrtarr) );
  // Since the axes don't change, we don't need to call plot.setupGrid()
  plot_xcn.draw();
}
