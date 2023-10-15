<#-- �Լ� include -->
<#include "../../../request.include_function.ftl"/>

<#assign selectAllTemplateIdQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectAllTemplateId.sql")!""/>
<#assign selectChannelIdQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectChannelId.sql")!""/>
<#assign selectTemplateQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectTemplate.sql")!""/>
<#assign deleteTemplateQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/deleteTemplate.sql")!""/>

<#assign sqlConn = m1.new("sql")/>

<#-- ���̽�ID�� �Է¹����� �ϳ��� ���̽�ID�� ó�� -->
<#assign templateCode = m1.sysenv["TEMPLATE_ID"]!"" />
<#if !templateCode?has_content>
    <#assign r = m1.log("[TMPL][DELETE][ERR] ���ڰ����� ������ ���ø��ڵ带 �Է��ؾ� �մϴ�. ", "ERROR")/>

<#else>
    <#assign r = m1.log("[TMPL][DELETE][START] �˸��� ���ø� �����۾� ����. @���ø��ڵ�=[${templateCode}]", "INFO")/>

    <#-- ���ø����� ��ȸ -->
    <#assign selectTemplateRs = sqlConn.query2array(selectTemplateQuery, {
        "���ø�ID": templateCode
    })/>
    
    <#if (selectTemplateRs?size > 0)>
        <#assign r = m1.log("[TMPL][DELETE][DB][SELECT] ���� ���ø� DB������ ����. @���ø�ID=[${templateCode}]", "INFO")/>
        <#list selectTemplateRs as row>
            <#assign r = m1.log(row, "DEBUG")/>
            <#assign senderKey = row["CHANNEL_ID"]!""/>
            <#assign seq = row["TM_SEQ"]!"-1"/>

            <#--  DB���� API-KEY ���� ��ȸ  -->
            <#assign profileKeyInfoMap = commonFunction_getProfileKeyInfoMap(sqlConn)/>
            <#assign resultCode = profileKeyInfoMap.code/>
            <#assign channelList = profileKeyInfoMap.data/>

            <#if resultCode != "200">
                <#assign resultMessage = profileKeyInfoMap.message/>

                <#assign r = m1.log("[TMPL][DELETE][ERR] �߽����������� ��ȸ ����.... ó�� ����. @�������=[${resultMessage}]", "ERROR")/>

            <#elseif !channelList?has_content>
                <#assign r = m1.log("[TMPL][DELETE][ERR] �߽����������� ����.... ó�� ����.", "ERROR")/>

            <#else>
                <#--  ���ø����� ����  -->
                <#assign r = m1.log("���ø����� ��û�۾� ����. @���ø�ID=[${templateCode}] @�߽�������Ű=[${senderKey}]", "INFO")/>
                <#assign r = m1.log(channelList, "INFO")/>


                <#assign clientInfo = channelList[senderKey]!""/>
                <#if !clientInfo?has_content>
                    <#assign r = m1.log("[TMPL][DELETE][ERR] ��� ���ø��� �߽�������Ű�� ��ϵǾ� �ִ� ��������(clientId / clientSecret) ����.... ó�� ����.", "ERROR")/>

                <#else>
                    <#assign clientId = clientInfo.clientId!""/>
                    <#assign clientSecret = clientInfo.clientSecret!""/>

                    <#assign headerMap = {
                        "Content-Type" : "application/json; charset=utf-8"
                        ,"Accept" : "application/json, text/plain, */*"
                        ,"siteid" : clientId
                        ,"auth_key" : clientSecret
                    }/>

                    <#assign payloadMap = {
                        "senderKey": senderKey
                        , "templateCode": templateCode
                    }/>

                    <#assign requestTemplateCancelUrl = "${tmplMngrUrl}/${deleteTemplateUrl}"/>

                    <#assign r = m1.log("[TMPL][DELETE][RBC][CANCEL] ���ø����� ��û. @���ø�ID=[${templateCode}] @�߽�������Ű=[${senderKey}] @��ûURL=[${requestTemplateCancelUrl}]", "INFO")/>

                    <#assign httpResponse = httpRequest.requestHttp(requestTemplateCancelUrl, "POST", headerMap, payloadMap, {}, {})/>

                    <#assign responseCode = httpResponse.getResponseCode()/>
                    <#assign succBody = httpResponse.getBody()/>
                    <#assign errBody = httpResponse.getErrorBody()/>

                    <#if responseCode != 200 && errBody != "">
                        <#assign responseBody = errBody/>
                    <#else>
                        <#assign responseBody = succBody/>
                    </#if>

                    <#if responseCode != 200>
                        <#assign r = m1.log("[TMPL][DELETE][RBC][CANCEL] ���ø����� ����. @�����ڵ�=[${responseCode}]", "ERROR")/>
                        <#assign r = m1.log(responseBody, "ERROR")/>

                    <#else>
                        <#--  ���ø� DB������ ����  -->

                        <#assign isSuccess = true/>

                        <#--  ���ս������̺��� ��� ���ս������̺�, RCS�������̺��� �����͸� �����ؾ��ϹǷ� ���������� ������ ������ �� �ֵ��� ó��  -->
                        <#assign deleteQueryList = deleteTemplateQuery?split("#DELIM")/>

                        <#list deleteQueryList as deleteQuery>
                            <#assign rs = sqlConn.execute(deleteQuery, {
                                "SEQ": seq
                            })/>

                            <#if (rs < 0)>
                                <#assign r = m1.log("[TMPL][DELETE][DB][DELETE][${deleteQuery_index}][FAIL] DB������ ���� ����. @SEQ=[${seq}] @ó�����=[${rs}]", "ERROR")/>
                                <#assign isSuccess = false/>

                                <#assign r = sqlConn.rollback()/>
                                <#break/>

                            </#if>

                        </#list>

                        <#if isSuccess>
                            <#assign r = m1.log("[TMPL][DELETE][DB][DELETE][SUCC] DB������ ���� ����. @SEQ=[${seq}]", "INFO")/>
                            <#assign r = sqlConn.commit()/>
                        </#if>

                    </#if>

                </#if>

            </#if>

        </#list>

    <#else>
        <#assign r = m1.log("[TMPL][DELETE][DB][SELECT] DB������ ����. @���ø�ID=[${templateCode}]", "INFO")/>
    </#if>
</#if>

<#assign r = sqlConn.close()/>

<#assign r = m1.log("[TMPL][DELETE][END] �˸��� ���ø� �����۾� ����. @���ø��ڵ�=[${templateCode}]", "INFO")/>
