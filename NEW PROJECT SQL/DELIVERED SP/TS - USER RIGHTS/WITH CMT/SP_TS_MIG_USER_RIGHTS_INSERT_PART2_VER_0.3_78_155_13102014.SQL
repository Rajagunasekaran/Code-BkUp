-- VERSION 0.3 STARTDATE:13/10/2014 ENDDATE:13/10/2014 ISSUE NO:78 COMMENT NO:155 DESC:REMOVED TABLE CREATION QUERIES. DONE BY :RAJA
-- version:0.2  --sdate:13/10/2014 --edate:13/10/2014 -- issue:78 --COMMENT NO:149 --desc: ADDED TEMP LOGIN DETAILS IN USER LOGIN DETAILS AND USER ACCESS TABLE --doneby:DHIVYA
-- version:0.1  --sdate:09/10/2014 --edate:09/10/2014 -- issue:78 --COMMENT NO:131 --desc: splitted userrights migration sp for  argument too large error --doneby:BHAVANI.R
DROP PROCEDURE IF EXISTS SP_TS_MIG_USER_RIGHTS_INSERT_PART2;
CREATE PROCEDURE SP_TS_MIG_USER_RIGHTS_INSERT_PART2(IN SOURCESCHEMA VARCHAR(50),IN DESTINATIONSCHEMA VARCHAR(50),IN USERSTAMP VARCHAR(50))
BEGIN
	DECLARE START_TIME TIME;
	DECLARE END_TIME TIME;
	DECLARE DURATION TIME;
	DECLARE MIN_RID INTEGER;
	DECLARE MAX_RID INTEGER;
	DECLARE MIN_ULDID INTEGER;
	DECLARE MAX_ULDID INTEGER;
	DECLARE LOGINID INTEGER;
	DECLARE MIN_UMDID INTEGER;
	DECLARE MAX_UMDID INTEGER;
	DECLARE MAX_ID INTEGER;
	DECLARE CHECK_UNAME TEXT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK;
		SET @DROP_TEMP_USER_ACCESS_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS'));
		PREPARE DROP_TEMP_USER_ACCESS_DETAILS_STMT FROM @DROP_TEMP_USER_ACCESS_DETAILS;
		EXECUTE DROP_TEMP_USER_ACCESS_DETAILS_STMT;
		SET @DROP_TEMP_USER_MENU_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_USER_MENU_DETAILS'));
		PREPARE DROP_TEMP_USER_MENU_DETAILS_STMT FROM @DROP_TEMP_USER_MENU_DETAILS;
		EXECUTE DROP_TEMP_USER_MENU_DETAILS_STMT;
		-- STATEMENT FOR DROPPING TEMP_USER_MENU_ULDID 
		SET @DROP_TEMP_USER_MENU_ULDID=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_USER_MENU_ULDID'));
		PREPARE DROP_TEMP_USER_MENU_ULDID_STMT FROM @DROP_TEMP_USER_MENU_ULDID;
		EXECUTE DROP_TEMP_USER_MENU_ULDID_STMT;
		SET @DROP_TEMP_USER_RIGHTS_SCDB_FORMAT=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_USER_RIGHTS_SCDB_FORMAT'));
		PREPARE DROP_TEMP_USER_RIGHTS_SCDB_FORMAT_STMT FROM @DROP_TEMP_USER_RIGHTS_SCDB_FORMAT;
		EXECUTE DROP_TEMP_USER_RIGHTS_SCDB_FORMAT_STMT;
	END;
		SET AUTOCOMMIT = 0;
	START TRANSACTION;
	SET FOREIGN_KEY_CHECKS = 0;
 -- STATEMENT FOR CHANGING MIGUSERSTAMP AS ULD_ID 
	SET @LOGIN_ID=(SELECT CONCAT('SELECT ULD_ID INTO @ULDID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=','"',USERSTAMP,'"'));
	PREPARE LOGINID FROM @LOGIN_ID;
	EXECUTE LOGINID;
	SET START_TIME = (SELECT CURTIME());
  
	SET @SET_TRUNCATE=(SELECT CONCAT('TRUNCATE ',DESTINATIONSCHEMA,'.USER_ACCESS'));
 	PREPARE SET_TRUNCATE_STMT FROM @SET_TRUNCATE;
 	EXECUTE SET_TRUNCATE_STMT;
	SET @DROP_TEMP_USER_ACCESS_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS'));
	PREPARE DROP_TEMP_USER_ACCESS_DETAILS_STMT FROM @DROP_TEMP_USER_ACCESS_DETAILS;
	EXECUTE DROP_TEMP_USER_ACCESS_DETAILS_STMT;
	SET @CREATE_TEMP_USER_ACCESS_DETAILS=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS(
	ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
	UNAME VARCHAR(250),
	URECVER VARCHAR(255) NULL,
	UJOIN VARCHAR(255) NULL,
	UTERMINATE VARCHAR(255) NULL,
	UJDATE DATE NULL,
	UEDATE DATE NULL,
	UREASON VARCHAR(255) NULL,
	USERSTAMP VARCHAR(255) NULL,
	URROLES VARCHAR(255) DEFAULT NULL,
	UTIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP)'));
	PREPARE CREATE_TEMP_USER_ACCESS_DETAILS_STMT FROM @CREATE_TEMP_USER_ACCESS_DETAILS;
	EXECUTE CREATE_TEMP_USER_ACCESS_DETAILS_STMT;		
	SET @INSERT_TEMP_USER_ACCESS_DETAILS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS(UNAME,URECVER,UJOIN,UTERMINATE,UJDATE,UEDATE,UREASON,USERSTAMP,URROLES,UTIMESTAMP) SELECT UNAME,URECVER,UJOIN,UTERMINATE,UJDATE,UEDATE,UREASON,USERSTAMP,ROLES,TIMESTAMP FROM ',SOURCESCHEMA,'.USERRIGHTS_SCDB_FORMAT WHERE UNAME IS NOT NULL'));
	PREPARE INSERT_TEMP_USER_ACCESS_DETAILS_STMT FROM @INSERT_TEMP_USER_ACCESS_DETAILS;
	EXECUTE INSERT_TEMP_USER_ACCESS_DETAILS_STMT;
	 SET @MAXID = (SELECT CONCAT('SELECT MAX(ID) INTO @USER_ACCESS_MAX_ID FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS'));
	PREPARE MAX_ID_STMT FROM @MAXID;
	EXECUTE MAX_ID_STMT;
	SET MAX_ID=@USER_ACCESS_MAX_ID;
	IF (MAX_ID IS NOT NULL) THEN    
		SET @ALTER_USER_ACCESS =(SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS AUTO_INCREMENT=',MAX_ID));
		PREPARE ALTER_USER_ACCESS_STMT FROM @ALTER_USER_ACCESS;
		EXECUTE ALTER_USER_ACCESS_STMT;
	END IF;
	SET @INSERT_TEMP_USER_ACCESS_DETAILS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS(UNAME,URECVER,UJOIN,UTERMINATE,UJDATE,UEDATE,UREASON,USERSTAMP,URROLES,UTIMESTAMP) SELECT UNAME,URECVER,UJOIN,UTERMINATE,UJDATE,UEDATE,UREASON,USERSTAMP,ROLES,TIMESTAMP FROM ',SOURCESCHEMA,'.TEMP_EMP_USER_RIGHTS_SCDB_FORMAT WHERE UNAME IS NOT NULL'));
	PREPARE INSERT_TEMP_USER_ACCESS_DETAILS_STMT FROM @INSERT_TEMP_USER_ACCESS_DETAILS;
	EXECUTE INSERT_TEMP_USER_ACCESS_DETAILS_STMT;
	SET @UPDATE_TEMP_USER_ACCESS_DETAILS=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS SET URROLES=''SUPER ADMIN'' WHERE URROLES="SPCLAdmin"'));
	PREPARE UPDATE_TEMP_USER_ACCESS_DETAILS_STMT FROM @UPDATE_TEMP_USER_ACCESS_DETAILS;
	EXECUTE UPDATE_TEMP_USER_ACCESS_DETAILS_STMT;
	SET @MINID=(SELECT CONCAT('SELECT MIN(ID)  INTO @MIN_ID  FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS'));
	PREPARE MINID_STMT FROM @MINID;
	EXECUTE MINID_STMT;
	SET @MAXID=(SELECT CONCAT('SELECT MAX(ID) INTO @MAX_ID FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS'));
	PREPARE MAXID_STMT FROM @MAXID;
	EXECUTE MAXID_STMT;	
	SET MIN_RID=@MIN_ID;
	SET MAX_RID=@MAX_ID;
 
WHILE (MIN_RID<=MAX_RID) DO
	SET @CHECK_PERMANENT_ID=(SELECT CONCAT('SELECT Uname INTO @CHECKUNAME FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE Uname LIKE "%ssomens.com" AND ID=',MIN_RID));
	PREPARE CHECK_PERMANENT_ID_STMT FROM @CHECK_PERMANENT_ID;
	EXECUTE CHECK_PERMANENT_ID_STMT;
	SET CHECK_UNAME=@CHECKUNAME;
	IF CHECK_UNAME IS NOT NULL THEN
		SET @INSERT_USER_ACCESS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.USER_ACCESS(RC_ID,ULD_ID,UA_REC_VER,UA_JOIN_DATE,UA_JOIN,UA_END_DATE,UA_TERMINATE,UA_REASON,UA_EMP_TYPE,UA_USERSTAMP,UA_TIMESTAMP)VALUES
		((SELECT RC_ID FROM ',DESTINATIONSCHEMA,'.ROLE_CREATION WHERE RC_NAME=(SELECT URROLES FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,')),
		(SELECT ULD_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=(SELECT UNAME FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,')),
		(SELECT URECVER FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
		(SELECT UJDATE FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
		(SELECT UJOIN FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
		(SELECT UEDATE FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
		(SELECT UTERMINATE FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
		(SELECT UREASON FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),6,
		(SELECT USERSTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
		(SELECT UTIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'))'));
		PREPARE INSERT_USER_ACCESS_STMT FROM @INSERT_USER_ACCESS;
		EXECUTE INSERT_USER_ACCESS_STMT;	
	ELSE
		SET @INSERT_USER_ACCESS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.USER_ACCESS(RC_ID,ULD_ID,UA_REC_VER,UA_JOIN_DATE,UA_JOIN,UA_END_DATE,UA_TERMINATE,UA_REASON,UA_EMP_TYPE,UA_USERSTAMP,UA_TIMESTAMP)VALUES
		((SELECT RC_ID FROM ',DESTINATIONSCHEMA,'.ROLE_CREATION WHERE RC_NAME=(SELECT URROLES FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,')),
		(SELECT ULD_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=(SELECT UNAME FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,')),
		(SELECT URECVER FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
		(SELECT UJDATE FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
		(SELECT UJOIN FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
		(SELECT UEDATE FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
		(SELECT UTERMINATE FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
		(SELECT UREASON FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),7,
		(SELECT USERSTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'),
		(SELECT UTIMESTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS WHERE ID=',MIN_RID,'))'));
		PREPARE INSERT_USER_ACCESS_STMT FROM @INSERT_USER_ACCESS;
		EXECUTE INSERT_USER_ACCESS_STMT;
	END IF;	
	SET @CHECKUNAME=NULL;
    SET MIN_RID=MIN_RID+1;
END WHILE;
   SET @MAXID = (SELECT CONCAT('SELECT MAX(UA_ID) INTO @USER_ACCESS_MAX_ID FROM ',DESTINATIONSCHEMA,'.USER_ACCESS'));
   PREPARE MAX_ID_STMT FROM @MAXID;
   EXECUTE MAX_ID_STMT;
   SET MAX_ID=@USER_ACCESS_MAX_ID;
   IF (MAX_ID IS NOT NULL) THEN    
     SET @ALTER_USER_ACCESS =(SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.USER_ACCESS AUTO_INCREMENT=',MAX_ID));
     PREPARE ALTER_USER_ACCESS_STMT FROM @ALTER_USER_ACCESS;
     EXECUTE ALTER_USER_ACCESS_STMT;
   END IF;
	SET END_TIME = (SELECT CURTIME());
	SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
 
	SET @COUNTUSER_ACCESS_SCDB_FORMAT =(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT1 FROM ',SOURCESCHEMA,'.USERRIGHTS_SCDB_FORMAT WHERE UNAME IS NOT NULL'));
	PREPARE COUNTUSER_ACCESS_SCDB_FORMAT_STMT FROM @COUNTUSER_ACCESS_SCDB_FORMAT;
	EXECUTE COUNTUSER_ACCESS_SCDB_FORMAT_STMT;
	SET @COUNTTEMPUSER_ACCESS_SCDB_FORMAT =(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT2 FROM ',SOURCESCHEMA,'.TEMP_EMP_USER_RIGHTS_SCDB_FORMAT WHERE UNAME IS NOT NULL'));
	PREPARE COUNTTEMPUSER_ACCESS_SCDB_FORMAT_STMT FROM @COUNTTEMPUSER_ACCESS_SCDB_FORMAT;
	EXECUTE COUNTTEMPUSER_ACCESS_SCDB_FORMAT_STMT;
	SET @COUNT_USER_ACCESS_SCDB_FORMAT=(@COUNT1+@COUNT2);
	SET @COUNTSPLITING_USER_ACCESS = (SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_USER_ACCESS FROM ',DESTINATIONSCHEMA,'.USER_ACCESS'));
	PREPARE COUNTSPLITING_USER_ACCESS_STMT FROM @COUNTSPLITING_USER_ACCESS;
	EXECUTE COUNTSPLITING_USER_ACCESS_STMT;	
	SET @REJECTION_COUNT=(@COUNT_USER_ACCESS_SCDB_FORMAT-@COUNT_SPLITING_USER_ACCESS);
 
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC = @COUNT_USER_ACCESS_SCDB_FORMAT WHERE PREASP_DATA='USER_ACCESS';

 INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='USER_ACCESS'),@COUNT_SPLITING_USER_ACCESS,(SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='USER_ACCESS'),
	(SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='USER RIGHTS'),DURATION,@REJECTION_COUNT,@ULDID);	

 
	SET @SET_TRUNCATE=(SELECT CONCAT('TRUNCATE ',DESTINATIONSCHEMA,'.USER_MENU_DETAILS'));
 	PREPARE SET_TRUNCATE_STMT FROM @SET_TRUNCATE;
 	EXECUTE SET_TRUNCATE_STMT;
	SET @DROP_TEMP_USER_MENU_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_USER_MENU_DETAILS'));
	PREPARE DROP_TEMP_USER_MENU_DETAILS_STMT FROM @DROP_TEMP_USER_MENU_DETAILS;
	EXECUTE DROP_TEMP_USER_MENU_DETAILS_STMT;

	SET @CREATE_TEMP_USER_MENU_DETAILS=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_USER_MENU_DETAILS( ID INTEGER NOT NULL AUTO_INCREMENT, TUMD_USERSTAMP VARCHAR(50) NOT NULL, PRIMARY KEY(ID))'));
	PREPARE CREATE_TEMP_USER_MENU_DETAILS_STMT FROM @CREATE_TEMP_USER_MENU_DETAILS;
	EXECUTE CREATE_TEMP_USER_MENU_DETAILS_STMT;
  	SET @INSERT_TEMP_USER_MENU_DETAILS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_USER_MENU_DETAILS(TUMD_USERSTAMP) SELECT USERSTAMP FROM ',SOURCESCHEMA,'.USER_RIGHTS_SQL_FORMAT WHERE USERSTAMP IS NOT NULL AND RC_ID IS NOT NULL'));
	PREPARE INSERT_TEMP_USER_MENU_DETAILS_STMT FROM @INSERT_TEMP_USER_MENU_DETAILS;
	EXECUTE INSERT_TEMP_USER_MENU_DETAILS_STMT;
	SET @DROP_TEMP_USER_MENU_ULDID=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_USER_MENU_ULDID'));
	PREPARE DROP_TEMP_USER_MENU_ULDID_STMT FROM @DROP_TEMP_USER_MENU_ULDID;
	EXECUTE DROP_TEMP_USER_MENU_ULDID_STMT;
	SET @CREATE_TEMP_USER_MENU_ULDID=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_USER_MENU_ULDID( ID INTEGER NOT NULL AUTO_INCREMENT,ULD_ID INTEGER(2) NOT NULL, PRIMARY KEY(ID))'));
	PREPARE CREATE_TEMP_USER_MENU_ULDID_STMT FROM @CREATE_TEMP_USER_MENU_ULDID;
	EXECUTE CREATE_TEMP_USER_MENU_ULDID_STMT;
	SET @INSERT_TEMP_USER_MENU_ULDID=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_USER_MENU_ULDID(ULD_ID) SELECT ULD_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=(SELECT TUMD_USERSTAMP FROM ',DESTINATIONSCHEMA,'.TEMP_USER_MENU_DETAILS WHERE ID=1)'));
	PREPARE INSERT_TEMP_USER_MENU_ULDID_STMT FROM @INSERT_TEMP_USER_MENU_ULDID;
	EXECUTE INSERT_TEMP_USER_MENU_ULDID_STMT;		
	SET @INSERTUSER_MENU_DETAILS=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.USER_MENU_DETAILS(MP_ID,RC_ID,ULD_ID,UMD_TIMESTAMP) SELECT A.MP_ID,A.RC_ID,B.ULD_ID,A.TIMESTAMP FROM USER_RIGHTS_SQL_FORMAT A,',DESTINATIONSCHEMA,'.TEMP_USER_MENU_ULDID B where MP_ID IS NOT NULL AND RC_ID IS NOT NULL'));
	PREPARE INSERTUSER_STMT FROM @INSERTUSER_MENU_DETAILS;
	EXECUTE INSERTUSER_STMT;
 
   SET @MAXID = (SELECT CONCAT('SELECT MAX(UMD_ID) INTO @USER_MENU_DETAILS_MAX_ID FROM ',DESTINATIONSCHEMA,'.USER_MENU_DETAILS'));
   PREPARE MAX_ID_STMT FROM @MAXID;
   EXECUTE MAX_ID_STMT;
   SET MAX_ID=@USER_MENU_DETAILS_MAX_ID;
   IF (MAX_ID IS NOT NULL) THEN    
     SET @ALTER_USER_MENU_DETAILS =(SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.USER_MENU_DETAILS AUTO_INCREMENT=',MAX_ID));
     PREPARE ALTER_USER_MENU_DETAILS_STMT FROM @ALTER_USER_MENU_DETAILS;
     EXECUTE ALTER_USER_MENU_DETAILS_STMT;
   END IF;
  	SET END_TIME = (SELECT CURTIME());
	SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
	SET @COUNT_USER_MENU_DETAILS_SCDB_FORMAT=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_USER_MENU_DETAILS_SCDB_FORMAT FROM ',SOURCESCHEMA,'.USER_RIGHTS_SQL_FORMAT WHERE RC_ID IS NOT NULL'));
	PREPARE COUNTUSERMENUDETAILSSCDBFORMAT FROM @COUNT_USER_MENU_DETAILS_SCDB_FORMAT;
	EXECUTE COUNTUSERMENUDETAILSSCDBFORMAT;
	SET @COUNT_SPLITING_USER_MENU_DETAILS=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_USER_MENU_DETAILS FROM ',DESTINATIONSCHEMA,'.USER_MENU_DETAILS'));
	PREPARE COUNTSPLITINGUSERMENUDETAILS FROM @COUNT_SPLITING_USER_MENU_DETAILS;
	EXECUTE COUNTSPLITINGUSERMENUDETAILS;	
	SET @REJECTION_COUNT=(@COUNT_USER_MENU_DETAILS_SCDB_FORMAT-@COUNT_SPLITING_USER_MENU_DETAILS);
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_USER_MENU_DETAILS_SCDB_FORMAT WHERE PREASP_DATA='USER_MENU_DETAILS';
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='USER_MENU_DETAILS'),@COUNT_SPLITING_USER_MENU_DETAILS,(SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='USER_MENU_DETAILS'),
	(SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='USER RIGHTS'),DURATION,@REJECTION_COUNT,@ULDID);
	-- PUBLIC HOLIDAY	
	SET @SET_TRUNCATE=(SELECT CONCAT('TRUNCATE ',DESTINATIONSCHEMA,'.PUBLIC_HOLIDAY'));
 	PREPARE SET_TRUNCATE_STMT FROM @SET_TRUNCATE;
 	EXECUTE SET_TRUNCATE_STMT;
    SET @INSERT_PUBLIC_HOLIDAY=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.PUBLIC_HOLIDAY(PH_DESCRIPTION,PH_DATE)SELECT PH_DESCRIPTION,PH_DATE FROM ',SOURCESCHEMA,'.USER_RIGHTS_SQL_FORMAT WHERE PH_DESCRIPTION IS NOT NULL AND PH_DATE IS NOT NULL'));
    PREPARE INSERTBASICMENUPROFILE FROM @INSERT_PUBLIC_HOLIDAY;
    EXECUTE INSERTBASICMENUPROFILE;
   SET @MAXID = (SELECT CONCAT('SELECT MAX(PH_ID) INTO @PUBLIC_HOLIDAY_MAX_ID FROM ',DESTINATIONSCHEMA,'.PUBLIC_HOLIDAY'));
   PREPARE MAX_ID_STMT FROM @MAXID;
   EXECUTE MAX_ID_STMT;
   SET MAX_ID=@PUBLIC_HOLIDAY_MAX_ID;
   IF (MAX_ID IS NOT NULL) THEN    
     SET @PUBLIC_HOLIDAY =(SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.PUBLIC_HOLIDAY AUTO_INCREMENT=',MAX_ID));
     PREPARE PUBLIC_HOLIDAY_STMT FROM @PUBLIC_HOLIDAY;
     EXECUTE PUBLIC_HOLIDAY_STMT;
   END IF;
    SET END_TIME = (SELECT CURTIME());
    SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
--  COUNT CHECKING FOR PUBLIC_HOLIDAY DETAILS
    SET @COUNT_PUBLIC_HOLIDAY_SQL_FORMAT=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_PUBLIC_HOLIDAY_SQL_FORMAT FROM ',SOURCESCHEMA,'.USER_RIGHTS_SQL_FORMAT WHERE PH_DESCRIPTION IS NOT NULL AND PH_DATE IS NOT NULL'));
	PREPARE COUNTPUBLICHOLIDAYSQLFORMAT FROM @COUNT_PUBLIC_HOLIDAY_SQL_FORMAT;
	EXECUTE COUNTPUBLICHOLIDAYSQLFORMAT;
    SET @COUNT_SPLITING_PUBLIC_HOLIDAY=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_PUBLIC_HOLIDAY FROM ',DESTINATIONSCHEMA,'.PUBLIC_HOLIDAY'));
	PREPARE COUNTPUBLICHOLIDAYSQLFORMAT FROM @COUNT_SPLITING_PUBLIC_HOLIDAY;
	EXECUTE COUNTPUBLICHOLIDAYSQLFORMAT;
    SET @REJECTION_COUNT=(@COUNT_PUBLIC_HOLIDAY_SQL_FORMAT-@COUNT_SPLITING_PUBLIC_HOLIDAY);
    UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_PUBLIC_HOLIDAY_SQL_FORMAT WHERE PREASP_DATA='PUBLIC_HOLIDAY';
    INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='PUBLIC_HOLIDAY'),@COUNT_SPLITING_PUBLIC_HOLIDAY,(SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='PUBLIC_HOLIDAY'),
    (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='USER RIGHTS'),DURATION,@REJECTION_COUNT,@ULDID);	
	SET @DROP_BASIC_ROLE_PROFILE=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.BASIC_ROLE_PROFILE'));
	PREPARE DROP_BASIC_ROLE_PROFILE_STMT FROM @DROP_BASIC_ROLE_PROFILE;
	EXECUTE DROP_BASIC_ROLE_PROFILE_STMT;
	SET @CREATE_BASIC_ROLE_PROFILE=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.BASIC_ROLE_PROFILE( BRP_ID INTEGER NOT NULL AUTO_INCREMENT, URC_ID INTEGER(2) NOT NULL, BRP_BR_ID INTEGER NOT NULL, ULD_ID INTEGER(2) NOT NULL, BRP_TIMESTAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY(BRP_ID), FOREIGN KEY(URC_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_RIGHTS_CONFIGURATION (URC_ID), FOREIGN KEY(BRP_BR_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_RIGHTS_CONFIGURATION (URC_ID), FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS (ULD_ID))'));
	PREPARE CREATE_BASIC_ROLE_PROFILE_STMT FROM @CREATE_BASIC_ROLE_PROFILE;
	EXECUTE CREATE_BASIC_ROLE_PROFILE_STMT;
    SET @INSERT_BASIC_ROLE_PROFILE=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.BASIC_ROLE_PROFILE(URC_ID, BRP_BR_ID, ULD_ID, BRP_TIMESTAMP)SELECT URSF.URC_ID, URSF.BRP_BR_ID, ULD.ULD_ID ,URSF.TIMESTAMP FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD , ',SOURCESCHEMA,'.USER_RIGHTS_SQL_FORMAT URSF WHERE ULD.ULD_LOGINID=URSF.USERSTAMP AND URSF.URC_ID IS NOT NULL AND URSF.BRP_BR_ID IS NOT NULL AND URSF.USERSTAMP IS NOT NULL'));
    PREPARE INSERTBASICROLEPROFILE FROM @INSERT_BASIC_ROLE_PROFILE;
    EXECUTE INSERTBASICROLEPROFILE;
   SET @MAXID = (SELECT CONCAT('SELECT MAX(BRP_ID) INTO @BASIC_ROLE_PROFILE_MAX_ID FROM ',DESTINATIONSCHEMA,'.BASIC_ROLE_PROFILE'));
   PREPARE MAX_ID_STMT FROM @MAXID;
   EXECUTE MAX_ID_STMT;
   SET MAX_ID=@BASIC_ROLE_PROFILE_MAX_ID;
   IF (MAX_ID IS NOT NULL) THEN    
     SET @ALTER_BASIC_ROLE_PROFILE =(SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.BASIC_ROLE_PROFILE AUTO_INCREMENT=',MAX_ID));
     PREPARE ALTER_BASIC_ROLE_PROFILE_STMT FROM @ALTER_BASIC_ROLE_PROFILE;
     EXECUTE ALTER_BASIC_ROLE_PROFILE_STMT;
   END IF;
	SET END_TIME = (SELECT CURTIME());
    SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
    SET @COUNT_BASIC_ROLE_PROFILE_SQL_FORMAT=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_BASIC_ROLE_PROFILE_SQL_FORMAT FROM ',SOURCESCHEMA,'.USER_RIGHTS_SQL_FORMAT WHERE URC_ID IS NOT NULL AND BRP_BR_ID IS NOT NULL AND USERSTAMP IS NOT NULL'));
	PREPARE COUNTBASICROLEPROFILESQLFORMAT FROM @COUNT_BASIC_ROLE_PROFILE_SQL_FORMAT;
	EXECUTE COUNTBASICROLEPROFILESQLFORMAT;
    SET @COUNT_SPLITING_BASIC_ROLE_PROFILE=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_BASIC_ROLE_PROFILE FROM ',DESTINATIONSCHEMA,'.BASIC_ROLE_PROFILE'));
	PREPARE COUNTSPLITINGBASICROLEPROFILE FROM @COUNT_SPLITING_BASIC_ROLE_PROFILE;
	EXECUTE COUNTSPLITINGBASICROLEPROFILE;
    SET @REJECTION_COUNT=(@COUNT_BASIC_ROLE_PROFILE_SQL_FORMAT-@COUNT_SPLITING_BASIC_ROLE_PROFILE);
    UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_BASIC_ROLE_PROFILE_SQL_FORMAT WHERE PREASP_DATA='BASIC_ROLE_PROFILE';
    INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='BASIC_ROLE_PROFILE'),@COUNT_SPLITING_BASIC_ROLE_PROFILE,(SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='BASIC_ROLE_PROFILE'),
    (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='USER RIGHTS'),DURATION,@REJECTION_COUNT,@ULDID);	
	SET @DROP_BASIC_MENU_PROFILE=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.BASIC_MENU_PROFILE'));
	PREPARE DROP_BASIC_MENU_PROFILE_STMT FROM @DROP_BASIC_MENU_PROFILE;
	EXECUTE DROP_BASIC_MENU_PROFILE_STMT;
	SET @CREATE_BASIC_MENU_PROFILE=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.BASIC_MENU_PROFILE( BMP_ID INTEGER NOT NULL AUTO_INCREMENT, URC_ID INTEGER(2) NOT NULL, MP_ID INTEGER(2) NOT NULL, ULD_ID INTEGER(2) NOT NULL, BMP_TIMESTAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY(BMP_ID), FOREIGN KEY(URC_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_RIGHTS_CONFIGURATION (URC_ID), FOREIGN KEY(MP_ID) REFERENCES ',DESTINATIONSCHEMA,'.MENU_PROFILE (MP_ID), FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS (ULD_ID))'));
	PREPARE CREATE_BASIC_MENU_PROFILE_STMT FROM @CREATE_BASIC_MENU_PROFILE;
	EXECUTE CREATE_BASIC_MENU_PROFILE_STMT;
	SET @INSERT_BASIC_MENU_PROFILE=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.BASIC_MENU_PROFILE(URC_ID,MP_ID,ULD_ID,BMP_TIMESTAMP)SELECT URSF.URC_ID,URSF.MP_ID,ULD.ULD_ID,URSF.TIMESTAMP FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD,',SOURCESCHEMA,'.USER_RIGHTS_SQL_FORMAT URSF WHERE ULD.ULD_LOGINID=URSF.USERSTAMP AND URC_ID IS NOT NULL AND MP_ID IS NOT NULL AND USERSTAMP IS NOT NULL'));
    PREPARE INSERTBASICMENUPROFILE FROM @INSERT_BASIC_MENU_PROFILE;
    EXECUTE INSERTBASICMENUPROFILE;    
   SET @MAXID = (SELECT CONCAT('SELECT MAX(BMP_ID) INTO @BASIC_MENU_PROFILE_MAX_ID FROM ',DESTINATIONSCHEMA,'.BASIC_MENU_PROFILE'));
   PREPARE MAX_ID_STMT FROM @MAXID;
   EXECUTE MAX_ID_STMT;
   SET MAX_ID=@BASIC_MENU_PROFILE_MAX_ID;
   IF (MAX_ID IS NOT NULL) THEN    
     SET @ALTER_BASIC_MENU_PROFILE =(SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.BASIC_MENU_PROFILE AUTO_INCREMENT=',MAX_ID));
     PREPARE ALTER_BASIC_MENU_PROFILE_STMT FROM @ALTER_BASIC_MENU_PROFILE;
     EXECUTE ALTER_BASIC_MENU_PROFILE_STMT;
   END IF;
	SET END_TIME = (SELECT CURTIME());
    SET DURATION=(SELECT TIMEDIFF(END_TIME,START_TIME));
    SET @COUNT_BASIC_MENU_PROFILE_SQL_FORMAT=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_BASIC_MENU_PROFILE_SQL_FORMAT FROM ',SOURCESCHEMA,'.USER_RIGHTS_SQL_FORMAT WHERE URC_ID IS NOT NULL AND MP_ID IS NOT NULL AND USERSTAMP IS NOT NULL'));
	PREPARE COUNTBASICMENUPROFILESQLFORMAT FROM @COUNT_BASIC_MENU_PROFILE_SQL_FORMAT;
	EXECUTE COUNTBASICMENUPROFILESQLFORMAT;
    SET @COUNT_SPLITING_BASIC_MENU_PROFILE=(SELECT CONCAT('SELECT COUNT(*) INTO @COUNT_SPLITING_BASIC_MENU_PROFILE FROM ',DESTINATIONSCHEMA,'.BASIC_MENU_PROFILE'));
	PREPARE COUNTSPLITINGBASICMENUPROFILE FROM @COUNT_SPLITING_BASIC_MENU_PROFILE;
	EXECUTE COUNTSPLITINGBASICMENUPROFILE;
    SET @REJECTION_COUNT=(@COUNT_BASIC_MENU_PROFILE_SQL_FORMAT-@COUNT_SPLITING_BASIC_MENU_PROFILE);
	UPDATE PRE_AUDIT_SUB_PROFILE SET PREASP_NO_OF_REC=@COUNT_BASIC_MENU_PROFILE_SQL_FORMAT WHERE PREASP_DATA='BASIC_MENU_PROFILE';
	INSERT INTO POST_AUDIT_HISTORY(POSTAP_ID,POSTAH_NO_OF_REC,PREASP_ID,PREAMP_ID,POSTAH_DURATION,POSTAH_NO_OF_REJ,ULD_ID)VALUES((SELECT POSTAP_ID FROM POST_AUDIT_PROFILE WHERE POSTAP_DATA='BASIC_MENU_PROFILE'),@COUNT_SPLITING_BASIC_MENU_PROFILE,(SELECT PREASP_ID FROM PRE_AUDIT_SUB_PROFILE WHERE PREASP_DATA='BASIC_MENU_PROFILE'),
    (SELECT PREAMP_ID FROM PRE_AUDIT_MAIN_PROFILE WHERE PREAMP_DATA='USER RIGHTS'),DURATION,@REJECTION_COUNT,@ULDID); 
        SET @DROP_TEMP_USER_ACCESS_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_USER_ACCESS_DETAILS'));
	PREPARE DROP_TEMP_USER_ACCESS_DETAILS_STMT FROM @DROP_TEMP_USER_ACCESS_DETAILS;
	EXECUTE DROP_TEMP_USER_ACCESS_DETAILS_STMT;
     SET @DROP_TEMP_USER_MENU_DETAILS=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_USER_MENU_DETAILS'));
	PREPARE DROP_TEMP_USER_MENU_DETAILS_STMT FROM @DROP_TEMP_USER_MENU_DETAILS;
	EXECUTE DROP_TEMP_USER_MENU_DETAILS_STMT;
     -- STATEMENT FOR DROPPING TEMP_USER_MENU_ULDID 
	SET @DROP_TEMP_USER_MENU_ULDID=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_USER_MENU_ULDID'));
	PREPARE DROP_TEMP_USER_MENU_ULDID_STMT FROM @DROP_TEMP_USER_MENU_ULDID;
	EXECUTE DROP_TEMP_USER_MENU_ULDID_STMT;
   	SET @DROP_TEMP_USER_RIGHTS_SCDB_FORMAT=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_USER_RIGHTS_SCDB_FORMAT'));
	PREPARE DROP_TEMP_USER_RIGHTS_SCDB_FORMAT_STMT FROM @DROP_TEMP_USER_RIGHTS_SCDB_FORMAT;
	EXECUTE DROP_TEMP_USER_RIGHTS_SCDB_FORMAT_STMT;
  SET FOREIGN_KEY_CHECKS = 1;
	  COMMIT;
END;
/*
SP_TS_MIG_USER_RIGHTS_INSERT_PART2('RAJA_SOURCE','RAJA_DEST','dhandapani.sattanathan@ssomens.com');
*/