
<#-- 결과요청 템플릿 DB조회 쿼리 로딩 -->
<#assign selectPollResult = m1.loadText("../TMPL_KKO_EXT/include/biz/sql/task/pollingResultDataQuery/selectPollResult.sql")/>
<#assign r = m1.session("selectPollResultQuery", selectPollResult)/>

<#-- 검수결과 응답전문의 템플릿상태 매핑목록 로딩 -->
<#assign templateResultStatusMapper = m1.loadText("../TMPL_KKO_EXT/include/biz/codemap/templateResultStatusMapper.json")/>
<#assign r = m1.session("templateResultStatusMapper", m1.parseJsonValue(templateResultStatusMapper))/>
