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
<#assign httpObj = m1.shareget("httpObj")!""/>
<#if !httpObj?has_content>
    <#assign httpObj = m1.statics["com.odinues.m1.open.template.TObjHttp"].newInstance() />
    <#assign r = m1.shareput("httpObj", httpObj)/>
</#if>

<#-- ���ø���� ���� ��� -->
<#assign channelList = m1.shareget("channelList")!""/>
<#if !channelList?has_content>
    <#assign channelList = m1props.getProperty("templateManage.api.channelList", "")?trim/>
    <#assign r=m1.shareput("channelList",channelList)/>
</#if>

<#-- �̹������ε� �߼۰��� ���� -->
<#assign rcsImgList = m1.shareget("rcsImgList")!""/>
<#if !rcsImgList?has_content>
    <#assign rcsImgList = m1props.getProperty("templateManage.api.rcsImgList", "")?trim/>
    <#assign r=m1.shareput("rcsImgList",rcsImgList)/>
</#if>

<#-- API���� ���� -->
<#assign apiVersion = m1.shareget("apiVersion")!""/>
<#if !apiVersion?has_content>
    <#assign apiVersion = m1props.getProperty("templateManage.api.version", "v2")?trim/>
    <#assign r=m1.shareput("apiVersion",apiVersion)/>
</#if>

<#-- api-key(clientId, clientSecret) ���� -->
<#assign clientInfoList = m1.shareget("clientInfoList")![]/>
<#if !clientInfoList?has_content>
    <#assign apikeyInfoListStr = m1props.getProperty("templateManage.api.apikeyInfoList", "")?trim/>

    <#assign newClientInfoList = m1.editable([])/>

    <#assign apikeyInfoList = apikeyInfoListStr?split(",")/>
    <#list apikeyInfoList as apikeyInfoStr>
        <#assign apikeyInfoList = apikeyInfoStr?split("^")/>

        <#assign r = newClientInfoList.put({
            "clientId": apikeyInfoList[0]
            , "clientSecret": apikeyInfoList[1]
        })/>

    </#list>


    <#assign r=m1.shareput("clientInfoList", newClientInfoList)/>
</#if>
