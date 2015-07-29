DROP PROCEDURE IF EXISTS SP_PAYMENT_ENTRY_TERMINATED_CUSTOMER;
CREATE PROCEDURE SP_PAYMENT_ENTRY_TERMINATED_CUSTOMER(
IN USERSTAMP VARCHAR(50),
OUT PAYMENT_ENTRY_TERMINATED_CUSTOMER TEXT)
BEGIN
	DECLARE USERSTAMP_ID INTEGER;
	DECLARE SYSDATEANDTIME VARCHAR(50);
	DECLARE SYSDATEANDULDID VARCHAR(50);
	DECLARE PAYMENT_MAX_RECVER TEXT;
	DECLARE TERMINATEDCUSTOMER TEXT;
	DECLARE TERMINATED_CUSTOMER TEXT;
	DECLARE T_ACTIVE_TERMINATED_RECVER TEXT;
	DECLARE PAYMENT_ACTIVE_TERMINATED_RECORDVERSION TEXT;
	DECLARE MINID INTEGER;
	DECLARE MAXID INTEGER;
	DECLARE FIRSTNAME CHAR(30);
	DECLARE LASTNAME CHAR(30);
	DECLARE TMINID INTEGER;
	DECLARE TMAXID INTEGER;
	DECLARE TFIRSTNAME CHAR(30);
	DECLARE TLASTNAME CHAR(30);
DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK; 
  IF(PAYMENT_MAX_RECVER IS NOT NULL)THEN
    SET @PAYMENT_MAX_RECVER_DROP = (SELECT CONCAT('DROP TABLE IF EXISTS ',PAYMENT_MAX_RECVER,''));
  	PREPARE PAYMENT_MAX_RECVER_DROP_STMT FROM @PAYMENT_MAX_RECVER_DROP;
  	EXECUTE PAYMENT_MAX_RECVER_DROP_STMT;
  END IF;
  IF(TERMINATEDCUSTOMER IS NOT NULL)THEN
  	SET @TERMINATEDCUSTOMER_DROP = (SELECT CONCAT('DROP TABLE IF EXISTS ',TERMINATEDCUSTOMER,''));
  	PREPARE TERMINATEDCUSTOMER_DROP_STMT FROM @TERMINATEDCUSTOMER_DROP;
  	EXECUTE TERMINATEDCUSTOMER_DROP_STMT;
  END IF;
  IF(TERMINATED_CUSTOMER IS NOT NULL)THEN
  	SET @TERMINATED_CUSTOMER_DROP = (SELECT CONCAT('DROP TABLE IF EXISTS ',TERMINATED_CUSTOMER,''));
  	PREPARE TERMINATED_CUSTOMER_DROP_STMT FROM @TERMINATED_CUSTOMER_DROP;
  	EXECUTE TERMINATED_CUSTOMER_DROP_STMT;
  END IF;
  IF(T_ACTIVE_TERMINATED_RECVER IS NOT NULL)THEN
  	SET @T_ACTIVE_TERMINATED_RECVER_DROP = (SELECT CONCAT('DROP TABLE IF EXISTS ',T_ACTIVE_TERMINATED_RECVER,''));
  	PREPARE T_ACTIVE_TERMINATED_RECVER_DROP_STMT FROM @T_ACTIVE_TERMINATED_RECVER_DROP;
  	EXECUTE T_ACTIVE_TERMINATED_RECVER_DROP_STMT;
  END IF;
  IF(PAYMENT_ACTIVE_TERMINATED_RECORDVERSION IS NOT NULL)THEN
  	SET @PAYMENT_ACTIVE_TERMINATED_RECORDVERSION_DROP = (SELECT CONCAT('DROP TABLE IF EXISTS ',PAYMENT_ACTIVE_TERMINATED_RECORDVERSION,''));
  	PREPARE PAYMENT_ACTIVE_TERMINATED_RECORDVERSION_DROP_STMT FROM @PAYMENT_ACTIVE_TERMINATED_RECORDVERSION_DROP;
  	EXECUTE PAYMENT_ACTIVE_TERMINATED_RECORDVERSION_DROP_STMT;
  END IF;
	END;
	START TRANSACTION;
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID=(SELECT @ULDID);
	SET SYSDATEANDTIME=(SELECT SYSDATE());
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,' ',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,'-',''));
	SET SYSDATEANDTIME=(SELECT REPLACE(SYSDATEANDTIME,':',''));
	SET SYSDATEANDULDID=(SELECT CONCAT(SYSDATEANDTIME,'_',USERSTAMP_ID));	
	SET PAYMENT_MAX_RECVER=(SELECT CONCAT('TEMP_PAYMENT_MAX_RECVER','_',SYSDATEANDULDID));
	SET @PAYMENT_MAXRECVER_CREATEQUERY = (SELECT CONCAT('CREATE TABLE ',PAYMENT_MAX_RECVER,'(
	CUSTOMERID INTEGER,REC_VER INTEGER)'));
	PREPARE PAYMENT_MAXRECVER_CREATEQUERYSTMT FROM @PAYMENT_MAXRECVER_CREATEQUERY;
	EXECUTE PAYMENT_MAXRECVER_CREATEQUERYSTMT;
	SET @PAYMENT_MAXRECVER_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',PAYMENT_MAX_RECVER,'(CUSTOMERID,REC_VER)
	SELECT CUSTOMER_ID,MAX(CED_REC_VER) FROM CUSTOMER_LP_DETAILS WHERE  CLP_GUEST_CARD IS NULL 
	AND IF(CLP_PRETERMINATE_DATE IS NOT NULL,CLP_STARTDATE<CLP_PRETERMINATE_DATE,CLP_STARTDATE) GROUP BY CUSTOMER_ID'));
	PREPARE PAYMENT_MAXRECVER_INSERTQUERYSTMT FROM @PAYMENT_MAXRECVER_INSERTQUERY;
	EXECUTE PAYMENT_MAXRECVER_INSERTQUERYSTMT;
	SET TERMINATEDCUSTOMER=(SELECT CONCAT('TEMP_PAYMENT_TERMINATED_CUSTOMER','_',SYSDATEANDULDID));
	SET @TERMINATEDCUSTOMER_CREATEQUERY = (SELECT CONCAT('CREATE TABLE ',TERMINATEDCUSTOMER,'(
	CUSTOMERID INTEGER,
	UASD_ID INTEGER,
	CLP_TERMINATE CHAR(1),
	REC_VER INTEGER,
	CED_CANCEL_DATE DATE)'));
	PREPARE TERMINATEDCUSTOMER_CREATEQUERYSTMT FROM @TERMINATEDCUSTOMER_CREATEQUERY;
	EXECUTE TERMINATEDCUSTOMER_CREATEQUERYSTMT;
	SET @TERMINATEDCUSTOMER_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',TERMINATEDCUSTOMER,'(
	CUSTOMERID,UASD_ID,CLP_TERMINATE,REC_VER,CED_CANCEL_DATE)
	SELECT C1.CUSTOMERID,C.UASD_ID,C.CLP_TERMINATE,C1.REC_VER,CED.CED_CANCEL_DATE FROM CUSTOMER_LP_DETAILS C,VW_SUB_CUSTOMER C1 ,
	CUSTOMER_ENTRY_DETAILS CED WHERE C.CED_REC_VER=C1.REC_VER AND CED.CED_REC_VER=C1.REC_VER AND CED.CUSTOMER_ID=C1.CUSTOMERID AND 
	C.CUSTOMER_ID=C1.CUSTOMERID AND C.CLP_TERMINATE IS NOT NULL AND C.CLP_GUEST_CARD IS NULL AND CED.CED_CANCEL_DATE IS NULL GROUP BY C.CUSTOMER_ID'));
	PREPARE TERMINATEDCUSTOMER_INSERTQUERYSTMT FROM @TERMINATEDCUSTOMER_INSERTQUERY;
	EXECUTE TERMINATEDCUSTOMER_INSERTQUERYSTMT;
	SET TERMINATED_CUSTOMER=(SELECT CONCAT('PAYMENT_TERMINATED_CUSTOMER','_',SYSDATEANDULDID));
	SET @TERMINATED_CUSTOMER_CREATEQUERY = (SELECT CONCAT('CREATE TABLE ',TERMINATED_CUSTOMER,'(
	ID INTEGER AUTO_INCREMENT,
	CUSTOMER_ID INTEGER,
	CUSTOMER_FIRST_NAME CHAR(30),
	CUSTOMER_LAST_NAME CHAR(30),
	CUSTOMERNAME VARCHAR(255),
	CED_REC_VER INTEGER,
	UNIT_NO SMALLINT(4) UNSIGNED ZEROFILL,
	CLP_STARTDATE DATE,
	CLP_ENDDATE DATE,
	CLP_PRETERMINATE_DATE DATE,
	CED_PRETERMINATE CHAR(1),
	CFD_AMOUNT DECIMAL(7,2),
	CPD_EMAIL VARCHAR(40),
	PRIMARY KEY(ID))'));
	PREPARE TERMINATED_CUSTOMER_CREATEQUERYSTMT FROM @TERMINATED_CUSTOMER_CREATEQUERY;
	EXECUTE TERMINATED_CUSTOMER_CREATEQUERYSTMT;
	SET @TERMINATED_CUSTOMER_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',TERMINATED_CUSTOMER,'(
	CUSTOMER_ID,CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME,CED_REC_VER,UNIT_NO,CLP_STARTDATE,CLP_ENDDATE,
	CLP_PRETERMINATE_DATE,CED_PRETERMINATE,CFD_AMOUNT,CPD_EMAIL)
	SELECT C.CUSTOMER_ID,C.CUSTOMER_FIRST_NAME,C.CUSTOMER_LAST_NAME,CED.CED_REC_VER,U.UNIT_NO,CTD.CLP_STARTDATE,CTD.CLP_ENDDATE,CTD.CLP_PRETERMINATE_DATE,
	CED.CED_PRETERMINATE,CFD.CFD_AMOUNT AS PAYMENT,CPD.CPD_EMAIL FROM CUSTOMER_ENTRY_DETAILS CED,CUSTOMER_LP_DETAILS CTD,CUSTOMER C,UNIT U,CUSTOMER_FEE_DETAILS CFD,',TERMINATEDCUSTOMER,' V,CUSTOMER_PERSONAL_DETAILS CPD WHERE
	C.CUSTOMER_ID=CED.CUSTOMER_ID AND C.CUSTOMER_ID=CTD.CUSTOMER_ID AND C.CUSTOMER_ID=CFD.CUSTOMER_ID AND C.CUSTOMER_ID=V.CUSTOMERID AND U.UNIT_ID=CED.UNIT_ID AND CTD.CUSTOMER_ID=CED.CUSTOMER_ID AND
	CTD.CUSTOMER_ID=CFD.CUSTOMER_ID AND CTD.CUSTOMER_ID=V.CUSTOMERID AND CED.CUSTOMER_ID=CFD.CUSTOMER_ID AND CED.CUSTOMER_ID=V.CUSTOMERID AND CFD.CUSTOMER_ID=CTD.CUSTOMER_ID AND CFD.CUSTOMER_ID=CED.CUSTOMER_ID AND CTD.CLP_GUEST_CARD IS NULL AND C.CUSTOMER_ID=CPD.CUSTOMER_ID AND
	CPD.CUSTOMER_ID=CTD.CUSTOMER_ID AND CPD.CUSTOMER_ID=CED.CUSTOMER_ID AND CFD.CUSTOMER_ID=CPD.CUSTOMER_ID AND V.CUSTOMERID=CPD.CUSTOMER_ID AND CFD.CPP_ID=1 AND CFD.CED_REC_VER=CTD.CED_REC_VER AND CFD.CED_REC_VER=CED.CED_REC_VER AND IF(CTD.CLP_PRETERMINATE_DATE IS NOT NULL,CTD.CLP_STARTDATE<CTD.CLP_PRETERMINATE_DATE,CTD.CLP_STARTDATE<CTD.CLP_ENDDATE) AND CPD.CUSTOMER_ID=C.CUSTOMER_ID
	AND CED.CED_CANCEL_DATE IS NULL AND V.CED_CANCEL_DATE IS NULL'));
	PREPARE TERMINATED_CUSTOMER_INSERTQUERYSTMT FROM @TERMINATED_CUSTOMER_INSERTQUERY;
	EXECUTE TERMINATED_CUSTOMER_INSERTQUERYSTMT;
	SET @MIN_ID = (SELECT CONCAT('SELECT MIN(ID) INTO @MINIMUMID FROM ',TERMINATED_CUSTOMER,''));
	PREPARE MIN_ID_STMT FROM @MIN_ID;
	EXECUTE MIN_ID_STMT;
	SET @MAX_ID = (SELECT CONCAT('SELECT MAX(ID) INTO @MAXIMUMID FROM ',TERMINATED_CUSTOMER,''));
	PREPARE MAX_ID_STMT FROM @MAX_ID;
	EXECUTE MAX_ID_STMT;
	SET MINID = @MINIMUMID;
	SET MAXID = @MAXIMUMID;
	WHILE(MINID <= MAXID) DO
		SET @FNAME = (SELECT CONCAT('SELECT CUSTOMER_FIRST_NAME INTO @F_NAME FROM ',TERMINATED_CUSTOMER,'
		WHERE ID=',MINID,''));
		PREPARE FNAME_STMT FROM @FNAME;
		EXECUTE FNAME_STMT;
		SET FIRSTNAME = @F_NAME;
		SET @LNAME = (SELECT CONCAT('SELECT CUSTOMER_LAST_NAME INTO @L_NAME FROM ',TERMINATED_CUSTOMER,'
		WHERE ID=',MINID,''));
		PREPARE LNAME_STMT FROM @LNAME;
		EXECUTE LNAME_STMT;
		SET LASTNAME = @L_NAME;
		SET @CUSTOMER_NAME = (SELECT CONCAT(FIRSTNAME,' ',LASTNAME));
		SET @UPDATEQUERY = (SELECT CONCAT('UPDATE ',TERMINATED_CUSTOMER,' SET 
		CUSTOMERNAME = @CUSTOMER_NAME WHERE ID=',MINID,''));
		PREPARE UPDATEQUERYSTMT FROM @UPDATEQUERY;
		EXECUTE UPDATEQUERYSTMT;
		SET MINID = MINID+1;
	END WHILE;
	SET T_ACTIVE_TERMINATED_RECVER=(SELECT CONCAT('TEMP_PAYMENT_ACTIVE_TERMINATED_RECVER','_',SYSDATEANDULDID));
	SET @ACTIVE_TERMINATED_RECVER_CREATEQUERY = (SELECT CONCAT('CREATE TABLE ',T_ACTIVE_TERMINATED_RECVER,'(
	CUSTOMER_ID INTEGER,
	CED_REC_VER INTEGER,
	UNIT_ID INTEGER)'));
	PREPARE ACTIVE_TERMINATED_RECVER_CREATEQUERYSTMT FROM @ACTIVE_TERMINATED_RECVER_CREATEQUERY;
	EXECUTE ACTIVE_TERMINATED_RECVER_CREATEQUERYSTMT;
	SET @ACTIVE_TERMINATED_RECVER_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',T_ACTIVE_TERMINATED_RECVER,' 
	(CUSTOMER_ID,CED_REC_VER,UNIT_ID)(SELECT CUSTOMER_ID,CED_REC_VER,UNIT_ID FROM VW_PAYMENT_CURRENT_ACTIVE_CUSTOMER V,UNIT U WHERE (CLP_STARTDATE<CURDATE() OR CLP_STARTDATE>CURDATE())AND IF(CLP_PRETERMINATE_DATE IS NOT NULL,CLP_PRETERMINATE_DATE>CURDATE(),CLP_ENDDATE>CURDATE())AND U.UNIT_NO=V.UNIT_NO)'));
	PREPARE ACTIVE_TERMINATED_RECVER_INSERTQUERYSTMT FROM @ACTIVE_TERMINATED_RECVER_INSERTQUERY;
	EXECUTE ACTIVE_TERMINATED_RECVER_INSERTQUERYSTMT;
	SET PAYMENT_ACTIVE_TERMINATED_RECORDVERSION=(SELECT CONCAT('PAYMENT_ACTIVE_TERMINATED_RECVER','_',SYSDATEANDULDID));
	SET @PAYMENT_ACTIVE_TERM_CREATEQUERY = (SELECT CONCAT('CREATE TABLE ',PAYMENT_ACTIVE_TERMINATED_RECORDVERSION,'(
	ID INTEGER AUTO_INCREMENT,
	CUSTOMER_ID INTEGER,
	CUSTOMER_FIRST_NAME CHAR(30),
	CUSTOMER_LAST_NAME CHAR(30),
	CUSTOMERNAME VARCHAR(250),
	CED_REC_VER INTEGER,
	UNIT_NO  SMALLINT(4) UNSIGNED ZEROFILL,
	CLP_STARTDATE DATE,
	CLP_ENDDATE DATE,
	CLP_PRETERMINATE_DATE DATE,
	CED_PRETERMINATE CHAR(1),
	PAYMENT DECIMAL(7,2),
	CPD_EMAIL VARCHAR(40),
	PRIMARY KEY(ID))'));
	PREPARE PAYMENT_ACTIVE_TERM_CREATEQUERYSTMT FROM @PAYMENT_ACTIVE_TERM_CREATEQUERY;
	EXECUTE PAYMENT_ACTIVE_TERM_CREATEQUERYSTMT;
	SET @PAYMENT_ACTIVE_TERM_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',PAYMENT_ACTIVE_TERMINATED_RECORDVERSION,'(
	CUSTOMER_ID,CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME,CED_REC_VER,UNIT_NO,CLP_STARTDATE,CLP_ENDDATE,
	CLP_PRETERMINATE_DATE,CED_PRETERMINATE,PAYMENT,CPD_EMAIL)
	(SELECT DISTINCT C.CUSTOMER_ID,C.CUSTOMER_FIRST_NAME,C.CUSTOMER_LAST_NAME,CED.CED_REC_VER,U.UNIT_NO,CTD.CLP_STARTDATE,CTD.CLP_ENDDATE,CTD.CLP_PRETERMINATE_DATE,
	CED.CED_PRETERMINATE,CFD.CFD_AMOUNT,CPD.CPD_EMAIL FROM CUSTOMER_ENTRY_DETAILS CED,CUSTOMER_LP_DETAILS CTD,CUSTOMER C,UNIT U,CUSTOMER_FEE_DETAILS CFD,',T_ACTIVE_TERMINATED_RECVER,' V,CUSTOMER_PERSONAL_DETAILS CPD WHERE
	C.CUSTOMER_ID=CED.CUSTOMER_ID AND V.UNIT_ID!=CED.UNIT_ID AND V.CUSTOMER_ID=CED.CUSTOMER_ID AND C.CUSTOMER_ID=CTD.CUSTOMER_ID AND C.CUSTOMER_ID=CFD.CUSTOMER_ID AND C.CUSTOMER_ID=V.CUSTOMER_ID AND U.UNIT_ID=CED.UNIT_ID AND CTD.CUSTOMER_ID=CED.CUSTOMER_ID AND
	CTD.CUSTOMER_ID=CFD.CUSTOMER_ID AND CTD.CUSTOMER_ID=V.CUSTOMER_ID AND CED.CUSTOMER_ID=CFD.CUSTOMER_ID AND CED.CUSTOMER_ID=V.CUSTOMER_ID AND CFD.CUSTOMER_ID=CTD.CUSTOMER_ID AND CFD.CUSTOMER_ID=CED.CUSTOMER_ID AND CTD.CLP_GUEST_CARD IS NULL AND C.CUSTOMER_ID=CPD.CUSTOMER_ID AND
	CPD.CUSTOMER_ID=CTD.CUSTOMER_ID AND CPD.CUSTOMER_ID=CED.CUSTOMER_ID AND CFD.CUSTOMER_ID=CPD.CUSTOMER_ID AND V.CUSTOMER_ID=CPD.CUSTOMER_ID AND CFD.CPP_ID=1 AND CFD.CED_REC_VER=CTD.CED_REC_VER AND CFD.CED_REC_VER=CED.CED_REC_VER AND IF(CTD.CLP_PRETERMINATE_DATE IS NOT NULL,CTD.CLP_STARTDATE<CTD.CLP_PRETERMINATE_DATE,CTD.CLP_STARTDATE<CTD.CLP_ENDDATE) AND CPD.CUSTOMER_ID=C.CUSTOMER_ID
	AND CED.CED_CANCEL_DATE IS NULL)'));
	PREPARE PAYMENT_ACTIVE_TERM_INSERTQUERYSTMT FROM @PAYMENT_ACTIVE_TERM_INSERTQUERY;
	EXECUTE PAYMENT_ACTIVE_TERM_INSERTQUERYSTMT;
	SET @TMIN_ID = (SELECT CONCAT('SELECT MIN(ID) INTO @MINIMUM_ID FROM ',PAYMENT_ACTIVE_TERMINATED_RECORDVERSION,''));
	PREPARE TMIN_ID_STMT FROM @TMIN_ID;
	EXECUTE TMIN_ID_STMT;
	SET @TMAX_ID = (SELECT CONCAT('SELECT MAX(ID) INTO @MAXIMUM_ID FROM ',PAYMENT_ACTIVE_TERMINATED_RECORDVERSION,''));
	PREPARE TMAX_ID_STMT FROM @TMAX_ID;
	EXECUTE TMAX_ID_STMT;
	SET TMINID = @MINIMUM_ID;
	SET TMAXID = @MAXIMUM_ID;
	WHILE(TMINID <= TMAXID) DO
		SET @TFNAME = (SELECT CONCAT('SELECT CUSTOMER_FIRST_NAME INTO @TF_NAME FROM ',PAYMENT_ACTIVE_TERMINATED_RECORDVERSION,'
		WHERE ID=',TMINID,''));
		PREPARE TFNAME_STMT FROM @TFNAME;
		EXECUTE TFNAME_STMT;
		SET TFIRSTNAME = @TF_NAME;
		SET @TLNAME = (SELECT CONCAT('SELECT CUSTOMER_LAST_NAME INTO @TL_NAME FROM ',PAYMENT_ACTIVE_TERMINATED_RECORDVERSION,'
		WHERE ID=',TMINID,''));
		PREPARE TLNAME_STMT FROM @TLNAME;
		EXECUTE TLNAME_STMT;
		SET TLASTNAME = @TL_NAME;
		SET @TCUSTOMER_NAME = (SELECT CONCAT(TFIRSTNAME,' ',TLASTNAME));
		SET @UPDATEQUERY = (SELECT CONCAT('UPDATE ',PAYMENT_ACTIVE_TERMINATED_RECORDVERSION,' SET 
		CUSTOMERNAME = @TCUSTOMER_NAME WHERE ID=',TMINID,''));
		PREPARE UPDATEQUERYSTMT FROM @UPDATEQUERY;
		EXECUTE UPDATEQUERYSTMT;
		SET TMINID = TMINID+1;
	END WHILE;
	SET PAYMENT_ENTRY_TERMINATED_CUSTOMER=(SELECT CONCAT('TEMP_PAYMENT_ENTRY_TERMINATED_CUSTOMER','_',SYSDATEANDULDID));
	SET @CREATEQUERY = (SELECT CONCAT('CREATE TABLE ',PAYMENT_ENTRY_TERMINATED_CUSTOMER,'(
	CUSTOMER_ID INTEGER,
	CUSTOMER_FIRST_NAME CHAR(30),
	CUSTOMER_LAST_NAME CHAR(30),
	CUSTOMERNAME CHAR(60),
	CED_REC_VER INTEGER,
	UNIT_NO SMALLINT(4)UNSIGNED ZEROFILL,
	CLP_STARTDATE DATE,
	CLP_ENDDATE DATE,
	CLP_PRETERMINATE_DATE DATE,
	CED_PRETERMINATE CHAR(1),
	PAYMENT DECIMAL(7,2),
	CPD_EMAIL VARCHAR(50))'));
	PREPARE CREATEQUERYSTMT FROM @CREATEQUERY;
	EXECUTE CREATEQUERYSTMT;
	SET @PAYMENTENTRY_TERM_INSERTQUERY = (SELECT CONCAT('INSERT INTO ',PAYMENT_ENTRY_TERMINATED_CUSTOMER,' 
	(CUSTOMER_ID,CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME,CUSTOMERNAME,CED_REC_VER,UNIT_NO,CLP_STARTDATE,CLP_ENDDATE,
	CLP_PRETERMINATE_DATE,CED_PRETERMINATE,PAYMENT,CPD_EMAIL)
	(SELECT CUSTOMER_ID,CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME,CUSTOMERNAME,CED_REC_VER,UNIT_NO,CLP_STARTDATE,CLP_ENDDATE,
	CLP_PRETERMINATE_DATE,CED_PRETERMINATE,CFD_AMOUNT,CPD_EMAIL FROM ',TERMINATED_CUSTOMER,')')); 
	PREPARE PAYMENTENTRY_TERM_INSERTQUERYSTMT FROM @PAYMENTENTRY_TERM_INSERTQUERY;
	EXECUTE PAYMENTENTRY_TERM_INSERTQUERYSTMT;
	SET @PAYMENTENTRY_TERM_INSERT_QUERY = (SELECT CONCAT('INSERT INTO ',PAYMENT_ENTRY_TERMINATED_CUSTOMER,'
	(CUSTOMER_ID,CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME,CUSTOMERNAME,CED_REC_VER,UNIT_NO,CLP_STARTDATE,CLP_ENDDATE,
	CLP_PRETERMINATE_DATE,CED_PRETERMINATE,PAYMENT,CPD_EMAIL)
	(SELECT CUSTOMER_ID,CUSTOMER_FIRST_NAME,CUSTOMER_LAST_NAME,CUSTOMERNAME,CED_REC_VER,UNIT_NO,CLP_STARTDATE,CLP_ENDDATE,
	CLP_PRETERMINATE_DATE,CED_PRETERMINATE,PAYMENT,CPD_EMAIL FROM ',PAYMENT_ACTIVE_TERMINATED_RECORDVERSION,')')); 
	PREPARE PAYMENTENTRY_TERM_INSERT_QUERY_STMT FROM @PAYMENTENTRY_TERM_INSERT_QUERY;
	EXECUTE PAYMENTENTRY_TERM_INSERT_QUERY_STMT;
	SET @PAYMENT_MAX_RECVER_DROP = (SELECT CONCAT('DROP TABLE IF EXISTS ',PAYMENT_MAX_RECVER,''));
	PREPARE PAYMENT_MAX_RECVER_DROP_STMT FROM @PAYMENT_MAX_RECVER_DROP;
	EXECUTE PAYMENT_MAX_RECVER_DROP_STMT;
	SET @TERMINATEDCUSTOMER_DROP = (SELECT CONCAT('DROP TABLE IF EXISTS ',TERMINATEDCUSTOMER,''));
	PREPARE TERMINATEDCUSTOMER_DROP_STMT FROM @TERMINATEDCUSTOMER_DROP;
	EXECUTE TERMINATEDCUSTOMER_DROP_STMT;
	SET @TERMINATED_CUSTOMER_DROP = (SELECT CONCAT('DROP TABLE IF EXISTS ',TERMINATED_CUSTOMER,''));
	PREPARE TERMINATED_CUSTOMER_DROP_STMT FROM @TERMINATED_CUSTOMER_DROP;
	EXECUTE TERMINATED_CUSTOMER_DROP_STMT;
	SET @T_ACTIVE_TERMINATED_RECVER_DROP = (SELECT CONCAT('DROP TABLE IF EXISTS ',T_ACTIVE_TERMINATED_RECVER,''));
	PREPARE T_ACTIVE_TERMINATED_RECVER_DROP_STMT FROM @T_ACTIVE_TERMINATED_RECVER_DROP;
	EXECUTE T_ACTIVE_TERMINATED_RECVER_DROP_STMT;
	SET @PAYMENT_ACTIVE_TERMINATED_RECORDVERSION_DROP = (SELECT CONCAT('DROP TABLE IF EXISTS ',PAYMENT_ACTIVE_TERMINATED_RECORDVERSION,''));
	PREPARE PAYMENT_ACTIVE_TERMINATED_RECORDVERSION_DROP_STMT FROM @PAYMENT_ACTIVE_TERMINATED_RECORDVERSION_DROP;
	EXECUTE PAYMENT_ACTIVE_TERMINATED_RECORDVERSION_DROP_STMT;
	COMMIT;
END;