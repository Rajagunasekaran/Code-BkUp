DROP PROCEDURE IF EXISTS SP_TS_MIG_REPORT_DETAILS_ONDUTY_INSERT;
CREATE PROCEDURE SP_TS_MIG_REPORT_DETAILS_ONDUTY_INSERT(
IN SOURCESCHEMA VARCHAR(40),
IN DESTINATIONSCHEMA VARCHAR(40),
IN MIGUSERSTAMP VARCHAR(50))
BEGIN
	DECLARE OD_TIMESTAMP TIMESTAMP; 
	DECLARE OD_USERSTAMP VARCHAR(50);
	DECLARE UARDMAX_ID INT;
	DECLARE OD_MIN_ID INT;
	DECLARE OD_MAX_ID INT;
	DECLARE START_TIME TIME;
	DECLARE END_TIME TIME;
	DECLARE DURATION TIME;  
	DECLARE PSMAX_ID INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
	END;
	START TRANSACTION;
	SET FOREIGN_KEY_CHECKS=0;
	SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=','"',MIGUSERSTAMP,'"'));
	PREPARE LOGINID_STMT FROM @LOGIN_ID;
	EXECUTE LOGINID_STMT;
	SET START_TIME = (SELECT CURTIME());
	SET @TRUNCATE_PROJECT_STATUS=(SELECT CONCAT('TRUNCATE ',DESTINATIONSCHEMA,'.PROJECT_STATUS'));
	PREPARE TRUNCATE_TIPROJECT_STATUS_STMT FROM @TRUNCATE_PROJECT_STATUS;
	EXECUTE TRUNCATE_TIPROJECT_STATUS_STMT;
	SET @INSERT_PROJECT_STATUS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.PROJECT_STATUS(PD_ID,PC_ID,PS_REC_VER,PS_START_DATE,PS_END_DATE,ULD_ID,PS_TIMESTAMP) 
	(SELECT CSQL.PD_ID,CSQL.PC_ID,CSQL.PS_REC_VER,CSQL.PS_START_DATE,CSQL.PS_END_DATE,ULD.ULD_ID,CSQL.TIMESTAMP FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT CSQL,',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD WHERE CSQL.PD_ID IS NOT NULL AND CSQL.PC_ID IS NOT NULL AND CSQL.PS_REC_VER IS NOT NULL AND ULD.ULD_LOGINID=CSQL.USER_STAMP)'));
	PREPARE INSERT_PROJECT_STATUS_STMT FROM @INSERT_PROJECT_STATUS;
	EXECUTE INSERT_PROJECT_STATUS_STMT;
	SET @PSMAXID = (SELECT CONCAT('SELECT MAX(PS_ID) INTO @PS_MAX_ID FROM ',DESTINATIONSCHEMA,'.PROJECT_STATUS'));
	PREPARE PS_MAX_ID_STMT FROM @PSMAXID;
	EXECUTE PS_MAX_ID_STMT;
	SET PSMAX_ID=@PS_MAX_ID;
	IF (PSMAX_ID IS NOT NULL) THEN    
		SET @ALTER_PROJECT_STATUS =(SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.PROJECT_STATUS AUTO_INCREMENT=',PSMAX_ID));
		PREPARE ALTER_PROJECT_STATUS_STMT FROM @ALTER_PROJECT_STATUS;
		EXECUTE ALTER_PROJECT_STATUS_STMT;
	END IF;
	SET END_TIME = (SELECT CURTIME());
	SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
	SET @COUNTPROJECTCONFIGSQLFOMAT=(SELECT CONCAT('SELECT COUNT(PS_REC_VER) INTO @COUNT_PROJECT_STATUS_SQL_FORMAT FROM ',SOURCESCHEMA,'.CONFIG_SQL_FORMAT WHERE PD_ID IS NOT NULL AND PC_ID IS NOT NULL AND PS_REC_VER IS NOT NULL'));
	PREPARE COUNTPROJECTCONFIGSQLFOMATSTMT FROM @COUNTPROJECTCONFIGSQLFOMAT;
	EXECUTE COUNTPROJECTCONFIGSQLFOMATSTMT;
	SET @COUNTSPLITINGPROJECTDETAILS=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_PROJECT_STATUS FROM ',DESTINATIONSCHEMA,'.PROJECT_STATUS'));
	PREPARE COUNTSPLITINGPROJECTDETAILSSTMT FROM @COUNTSPLITINGPROJECTDETAILS;
	EXECUTE COUNTSPLITINGPROJECTDETAILSSTMT;
	SET @REJECTION_COUNT=(@COUNT_PROJECT_STATUS_SQL_FORMAT-@COUNT_SPLITING_PROJECT_STATUS);
	SET @POSTAPID= (SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='PROJECT_STATUS');
	SET @PREASPID = (SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='PROJECT_STATUS');
	SET @PREAMPID = (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='REPORT');
	SET @DUR=DURATION;
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_PROJECT_STATUS_SQL_FORMAT WHERE PREASP_DATA='PROJECT_STATUS';    
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES
	(@POSTAPID,@COUNT_SPLITING_PROJECT_STATUS,@PREASPID,@PREAMPID,@DUR,@REJECTION_COUNT,@ULDID);
	SET START_TIME = (SELECT CURTIME());
	SET @DROP_TEMP_ONDUTY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_ONDUTY'));
	PREPARE DROP_DROP_TEMP_ONDUTY_STMT FROM @DROP_TEMP_ONDUTY;
	EXECUTE DROP_DROP_TEMP_ONDUTY_STMT;
	SET @CREATE_TEMP_ONDUTY=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_ONDUTY(
	ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
	UID INT(11) NOT NULL ,
	UNAME VARCHAR(255) DEFAULT NULL,
	UDATE VARCHAR(255) DEFAULT NULL,
	UREPORT TEXT,
	USERSTAMP VARCHAR(255) DEFAULT NULL,
	TIMESTAMP VARCHAR(255) DEFAULT NULL)'));
	PREPARE CREATE_TEMP_ONDUTY_STMT FROM @CREATE_TEMP_ONDUTY;
	EXECUTE CREATE_TEMP_ONDUTY_STMT;
	SET @INSERT_TEMPONDUTY=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_ONDUTY(UID,UNAME,UDATE,UREPORT,USERSTAMP,TIMESTAMP) 
	(SELECT UID,UNAME,UDATE,UREPORT,USERSTAMP,TIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_REPORTS_SCDB_FORMAT WHERE (UREPORT LIKE "%on-duty%" OR UREPORT LIKE "%onduty%" OR UREPORT LIKE "%on duty%" OR UREPORT LIKE "%worked in new year%" OR UREPORT LIKE "holiday"
	OR UREPORT LIKE "BAKRID HOLIDAY" OR UREPORT LIKE "%on_duty%" OR  UREPORT LIKE "OD" OR  UREPORT LIKE "%We went%" OR  UREPORT LIKE "Worked in Christmas%" OR UREPORT LIKE "on leave%") AND UREPORT NOT LIKE "%ONDUTY%SEARCH%UPDATE%" AND UREPORT NOT LIKE "%testing onduty%absent%halfday%"
	AND UREPORT NOT LIKE "%ABSENT & ONDUTY%" AND UREPORT NOT LIKE "%absent and onduty%" AND UREPORT NOT LIKE "%calculate%present, onduty%" AND UREPORT NOT LIKE "%onduty entry%" AND UREPORT NOT LIKE "%onduty_levae_dtls%")'));
	PREPARE INSERT_TEMP_ONDUTY_STMT FROM @INSERT_TEMPONDUTY;
	EXECUTE INSERT_TEMP_ONDUTY_STMT; 
	SET @DELETE_TEMPONDUTY=(SELECT CONCAT('DELETE FROM ',DESTINATIONSCHEMA,'.TEMP_REPORTS_SCDB_FORMAT WHERE UID IN (SELECT UID FROM ',DESTINATIONSCHEMA,'.TEMP_ONDUTY)'));
	PREPARE DELETE_TEMPONDUTY_STMT FROM @DELETE_TEMPONDUTY;
	EXECUTE DELETE_TEMPONDUTY_STMT; 
	SET @ONDUTYMINID = (SELECT CONCAT('SELECT MIN(ID) INTO @ODMIN_ID FROM ',DESTINATIONSCHEMA,'.TEMP_ONDUTY'));
	PREPARE ONDUTYMIN_ID_STMT FROM @ONDUTYMINID;
	EXECUTE ONDUTYMIN_ID_STMT;
	SET @ONDUTYMAXID = (SELECT CONCAT('SELECT MAX(ID) INTO @ODMAX_ID FROM ',DESTINATIONSCHEMA,'.TEMP_ONDUTY'));
	PREPARE ONDUTYMAX_ID_STMT FROM @ONDUTYMAXID;
	EXECUTE ONDUTYMAX_ID_STMT;
	SET OD_MIN_ID = @ODMIN_ID;
	SET OD_MAX_ID = @ODMAX_ID;
	WHILE(OD_MIN_ID <= OD_MAX_ID)DO
		SET @SELECT_ONDUTY_USERSTAMP_TIMESTAMP=(SELECT CONCAT('SELECT USERSTAMP, `TIMESTAMP` INTO @ODUSERSTAMP, @ODTIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_ONDUTY WHERE ID=',OD_MIN_ID));
		PREPARE SELECT_ONDUTY_USERSTAMP_TIMESTAMP_STMT FROM @SELECT_ONDUTY_USERSTAMP_TIMESTAMP;
		EXECUTE SELECT_ONDUTY_USERSTAMP_TIMESTAMP_STMT;
		SET OD_USERSTAMP=@ODUSERSTAMP;
		SET OD_TIMESTAMP=@ODTIMESTAMP;
		IF (OD_USERSTAMP IS NOT NULL OR OD_TIMESTAMP IS NOT NULL) THEN
			SET @INSERT_USERADMINREPORTDETAILS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_USER_ADMIN_REPORT_DETAILS(UARD_REASON,UARD_DATE,UARD_ATTENDANCE,UARD_AM_SESSION,UARD_PM_SESSION, URC_ID, ULD_ID, UARD_BANDWIDTH, UARD_USERSTAMP_ID, UARD_TIMESTAMP) VALUES 
			((SELECT DISTINCT UREPORT FROM ',DESTINATIONSCHEMA,'.TEMP_ONDUTY WHERE ID=',OD_MIN_ID,'),    
			(SELECT DISTINCT UDATE FROM ',DESTINATIONSCHEMA,'.TEMP_ONDUTY WHERE ID=',OD_MIN_ID,'),
			(SELECT DISTINCT AC_ID FROM ',DESTINATIONSCHEMA,'.ATTENDANCE_CONFIGURATION WHERE AC_DATA="OD" AND CGN_ID=5),
			(SELECT DISTINCT AC_ID FROM ',DESTINATIONSCHEMA,'.ATTENDANCE_CONFIGURATION WHERE AC_DATA="ONDUTY"),
			(SELECT DISTINCT AC_ID FROM ',DESTINATIONSCHEMA,'.ATTENDANCE_CONFIGURATION WHERE AC_DATA="ONDUTY"),
			(SELECT DISTINCT RC.URC_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD,',DESTINATIONSCHEMA,'.ROLE_CREATION RC,',DESTINATIONSCHEMA,'.USER_ACCESS UA,',DESTINATIONSCHEMA,'.TEMP_ONDUTY RSF WHERE ULD.ULD_LOGINID= RSF.UNAME AND ULD.ULD_ID = UA.ULD_ID AND UA.RC_ID = RC.RC_ID AND RSF.ID=',OD_MIN_ID,'),
			(SELECT DISTINCT ULD_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=(SELECT UNAME FROM ',DESTINATIONSCHEMA,'.TEMP_ONDUTY WHERE ID=',OD_MIN_ID,')),
			(0),(SELECT DISTINCT ULD_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=(SELECT USERSTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_ONDUTY WHERE ID=',OD_MIN_ID,')),
			(SELECT DISTINCT TIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_ONDUTY WHERE ID=',OD_MIN_ID,'))'));      
			PREPARE INSERT_TEMP_USER_ADMIN_REPORT_DETAILS_STMT FROM @INSERT_USERADMINREPORTDETAILS;
			EXECUTE INSERT_TEMP_USER_ADMIN_REPORT_DETAILS_STMT;     
			SET @UARDMAXID = (SELECT CONCAT('SELECT MAX(UARD_ID) INTO @UARD_MAX_ID FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ADMIN_REPORT_DETAILS'));
			PREPARE UARD_MAX_ID_STMT FROM @UARDMAXID;
			EXECUTE UARD_MAX_ID_STMT;
			SET UARDMAX_ID=@UARD_MAX_ID;
			IF (UARDMAX_ID IS NOT NULL) THEN    
				SET @ALTER_USER_ADMIN_REPORT_DETAILS =(SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.TEMP_USER_ADMIN_REPORT_DETAILS AUTO_INCREMENT=',UARDMAX_ID));
				PREPARE ALTER_USER_ADMIN_REPORT_DETAILS_STMT FROM @ALTER_USER_ADMIN_REPORT_DETAILS;
				EXECUTE ALTER_USER_ADMIN_REPORT_DETAILS_STMT;
			END IF;
		END IF;
		IF (OD_USERSTAMP IS NULL OR OD_TIMESTAMP IS NULL) THEN
			SET @INSERT_USERADMINREPORTDETAILS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_USER_ADMIN_REPORT_DETAILS(UARD_REASON,UARD_DATE,UARD_ATTENDANCE,UARD_AM_SESSION,UARD_PM_SESSION, URC_ID, ULD_ID, UARD_BANDWIDTH, UARD_USERSTAMP_ID, UARD_TIMESTAMP) VALUES 
			((SELECT DISTINCT UREPORT FROM ',DESTINATIONSCHEMA,'.TEMP_ONDUTY WHERE ID=',OD_MIN_ID,'),    
			(SELECT DISTINCT UDATE FROM ',DESTINATIONSCHEMA,'.TEMP_ONDUTY WHERE ID=',OD_MIN_ID,'),
			(SELECT DISTINCT AC_ID FROM ',DESTINATIONSCHEMA,'.ATTENDANCE_CONFIGURATION WHERE AC_DATA="OD" AND CGN_ID=5),
			(SELECT DISTINCT AC_ID FROM ',DESTINATIONSCHEMA,'.ATTENDANCE_CONFIGURATION WHERE AC_DATA="ONDUTY"),
			(SELECT DISTINCT AC_ID FROM ',DESTINATIONSCHEMA,'.ATTENDANCE_CONFIGURATION WHERE AC_DATA="ONDUTY"),
			(SELECT DISTINCT RC.URC_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD,',DESTINATIONSCHEMA,'.ROLE_CREATION RC,',DESTINATIONSCHEMA,'.USER_ACCESS UA,',DESTINATIONSCHEMA,'.TEMP_ONDUTY RSF WHERE ULD.ULD_LOGINID= RSF.UNAME AND ULD.ULD_ID = UA.ULD_ID AND UA.RC_ID = RC.RC_ID AND RSF.ID=',OD_MIN_ID,'),
			(SELECT DISTINCT ULD_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=(SELECT UNAME FROM ',DESTINATIONSCHEMA,'.TEMP_ONDUTY WHERE ID=',OD_MIN_ID,')),
			(0),(SELECT DISTINCT ULD_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=(SELECT UNAME FROM ',DESTINATIONSCHEMA,'.TEMP_ONDUTY WHERE ID=',OD_MIN_ID,')),
			(SELECT DISTINCT UDATE FROM ',DESTINATIONSCHEMA,'.TEMP_ONDUTY WHERE ID=',OD_MIN_ID,'))'));      
			PREPARE INSERT_TEMP_USER_ADMIN_REPORT_DETAILS_STMT FROM @INSERT_USERADMINREPORTDETAILS;
			EXECUTE INSERT_TEMP_USER_ADMIN_REPORT_DETAILS_STMT;   
			SET @UARDMAXID = (SELECT CONCAT('SELECT MAX(UARD_ID) INTO @UARD_MAX_ID FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ADMIN_REPORT_DETAILS'));
			PREPARE UARD_MAX_ID_STMT FROM @UARDMAXID;
			EXECUTE UARD_MAX_ID_STMT;
			SET UARDMAX_ID=@UARD_MAX_ID;
			IF (UARDMAX_ID IS NOT NULL) THEN    
				SET @ALTER_USER_ADMIN_REPORT_DETAILS =(SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.TEMP_USER_ADMIN_REPORT_DETAILS AUTO_INCREMENT=',UARDMAX_ID));
				PREPARE ALTER_USER_ADMIN_REPORT_DETAILS_STMT FROM @ALTER_USER_ADMIN_REPORT_DETAILS;
				EXECUTE ALTER_USER_ADMIN_REPORT_DETAILS_STMT;
			END IF;
		END IF; 
	SET OD_MIN_ID=OD_MIN_ID+1;
	END WHILE;
	SET @DROP_TEMPONDUTY=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_ONDUTY'));
	PREPARE DROP_TEMPONDUTY_STMT FROM @DROP_TEMPONDUTY;
	EXECUTE DROP_TEMPONDUTY_STMT;
	SET END_TIME = (SELECT CURTIME());
	SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
	SET @INSERT_TEMP_DURATION=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_DURATION(DURATION)VALUES(','"',DURATION,'"',')'));
	PREPARE INSERT_TEMP_DURATION_STMT FROM @INSERT_TEMP_DURATION;
	EXECUTE INSERT_TEMP_DURATION_STMT;
	SET FOREIGN_KEY_CHECKS=1;
	COMMIT;
END;