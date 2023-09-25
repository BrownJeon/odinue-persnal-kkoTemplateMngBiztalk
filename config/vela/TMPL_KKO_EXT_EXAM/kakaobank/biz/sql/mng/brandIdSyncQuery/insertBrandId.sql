INSERT INTO M1_TEMPLATE_EXT_RCS_BRAND
(
    BR_ID, BR_NM, BR_KEY, USE_YN, STATUS
    , REG_DT, UPDATE_DT, APPR_REQ_YMD, APPR_YMD
)
VALUES
(
    @브랜드ID, @브랜드명, @브랜드키, @사용여부, @브랜드상태
    , @등록일시, @수정일시, @승인날짜, @승인날짜
)
