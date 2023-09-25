UPDATE 
    M1_TEMPLATE_EXT_RCS_MSGBASE_FORM
SET 
    FORM_NAME = @베이스명
    , PRODUCTCODE = @템플릿타입
    , SPEC = @스펙
    , CARD_TYPE = @카드타입
    , BIZ_CONDITION = @업태
    , BIZ_CATEGORY = @유형그룹
    , BIZ_SERVICE = @유형서비스
    , POLICY_INFO = @검증정보
    , GUIDE_INFO = @가이드정보
    , FORM_PARAMS = @검수파라미터
    , FORMATTED_STRING = @RCS규격
    , MEDIA_FILEID = @미디어파일ID
    , MEDIA_URL = @미디어URL
    , UPDATE_DT = @수정일시
WHERE 
    MSGBASE_FORM_ID = @베이스폼ID
