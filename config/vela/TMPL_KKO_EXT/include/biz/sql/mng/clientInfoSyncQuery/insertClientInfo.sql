INSERT INTO M1_TEMPLATE_EXT_KKO_AUTH
(
    CHANNEL_ID, CLIENT_ID, CLIENT_SECRET
    , ETC1, ETC2, ETC3
    , EXPIRE_YN, REJECT_YN
)
VALUES
(
    @발신프로필키, @계정정보, @계정인증키
    , @추가정보1, @추가정보2, @추가정보3
    , @휴면여부, @차단여부
)

