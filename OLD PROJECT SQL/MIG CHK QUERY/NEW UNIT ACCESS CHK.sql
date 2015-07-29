SELECT*FROM UNIT
SELECT * FROM SOURCE_12052014.UNIT_SCDB_FORMAT
SELECT UNIT_ID,UNIT_ACCESS_CARD FROM SOURCE_12052014.UNIT_SCDB_FORMAT

-- ACCESS STAMP DETAILS AND UNIT SCDB
-- ALL THE VALUES ARE MATCHED

SELECT*FROM UNIT_ACCESS_STAMP_DETAILS

SELECT DISTINCT UNIT_ACCESS_CARD FROM SOURCE_12052014.UNIT_SCDB_FORMAT WHERE UNIT_ACCESS_CARD IS NOT NULL 

SELECT DISTINCT UASD_ACCESS_CARD FROM UNIT_ACCESS_STAMP_DETAILS

SELECT DISTINCT SCU.UNIT_ACCESS_CARD,UAS.UASD_ACCESS_CARD 
FROM UNIT_ACCESS_STAMP_DETAILS UAS ,SOURCE_12052014.UNIT_SCDB_FORMAT SCU 
WHERE UAS.UASD_ACCESS_CARD=SCU.UNIT_ACCESS_CARD

SELECT SCU.UNIT_ACCESS_CARD,UAS.UASD_ACCESS_CARD,UAS.UNIT_ID , U.UNIT_ID,U.UNIT_NO, SCU.UNIT_NO
FROM UNIT_ACCESS_STAMP_DETAILS UAS
INNER JOIN UNIT U ON UAS.UNIT_ID = U.UNIT_ID
INNER JOIN SOURCE_12052014.UNIT_SCDB_FORMAT SCU ON U.UNIT_NO= SCU.UNIT_NO AND UAS.UASD_ACCESS_CARD=SCU.UNIT_ACCESS_CARD
WHERE SCU.UNIT_ACCESS_CARD IS NOT NULL AND UAS.UASD_ACCESS_CARD IS NOT NULL
GROUP BY UAS.UASD_ACCESS_CARD

SELECT UAS.UASD_ACCESS_CARD,U.UNIT_NO
FROM UNIT_ACCESS_STAMP_DETAILS UAS
INNER JOIN UNIT U ON UAS.UNIT_ID = U.UNIT_ID
WHERE UAS.UASD_ACCESS_CARD IS NOT NULL AND UAS.UASD_ACCESS_INVENTORY='X'
GROUP BY UAS.UASD_ACCESS_CARD
