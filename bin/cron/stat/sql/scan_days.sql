SELECT
	'BR' AS ��豸��,
	'D' AS �ֱ��ڵ�,
	�й���,
	�޽�������,
	nvl(�����ĺ���, 'XXXXXXXXXX') AS �����ĺ���,
	nvl(�����ĺ���, 'XXXXXXXXXX') AS �׷찪1,
	'' AS �׷찪2,
	'' AS �׷찪3,
	�������
FROM TSUMSSU00
WHERE �й��� BETWEEN TO_CHAR(SYSDATE-5, 'YYYYMMDDHH24MISS')
AND TO_CAHR(SYSDATE, 'YYYYMMDDHH24MISS')
