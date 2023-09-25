UPDATE 
    M1_TEMPLATE_EXT_RCS_BRAND
SET 
    BR_NM = @브랜드명
    , BR_KEY = @브랜드키
    , USE_YN = @사용여부
    , STATUS = @브랜드상태
    , REG_DT = @등록일시
    , UPDATE_DT = @수정일시
    , APPR_REQ_YMD = @승인날짜
    , APPR_YMD = @승인날짜
WHERE 
    BR_ID = @브랜드ID
