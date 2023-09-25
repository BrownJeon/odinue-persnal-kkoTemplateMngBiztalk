<#-- ���� �԰� �ε� (Load FFDMessage) -->
<#assign m1home = m1.sysenv["M1_HOME"]/>
<#assign r = m1.loadffdef("${m1home}/config/vela-mdefs/M1.def") />

<#--config �ε�-->
<#assign m1props = m1.statics["com.odinues.m1.util.ClassProperties"].global/>

<#-- �˼���û ������ ���� ���� -->
<#assign requestCountFetch = m1.shareget("requestCountFetch")!""/>
<#if !requestCountFetch?has_content>
    <#assign requestCountFetch = m1props.getProperty("templateManage.api.request.pollkey.requestCountFetch", "50")?trim/>
    <#assign r = m1.shareput("requestCountFetch", requestCountFetch?number)/>
</#if>

<#-- �˼���� ������ ���� ���� -->
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

<#-- ť���� -->
<#--  ��û ť  -->
<#assign requestFileQueueName = m1.shareget("requestFileQueueName")!""/>
<#if !requestFileQueueName?has_content>
    <#assign requestFileQueueName = m1props.getProperty("templateManage.api.queue.request", "")?trim/>
    <#assign r=m1.shareput("requestFileQueueName",requestFileQueueName)/>
</#if>

<#--  DBX ť  -->
<#assign dbxFileQueueName = m1.shareget("dbxFileQueueName")!""/>
<#if !dbxFileQueueName?has_content>
    <#assign dbxFileQueueName = m1props.getProperty("templateManage.api.queue.dbx", "")?trim/>
    <#assign r=m1.shareput("dbxFileQueueName",dbxFileQueueName)/>
</#if>

<#-- ���� ����ť ��ü -->
<#assign fileQueueObj = m1.shareget("fileQueueObj")!""/>
<#if !fileQueueObj?has_content>
    <#assign fq = m1.new("fileq") />
    <#assign r = m1.shareput("fileQueueObj", fq)/>
</#if>

<#-- HTTP��ü -->
<#--  TODO. �������� ��� TObjHttp��ü�� ���� ���� �߻�  -->
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

<#-- ���ø���� ���� ��� -->
<#assign channelList = m1.shareget("channelList")!m1.editable({})/>
<#if !channelList?has_content>
    <#assign channelListString = m1props.getProperty("templateManage.api.channelList", "")?trim/>

    <#assign channelInfoList = channelListString?split(",")/>
    <#list channelInfoList as channelString>
        <#assign r = m1.log("[TMPL][INIT] @ä�θ��=[${channelString}]","INFO")/>
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


<#-- �������� -->
<#assign authYn = m1.shareget("authYn")!""/>
<#if !authYn?has_content>
    <#assign authYn = m1props.getProperty("templateManage.api.authYn", "n")?trim/>
    <#assign r=m1.shareput("authYn",authYn)/>
</#if>

<#-- ����ȭ���� -->
<#assign syncTemplateYn = m1.shareget("syncTemplateYn")!""/>
<#if !syncTemplateYn?has_content>
    <#assign syncTemplateYn = m1props.getProperty("templateManage.api.syncTemplateYn", "n")?trim/>
    <#assign r=m1.shareput("syncTemplateYn",syncTemplateYn)/>
</#if>

<#-- API��� -->
<#--  ���ø� �ܰ� ��ȸ  -->
<#assign selectTemplateOne = m1.shareget("selectTemplateOne")!""/>
<#if !selectTemplateOne?has_content>
    <#assign selectTemplateOne = m1props.getProperty("templateManage.api.url.selectTemplateOne", "")?trim/>
    <#assign r=m1.shareput("selectTemplateOne",selectTemplateOne)/>
</#if>