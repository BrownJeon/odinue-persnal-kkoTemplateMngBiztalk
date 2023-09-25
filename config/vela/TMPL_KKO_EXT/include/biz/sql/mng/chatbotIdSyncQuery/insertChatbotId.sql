INSERT INTO M1_TEMPLATE_EXT_RCS_CHATBOT (
    BR_ID, SUB_NUM, SUB_TITLE, DISPLAY, GRP_ID,
    APPR_YMD, APPR_RESULT, UPDATE_USER_ID, UPDATE_DT, REG_USER_ID,
    REG_DT, MAINNUM_YN, STATUS, CHATBOT_ID
) VALUES (
    @brandId, @subNum, @subTitle, @display, @groupId,
    @approvalDate, @approvalResult, @updateId, @updateDate, @registerId,
    @registerDate, @isMainNum, @service, @chatbotId
)