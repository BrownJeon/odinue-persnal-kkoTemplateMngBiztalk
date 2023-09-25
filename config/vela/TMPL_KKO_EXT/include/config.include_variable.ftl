<#-- 전문 규격 로딩 (Load FFDMessage) -->
<#assign m1home = m1.sysenv["M1_HOME"]/>
<#assign r = m1.loadffdef("${m1home}/config/vela-mdefs/M1.def") />

<#--config 로드-->
<#assign m1props = m1.statics["com.odinues.m1.util.ClassProperties"].global/>

<#-- 검수요청 데이터 폴링 개수 -->
<#assign requestCountFetch = m1.shareget("requestCountFetch")!""/>
<#if !requestCountFetch?has_content>
    <#assign requestCountFetch = m1props.getProperty("templateManage.api.request.pollkey.requestCountFetch", "50")?trim/>
    <#assign r = m1.shareput("requestCountFetch", requestCountFetch?number)/>
</#if>

<#-- 검수결과 데이터 폴링 개수 -->
<#assign resultCountFetch = m1.shareget("resultCountFetch")!""/>
<#if !resultCountFetch?has_content>
    <#assign resultCountFetch = m1props.getProperty("templateManage.api.result.pollkey.resultCountFetch", "50")?trim/>
    <#assign r = m1.shareput("resultCountFetch", resultCountFetch?number)/>
</#if>

<#-- KEP baseURL -->
<#assign tmplMngrUrl = m1.shareget("tmplMngrUrl")!""/>
<#if !tmplMngrUrl?has_content>
    <#assign tmplMngrUrl = m1props.getProperty("templateManage.api.url", "")?trim/>
    <#assign r=m1.shareput("tmplMngrUrl", tmplMngrUrl)/>
</#if>

<#-- 큐정보 -->
<#--  요청 큐  -->
<#assign requestFileQueueName = m1.shareget("requestFileQueueName")!""/>
<#if !requestFileQueueName?has_content>
    <#assign requestFileQueueName = m1props.getProperty("templateManage.api.queue.request", "")?trim/>
    <#assign r=m1.shareput("requestFileQueueName",requestFileQueueName)/>
</#if>

<#--  DBX 큐  -->
<#assign dbxFileQueueName = m1.shareget("dbxFileQueueName")!""/>
<#if !dbxFileQueueName?has_content>
    <#assign dbxFileQueueName = m1props.getProperty("templateManage.api.queue.dbx", "")?trim/>
    <#assign r=m1.shareput("dbxFileQueueName",dbxFileQueueName)/>
</#if>

<#-- 공통 파일큐 객체 -->
<#assign fileQueueObj = m1.shareget("fileQueueObj")!""/>
<#if !fileQueueObj?has_content>
    <#assign fq = m1.new("fileq") />
    <#assign r = m1.shareput("fileQueueObj", fq)/>
</#if>

<#-- HTTP객체 -->
<#--  TODO. 비즈톡의 경우 TObjHttp객체를 사용시 에러 발생  -->
<#--  <#assign httpObj = m1.shareget("httpObj")!""/>
<#if !httpObj?has_content>
    <#assign httpObj = m1.statics["com.odinues.m1.open.template.TObjHttp"].newInstance() />
    <#assign r = m1.shareput("httpObj", httpObj)/>
</#if>  -->
<#assign httpRequest = m1.shareget("httpRequest")!""/>
<#if !httpRequest?has_content>
    <#assign httpRequest = m1.new("java:com.odinues.m1.openagent.util.HttpRequestUtil")/>
    <#assign r = m1.shareput("httpRequest", httpRequest)/>
</#if>

<#-- 템플릿등록 계정 목록 -->
<#assign channelList = m1.shareget("channelList")!m1.editable({})/>
<#if !channelList?has_content>
    <#assign channelListString = m1props.getProperty("templateManage.api.channelList", "")?trim/>

    <#assign channelInfoList = channelListString?split(",")/>
    <#list channelInfoList as channelString>
        <#assign r = m1.log("[TMPL][INIT] @채널목록=[${channelString}]","INFO")/>
        <#assign channelInfo = channelString?split("*^*")/>

        <#assign profileKey = channelInfo[0]!""/>
        <#if profileKey != "">
            <#assign r = channelList.put(profileKey, {
                    "clientId":channelInfo[1]!"",
                    "clientSecret":channelInfo[2]!""
                }
            )/>
        </#if>

    </#list>
    <#assign r = m1.log(channelList,"DEBUG")/>

    <#assign r=m1.shareput("channelList",channelList)/>


    <#assign r = m1.log(channelList,"INFO")/>
</#if>


<#-- 인증여부 -->
<#assign authYn = m1.shareget("authYn")!""/>
<#if !authYn?has_content>
    <#assign authYn = m1props.getProperty("templateManage.api.authYn", "n")?trim/>
    <#assign r=m1.shareput("authYn",authYn)/>
</#if>

<#-- 동기화여부 -->
<#assign syncTemplateYn = m1.shareget("syncTemplateYn")!""/>
<#if !syncTemplateYn?has_content>
    <#assign syncTemplateYn = m1props.getProperty("templateManage.api.syncTemplateYn", "n")?trim/>
    <#assign r=m1.shareput("syncTemplateYn",syncTemplateYn)/>
</#if>

<#-- API목록 -->
<#--  템플릿 단건 조회  -->
<#assign selectTemplateOne = m1.shareget("selectTemplateOne")!""/>
<#if !selectTemplateOne?has_content>
    <#assign selectTemplateOne = m1props.getProperty("templateManage.api.url.selectTemplateOne", "")?trim/>
    <#assign r=m1.shareput("selectTemplateOne",selectTemplateOne)/>
</#if>