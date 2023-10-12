INSERT INTO M1_TEMPLATE_EXT_KKO_AUTH
(
    CHANNEL_ID, AUTH_ID, AUTH_KEY
    , ETC1, ETC2, ETC3
    , EXPIRE_YN, REJECT_YN, REG_DATE
)
VALUES
(
    @발신프로필키, @계정ID, @계정인증키
    , @추가정보1, @추가정보2, @추가정보3
    , @휴면여부, @차단여부, @등록일시
)

