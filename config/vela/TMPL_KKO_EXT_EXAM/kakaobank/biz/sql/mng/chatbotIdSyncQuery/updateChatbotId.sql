UPDATE 
    M1_TEMPLATE_EXT_RCS_CHATBOT
SET 
    BR_ID = @brandId,
    SUB_NUM = @subNum,
    SUB_TITLE = @subTitle,
    DISPLAY = @display,
    GRP_ID = @groupId,
    APPR_YMD = @approvalDate,
    APPR_RESULT = @approvalResult,
    UPDATE_USER_ID = @updateId,
    UPDATE_DT = @updateDate,
    REG_USER_ID = @registerId,
    REG_DT = @registerDate,
    MAINNUM_YN = @isMainNum,
    STATUS = @service
WHERE 
    CHATBOT_ID = @chatbotId