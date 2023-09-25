<#-- �Լ� include -->
<#include "../../../request.include_function.ftl"/>

<#assign selectMessagebaseIdQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectMessagebaseId.sql")!""/>
<#assign selectBrandIdQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectBrandId.sql")!""/>
<#assign selectRcsTemplateQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectRcsTemplate.sql")!""/>
<#assign deleteRcsTemplateQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/deleteRcsTemplate.sql")!""/>

<#assign sqlConn = m1.new("sql")/>


<#-- ���̽�ID�� �Է¹����� �ϳ��� ���̽�ID�� ó�� -->
<#assign msgbaseIdCommand = m1.sysenv["MESSAGEBASE_ID"]!"" />
<#if !msgbaseIdCommand?has_content>
    <#assign r = m1.log("[TMPL][DELETE][ERR] ���ڰ��� �Է��ؾ� �մϴ�.", "ERROR")/>

<#else>
    <#assign r = m1.log("[TMPL][DELETE][START] RCS���ø� �����۾� ����....", "INFO")/>

    <#--  API-KEY ������ �����ٰ� �귣��ID��� ����  -->
    <#assign clientInfoList = m1.shareget("clientInfoList")![]/>
    <#if !clientInfoList?has_content>
        <#assign r = m1.log("[TMPL][DELETE][ERR] API-KEY���� ����.... ó�� ����.", "ERROR")/>

    <#else>
        <#list clientInfoList as clientInfo>
            <#assign clientId = clientInfo.clientId!""/>
            <#assign clientSecret = clientInfo.clientSecret!""/>

            <#assign token = getToken(httpObj, tmplMngrUrl, clientId, clientSecret)/>

            <#assign header = {
                "Content-Type" : "application/json; charset=utf-8",
                "Accept" : "application/json, text/plain, */*",
                "Authorization" : "Bearer ${token}"
            }/>

            <#if msgbaseIdCommand?upper_case == "ALL">

                <#assign arrList = m1.editable([])/>

                <#assign selectMsgIdRs = sqlConn.query2array(selectMessagebaseIdQuery, {
                    "�˼�����": "3"
                    , "�˼�����ڵ�": "20000000"
                })/>
                <#list selectMsgIdRs as row>
                    <#assign r = arrList.put(row.TEMPLATE_ID!"")/>
                </#list>

                <#assign r = sqlConn.close(selectMsgIdRs)/>

            <#else>
                <#assign arrList = [msgbaseIdCommand]/>

            </#if>

            <#list arrList as messagebaseId>
                <#--  ���̽�ID�� ���ø����̺��� ��ȸ�Ͽ� �귣��ID�� ��������  -->
                <#assign brandIdRs = sqlConn.query2array(selectBrandIdQuery, {
                    "���̽�ID": messagebaseId
                })/>

                <#--  DB���� ��ȸ�� �����Ϳ��� �귣��ID�� ����  -->
                <#if brandIdRs?has_content>
                    <#assign brandId = brandIdRs[0]["CHANNEL_ID"]!""/>
                <#else>
                    <#assign brandId = ""/>
                </#if>

                <#assign requestTemplateCancelUrl = "${tmplMngrUrl}/brand/${brandId}/messagebase/${messagebaseId}/cancel"/>

                <#assign r = m1.log("[TMPL][DELETE][RBC][CANCEL] ���ø� �˼���� ��û. @��ûURL=[${requestTemplateCancelUrl}]", "INFO")/>

                <#assign httpTemplateCancelResponseCode = httpObj.request(requestTemplateCancelUrl, "PUT", "", header)!-1/>
                <#if httpObj.responseData?has_content>
                    <#assign httpTemplateCancelResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>
                <#else>
                    <#assign httpTemplateCancelResponseBody = ""/>
                </#if>

                <#if httpTemplateCancelResponseCode != 200>
                    <#assign r = m1.log("[TMPL][DELETE][RBC][CANCEL] ���ø� �˼���� ����. @�����ڵ�=[${httpTemplateCancelResponseCode}]", "ERROR")/>
                    <#assign r = m1.log(httpTemplateCancelResponseBody, "ERROR")/>

                <#else>
                    <#assign requestTemplateDeleteUrl = "${tmplMngrUrl}/brand/${brandId}/messagebase/${messagebaseId}"/>

                    <#assign r = m1.log("[TMPL][DELETE][RBC][DELETE] ���ø� ���� ��û. @��ûURL=[${requestTemplateDeleteUrl}]", "INFO")/>

                    <#assign httpTemplateDeleteResponseCode = httpObj.request(requestTemplateDeleteUrl, "DELETE", "", header)!-1/>
                    <#assign httpTemplateDeleteResponseBody = m1.getString(httpObj.responseData, "UTF-8")/>

                    <#if httpTemplateDeleteResponseCode != 200>
                        <#assign r = m1.log("[TMPL][DELETE][RBC][DELETE] ���ø����� ����. @�����ڵ�=[${httpTemplateDeleteResponseCode}]" , "ERROR")/>
                        <#assign r = m1.log(httpTemplateDeleteResponseBody, "ERROR")/>
                    <#else>
                        <#-- ���ø� �˼���û ��� & ���� �Ϸ�Ǿ� DB������ ����ó�� -->
                        <#assign r = m1.log("[TMPL][DELETE][BRC][DELETE] ���ø����� ����. @�����ڵ�=[${httpTemplateDeleteResponseCode}]", "INFO")/>
                        <#assign r = m1.log(httpTemplateDeleteResponseBody, "DEBUG")/>

                        <#-- ���ø����� ��ȸ -->
                        <#assign selectRcsTemplateRs = sqlConn.query2array(selectRcsTemplateQuery, {
                            "���̽�ID": messagebaseId
                        })/>

                        <#if (selectRcsTemplateRs?size > 0)>
                            <#assign r = m1.log("[TMPL][DELETE][DB][SELECT] �˼���� ���ø� DB������ ��ȸ �Ϸ�. @���̽�ID=[${messagebaseId}]", "INFO")/>
                            <#list selectRcsTemplateRs as row>
                                <#assign r = m1.log(row, "DEBUG")/>

                                <#assign seq = row["TM_SEQ"]!"-1"/>

                                <#--  ��ȸ�� ���ø������� ������ ���ø�����  -->
                                <#--  ���ս������̺��� ��� ���ս������̺�, RCS�������̺��� �����͸� �����ؾ��ϹǷ� ���������� ������ ������ �� �ֵ��� ó��  -->
                                <#assign deleteQueryList = deleteRcsTemplateQuery?split("#DELIM")/>

                                <#list deleteQueryList as deleteQuery>
                                    <#assign rs = sqlConn.execute(deleteQuery, {
                                        "SEQ": seq
                                    })/>

                                    <#if (rs >= 0)>
                                        <#assign r = m1.log("[TMPL][DELETE][DB][DELETE][${deleteQuery_index}][SUCC] DB������ ���� ����. @SEQ=[${seq}]", "INFO")/>

                                    <#else>
                                        <#assign r = m1.log("[TMPL][DELETE][DB][DELETE][${deleteQuery_index}][FAIL] DB������ ���� ����. @SEQ=[${seq}] @ó�����=[${rs}]", "ERROR")/>

                                        <#assign r = sqlConn.rollback()/>
                                        <#break/>

                                    </#if>

                                </#list>
                            </#list>

                        <#else>
                            <#assign r = m1.log("[TMPL][DELETE][DB][SELECT] DB������ ����. @���̽�ID=[${messagebaseId}]", "INFO")/>
                        </#if>

                        <#assign r = sqlConn.close(selectRcsTemplateRs)/>

                        <#assign r = sqlConn.commit()/>
                    </#if>
                </#if>
            </#list>
            
        </#list>
    </#if>
</#if>

<#assign r = sqlConn.close()/>

<#assign r = m1.log("[TMPL][DELETE][END] RCS���ø� �����۾� ����....", "INFO")/>


<#-- ��ū���� ��ȸ -->
<#function getToken _httpObj _tmplMngrUrl _clientId _clientSecret>

    <#local token = ""/>

    <#local header = {
            "Content-Type" : "application/json; charset=utf-8",
            "Accept" : "application/json, text/plain, */*"
    }/>
    <#local payloadMap = {
            "clientId" : _clientId
            , "clientSecret" : _clientSecret
    }/>

    <#local r = m1.log("[TMPL][RBC][TOKEN] ��ū�߱� ��û. @clientId=[${_clientId}]", "INFO")/>

    <#local payload = m1.toJsonBytes(payloadMap)?string/>
    <#local bcbytes = m1.getBytes(payload, "UTF-8")/>
    
    <#local httpResponseCode=_httpObj.post("${_tmplMngrUrl}/token", bcbytes, 0, bcbytes?size, header)!-1/>
    <#local httpResponseBody = m1.getString(_httpObj.responseData, "UTF-8")/>

    <#local r = m1.log("[TMPL][RBC][TOKEN] ��ū�߱� �Ϸ�. @�����ڵ�=[${httpResponseCode}]", "INFO")/>
    <#local r = m1.log(httpResponseBody, "DEBUG")/>
    
    <#local responseBody = m1.parseJsonValue(httpResponseBody)/>
    
    <#local token = responseBody.accessToken/>

    <#return token/>
    
</#function>