/* dotask.TMPL_PL_REQUEST.ftl pollUpdate */
update tmpl_mngr_log
set status = '2',
    pollkey = @pollkey,
    polldate = now()
where status = '1'
limit 50