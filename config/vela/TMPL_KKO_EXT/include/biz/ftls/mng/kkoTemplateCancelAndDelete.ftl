<#-- 함수 include -->
<#include "../../../request.include_function.ftl"/>

<#assign selectAllTemplateIdQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectAllTemplateId.sql")!""/>
<#assign selectChannelIdQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectChannelId.sql")!""/>
<#assign selectTemplateQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/selectTemplate.sql")!""/>
<#assign deleteTemplateQuery = m1.loadText("../../sql/mng/deleteTemplateQuery/deleteTemplate.sql")!""/>

<#assign sqlConn = m1.new("sql")/>

<#-- 베이스ID를 입력받으면 하나의 베이스ID를 처리 -->
<#assign templateCode = m1.sysenv["TEMPLATE_ID"]!"" />
<#if !templateCode?has_content>
    <#assign r = m1.log("[TMPL][DELETE][ERR] 인자값으로 삭제할 템플릿코드를 입력해야 합니다. ", "ERROR")/>

<#else>
    <#assign r = m1.log("[TMPL][DELETE][START] 알림톡 템플릿 삭제작업 시작. @템플릿코드=[${templateCode}]", "INFO")/>

    <#-- 템플릿정보 조회 -->
    <#assign selectTemplateRs = sqlConn.query2array(selectTemplateQuery, {
        "템플릿ID": templateCode
    })/>
    
    <#if (selectTemplateRs?size > 0)>
        <#assign r = m1.log("[TMPL][DELETE][DB][SELECT] 삭제 템플릿 DB데이터 존재. @템플릿ID=[${templateCode}]", "INFO")/>
        <#list selectTemplateRs as row>
            <#assign r = m1.log(row, "DEBUG")/>
            <#assign senderKey = row["CHANNEL_ID"]!""/>
            <#assign seq = row["TM_SEQ"]!"-1"/>

            <#--  DB에서 API-KEY 정보 조회  -->
            <#assign profileKeyInfoMap = commonFunction_getProfileKeyInfoMap(sqlConn)/>
            <#assign resultCode = profileKeyInfoMap.code/>
            <#assign channelList = profileKeyInfoMap.data/>

            <#if resultCode != "200">
                <#assign resultMessage = profileKeyInfoMap.message/>

                <#assign r = m1.log("[TMPL][DELETE][ERR] 발신프로필정보 조회 실패.... 처리 종료. @결과내용=[${resultMessage}]", "ERROR")/>

            <#elseif !channelList?has_content>
                <#assign r = m1.log("[TMPL][DELETE][ERR] 발신프로필정보 없음.... 처리 종료.", "ERROR")/>

            <#else>
                <#--  템플릿삭제 시작  -->
                <#assign r = m1.log("템플릿삭제 요청작업 시작. @템플릿ID=[${templateCode}] @발신프로필키=[${senderKey}]", "INFO")/>
                <#assign r = m1.log(channelList, "INFO")/>


                <#assign clientInfo = channelList[senderKey]!""/>
                <#if !clientInfo?has_content>
                    <#assign r = m1.log("[TMPL][DELETE][ERR] 대상 템플릿의 발신프로필키로 등록되어 있는 인증정보(clientId / clientSecret) 없음.... 처리 종료.", "ERROR")/>

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

                    <#assign r = m1.log("[TMPL][DELETE][RBC][CANCEL] 템플릿삭제 요청. @템플릿ID=[${templateCode}] @발신프로필키=[${senderKey}] @요청URL=[${requestTemplateCancelUrl}]", "INFO")/>

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
                        <#--  템플릿 DB데이터 삭제  -->

                        <#assign isSuccess = true/>

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
                            <#assign r = sqlConn.commit()/>
                        </#if>

                    </#if>

                </#if>

            </#if>

        </#list>

    <#else>
        <#assign r = m1.log("[TMPL][DELETE][DB][SELECT] DB데이터 없음. @템플릿ID=[${templateCode}]", "INFO")/>
    </#if>
</#if>

<#assign r = sqlConn.close()/>

<#assign r = m1.log("[TMPL][DELETE][END] 알림톡 템플릿 삭제작업 종료. @템플릿코드=[${templateCode}]", "INFO")/>
