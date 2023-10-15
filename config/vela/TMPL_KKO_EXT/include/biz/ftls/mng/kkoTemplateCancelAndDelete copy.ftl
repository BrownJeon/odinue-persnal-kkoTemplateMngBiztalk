<#-- �Լ� include -->
<#include "../../../request.include_function.ftl"/>

<#assign selectAllTemplateIdQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectAllTemplateId.sql")!""/>
<#assign selectChannelIdQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectChannelId.sql")!""/>
<#assign selectTemplateQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectTemplate.sql")!""/>
<#assign deleteTemplateQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/deleteTemplate.sql")!""/>

<#assign sqlConn = m1.new("sql")/>

<#-- ���̽�ID�� �Է¹����� �ϳ��� ���̽�ID�� ó�� -->
<#assign templateIdCommand = m1.sysenv["TEMPLATE_ID"]!"" />
<#if !templateIdCommand?has_content>
    <#assign r = m1.log("[TMPL][DELETE][ERR] ���ڰ��� �Է��ؾ� �մϴ�.", "ERROR")/>

<#else>
    <#assign r = m1.log("[TMPL][DELETE][START] �˸��� ���ø� �����۾� ����....", "INFO")/>

    <#--  API-KEY ������ �����ٰ� �귣��ID��� ����  -->
    <#assign profileKeyInfoMap = commonFunction_getProfileKeyInfoMap(sqlConn)/>
    <#assign resultCode = profileKeyInfoMap.code/>
    <#assign channelList = profileKeyInfoMap.data/>

    <#assign r = m1.log("==============", "INFO")/>
    <#assign r = m1.log(channelList, "INFO")/>

    <#if resultCode != "200">
        <#assign resultMessage = profileKeyInfoMap.message/>

        <#assign r = m1.log("[TMPL][DELETE][ERR] �߽����������� ��ȸ ����.... ó�� ����. @�������=[${resultMessage}]", "ERROR")/>

    <#elseif !channelList?has_content>
        <#assign r = m1.log("[TMPL][DELETE][ERR] �߽����������� ����.... ó�� ����.", "ERROR")/>

    <#else>
        <#list channelList as senderKey, clientInfo>
            <#assign clientId = clientInfo.clientId!""/>
            <#assign clientSecret = clientInfo.clientSecret!""/>

            <#assign headerMap = {
                "Content-Type" : "application/json; charset=utf-8"
                ,"Accept" : "application/json, text/plain, */*"
                ,"siteid" : clientId
                ,"auth_key" : clientSecret
            }/>

            <#if templateIdCommand?upper_case == "ALL">

                <#assign arrList = m1.editable([])/>

                <#assign selectMsgIdRs = sqlConn.query2array(selectAllTemplateIdQuery, {
                    "�˼�����": "3"
                    , "�˼�����ڵ�": "200"
                    , "ä�α���": "KM"
                })/>
                <#list selectMsgIdRs as row>
                    <#assign r = arrList.put(row.TEMPLATE_ID!"")/>
                </#list>

                <#assign r = sqlConn.close(selectMsgIdRs)/>

            <#else>
                <#assign arrList = [templateIdCommand]/>

            </#if>

            <#list arrList as templateId>
                <#--  ���̽�ID�� ���ø����̺��� ��ȸ�Ͽ� �귣��ID�� ��������  -->
                <#assign channelRs = sqlConn.query2array(selectChannelIdQuery, {
                    "���ø�ID": templateId
                    , "ä�α���": "KM"
                })/>

                <#--  DB���� ��ȸ�� �����Ϳ��� �귣��ID�� ����  -->
                <#if channelRs?has_content>
                    <#assign senderKey = channelRs[0]["CHANNEL_ID"]!""/>
                <#else>
                    <#assign senderKey = ""/>
                </#if>

                <#assign payloadMap = {
                    "senderKey": senderKey
                    , "templateCode": templateId
                }/>

                <#assign requestTemplateCancelUrl = "${tmplMngrUrl}/${deleteTemplateUrl}"/>

                <#assign r = m1.log("[TMPL][DELETE][RBC][CANCEL] ���ø����� ��û. @���ø�ID=[${templateId}] @�߽�������Ű=[${senderKey}] @��ûURL=[${requestTemplateCancelUrl}]", "INFO")/>

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
                    <#-- ���ø� �˼���û ��� & ���� �Ϸ�Ǿ� DB������ ����ó�� -->
                    <#assign r = m1.log("[TMPL][DELETE][BRC][DELETE] ���ø����� ����. @�����ڵ�=[${responseCode}]", "INFO")/>
                    <#assign r = m1.log(responseBody, "DEBUG")/>

                    <#-- ���ø����� ��ȸ -->
                    <#assign selectTemplateRs = sqlConn.query2array(selectTemplateQuery, {
                        "���ø�ID": templateId
                    })/>

                    <#if (selectTemplateRs?size > 0)>
                        <#assign r = m1.log("[TMPL][DELETE][DB][SELECT] �˼���� ���ø� DB������ ��ȸ �Ϸ�. @���̽�ID=[${templateId}]", "INFO")/>
                        <#list selectTemplateRs as row>
                            <#assign r = m1.log(row, "DEBUG")/>

                            <#assign isSuccess = true/>

                            <#assign seq = row["TM_SEQ"]!"-1"/>

                            <#--  ��ȸ�� ���ø������� ������ ���ø�����  -->
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
                            </#if>
                        </#list>

                    <#else>
                        <#assign r = m1.log("[TMPL][DELETE][DB][SELECT] DB������ ����. @���̽�ID=[${templateId}]", "INFO")/>
                    </#if>

                    <#assign r = sqlConn.close(selectTemplateRs)/>

                    <#assign r = sqlConn.commit()/>
                </#if>
            </#list>
        </#list>
    </#if>
</#if>

<#assign r = sqlConn.close()/>

<#assign r = m1.log("[TMPL][DELETE][END] �˸��� ���ø� �����۾� ����....", "INFO")/>
