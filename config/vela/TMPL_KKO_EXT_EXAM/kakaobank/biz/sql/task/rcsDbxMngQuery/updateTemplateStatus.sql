/* dotask.TMPL_DBX.ftl updateTemplateStatus */
UPDATE
    M1_TEMPLATE_MST
SET
    TEMPLATE_ID = DECODE(@���̽�ID, '', TEMPLATE_ID, @���̽�ID)
    , APPROVAL_DATE = DECODE(NVL(@ó���Ͻ�, ''), '', APPROVAL_DATE, @ó���Ͻ�)
    , REQ_DATE = DECODE(NVL(@���ο�û�Ͻ�, ''), '', REQ_DATE, @���ο�û�Ͻ�)
    , UPDATE_DATE = DECODE(NVL(@�����Ͻ�,''), '', UPDATE_DATE, @�����Ͻ�)
    , APPROVAL_REASON = @ó���������
    , APPROVAL_CODE = @�˼�����ڵ�
    , APPROVAL_STATUS = @�˼�ó���ܰ�
    , USE_YN = @���ø���뿩��
WHERE
    TM_SEQ = @SEQ

#DELIM

UPDATE
    M1_TEMPLATE_EXT_RCS
SET
    TEMPLATE_ID = DECODE(@���̽�ID, '', TEMPLATE_ID, @���̽�ID)
WHERE
    TM_SEQ = @SEQ