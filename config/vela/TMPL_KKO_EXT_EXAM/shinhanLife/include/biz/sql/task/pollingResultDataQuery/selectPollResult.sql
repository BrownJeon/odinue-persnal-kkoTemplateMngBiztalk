/* dotaks.TMPL_PL_RESULT.ftl selectPollResult */
SELECT 
    TM_SEQ, CHANNEL_ID, TEMPLATE_ID, USE_YN
FROM 
    M1_TEMPLATE_MST
WHERE 
    APPROVAL_STATUS = '3'
    AND APPROVAL_CODE = @approvalCode
    AND APPROVAL_REASON = @approvalReason
    AND (
	    REG_DATE > TO_CHAR(sysdate - @searchInterval, 'YYYYMMDDHH24MISS') AND REG_DATE <= TO_CHAR(sysdate, 'YYYYMMDDHH24MISS')
	)
    AND rownum < @countFetch
ORDER BY REG_DATE ASC

