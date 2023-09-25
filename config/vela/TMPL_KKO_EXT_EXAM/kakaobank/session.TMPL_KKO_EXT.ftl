<#-- 공통 설정파일 로딩-->
<#include "include/request.include_function.ftl"/>

<#-- 전문 규격 로딩 (Load FFDMessage) -->
<#assign m1home = m1.sysenv["M1_HOME"]/>
<#assign r = m1.loadffdef("${m1home}/config/vela-mdefs/M1.def") />

<#-- api baseURL 설정 -->
<#assign tmplMngrUrl = m1.shareget("tmplMngrUrl")/>

<#-- 승인템플릿 존재여부 조회 쿼리 -->
<#assign selectRcsTemplateQuery = m1.loadText("include/biz/sql/mng/rcsTemplateSyncQuery/selectRcsTemplate.sql")!""/>

<#-- 승인템플릿 동기화처리 쿼리 -->
<#assign insertRcsTemplateQuery =  m1.loadText("include/biz/sql/mng/rcsTemplateSyncQuery/insertRcsTemplate.sql")!""/>

<#--  브랜드정보 조회 쿼리  -->
<#assign selectBrandInfoQuery = m1.loadText("include/biz/sql/common/selectBrandInfo.sql")!""/>

<#-- SQL객체 정의 -->
<#assign sqlConn = m1.new("sql")/>

<#-- 
    토큰정보를 메모리에 존재여부 체크 
    RCS 브랜드ID를 통해서 조회
-->
<#-- 브랜드ID목록 -->
<#assign brandInfoMap = m1.editable({})/>

<#--  API-KEY 정보를 가져다가 브랜드ID목록 세팅  -->
<#assign clientInfoList = m1.shareget("clientInfoList")![]/>
<#if !clientInfoList?has_content>
    <#assign r = m1.log("[INIT][ERR] API-KEY정보 없음.... 시스템 종료.", "ERROR")/>

    <#assign r = m1.stack("return", -9)/>

<#else>
    <#assign r = m1.log("[INIT][BRAND] 브랜드정보 DB조회.", "INFO")/>
    
    <#list clientInfoList as clientInfo>
        <#assign clientId = clientInfo.clientId!""/>
        <#assign clientSecret = clientInfo.clientSecret!""/>

        <#--  브랜드ID 조회 쿼리  -->
        <#assign brandInfoRs = sqlConn.query2array(selectBrandInfoQuery, {})/>
        <#list brandInfoRs as brandInfo>

            <#assign brandId = brandInfo.BR_ID!""/>
            <#assign brandKey = brandInfo.BR_KEY!""/>
            <#if brandId?has_content>

                <#assign r = brandInfoMap.put(brandId, {
                    "brandKey": brandKey
                    , "clientId": clientId
                    , "clientSecret": clientSecret
                })/>
            </#if>
        </#list>
    </#list>

    <#assign r = sqlConn.close(brandInfoRs)/>

</#if>
<#assign r = m1.shareput("brandInfoMap", brandInfoMap)/>


<#assign token = ""/>

<#list brandInfoMap as brandId, brandInfo>

    <#assign clientId = brandInfo.clientId!""/>
    <#assign clientSecret = brandInfo.clientSecret!""/>

    <#--
        프로세스 기동시 최초 토큰발급 처리
    -->
    <#assign r = m1.log("="?left_pad(80, "="), "INFO")/>
    <#assign r = m1.log("[INIT][TOKEN][CREATE][START] 토큰발급 시작. @브랜드ID=[${brandId}] @clientId=[${clientId}] @clientSecret=[${clientSecret}]", "INFO")/>
    <#assign tokenInfo = commonFunction_requestTokenInfo({
        "clientId": clientId
        , "clientSecret": clientSecret
    })/>

    <#if tokenInfo?has_content && tokenInfo.code == 200>
        <#assign r = m1.shareput(brandId, tokenInfo)/>

        <#assign r = m1.log("[INIT][TOKEN][CREATE][SUCC] 토큰정보 발급. @토큰정보=[${m1.toJsonBytes(tokenInfo!{})}]", "INFO")/>
    </#if>

    <#assign token = tokenInfo.accessToken!""/>
    <#if !token?has_content>
        <#assign r = m1.log("[INIT][TOKEN][CREATE][ERR] 토큰정보 없음. 프로세스 종료.", "ERROR")/>

        <#break/>
    <#else>
        <#--  
            RBC 템플릿 동기화처리
                - 승인된 템플릿을 기준으로 동기화처리
        -->
        <#assign r = m1.log("="?left_pad(40, "=") + " 승인/승인대기 템플릿 동기화처리 시작." + "="?left_pad(40, "="), "INFO")/>

        <#assign rcsTemplateSyncParamMap = {
            "token": token
            , "sqlConn": sqlConn
            , "query": {
                "selectQuery": selectRcsTemplateQuery
                , "insertQuery": insertRcsTemplateQuery
            }
            , "requestUrl": "${tmplMngrUrl}/brand/${brandId}/messagebase"
        }/>

        <#assign resultMap = commonFunction_rbc2dbSync("RCS_TMPL", rcsTemplateSyncParamMap)/>
        
        <#if resultMap?has_content && resultMap.code == "200">
            <#assign r = m1.log("[RBC][FORM_ID][SUCC] 승인/승인대기 동기화 성공.", "INFO")/>
        
        <#else>
            <#assign r = m1.log("[RBC][FORM_ID][FAIL] 승인/승인대기 동기화 실패.", "ERROR")/>

        </#if>

        <#assign r = m1.log("="?left_pad(40, "=") + " 승인/승인대기 템플릿 동기화처리 완료." + "="?left_pad(40, "="), "INFO")/>
    </#if>

</#list>

<#assign r = sqlConn.close()/>