/* dotask.TMPL_DBX.ftl updateTemplateStatus */
UPDATE
    M1_TEMPLATE_MST
SET
    TEMPLATE_ID = DECODE(@베이스ID, '', TEMPLATE_ID, @베이스ID)
    , APPROVAL_DATE = DECODE(NVL(@처리일시, ''), '', APPROVAL_DATE, @처리일시)
    , REQ_DATE = DECODE(NVL(@승인요청일시, ''), '', REQ_DATE, @승인요청일시)
    , UPDATE_DATE = DECODE(NVL(@수정일시,''), '', UPDATE_DATE, @수정일시)
    , APPROVAL_REASON = @처리결과내용
    , APPROVAL_CODE = @검수결과코드
    , APPROVAL_STATUS = @검수처리단계
    , USE_YN = @템플릿사용여부
WHERE
    TM_SEQ = @SEQ

#DELIM

UPDATE
    M1_TEMPLATE_EXT_RCS
SET
    TEMPLATE_ID = DECODE(@베이스ID, '', TEMPLATE_ID, @베이스ID)
WHERE
    TM_SEQ = @SEQ