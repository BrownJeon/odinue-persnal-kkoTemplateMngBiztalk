<#-- 함수 include -->
<#include "../../../request.include_function.ftl"/>

<#assign selectAllTemplateIdQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectAllTemplateId.sql")!""/>
<#assign selectChannelIdQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectChannelId.sql")!""/>
<#assign selectTemplateQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectTemplate.sql")!""/>
<#assign deleteTemplateQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/deleteTemplate.sql")!""/>

<#assign sqlConn = m1.new("sql")/>

<#-- 베이스ID를 입력받으면 하나의 베이스ID를 처리 -->
<#assign templateIdCommand = m1.sysenv["TEMPLATE_ID"]!"" />
<#if !templateIdCommand?has_content>
    <#assign r = m1.log("[TMPL][DELETE][ERR] 인자값을 입력해야 합니다.", "ERROR")/>

<#else>
    <#assign r = m1.log("[TMPL][DELETE][START] 알림톡 템플릿 삭제작업 시작....", "INFO")/>

    <#--  API-KEY 정보를 가져다가 브랜드ID목록 세팅  -->
    <#assign profileKeyInfoMap = commonFunction_getProfileKeyInfoMap(sqlConn)/>
    <#assign resultCode = profileKeyInfoMap.code/>
    <#assign channelList = profileKeyInfoMap.data/>

    <#assign r = m1.log("==============", "INFO")/>
    <#assign r = m1.log(channelList, "INFO")/>

    <#if resultCode != "200">
        <#assign resultMessage = profileKeyInfoMap.message/>

        <#assign r = m1.log("[TMPL][DELETE][ERR] 발신프로필정보 조회 실패.... 처리 종료. @결과내용=[${resultMessage}]", "ERROR")/>

    <#elseif !channelList?has_content>
        <#assign r = m1.log("[TMPL][DELETE][ERR] 발신프로필정보 없음.... 처리 종료.", "ERROR")/>

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
                    "검수상태": "3"
                    , "검수결과코드": "200"
                    , "채널구분": "KM"
                })/>
                <#list selectMsgIdRs as row>
                    <#assign r = arrList.put(row.TEMPLATE_ID!"")/>
                </#list>

                <#assign r = sqlConn.close(selectMsgIdRs)/>

            <#else>
                <#assign arrList = [templateIdCommand]/>

            </#if>

            <#list arrList as templateId>
                <#--  베이스ID를 템플릿테이블에서 조회하여 브랜드ID를 가져오기  -->
                <#assign channelRs = sqlConn.query2array(selectChannelIdQuery, {
                    "템플릿ID": templateId
                    , "채널구분": "KM"
                })/>

                <#--  DB에서 조회한 데이터에서 브랜드ID를 세팅  -->
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

                <#assign r = m1.log("[TMPL][DELETE][RBC][CANCEL] 템플릿삭제 요청. @템플릿ID=[${templateId}] @발신프로필키=[${senderKey}] @요청URL=[${requestTemplateCancelUrl}]", "INFO")/>

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
                    <#assign r = m1.log("[TMPL][DELETE][RBC][CANCEL] 템플릿삭제 실패. @응답코드=[${responseCode}]", "ERROR")/>
                    <#assign r = m1.log(responseBody, "ERROR")/>

                <#else>
                    <#-- 템플릿 검수요청 취소 & 삭제 완료되어 DB데이터 삭제처리 -->
                    <#assign r = m1.log("[TMPL][DELETE][BRC][DELETE] 템플릿삭제 성공. @응답코드=[${responseCode}]", "INFO")/>
                    <#assign r = m1.log(responseBody, "DEBUG")/>

                    <#-- 템플릿정보 조회 -->
                    <#assign selectTemplateRs = sqlConn.query2array(selectTemplateQuery, {
                        "템플릿ID": templateId
                    })/>

                    <#if (selectTemplateRs?size > 0)>
                        <#assign r = m1.log("[TMPL][DELETE][DB][SELECT] 검수취소 템플릿 DB데이터 조회 완료. @베이스ID=[${templateId}]", "INFO")/>
                        <#list selectTemplateRs as row>
                            <#assign r = m1.log(row, "DEBUG")/>

                            <#assign isSuccess = true/>

                            <#assign seq = row["TM_SEQ"]!"-1"/>

                            <#--  조회된 템플릿정보가 있으면 템플릿삭제  -->
                            <#--  통합승인테이블의 경우 통합승인테이블, RCS승인테이블의 데이터를 삭제해야하므로 삭제쿼리를 여러번 실행할 수 있도록 처리  -->
                            <#assign deleteQueryList = deleteTemplateQuery?split("#DELIM")/>

                            <#list deleteQueryList as deleteQuery>
                                <#assign rs = sqlConn.execute(deleteQuery, {
                                    "SEQ": seq
                                })/>

                                <#if (rs < 0)>
                                    <#assign r = m1.log("[TMPL][DELETE][DB][DELETE][${deleteQuery_index}][FAIL] DB데이터 삭제 실패. @SEQ=[${seq}] @처리결과=[${rs}]", "ERROR")/>
                                    <#assign isSuccess = false/>

                                    <#assign r = sqlConn.rollback()/>
                                    <#break/>

                                </#if>

                            </#list>

                            <#if isSuccess>
                                <#assign r = m1.log("[TMPL][DELETE][DB][DELETE][SUCC] DB데이터 삭제 성공. @SEQ=[${seq}]", "INFO")/>
                            </#if>
                        </#list>

                    <#else>
                        <#assign r = m1.log("[TMPL][DELETE][DB][SELECT] DB데이터 없음. @베이스ID=[${templateId}]", "INFO")/>
                    </#if>

                    <#assign r = sqlConn.close(selectTemplateRs)/>

                    <#assign r = sqlConn.commit()/>
                </#if>
            </#list>
        </#list>
    </#if>
</#if>

<#assign r = sqlConn.close()/>

<#assign r = m1.log("[TMPL][DELETE][END] 알림톡 템플릿 삭제작업 종료....", "INFO")/>
