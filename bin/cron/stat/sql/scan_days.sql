SELECT
	'BR' AS 통계구분,
	'D' AS 주기코드,
	분배일,
	메시지구분,
	nvl(업무식별자, 'XXXXXXXXXX') AS 업무식별자,
	nvl(업무식별자, 'XXXXXXXXXX') AS 그룹값1,
	'' AS 그룹값2,
	'' AS 그룹값3,
	결과구분
FROM TSUMSSU00
WHERE 분배일 BETWEEN TO_CHAR(SYSDATE-5, 'YYYYMMDDHH24MISS')
AND TO_CAHR(SYSDATE, 'YYYYMMDDHH24MISS')
