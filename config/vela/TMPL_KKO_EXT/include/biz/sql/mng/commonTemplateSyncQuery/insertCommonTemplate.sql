INSERT INTO M1_TEMPLATE_MST
(
	TM_SEQ, CHANNEL_ID, TEMPLATE_ID
	, CHANNEL_TYPE, TEMPLATE_NAME, TEMPLATE_TITLE
	, APPROVAL_REASON, REG_USER , REG_DATE
	, APPROVAL_CODE, UPDATE_DATE, UPDATE_USER, USE_YN
)
VALUES
(
	@������, @�귣��ID, @���̽�ID
	, @ä�α���, @���ø���, @���ø�����
	, @���ΰ������, @�����, @����Ͻ�
	, @�˼�����ڵ�, @�����Ͻ�, @������, @���ø���뿩��
)


#DELIM

INSERT INTO M1_TEMPLATE_EXT_RCS
(
	TM_SEQ, TEMPLATE_ID, MESSAGEBASE_FORM_ID, AGENCY_ID
	, MESSAGEBASE_TYPE
)
VALUES
(
	@������, @���̽�ID, @���ø���ID, @�׷�ID
	, @���̽�Ÿ��
)
