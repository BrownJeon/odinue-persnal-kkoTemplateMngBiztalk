

<#--

m1.stack("input")

-->

<#assign bs=m1.loadFile(m1.sysenv["M1_HOME"] + "/vela-tools/data/ASIS000817.txt" )/>
<#assign r=m1.loadffdef(m1.sysenv["M1_HOME"] + "/config/vela-mdefs/ASIS000817.def" )/>

ASIS인뱅공통
ASIS000817

<#assign msgComm=m1.parse(bs,"ASIS인뱅공통" )/>
<#assign msg817=m1.parseNext(bs,"ASIS000817" )/>

<#assign r=m1.print(msgComm)/>
<#assign r=m1.print(msg817)/>


