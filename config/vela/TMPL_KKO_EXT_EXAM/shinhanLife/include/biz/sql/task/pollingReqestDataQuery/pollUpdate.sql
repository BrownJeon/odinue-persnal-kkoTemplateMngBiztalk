/* dotask.TMPL_PL_REQUEST.ftl pollUpdate */
UPDATE 
   M1_TEMPLATE_MST
SET
    APPROVAL_STATUS = '2'
    , POLL_DATE = @�����Ͻ�
    , POLL_KEY = @����Ű
WHERE 
    APPROVAL_STATUS = '1'
    AND REG_DATE > TO_CHAR(sysdate-3, 'YYYYMMDDHH24MISS')
    AND REG_DATE <= TO_CHAR(sysdate, 'YYYYMMDDHH24MISS')
    AND ROWNUM < @countFetch