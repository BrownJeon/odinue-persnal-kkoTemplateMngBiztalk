/* dotask.TMPL_KKO_PL_REQ.ftl selectPoll */
SELECT
	tmpl.TM_SEQ
	, tmpl.CHANNEL_ID
	, tmpl.TEMPLATE_ID
	, tmpl.TEMPLATE_NAME 
	, tmpl.TEMPLATE_TITLE
	, ext.MESSAGE_TYPE
	, ext.CATEGORY_CODE
	, ext.FORM_PARAM
	, ext.BUTTON_INFO
	, ext.OPTION_INFO
FROM
	M1_TEMPLATE_MST tmpl JOIN M1_TEMPLATE_EXT_KKO ext
	ON tmpl.TM_SEQ = ext.TM_SEQ
WHERE
	tmpl.APPROVAL_STATUS = '2'
	AND tmpl.CHANNEL_TYPE = 'KM'
    AND tmpl.REG_DATE > TO_CHAR(sysdate-3, 'YYYYMMDDHH24MISS')
    AND tmpl.REG_DATE <= TO_CHAR(sysdate, 'YYYYMMDDHH24MISS')
    AND tmpl.POLL_KEY = @pollkey
ORDER BY tmpl.REG_DATE ASC