-- VERSION 0.1 STARTDATE:17/09/2014 ENDDATE:17/09/2014 ISSUE NO:84 COMMENT NO:10 DESC:CHECK CONSTRAINTS FOR THE PROJECT_DETAILS. DONE BY :RAJA
DROP PROCEDURE IF EXISTS SP_TS_TRG_PROJECT_DETAILS_VALIDATION;
CREATE PROCEDURE SP_TS_TRG_PROJECT_DETAILS_VALIDATION(
IN PROJECT_NAME VARCHAR(50),
IN PROJECT_DESCRIPTION VARCHAR(100),
IN PROCESS VARCHAR(10))
BEGIN
	DECLARE ERROR_MSG TEXT;
	DECLARE MESSAGE_TEXT TEXT;
	IF(PROCESS='INSERT') OR (PROCESS='UPDATE')THEN

		IF (PROJECT_NAME IS NOT NULL) THEN
			IF (PROJECT_NAME REGEXP BINARY '[a-z]') THEN
				SET ERROR_MSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=38);
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT=ERROR_MSG;
			END IF;
		END IF;
		IF (PROJECT_DESCRIPTION IS NOT NULL) THEN
			IF (PROJECT_DESCRIPTION REGEXP BINARY '[a-z]') THEN
				SET ERROR_MSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=39);
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT=ERROR_MSG;
			END IF;
		END IF;

	END IF;
END;
/*
call sp_ts_trg_project_details_validation ('ei','expatsintegrated','update');
*/