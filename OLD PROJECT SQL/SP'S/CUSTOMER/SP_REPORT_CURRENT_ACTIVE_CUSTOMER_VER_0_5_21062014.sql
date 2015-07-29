-- version 0.5 srartdate:21/06/2014 -- enddate:21/06/2014-- - issueno 817 desc: DROP THE TEMP TABLES IF ROLLBACK OCCURS done by RAJA.
-- VERSION:0.4 -- SDATE:19/06/2014 -- EDATE:19/06/2014 -- ISSUE:345 -- COMMENTNO#717 -- DESC:CHANGED TEMP VIEW AS SUB VIEW -- DONEBY:BHAVANI.R
-- VERSION:0.3 -- SDATE:13/05/2014 -- EDATE:14/05/2014 -- ISSUE:817 -- COMMENTNO#49 -- DESC:CHANGED TEMP TABLE AS DYNAMIC -- DONEBY:RL
-- VER 0.2 STARTDATE:04/04/2014 ENDDATE:04/04/2014 ISSUENO:797 COMMENTNO:#4 DESC:REPLACED HEADER ND TABLE NAME DONE BY:LALITHA
-- VER 0.1 ISSUE NO:641 COMMENT NO:#21 START DATE:10/12/2013 END DATE:11/12/2013 DESC:VIEW FOR CURRENT ACTIVE CUSTOMER  DONE BY:RL

DROP PROCEDURE IF EXISTS SP_REPORT_CURRENT_ACTIVE_CUSTOMER;
CREATE PROCEDURE SP_REPORT_CURRENT_ACTIVE_CUSTOMER(
IN USERSTAMP VARCHAR(50),
OUT REPORT_CURRENT_ACTIVE_CUSTOMER TEXT)

BEGIN

	DECLARE USERSTAMP_ID INTEGER;
	DECLARE SYSDATEANDTIME VARCHAR(50);
	DECLARE SYSDATEANDULDID VARCHAR(50);
	
	DECLARE ALL_CUSTOMER_SEARCH_TEMP_FEE_DETAIL TEXT;
	DECLARE CURRENT_ACTIVECUSTOMER TEXT;
	
	DECLARE MINID INTEGER;
	DECLARE MAXID INTEGER;
	DECLARE FIRSTNAME CHAR(30);
	DECLARE LASTNAME CHAR(30);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK; 
  IF(CURRENT_ACTIVECUSTOMER IS NOT NULL)THEN
    SET @ACTIVECUSTOMER_DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',CURRENT_ACTIVECUSTOMER,''));
    PREPARE ACTIVECUSTOMER_DROPQUERYSTMT FROM @ACTIVECUSTOMER_DROPQUERY;
    EXECUTE ACTIVECUSTOMER_DROPQUERYSTMT;
  END IF;
  IF(ALL_CUSTOMER_SEARCH_TEMP_FEE_DETAIL IS NOT NULL)THEN
    SET @TEMP_FEE_DETAIL_DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',ALL_CUSTOMER_SEARCH_TEMP_FEE_DETAIL,''));
    PREPARE TEMP_FEE_DETAIL_DROPQUERYSTMT FROM @TEMP_FEE_DETAIL_DROPQUERY;
    EXECUTE TEMP_FEE_DETAIL_DROPQUERYSTMT;
  END IF;
	END;
	
	START TRANSACTION;

	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID=(SELECT @ULDID);

-- CALL QUERY FOR SP_ALL_CUSTOMER_SEARCH_TEMP_FEE_DETAIL
	CALL SP_ALL_CUSTOMER_SEARCH_TEMP_FEE_DETAIL(USERSTAMP,@CUSTOMER_SEARCH_FEE_TEMPTBLNAME);
	SET ALL_CUSTOMER_SEARCH_TEMP_FEE_DETAIL = (SELECT @CUSTOMER_SEARCH_FEE_TEMPTBLNAME);
	
	SET SYSDATEANDTIME=(SELECT SYSDATE());
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,' ',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,'-',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,':',''));
	SET SYSDATEANDULDID=(SELECT CONCAT(SYSDATEANDTIME,'_',USERSTAMP_ID));	
	
-- CURRENT_ACTIVE_CUSTOMER
	SET CURRENT_ACTIVECUSTOMER=(SELECT CONCAT('TEMP_REPORT_CURRENTACTIVE_CUSTOMER','_',SYSDATEANDULDID));
	SET @TEMPACTIVECUSTOMER_CREATEQUERY=(SELECT CONCAT('CREATE TABLE ',CURRENT_ACTIVECUSTOMER,'(
	ID INTEGER AUTO_INCREMENT,
	UNIT_NO  SMALLINT(4) UNSIGNED ZEROFILL,
	CUSTOMER_ID INTEGER,
	CUSTOMER_FIRST_NAME CHAR(30),
	CUSTOMER_LAST_NAME CHAR(30),
	CUSTOMERNAME VARCHAR(250),
	CLP_STARTDATE DATE,
	CLP_ENDDATE DATE,
	CLP_PRETERMINATE_DATE DATE,
	LEASE_PERIOD INTEGER,
	CED_RECHECKIN CHAR(1),
	CED_EXTENSION CHAR(1),
	CED_PRETERMINATE CHAR(1),
	CLP_TERMINATE CHAR(1),
	CC_PAYMENT_AMOUNT DECIMAL(7,2),
	CC_DEPOSIT DECIMAL(7,2),
	CC_PROCESSING_FEE DECIMAL(7,2),
	CC_AIRCON_FIXED_FEE DECIMAL(7,2),
	CC_ELECTRICITY_CAP DECIMAL(7,2),
	CC_DRYCLEAN_FEE DECIMAL(7,2),
	CC_AIRCON_QUARTERLY_FEE DECIMAL(7,2),
	CC_CHECKOUT_CLEANING_FEE DECIMAL(7,2),
	PRIMARY KEY(ID))'));
	PREPARE TEMPACTIVECUSTOMER_CREATEQUERYSTMT FROM @TEMPACTIVECUSTOMER_CREATEQUERY;
	EXECUTE TEMPACTIVECUSTOMER_CREATEQUERYSTMT;
	
	SET @TEMPACTIVECUSTOMER_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',CURRENT_ACTIVECUSTOMER,'(
	CUSTOMER_ID,CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME,UNIT_NO,LEASE_PERIOD,CED_RECHECKIN,CED_EXTENSION,CED_PRETERMINATE,
	CC_PAYMENT_AMOUNT,CC_DEPOSIT,CC_PROCESSING_FEE,CC_AIRCON_FIXED_FEE,CC_ELECTRICITY_CAP,CC_DRYCLEAN_FEE,
	CC_AIRCON_QUARTERLY_FEE,CC_CHECKOUT_CLEANING_FEE,CLP_STARTDATE,CLP_ENDDATE,CLP_PRETERMINATE_DATE,CLP_TERMINATE)
	SELECT C.CUSTOMER_ID,C.CUSTOMER_FIRST_NAME,C.CUSTOMER_LAST_NAME, 
	U.UNIT_NO, CED.CED_REC_VER, CED.CED_RECHECKIN, CED.CED_EXTENSION, CED.CED_PRETERMINATE, 
	T.CC_PAYMENT_AMOUNT, T.CC_DEPOSIT, T.CC_PROCESSING_FEE, T.CC_AIRCON_FIXED_FEE, T.CC_ELECTRICITY_CAP,T.CC_DRYCLEAN_FEE,
	T.CC_AIRCON_QUARTERLY_FEE, T.CC_CHECKOUT_CLEANING_FEE,CTD.CLP_STARTDATE, CTD.CLP_ENDDATE, CTD.CLP_PRETERMINATE_DATE,CTD.CLP_TERMINATE
	FROM UNIT U, CUSTOMER C, CUSTOMER_ENTRY_DETAILS CED, ',ALL_CUSTOMER_SEARCH_TEMP_FEE_DETAIL,' T,
	CUSTOMER_LP_DETAILS CTD, VW_SUB_ACTIVE_CUSTOMER_LIST V WHERE
	C.CUSTOMER_ID=CED.CUSTOMER_ID AND C.CUSTOMER_ID=CTD.CUSTOMER_ID AND C.CUSTOMER_ID=T.CUSTOMER_ID AND 
	C.CUSTOMER_ID=V.CUSTOMER_ID AND U.UNIT_ID=CED.UNIT_ID AND CTD.CUSTOMER_ID=CED.CUSTOMER_ID AND
	CTD.CUSTOMER_ID=T.CUSTOMER_ID AND CTD.CUSTOMER_ID=V.CUSTOMER_ID AND CED.CUSTOMER_ID=T.CUSTOMER_ID AND 
	CED.CUSTOMER_ID=V.CUSTOMER_ID AND T.CUSTOMER_ID=CTD.CUSTOMER_ID AND T.CUSTOMER_ID=CED.CUSTOMER_ID AND 
	CTD.CLP_GUEST_CARD IS NULL AND T.CUSTOMER_VER=CTD.CED_REC_VER AND T.CUSTOMER_VER=CED.CED_REC_VER 
	AND IF(CTD.CLP_PRETERMINATE_DATE IS NOT NULL,CTD.CLP_STARTDATE<CTD.CLP_PRETERMINATE_DATE,CTD.CLP_STARTDATE<CTD.CLP_ENDDATE)'));
	PREPARE TEMPACTIVECUSTOMER_INSERTQUERYSTMT FROM @TEMPACTIVECUSTOMER_INSERTQUERY;
	EXECUTE TEMPACTIVECUSTOMER_INSERTQUERYSTMT;
	
	SET @TEMP_FEE_DETAIL_DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',ALL_CUSTOMER_SEARCH_TEMP_FEE_DETAIL,''));
	PREPARE TEMP_FEE_DETAIL_DROPQUERYSTMT FROM @TEMP_FEE_DETAIL_DROPQUERY;
	EXECUTE TEMP_FEE_DETAIL_DROPQUERYSTMT;
	
	SET @MIN_ID = (SELECT CONCAT('SELECT MIN(ID) INTO @MINIMUMID FROM ',CURRENT_ACTIVECUSTOMER,''));
	PREPARE MIN_ID_STMT FROM @MIN_ID;
	EXECUTE MIN_ID_STMT;
	
	SET @MAX_ID = (SELECT CONCAT('SELECT MAX(ID) INTO @MAXIMUMID FROM ',CURRENT_ACTIVECUSTOMER,''));
	PREPARE MAX_ID_STMT FROM @MAX_ID;
	EXECUTE MAX_ID_STMT;
	
	SET MINID = @MINIMUMID;
	SET MAXID = @MAXIMUMID;
	
	WHILE(MINID <= MAXID) DO
	
		SET @FNAME = (SELECT CONCAT('SELECT CUSTOMER_FIRST_NAME INTO @F_NAME FROM ',CURRENT_ACTIVECUSTOMER,'
		WHERE ID=',MINID,''));
		PREPARE FNAME_STMT FROM @FNAME;
		EXECUTE FNAME_STMT;
		
		SET FIRSTNAME = @F_NAME;
		
		SET @LNAME = (SELECT CONCAT('SELECT CUSTOMER_LAST_NAME INTO @L_NAME FROM ',CURRENT_ACTIVECUSTOMER,'
		WHERE ID=',MINID,''));
		PREPARE LNAME_STMT FROM @LNAME;
		EXECUTE LNAME_STMT;
		
		SET LASTNAME = @L_NAME;
		
		SET @CUST_NAME = (SELECT CONCAT(FIRSTNAME,' ',LASTNAME));
		
		SET @UPDATEQUERY = (SELECT CONCAT('UPDATE ',CURRENT_ACTIVECUSTOMER,' SET 
		CUSTOMERNAME = @CUST_NAME WHERE ID=',MINID,''));
		PREPARE UPDATEQUERYSTMT FROM @UPDATEQUERY;
		EXECUTE UPDATEQUERYSTMT;
		
		SET MINID = MINID+1;
		
	END WHILE;
	
	SET REPORT_CURRENT_ACTIVE_CUSTOMER=(SELECT CONCAT('TEMP_REPORT_CURRENT_ACTIVE_CUSTOMER','_',SYSDATEANDULDID));
	SET @CREATEQUERY=(SELECT CONCAT('CREATE TABLE ',REPORT_CURRENT_ACTIVE_CUSTOMER,'(
	ID INTEGER AUTO_INCREMENT,
	UNIT_NO  SMALLINT(4) UNSIGNED ZEROFILL,
	CUSTOMER_ID INTEGER,
	CUSTOMER_FIRST_NAME CHAR(30),
	CUSTOMER_LAST_NAME CHAR(30),
	CUSTOMERNAME VARCHAR(250),
	CLP_STARTDATE DATE,
	CLP_ENDDATE DATE,
	CLP_PRETERMINATE_DATE DATE,
	LEASE_PERIOD INTEGER,
	CED_RECHECKIN CHAR(1),
	CED_EXTENSION CHAR(1),
	CED_PRETERMINATE CHAR(1),
	CLP_TERMINATE CHAR(1),
	CC_PAYMENT_AMOUNT DECIMAL(7,2),
	CC_DEPOSIT DECIMAL(7,2),
	CC_PROCESSING_FEE DECIMAL(7,2),
	CC_AIRCON_FIXED_FEE DECIMAL(7,2),
	CC_ELECTRICITY_CAP DECIMAL(7,2),
	CC_DRYCLEAN_FEE DECIMAL(7,2),
	CC_AIRCON_QUARTERLY_FEE DECIMAL(7,2),
	CC_CHECKOUT_CLEANING_FEE DECIMAL(7,2),
	PRIMARY KEY(ID))'));
	PREPARE CREATEQUERYSTMT FROM @CREATEQUERY;
	EXECUTE CREATEQUERYSTMT;
	
	SET @INSERTQUERY = (SELECT CONCAT('INSERT INTO ',REPORT_CURRENT_ACTIVE_CUSTOMER,' (CUSTOMER_ID,CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME,CUSTOMERNAME,UNIT_NO,LEASE_PERIOD,CED_RECHECKIN,
	CED_EXTENSION,CED_PRETERMINATE,CC_PAYMENT_AMOUNT,CC_DEPOSIT,CC_PROCESSING_FEE,CC_AIRCON_FIXED_FEE,CC_ELECTRICITY_CAP,CC_DRYCLEAN_FEE,
	CC_AIRCON_QUARTERLY_FEE,CC_CHECKOUT_CLEANING_FEE,CLP_STARTDATE,CLP_ENDDATE,CLP_PRETERMINATE_DATE,CLP_TERMINATE)
	SELECT CUSTOMER_ID,CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME,CUSTOMERNAME,UNIT_NO,LEASE_PERIOD,CED_RECHECKIN,CED_EXTENSION,CED_PRETERMINATE,
	CC_PAYMENT_AMOUNT,CC_DEPOSIT,CC_PROCESSING_FEE,CC_AIRCON_FIXED_FEE,CC_ELECTRICITY_CAP,CC_DRYCLEAN_FEE,
	CC_AIRCON_QUARTERLY_FEE,CC_CHECKOUT_CLEANING_FEE,CLP_STARTDATE,CLP_ENDDATE,CLP_PRETERMINATE_DATE,CLP_TERMINATE FROM
	',CURRENT_ACTIVECUSTOMER,''));
	PREPARE INSERTQUERYSTMT FROM @INSERTQUERY;
	EXECUTE INSERTQUERYSTMT;
	
COMMIT;
	
	SET @ACTIVECUSTOMER_DROPQUERY = (SELECT CONCAT('DROP TABLE IF EXISTS ',CURRENT_ACTIVECUSTOMER,''));
	PREPARE ACTIVECUSTOMER_DROPQUERYSTMT FROM @ACTIVECUSTOMER_DROPQUERY;
	EXECUTE ACTIVECUSTOMER_DROPQUERYSTMT;
END;