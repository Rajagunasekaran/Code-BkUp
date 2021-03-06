-- VERSION 0.8 STARTDATE:11/08/2014 ENDDATE:11/08/2014 ISSUE NO:835 COMMENTNO :66 DESC:IMPLEMENTED SET AUTOCOMMIT=0 BEFORE TRANSACTION. DONE BY :RAJA
-- version 0.7 startdate:04/07/2014 --enddate:04/07/2014 -->desc: TEMP TABLE DROPPED WHEN ROLLBACK OCCUR --DONEBY:SAFI
-- version 0.5 startdate:10/06/2014 --enddate:10/06/2014--- issueno 566 commentno:12-->desc: ADDED ROLLBACK AND COMMIT BY SASIKALA
-- version 0.4 startdate:14/05/2014 --enddate:14/05/2014--- issueno 817 commentno:65-->desc: CHANGED THE SP FOR DYNAMIC PURPOSE BY RAJA
-- version 0.3 startdate:28/02/2014 --enddate:28/02/2014--- issueno 754 commentno:36-->desc: APPLIED SUB_SP TO REPLACE USERSTAMP AS ID-SAFI
-- version 0.2 --sdate:27/02/2014 --edate:27/02/2014 --issue:754 --comment:22 --doneby:RL	
-- VER 0.1--ISSUE NO:659 COMMENT NO:#2 START DATE:12/12/2013 ENDDATE:13/12/2013 DESC:SP FOR LOGIN CREATION UPDATE  DONE BY:DHIVYA.A
DROP PROCEDURE IF EXISTS SP_LOGIN_UPDATE;
CREATE PROCEDURE SP_LOGIN_UPDATE(
LOGINID VARCHAR(40),
ROLENAME VARCHAR(15),
JOINDATE DATE,
USERSTAMP VARCHAR(50),
OUT UR_FLAG INTEGER)
BEGIN
DECLARE OLDROLENAME VARCHAR(15);
DECLARE MINID INTEGER;
DECLARE MAXID INTEGER;
DECLARE RECVER INTEGER;
DECLARE USERSTAMP_ID INTEGER(2);
DECLARE TEMPTBL_MENU TEXT;
DECLARE TEMPTBL_LOGINID TEXT;
DECLARE TMP_MENU TEXT;
DECLARE TMP_LOGINID TEXT;
DECLARE EPID INT;
DECLARE EMAILLIST INT;
DECLARE EMAIL_MINID INTEGER;
DECLARE EMAIL_MAXID INTEGER;
DECLARE T_ELID INTEGER;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
	ROLLBACK; 
IF(TEMPTBL_MENU IS NOT NULL)THEN
  SET @DROP_TEMPTBL_MENU=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMPTBL_MENU));
  PREPARE DROP_TEMPTBL_MENU_STMT FROM @DROP_TEMPTBL_MENU;
  EXECUTE DROP_TEMPTBL_MENU_STMT;
END IF;
IF (TEMPTBL_LOGINID IS NOT NULL)THEN
			SET @DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMPTBL_LOGINID,''));
			PREPARE DROPQUERYSTMT FROM @DROPQUERY;
			EXECUTE DROPQUERYSTMT;
		END IF;
END;
SET AUTOCOMMIT = 0;
START TRANSACTION; 
SET FOREIGN_KEY_CHECKS=0;
SET UR_FLAG=0;
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID = (SELECT @ULDID);
SET TMP_MENU=(SELECT CONCAT('TEMPTBL_MENU',SYSDATE()));
SET TMP_MENU=(SELECT REPLACE(TMP_MENU,' ',''));
SET TMP_MENU=(SELECT REPLACE(TMP_MENU,'-',''));
SET TMP_MENU=(SELECT REPLACE(TMP_MENU,':',''));
SET TEMPTBL_MENU=(SELECT CONCAT(TMP_MENU,'_',USERSTAMP_ID));
SET TMP_LOGINID=(SELECT CONCAT('TEMPTBL_LOGINID',SYSDATE()));
SET TMP_LOGINID=(SELECT REPLACE(TMP_LOGINID,' ',''));
SET TMP_LOGINID=(SELECT REPLACE(TMP_LOGINID,'-',''));
SET TMP_LOGINID=(SELECT REPLACE(TMP_LOGINID,':',''));
SET TEMPTBL_LOGINID=(SELECT CONCAT(TMP_LOGINID,'_',USERSTAMP_ID));
SET RECVER=(SELECT MAX(UA_REC_VER) FROM USER_ACCESS WHERE ULD_ID=(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=LOGINID));
SET OLDROLENAME=(SELECT R.RC_NAME FROM USER_ACCESS U,ROLE_CREATION R WHERE R.RC_ID=U.RC_ID AND U.ULD_ID=(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=LOGINID)AND U.UA_REC_VER=RECVER);
	IF (ROLENAME IS NOT NULL AND JOINDATE IS NOT NULL AND USERSTAMP IS NOT NULL)THEN
		UPDATE USER_ACCESS SET RC_ID=(SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=ROLENAME),UA_JOIN_DATE=JOINDATE,UA_USERSTAMP=USERSTAMP WHERE ULD_ID=(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=LOGINID)AND UA_REC_VER=RECVER;
      SET UR_FLAG=1;
	END IF;
	IF (OLDROLENAME!=ROLENAME)THEN
		SET @CREATE_TEMPTBL_LOGINID=(SELECT CONCAT('CREATE TABLE ',TEMPTBL_LOGINID,'(ID INTEGER AUTO_INCREMENT PRIMARY KEY,ELID VARCHAR(40))'));
		PREPARE CREATE_TEMPTBL_LOGINID_STMT FROM @CREATE_TEMPTBL_LOGINID;
		EXECUTE CREATE_TEMPTBL_LOGINID_STMT;
		SET @INSERT_TEMPTBL_LOGINID=(SELECT CONCAT('INSERT INTO ',TEMPTBL_LOGINID,'(ELID) SELECT EL_ID FROM EMAIL_LIST WHERE EL_EMAIL_ID=','"',LOGINID,'" AND  EP_ID IN(1,17,15,16,13,14,20)'));
		PREPARE INSERT_TEMPTBL_LOGINID_STMT FROM @INSERT_TEMPTBL_LOGINID;
		EXECUTE INSERT_TEMPTBL_LOGINID_STMT;
		SET @MIN_ID=NULL;
		SET @SELECT_MINID=(SELECT CONCAT('SELECT MIN(ID) INTO @MIN_ID FROM ',TEMPTBL_LOGINID));
		PREPARE SELECT_MINID_STMT FROM @SELECT_MINID;
		EXECUTE SELECT_MINID_STMT;
		SET EMAIL_MINID=@MIN_ID;
		SET @MAX_ID=NULL;
		SET @SELECT_MAXID=(SELECT CONCAT('SELECT MAX(ID) INTO @MAX_ID FROM ',TEMPTBL_LOGINID));
		PREPARE SELECT_MAXID_STMT FROM @SELECT_MAXID;
		EXECUTE SELECT_MAXID_STMT;
		SET EMAIL_MAXID=@MAX_ID;
		WHILE EMAIL_MINID<=EMAIL_MAXID DO
			SET @SELECT_ELID=(SELECT CONCAT('SELECT ELID INTO @EID FROM ',TEMPTBL_LOGINID,' WHERE ID=',EMAIL_MINID));
			PREPARE SELECT_ELID_STMT FROM @SELECT_ELID;
			EXECUTE SELECT_ELID_STMT;
			SET T_ELID=@EID;
			CALL SP_SINGLE_TABLE_ROW_DELETION((SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='EMAIL_LIST'),T_ELID,USERSTAMP,@DELETION_FLAG);
			SET EMAIL_MINID=EMAIL_MINID+1;
		END WHILE;
		SET UR_FLAG=1;
	  IF (TEMPTBL_LOGINID IS NOT NULL)THEN
  		SET @DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMPTBL_LOGINID,''));
  		PREPARE DROPQUERYSTMT FROM @DROPQUERY;
  		EXECUTE DROPQUERYSTMT;
	  END IF;   
	SET @CREATE_TEMPTBL_MENU=(SELECT CONCAT('CREATE TABLE ',TEMPTBL_MENU,'(ID INTEGER PRIMARY KEY AUTO_INCREMENT,MP_ID INTEGER,EP_ID INTEGER)'));
  PREPARE CREATE_TEMPTBL_MENU_STMT FROM @CREATE_TEMPTBL_MENU;
  EXECUTE CREATE_TEMPTBL_MENU_STMT;
	SET @INSERT_TEMPTBL_MENU=(SELECT CONCAT('INSERT INTO ',TEMPTBL_MENU,'(MP_ID,EP_ID) SELECT M.MP_ID,M.EP_ID FROM USER_MENU_DETAILS U,MENU_PROFILE M WHERE U.RC_ID=(SELECT RC_ID FROM ROLE_CREATION WHERE RC_NAME=','"',ROLENAME,'"',')AND U.MP_ID=M.MP_ID'));
	PREPARE INSERT_TEMPTBL_MENU_STMT FROM @INSERT_TEMPTBL_MENU;
  EXECUTE INSERT_TEMPTBL_MENU_STMT;
  SET @MIN_ID=NULL; 
  SET @SELECT_MINID=(SELECT CONCAT('SELECT MIN(ID) INTO @MIN_ID FROM ',TEMPTBL_MENU));
  PREPARE SELECT_MINID_STMT FROM @SELECT_MINID;
  EXECUTE SELECT_MINID_STMT;
	SET MINID=@MIN_ID;
  SET @MAX_ID=NULL;
  SET @SELECT_MAXID=(SELECT CONCAT('SELECT MAX(ID) INTO @MAX_ID FROM ',TEMPTBL_MENU));
  PREPARE SELECT_MAXID_STMT FROM @SELECT_MAXID;
  EXECUTE SELECT_MAXID_STMT;
	SET MAXID=@MAX_ID;
	WHILE (MINID<=MAXID)DO 
    SET @T_EPID=NULL;
    SET @SELECT_EPID=(SELECT CONCAT('SELECT EP_ID INTO @T_EPID FROM ',TEMPTBL_MENU,' WHERE ID=',MINID,' AND EP_ID IS NOT NULL'));
    PREPARE SELECT_EPID_STMT FROM @SELECT_EPID;
    EXECUTE SELECT_EPID_STMT;
    SET EPID=(SELECT @T_EPID);
  		IF (EPID IS NOT NULL)THEN
       SET @SELECT_EMAIL_LIST=(SELECT CONCAT('SELECT COUNT(*) INTO @T_EMAILLIST FROM EMAIL_LIST WHERE EP_ID=(SELECT EP_ID FROM ',TEMPTBL_MENU,' WHERE ID=',MINID,')AND EL_EMAIL_ID=','"',LOGINID,'"'));
       PREPARE SELECT_EMAIL_LIST_STMT FROM @SELECT_EMAIL_LIST;
       EXECUTE SELECT_EMAIL_LIST_STMT;
       SET EMAILLIST=(SELECT @T_EMAILLIST);
	        IF (EMAILLIST=0)THEN 
      			SET @INSERT_EMAIL_LIST=(SELECT CONCAT('INSERT INTO EMAIL_LIST(EP_ID,EL_EMAIL_ID,ULD_ID)VALUES((SELECT EP_ID FROM ',TEMPTBL_MENU,' WHERE ID=',MINID,'),','"',LOGINID,'"',',',USERSTAMP_ID,')'));
            PREPARE INSERT_EMAIL_LIST_STMT FROM @INSERT_EMAIL_LIST;
            EXECUTE INSERT_EMAIL_LIST_STMT;
              SET UR_FLAG=1;
		      END IF;
		  END IF;
		SET MINID=MINID+1;
	END WHILE;
  SET @DROP_TEMPTBL_MENU=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMPTBL_MENU));
  PREPARE DROP_TEMPTBL_MENU_STMT FROM @DROP_TEMPTBL_MENU;
  EXECUTE DROP_TEMPTBL_MENU_STMT;
	END IF;
    SET FOREIGN_KEY_CHECKS=1;
END;
/*
CALL SP_LOGIN_UPDATE('DEEPANAIDU25@GMAIL.COM','ADMIN','2014-09-07','EXPATSINTEGRATED@GMAIL.COM',@UR_FLAG);
*/