-- version 0.5 -- sdate:23/06/2014 -- edate:23/06/2014 -- issue:817 -- comment:139 -- DROP THE TEMP TABLE IF ROLLBACK OCCURS -- doneby: RAJA
-- version 0.4 -- sdate:26/05/2014 -- edate:26/05/2014 -- issue:817 -- comment:117 -- DROP TEMP TABLE TEMPTBL_LOGINID -- doneby:RL
-- version 0.3 startdate:14/05/2014 -- enddate:14/05/2014-- - issueno 817 commentno:65-- >desc: CHANGED THE SP FOR DYNAMIC PURPOSE BY RAJA
-- version 0.2 -- sdate:07/04/2014 -- edate:07/02/2014 -- issue:797 -- comment:28 DESC:RENAME POST AUDIT PROFILE TO TICKLER_TABID_PROFILE -- doneby:SAFI
-- version:0.1 -- startdate:11/03/2014 enddate:12/03/2014 description -- > SP for LOGIN TERMINATE SAVING PART by -- >DHIVYA -- >issue :345


DROP PROCEDURE IF EXISTS SP_LOGIN_TERMINATE_SAVE;
CREATE PROCEDURE SP_LOGIN_TERMINATE_SAVE(
IN LOGINID VARCHAR(40),
IN ENDDATE DATE,
IN REASON TEXT,
IN USERSTAMP VARCHAR(50),
OUT SUCCESS_FLAG INTEGER)
BEGIN
-- VARIABLE DECLARATION
	DECLARE RECVER INTEGER;
	DECLARE MINID INTEGER;
	DECLARE MAXID INTEGER;
	DECLARE TEMPTBL_LOGINID TEXT;
	DECLARE TEMP_LOGINID TEXT;
	DECLARE USERSTAMP_ID INT;
	DECLARE T_ELID INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
	SET SUCCESS_FLAG=0;
  IF(TEMPTBL_LOGINID IS NOT NULL)THEN
    SET @DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMPTBL_LOGINID,''));
		PREPARE DROPQUERYSTMT FROM @DROPQUERY;
		EXECUTE DROPQUERYSTMT;
  END IF;
	END;

	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID = (SELECT @ULDID);
-- TEMP TABLE NAME START
	SET TEMP_LOGINID=(SELECT CONCAT('TEMPTBL_LOGINID',SYSDATE()));
	SET TEMP_LOGINID=(SELECT REPLACE(TEMP_LOGINID,' ',''));
	SET TEMP_LOGINID=(SELECT REPLACE(TEMP_LOGINID,'-',''));
	SET TEMP_LOGINID=(SELECT REPLACE(TEMP_LOGINID,':',''));
	SET TEMPTBL_LOGINID=(SELECT CONCAT(TEMP_LOGINID,'_',USERSTAMP_ID));

	IF LOGINID IS NOT NULL AND ENDDATE IS NOT NULL AND REASON IS NOT NULL THEN
		SET RECVER=(SELECT MAX(UA_REC_VER) FROM USER_ACCESS WHERE ULD_ID=(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=LOGINID));
-- UPDATE QUERY FOR USER ACCESS
		UPDATE USER_ACCESS SET UA_JOIN=NULL,UA_TERMINATE='X',UA_REASON=REASON,UA_END_DATE=ENDDATE,
		UA_USERSTAMP=USERSTAMP WHERE ULD_ID=(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=LOGINID)AND
		UA_REC_VER=RECVER;
		SET SUCCESS_FLAG=1;
	
	-- DROP TABLE IF EXISTS TEMPTBL_LOGINID;
		SET @CREATE_TEMPTBL_LOGINID=(SELECT CONCAT('CREATE TABLE ',TEMPTBL_LOGINID,'(ID INTEGER AUTO_INCREMENT PRIMARY KEY,ELID VARCHAR(40))'));
		PREPARE CREATE_TEMPTBL_LOGINID_STMT FROM @CREATE_TEMPTBL_LOGINID;
		EXECUTE CREATE_TEMPTBL_LOGINID_STMT;
  
		SET @INSERT_TEMPTBL_LOGINID=(SELECT CONCAT('INSERT INTO ',TEMPTBL_LOGINID,'(ELID) SELECT EL_ID FROM EMAIL_LIST WHERE EL_EMAIL_ID=','"',LOGINID,'"'));
		PREPARE INSERT_TEMPTBL_LOGINID_STMT FROM @INSERT_TEMPTBL_LOGINID;
		EXECUTE INSERT_TEMPTBL_LOGINID_STMT;
	
		SET @MIN_ID=NULL;
		SET @SELECT_MINID=(SELECT CONCAT('SELECT MIN(ID) INTO @MIN_ID FROM ',TEMPTBL_LOGINID));
		PREPARE SELECT_MINID_STMT FROM @SELECT_MINID;
		EXECUTE SELECT_MINID_STMT;
		SET MINID=@MIN_ID;
  
		SET @MAX_ID=NULL;
		SET @SELECT_MAXID=(SELECT CONCAT('SELECT MAX(ID) INTO @MAX_ID FROM ',TEMPTBL_LOGINID));
		PREPARE SELECT_MAXID_STMT FROM @SELECT_MAXID;
		EXECUTE SELECT_MAXID_STMT;
		SET MAXID=@MAX_ID;
  
		WHILE MINID<=MAXID DO
-- DELETE LOGINID IN EMAIL LIST
			SET @SELECT_ELID=(SELECT CONCAT('SELECT ELID INTO @EID FROM ',TEMPTBL_LOGINID,' WHERE ID=',MINID));
			PREPARE SELECT_ELID_STMT FROM @SELECT_ELID;
			EXECUTE SELECT_ELID_STMT;
			SET T_ELID=@EID;
    
			CALL SP_SINGLE_TABLE_ROW_DELETION((SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='EMAIL_LIST'),T_ELID,USERSTAMP,@DELETION_FLAG);
			SET MINID=MINID+1;
		END WHILE;
		SET SUCCESS_FLAG=1;
		IF (TEMPTBL_LOGINID IS NOT NULL)THEN
			SET @DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMPTBL_LOGINID,''));
			PREPARE DROPQUERYSTMT FROM @DROPQUERY;
			EXECUTE DROPQUERYSTMT;
		END IF;
	END IF;
COMMIT;
END;
/*
CALL SP_LOGIN_TERMINATE_SAVE('deepanaidu25@gmail.com','2014-05-03','NEW USER','expatsintegrated@gmail.com',@SUCCESS_FLAG);
*/