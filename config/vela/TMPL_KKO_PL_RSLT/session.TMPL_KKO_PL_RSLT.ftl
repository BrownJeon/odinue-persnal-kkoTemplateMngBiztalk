
<#-- �����û ���ø� DB��ȸ ���� �ε� -->
<#assign selectPollResult = m1.loadText("../TMPL_KKO_EXT/include/biz/sql/task/pollingResultDataQuery/selectPollResult.sql")/>
<#assign r = m1.session("selectPollResultQuery", selectPollResult)/>

<#-- �˼���� ���������� ���ø����� ���θ�� �ε� -->
<#assign templateResultStatusMapper = m1.loadText("../TMPL_KKO_EXT/include/biz/codemap/templateResultStatusMapper.json")/>
<#assign r = m1.session("templateResultStatusMapper", m1.parseJsonValue(templateResultStatusMapper))/>
