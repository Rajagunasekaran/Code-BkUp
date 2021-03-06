-- VERSION 0.3 STARTDATE:01/09/2014 ENDDATE:01/09/2014 ISSUE NO:78 COMMENT NO :14 DESC:ALTER THE AUTO INCREMENT ID OF THE TABLES. DONE BY :RAJA
-- VERSION 0.2 STARTDATE:18/08/2014 ENDDATE:18/08/2014 ISSUE NO:78 COMMENT NO :6 DESC:ADDED THE INSERT QUERY,DATA FOR PRE_AUDIT_SUB_PROFILE,POST_AUDIT_PROFILE. DONE BY :RAJA
-- VERSION 0.1 STARTDATE:14/08/2014 ENDDATE:14/08/2014 ISSUE NO:78 COMMENT NO :6 DESC:CREATED SP FOR TS AUDIT GET SOURCE TO DESTINATION DYNAMICALLY. DONE BY :RAJA
DROP PROCEDURE IF EXISTS SP_TS_POST_AUDIT_CREATE_INSERT;
CREATE PROCEDURE SP_TS_POST_AUDIT_CREATE_INSERT(IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
	DECLARE MAX_ID INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
	END;
	START TRANSACTION;	
	SET FOREIGN_KEY_CHECKS=0;
	
		-- QUERY FOR CREATE USER_LOGIN_DETAILS TABLE
		-- STATEMENT FOR USER_LOGIN_DETAILS 
		SET @DROP_USER_LOGIN_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS'));
		PREPARE DROP_USERLOGINDETAILS FROM @DROP_USER_LOGIN_DETAILS;
		EXECUTE DROP_USERLOGINDETAILS;
		SET @CREATE_USER_LOGIN_DETAILS=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS(
		ULD_ID INT(2) NOT NULL AUTO_INCREMENT, 
		ULD_LOGINID VARCHAR(40) NOT NULL, 
		ULD_USERSTAMP VARCHAR(50) NOT NULL, 
		ULD_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
		PRIMARY KEY(ULD_ID),
		UNIQUE (ULD_LOGINID))'));
		PREPARE CREATE_USERLOGINDETAILS FROM @CREATE_USER_LOGIN_DETAILS;
		EXECUTE CREATE_USERLOGINDETAILS;

		-- PRE_AUDIT_MAIN_PROFILE
		-- STATEMENT FOR PRE_AUDIT_MAIN_PROFILE 
		DROP TABLE IF EXISTS PRE_AUDIT_MAIN_PROFILE;
		CREATE TABLE PRE_AUDIT_MAIN_PROFILE( 
		PREAMP_ID INTEGER NOT NULL AUTO_INCREMENT, 
		PREAMP_DATA VARCHAR(50) NOT NULL,
		PRIMARY KEY(PREAMP_ID));

		-- PRE_AUDIT_SUB_PROFILE
		-- STATEMENT FOR PRE_AUDIT_SUB_PROFILE 
		DROP TABLE IF EXISTS PRE_AUDIT_SUB_PROFILE;
		CREATE TABLE PRE_AUDIT_SUB_PROFILE(
		PREASP_ID INTEGER NOT NULL AUTO_INCREMENT,
		PREAMP_ID INTEGER NOT NULL, 
		PREASP_DATA VARCHAR(50) NOT NULL,
		PREASP_NO_OF_REC INTEGER NULL,
		PRIMARY KEY(PREASP_ID),
		FOREIGN KEY(PREAMP_ID) REFERENCES PRE_AUDIT_MAIN_PROFILE (PREAMP_ID));

		-- PRE_AUDIT_HISTORY
		-- STATEMENT FOR PRE_AUDIT_HISTORY 
		DROP TABLE IF EXISTS PRE_AUDIT_HISTORY;
		SET @CREATE_PRE_AUDIT_HISTORY=(SELECT CONCAT('CREATE TABLE PRE_AUDIT_HISTORY(
		PREAH_ID INTEGER NOT NULL AUTO_INCREMENT, 
		PREAMP_ID INTEGER NOT NULL, 
		PREAMP_PROJ_KEY VARCHAR(50) NULL,
		PREAMP_STATUS INTEGER NOT NULL,
		PREAMP_SCDB_REC_BDUMP INTEGER NULL ,
		PREAMP_SCDB_AREC INTEGER NULL , 
		PREAMP_SQL_REC INTEGER NOT NULL,
		PREAMP_PSTIME TIME NOT NULL ,
		PREAMP_PETIME TIME NOT NULL, 
		PREAMP_EXE_TIME TIME NOT NULL, 
		ULD_ID INTEGER NOT NULL, 
		PREAMP_TIMESTAMP TIMESTAMP NOT NULL, 
		PRIMARY KEY(PREAH_ID),
		FOREIGN KEY(PREAMP_ID) REFERENCES .PRE_AUDIT_MAIN_PROFILE (PREAMP_ID),
		FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS (ULD_ID))'));
		PREPARE CREATE_PRE_AUDIT_HISTORY_STMT FROM @CREATE_PRE_AUDIT_HISTORY;
		EXECUTE CREATE_PRE_AUDIT_HISTORY_STMT;
    -- QUERY FOR ALTER AUTO_INCREMENT ID 
    SELECT MAX(PREAH_ID) INTO @PREAH_MAX_ID FROM PRE_AUDIT_HISTORY;
		SET MAX_ID=@PREAH_MAX_ID;
		IF (MAX_ID IS NOT NULL) THEN    
			SET @ALTER_PRE_AUDIT_HISTORY =(SELECT CONCAT('ALTER TABLE PRE_AUDIT_HISTORY AUTO_INCREMENT=',MAX_ID));
			PREPARE ALTER_PRE_AUDIT_HISTORY_STMT FROM @ALTER_PRE_AUDIT_HISTORY;
			EXECUTE ALTER_PRE_AUDIT_HISTORY_STMT;
		END IF;
    
		-- POST_AUDIT_PROFILE
		-- STATEMENT FOR DROPPING POST_AUDIT_PROFILE 
		DROP TABLE IF EXISTS POST_AUDIT_PROFILE;
		CREATE TABLE POST_AUDIT_PROFILE (
		POSTAP_ID INTEGER NOT NULL AUTO_INCREMENT,
		POSTAP_DATA VARCHAR(50) NOT NULL,
		PRIMARY KEY(POSTAP_ID));
	  
		-- POST_AUDIT_HISTORY
		-- STATEMENT FOR POST_AUDIT_HISTORY 
		DROP TABLE IF EXISTS POST_AUDIT_HISTORY;
		SET @CREATE_POST_AUDIT_HISTORY=(SELECT CONCAT('CREATE TABLE POST_AUDIT_HISTORY( 
		POSTAH_ID INTEGER NOT NULL AUTO_INCREMENT, 
		POSTAP_ID INTEGER NOT NULL, 
		POSTAH_NO_OF_REC INTEGER NOT NULL,
		PREASP_ID INTEGER NOT NULL, 
		PREAMP_ID INTEGER NOT NULL,
		POSTAH_DURATION TIME NOT NULL, 
		POSTAH_NO_OF_REJ INTEGER NOT NULL, 
		ULD_ID INTEGER NOT NULL,
		POSTAH_TIMESTAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
		PRIMARY KEY(POSTAH_ID), 
		FOREIGN KEY(POSTAP_ID) REFERENCES POST_AUDIT_PROFILE (POSTAP_ID),
		FOREIGN KEY(PREASP_ID) REFERENCES PRE_AUDIT_SUB_PROFILE (PREASP_ID), 
		FOREIGN KEY(PREAMP_ID) REFERENCES PRE_AUDIT_MAIN_PROFILE (PREAMP_ID),
		FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS (ULD_ID))'));
		PREPARE CREATE_POST_AUDIT_HISTORY_STMT FROM @CREATE_POST_AUDIT_HISTORY;
		EXECUTE CREATE_POST_AUDIT_HISTORY_STMT;
    -- QUERY FOR ALTER AUTO_INCREMENT ID 
		SELECT MAX(POSTAH_ID) INTO @POSTAH_MAX_ID FROM POST_AUDIT_HISTORY;
		SET MAX_ID=@POSTAH_MAX_ID;
		IF (MAX_ID IS NOT NULL) THEN    
			SET @ALTER_POST_AUDIT_HISTORY=(SELECT CONCAT('ALTER TABLE POST_AUDIT_HISTORY AUTO_INCREMENT=',MAX_ID));
			PREPARE ALTER_POST_AUDIT_HISTORY_STMT FROM @ALTER_POST_AUDIT_HISTORY;
			EXECUTE ALTER_POST_AUDIT_HISTORY_STMT;
		END IF;
    
		-- QUERY FOR INSERT THE VALUES FOR POST_AUDIT_PROFILE
		INSERT INTO POST_AUDIT_PROFILE(POSTAP_DATA) VALUES ('PROJECT_DETAILS'),('USER_ADMIN_REPORT_DETAILS'),('ADMIN_WEEKLY_REPORT_DETAILS'),('ONDUTY_ENTRY_DETAILS'),
		('EMPLOYEE_DETAILS'),('MENU_PROFILE'),('ROLE_CREATION'),('USER_LOGIN_DETAILS'),('USER_ACCESS'),('USER_MENU_DETAILS'),('PUBLIC_HOLIDAY'),('CONFIGURATION_PROFILE'),
		('CONFIGURATION'),('ERROR_MESSAGE_CONFIGURATION'),('USER_RIGHTS_CONFIGURATION'),('REPORT_CONFIGURATION'),('ATTENDANCE_CONFIGURATION'),('TICKLER_PROFILE'),('TICKLER_TABID_PROFILE');
		-- QUERY FOR ALTER AUTO_INCREMENT ID 
		SELECT MAX(POSTAP_ID) INTO @POSTAP_MAX_ID FROM POST_AUDIT_PROFILE;
		SET MAX_ID=@POSTAP_MAX_ID;
		IF (MAX_ID IS NOT NULL) THEN    
			SET @ALTER_POST_AUDIT_PROFILE =(SELECT CONCAT('ALTER TABLE POST_AUDIT_PROFILE AUTO_INCREMENT=',MAX_ID));
			PREPARE ALTER_POST_AUDIT_PROFILE_STMT FROM @ALTER_POST_AUDIT_PROFILE;
			EXECUTE ALTER_POST_AUDIT_PROFILE_STMT;
		END IF;
    
		-- QUERY FOR INSERT THE VALUES FOR PRE_AUDIT_MAIN_PROFILE
		INSERT INTO PRE_AUDIT_MAIN_PROFILE(PREAMP_DATA) VALUES ('CONFIGURATION'),('USER RIGHTS'),('REPORT');
    -- QUERY FOR ALTER AUTO_INCREMENT ID 
		SELECT MAX(PREAMP_ID) INTO @PREAMP_MAX_ID FROM PRE_AUDIT_MAIN_PROFILE;
		SET MAX_ID=@PREAMP_MAX_ID;
		IF (MAX_ID IS NOT NULL) THEN    
			SET @ALTER_PRE_AUDIT_MAIN_PROFILE =(SELECT CONCAT('ALTER TABLE PRE_AUDIT_MAIN_PROFILE AUTO_INCREMENT=',MAX_ID));
			PREPARE ALTER_PRE_AUDIT_MAIN_PROFILE_STMT FROM @ALTER_PRE_AUDIT_MAIN_PROFILE;
			EXECUTE ALTER_PRE_AUDIT_MAIN_PROFILE_STMT;
		END IF;
    
		-- QUERY FOR INSERT THE VALUES FOR PRE_AUDIT_SUB_PROFILE
		INSERT INTO PRE_AUDIT_SUB_PROFILE(PREAMP_ID,PREASP_DATA) VALUES (1,'CONFIGURATION_PROFILE'),(1,'CONFIGURATION'),(1,'ERROR_MESSAGE_CONFIGURATION'),
		(1,'USER_RIGHTS_CONFIGURATION'),(1,'REPORT_CONFIGURATION'),(1,'ATTENDANCE_CONFIGURATION'),(1,'TICKLER_PROFILE'),(1,'TICKLER_TABID_PROFILE'),
		(2,'MENU_PROFILE'),(2,'ROLE_CREATION'),(2,'USER_LOGIN_DETAILS'),(2,'USER_ACCESS'),(2,'USER_MENU_DETAILS'),(2,'PUBLIC_HOLIDAY'),(3,'USER_ADMIN_REPORT_DETAILS'),
		(3,'ADMIN_WEEKLY_REPORT_DETAILS'),(3,'ONDUTY_ENTRY_DETAILS'),(3,'EMPLOYEE_DETAILS'),(3,'COMPANY_PROPERTIES_DETAILS'),(3,'PROJECT_DETAILS');
    -- QUERY FOR ALTER AUTO_INCREMENT ID 
		SELECT MAX(PREASP_ID) INTO @PREASP_MAX_ID FROM PRE_AUDIT_SUB_PROFILE;
		SET MAX_ID=@PREASP_MAX_ID;
		IF (MAX_ID IS NOT NULL) THEN    
			SET @ALTER_PRE_AUDIT_SUB_PROFILE =(SELECT CONCAT('ALTER TABLE PRE_AUDIT_SUB_PROFILE AUTO_INCREMENT=',MAX_ID));
			PREPARE ALTER_PRE_AUDIT_SUB_PROFILE_STMT FROM @ALTER_PRE_AUDIT_SUB_PROFILE;
			EXECUTE ALTER_PRE_AUDIT_SUB_PROFILE_STMT;
		END IF;
		
		-- QUERY FOR INSERT THE VALUES FOR USER_LOGIN_DETAILS
		SET @INSERT_USER_LOGIN_DETAILS = (SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS (ULD_LOGINID,ULD_USERSTAMP) VALUES ("dhandapani.sattanathan@ssomens.com","dhandapani.sattanathan@ssomens.com")'));
		PREPARE INSERT_USER_LOGIN_DETAILS_STMT FROM @INSERT_USER_LOGIN_DETAILS;
		EXECUTE INSERT_USER_LOGIN_DETAILS_STMT;    
    -- QUERY FOR ALTER AUTO_INCREMENT ID 
		SET @USER_LOGIN_DETAILS_MAX_ID = (SELECT CONCAT('SELECT MAX(ULD_ID) INTO @ULD_MAX_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS'));
		PREPARE USER_LOGIN_DETAILS_MAX_ID_STMT FROM @USER_LOGIN_DETAILS_MAX_ID;
		EXECUTE USER_LOGIN_DETAILS_MAX_ID_STMT;
		SET MAX_ID=@ULD_MAX_ID;
		IF (MAX_ID IS NOT NULL) THEN    
			SET @ALTER_USER_LOGIN_DETAILS =(SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS AUTO_INCREMENT=',MAX_ID));
			PREPARE ALTER_USER_LOGIN_DETAILS_STMT FROM @ALTER_USER_LOGIN_DETAILS;
			EXECUTE ALTER_USER_LOGIN_DETAILS_STMT;
		END IF;
	SET FOREIGN_KEY_CHECKS=1;
	COMMIT;
END;
/*
CALL SP_TS_POST_AUDIT_CREATE_INSERT('DEST_RAJA');
*/