UPDATE 
    M1_TEMPLATE_MST
SET 
    CHANNEL_ID=@�귣��ID
    , APPROVAL_STATUS=@���±���
    , APPROVAL_CODE=@����ڵ�
    , APPROVAL_REASON=@���ΰ������
    , USE_YN=@���ø���뿩��
    , REG_DATE=@����Ͻ�
    , REQ_DATE=@�����Ͻ�
    , APPROVAL_DATE=@�����Ͻ�
    , UPDATE_DATE=@�����Ͻ�
    , REG_USER=@�����
    , UPDATE_USER=@������
WHERE 
    TEMPLATE_ID = @���̽�ID

#DELIM

UPDATE 
    M1_TEMPLATE_EXT_RCS
SET 
    MESSAGEBASE_FORM_ID=@���ø���ID
    , AGENCY_ID=@�׷�ID
WHERE 
    TEMPLATE_ID = @���̽�ID

 