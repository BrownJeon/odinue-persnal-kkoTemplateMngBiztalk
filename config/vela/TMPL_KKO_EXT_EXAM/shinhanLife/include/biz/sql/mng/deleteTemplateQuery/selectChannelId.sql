SELECT
    CHANNEL_ID 
FROM 
    M1_TEMPLATE_MST 
WHERE 
    TEMPLATE_ID = @템플릿ID
    AND CHANNEL_TYPE = @채널구분