UPDATE 
    M1_TEMPLATE_MST
SET 
    CHANNEL_ID=@발신프로필키
    , APPROVAL_STATUS=@상태구분
    , APPROVAL_CODE=@결과코드
    , APPROVAL_REASON=@승인결과내용
    , USE_YN=@템플릿사용여부
    , REG_DATE=@등록일시
    , REQ_DATE=@승인일시
    , APPROVAL_DATE=@승인일시
    , UPDATE_DATE=@수정일시
    , REG_USER=@등록자
    , UPDATE_USER=@수정자
WHERE 
    TEMPLATE_ID = @템플릿ID

#DELIM

UPDATE 
    M1_TEMPLATE_EXT_KKO
SET 
    MESSAGEBASE_FORM_ID=@템플릿폼ID
    , AGENCY_ID=@그룹ID
WHERE 
    TEMPLATE_ID = @템플릿ID

 