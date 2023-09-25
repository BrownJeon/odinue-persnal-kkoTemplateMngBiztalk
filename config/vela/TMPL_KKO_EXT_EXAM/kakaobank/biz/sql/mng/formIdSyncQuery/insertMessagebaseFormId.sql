INSERT INTO M1_TEMPLATE_EXT_RCS_MSGBASE_FORM
(
    MSGBASE_FORM_ID, FORM_NAME, PRODUCTCODE, SPEC, CARD_TYPE
    , BIZ_CONDITION, BIZ_CATEGORY, BIZ_SERVICE, POLICY_INFO, GUIDE_INFO
    , FORM_PARAMS, FORMATTED_STRING, MEDIA_FILEID, MEDIA_URL, REG_DT
    , UPDATE_DT
)
VALUES
(
    @베이스폼ID, @베이스명, @템플릿타입, @스펙, @카드타입
    , @업태, @유형그룹, @유형서비스, @검증정보, @가이드정보
    , @검수파라미터, @RCS규격, @미디어파일ID, @미디어URL, @등록일시
    , @수정일시
)
