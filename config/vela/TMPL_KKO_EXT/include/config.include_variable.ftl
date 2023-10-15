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

<#--  URL��� �ε�  -->
<#-- ��û baseURL -->
<#assign tmplMngrUrl = m1.shareget("tmplMngrUrl")!""/>
<#if !tmplMngrUrl?has_content>
    <#assign tmplMngrUrl = m1props.getProperty("templateManage.api.url", "")?trim/>
    <#assign r=m1.shareput("tmplMngrUrl", tmplMngrUrl)/>
</#if>
<#-- ���ø����� ��û URL -->
<#assign createTemplateUrl = m1.shareget("createTemplateUrl")!""/>
<#if !createTemplateUrl?has_content>
    <#assign createTemplateUrl = m1props.getProperty("templateManage.api.url.createTemplate", "")?trim/>
    <#assign r=m1.shareput("createTemplateUrl", createTemplateUrl)/>
</#if>
<#-- ���ø� �̹������ε� (�̹��� / ���̶���Ʈ) URL -->
<#assign uploadImageUrl = m1.shareget("uploadImageUrl")!""/>
<#if !uploadImageUrl?has_content>
    <#assign uploadImageUrl = m1props.getProperty("templateManage.api.url.uploadImage", "")?trim/>
    <#assign r=m1.shareput("uploadImageUrl", uploadImageUrl)/>
</#if>
<#-- ���ø� ����� �̹������ε� URL -->
<#assign uploadHighlightImageUrl = m1.shareget("uploadHighlightImageUrl")!""/>
<#if !uploadHighlightImageUrl?has_content>
    <#assign uploadHighlightImageUrl = m1props.getProperty("templateManage.api.url.uploadHighlightImage", "")?trim/>
    <#assign r=m1.shareput("uploadHighlightImageUrl", uploadHighlightImageUrl)/>
</#if>
<#-- ���ø� �ܰ� ��ȸ URL -->
<#assign selectTemplate4OneUrl = m1.shareget("selectTemplate4OneUrl")!""/>
<#if !selectTemplate4OneUrl?has_content>
    <#assign selectTemplate4OneUrl = m1props.getProperty("templateManage.api.url.selectTemplate", "")?trim/>
    <#assign r=m1.shareput("selectTemplate4OneUrl", selectTemplate4OneUrl)/>
</#if>
<#-- ���ø� ���� URL -->
<#assign deleteTemplateUrl = m1.shareget("deleteTemplateUrl")!""/>
<#if !deleteTemplateUrl?has_content>
    <#assign deleteTemplateUrl = m1props.getProperty("templateManage.api.url.deleteTemplate", "")?trim/>
    <#assign r=m1.shareput("deleteTemplateUrl", deleteTemplateUrl)/>
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
<#assign httpRequest = m1.shareget("httpRequest")!""/>
<#if !httpRequest?has_content>
    <#assign httpRequest = m1.new("java:com.odinues.m1.openagent.util.HttpRequestUtil")/>
    <#assign r = m1.shareput("httpRequest", httpRequest)/>
</#if>


<#-- �������� -->
<#assign authYn = m1.shareget("authYn")!""/>
<#if !authYn?has_content>
    <#assign authYn = m1props.getProperty("templateManage.api.authYn", "n")?trim/>
    <#assign r=m1.shareput("authYn",authYn)/>
</#if>

<#-- ���ø� ����ȭ���� -->
<#assign syncTemplateYn = m1.shareget("syncTemplateYn")!""/>
<#if !syncTemplateYn?has_content>
    <#assign syncTemplateYn = m1props.getProperty("templateManage.api.syncTemplateYn", "n")?trim/>
    <#assign r=m1.shareput("syncTemplateYn",syncTemplateYn)/>
</#if>


<#--  SQL������ �ε�  -->
<#--  �����������̺��� �߽����������� ��ȸ  -->
<#assign selecProfileKeyInfoQuery = m1.shareget("selecProfileKeyInfoQuery")!""/>
<#if !selecProfileKeyInfoQuery?has_content>
    <#assign selecProfileKeyInfoQuery = m1.loadText("biz/sql/common/selecProfileKeyInfo.sql")!""/>

    <#assign r=m1.shareput("selecProfileKeyInfoQuery",selecProfileKeyInfoQuery)/>
</#if>

