INSERT INTO M1_TEMPLATE_EXT_KKO_PRIFILE
(
    CHANNEL_ID, CATEGORY_CODE, CHANNEL_KEY, PROFILE_KEY
    , EXPIRE_YN, REJECT_YN
)
VALUES
(
    @채널ID, @카테고리코드, @결과수신채널, @발신프로필키
    , 'N', 'N'
)
