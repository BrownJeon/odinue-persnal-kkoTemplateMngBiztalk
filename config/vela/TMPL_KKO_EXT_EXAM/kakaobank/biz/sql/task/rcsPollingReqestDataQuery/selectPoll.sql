/* dotask.TMPL_PL_REQUEST.ftl selectRequest */
select
	seq, channel_id, template_data, requester_alarm_number, requester_nickname
	, template_code, template_name
from tmpl_mngr_log
where status = '2'
	and pollkey = @pollkey
order by channel_id