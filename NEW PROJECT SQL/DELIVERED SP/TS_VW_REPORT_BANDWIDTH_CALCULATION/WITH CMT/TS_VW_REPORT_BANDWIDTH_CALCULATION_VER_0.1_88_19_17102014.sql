-- VERSION 0.1 STARTDATE:17/10/2014 ENDDATE:17/10/2014 ISSUE NO:88 COMMENT NO:19 DESC:VIEW FOR CALCULATE BANDWITH USAGE. DONE BY :RAJA
DROP PROCEDURE IF EXISTS TS_VW_REPORT_BANDWIDTH_CALCULATION;
CREATE PROCEDURE TS_VW_REPORT_BANDWIDTH_CALCULATION()
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
	END;
	START TRANSACTION;
	-- MULTIPLE USER
	CREATE OR REPLACE VIEW VW_ULDID_MONTH AS SELECT DISTINCT ULD_ID,DATE_FORMAT(UARD_DATE,'%Y-%m-01')`MONTH` FROM USER_ADMIN_REPORT_DETAILS ORDER BY ULD_ID;

	CREATE OR REPLACE VIEW VW_ALL_BANDWIDTH_USAGE AS SELECT VUM.ULD_ID AS ULD_ID,ULD.ULD_LOGINID AS LOGINID,VUM.`MONTH` AS REPORT_DATE,SUM(UARD_BANDWIDTH)AS BANDWIDTH_MB
	FROM USER_ADMIN_REPORT_DETAILS UARD JOIN USER_LOGIN_DETAILS ULD ON ULD.ULD_ID = UARD.ULD_ID JOIN VW_ULDID_MONTH VUM ON UARD.ULD_ID=VUM.ULD_ID AND ULD.ULD_ID = VUM.ULD_ID
	WHERE UARD.UARD_DATE BETWEEN VUM.`MONTH` AND LAST_DAY(VUM.`MONTH`)GROUP BY VUM.`MONTH`,VUM.ULD_ID ORDER BY ULD.ULD_ID;

	-- SINGLE USER
	CREATE OR REPLACE VIEW VW_SINGLE_BANDWIDTH_USAGE AS SELECT VUM.ULD_ID AS ULD_ID,UARD.UARD_DATE AS REPORT_DATE,UARD_BANDWIDTH AS BANDWIDTH_MB
	FROM USER_ADMIN_REPORT_DETAILS UARD JOIN USER_LOGIN_DETAILS ULD ON UARD.ULD_ID=ULD.ULD_ID JOIN VW_ULDID_MONTH VUM ON UARD.ULD_ID=VUM.ULD_ID AND ULD.ULD_ID = VUM.ULD_ID 
	WHERE UARD.UARD_DATE BETWEEN VUM.`MONTH` AND LAST_DAY(VUM.`MONTH`)GROUP BY UARD.UARD_ID ORDER BY ULD.ULD_ID;
	COMMIT;
END;
/*
CALL TS_VW_REPORT_BANDWIDTH_CALCULATION();

SELECT COALESCE(LOGINID,'TOTAL')LOGINID,SUM(BANDWIDTH_MB)BANDWIDTH_MB FROM VW_ALL_BANDWIDTH_USAGE WHERE REPORT_DATE ='2014-10-01' GROUP BY LOGINID WITH ROLLUP;
SELECT COALESCE(DATE_FORMAT(REPORT_DATE,"%d-%m-%Y,%a"),'TOTAL')REPORT_DATE,SUM(BANDWIDTH_MB)BANDWIDTH_MB FROM VW_SINGLE_BANDWIDTH_USAGE 
WHERE ULD_ID=1 AND REPORT_DATE BETWEEN "2014-09-01" AND "2014-09-31" GROUP BY REPORT_DATE WITH ROLLUP;
*/