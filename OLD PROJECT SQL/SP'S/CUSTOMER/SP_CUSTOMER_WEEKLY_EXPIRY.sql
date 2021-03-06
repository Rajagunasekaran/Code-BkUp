-- VER 0.4-->startdate:05/05/2014 enddate:05/05/2014 description --> concat the userstamp id and sysdate created by -->raja
--> VER 0.3-->issue tracker no :797 comment no:#4 startdate:03/04/2014 enddate:03/04/2014 description --> REPLACED TABLENAME AND HEADERNAME created by -->SASIKALA.D
--> VER 0.2-->issue tracker no :636 comment no:#47 startdate:08/11/2013 enddate:08/11/2013 description --> changed sp name and changed temp table name inside select query created by -->Dhivya.A 
--VER 0.1 ISSUE NO:345 COMMENT NO:#312 START DATE:05/11/2013 ENDDATE:06/11/2013 DESC:SP FOR CUSTOMER WEEKLY EXPIRY DONE BY:DHIVYA.A

DROP PROCEDURE IF EXISTS SP_CUSTOMER_WEEKLY_EXPIRY;
CREATE PROCEDURE SP_CUSTOMER_WEEKLY_EXPIRY(IN WEEK INTEGER,IN USERSTAMP VARCHAR(50),OUT CUSTOMER_WEEKLY_EXPIRY TEXT)
BEGIN
DECLARE ENDDATE DATE;
DECLARE USERSTAMP_ID INT;
DECLARE TEMP_CUSTOMER_WEEKLY_EXPIRY TEXT;
DECLARE CUSTOMER_EXPIRY_FEE_TEMPTABLE TEXT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK; 
END;
START TRANSACTION;
SET ENDDATE=(SELECT DATE_ADD(CURDATE(), INTERVAL (WEEK*7) day));
-- TEMPORARY VIEW FOR GETTING CUSTOMER_ID AND MAX REC VER
CREATE OR REPLACE VIEW EXPIRY_MAXRECVER AS SELECT C1.CUSTOMER_ID,MAX(C1.CED_REC_VER) AS REC_VER FROM CUSTOMER_LP_DETAILS C1 WHERE C1.CLP_GUEST_CARD IS NULL AND IF(C1.CLP_PRETERMINATE_DATE IS NOT NULL,C1.CLP_STARTDATE<C1.CLP_PRETERMINATE_DATE,C1.CLP_STARTDATE)GROUP BY C1.CUSTOMER_ID;
--  TEMP TABLE NAME START
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID=(SELECT @ULDID);
SET TEMP_CUSTOMER_WEEKLY_EXPIRY=(SELECT CONCAT('CUSTOMER_WEEKLY_EXPIRY',SYSDATE()));
--  temp table name
SET TEMP_CUSTOMER_WEEKLY_EXPIRY=(SELECT REPLACE(TEMP_CUSTOMER_WEEKLY_EXPIRY,' ',''));
SET TEMP_CUSTOMER_WEEKLY_EXPIRY =(SELECT REPLACE(TEMP_CUSTOMER_WEEKLY_EXPIRY,'-',''));
SET TEMP_CUSTOMER_WEEKLY_EXPIRY =(SELECT REPLACE(TEMP_CUSTOMER_WEEKLY_EXPIRY,':',''));
SET CUSTOMER_WEEKLY_EXPIRY=(SELECT CONCAT(TEMP_CUSTOMER_WEEKLY_EXPIRY,'_',USERSTAMP_ID)); 
-- SET VARIABLE FOR TEMP_ALL_CUSTOMER_EXPIRY_LIST_FEE_DETAIL
-- SET CUSTOMER_EXPIRY_LIST =(SELECT @TEMP_ALL_CUSTOMER_EXPIRY_LIST_FEE_DETAIL20140503171448_1 )
CALL SP_ALL_CUSTOMER_EXPIRY_LIST_TEMP_FEE_DETAIL('expatsintegrated@gmail.com',@CUSTOMER_EXPIRY_FEE_TEMPTBLNAME,@FLAG);
SET CUSTOMER_EXPIRY_FEE_TEMPTABLE=(SELECT @CUSTOMER_EXPIRY_FEE_TEMPTBLNAME);
-- CREATE TEMPORARY TABLE FOR CUSTOMER_WEEKLY_EXPIRY;
SET @CREATE_CUSTOMER_WEEKLY_EXPIRY=(SELECT CONCAT('CREATE TABLE ',CUSTOMER_WEEKLY_EXPIRY,'(CUSTOMERFIRSTNAME VARCHAR(100),CUSTOMERLASTNAME VARCHAR(100),RECVER INTEGER,UNITNO INTEGER,ENDDATE DATE,PRETERMINATEDATE DATE,PAYMENT INTEGER)'));
PREPARE CUSTOMER_WEEKLY_EXPIRY_STMT FROM @CREATE_CUSTOMER_WEEKLY_EXPIRY;
EXECUTE CUSTOMER_WEEKLY_EXPIRY_STMT;
-- INSERT QUERY FOR TEMP_CUSTOMER_WEEK_EXPIRY
-- INSERT INTO TEMP_CUSTOMER_WEEKLY_EXPIRY
SET @INSERT_CUSTOMER_WEEKLY_EXPIRY=(SELECT CONCAT('INSERT INTO ',CUSTOMER_WEEKLY_EXPIRY,'(CUSTOMERFIRSTNAME,CUSTOMERLASTNAME,RECVER,UNITNO,ENDDATE,PRETERMINATEDATE,PAYMENT) SELECT C3.CUSTOMER_FIRST_NAME,C3.CUSTOMER_LAST_NAME,CTD.CED_REC_VER,U.UNIT_NO,CTD.CLP_ENDDATE,CTD.CLP_PRETERMINATE_DATE,E1.CC_PAYMENT_AMOUNT FROM CUSTOMER_LP_DETAILS CTD,CUSTOMER_ENTRY_DETAILS CED,EXPIRY_MAXRECVER E,',CUSTOMER_EXPIRY_FEE_TEMPTABLE,' E1,UNIT U,CUSTOMER C3 WHERE CED.CUSTOMER_ID=CTD.CUSTOMER_ID AND CED.CED_REC_VER=CTD.CED_REC_VER AND CTD.CLP_GUEST_CARD IS NULL AND E.CUSTOMER_ID=CED.CUSTOMER_ID AND E.CUSTOMER_ID=CTD.CUSTOMER_ID AND E.REC_VER=CED.CED_REC_VER AND E.REC_VER=CTD.CED_REC_VER AND CTD.CLP_TERMINATE IS NULL AND CED.CED_CANCEL_DATE IS NULL AND E1.CUSTOMER_ID=CED.CUSTOMER_ID AND E1.CUSTOMER_ID=CTD.CUSTOMER_ID AND E1.CUSTOMER_VER=CED.CED_REC_VER AND E1.CUSTOMER_VER=CTD.CED_REC_VER AND E.REC_VER=E1.CUSTOMER_VER AND E.CUSTOMER_ID=E1.CUSTOMER_ID AND U.UNIT_ID=CED.UNIT_ID AND C3.CUSTOMER_ID=CTD.CUSTOMER_ID AND C3.CUSTOMER_ID=CED.CUSTOMER_ID AND E.CUSTOMER_ID=C3.CUSTOMER_ID AND E1.CUSTOMER_ID=C3.CUSTOMER_ID AND IF(CTD.CLP_PRETERMINATE_DATE IS NOT NULL,CTD.CLP_PRETERMINATE_DATE=','"',ENDDATE,'"',',CTD.CLP_ENDDATE=','"',ENDDATE,'"',') GROUP BY CTD.CUSTOMER_ID  ORDER BY U.UNIT_NO,C3.CUSTOMER_FIRST_NAME'));
PREPARE INSERT_CUSTOMER_WEEKLY_EXPIRY_STMT FROM @INSERT_CUSTOMER_WEEKLY_EXPIRY;
EXECUTE INSERT_CUSTOMER_WEEKLY_EXPIRY_STMT;
DROP VIEW IF EXISTS EXPIRY_MAXRECVER;
COMMIT;
END;


CALL SP_CUSTOMER_WEEKLY_EXPIRY(1,'admin@expatsint.com',@CUSTOMER_WEEKLY_EXPIRY);
SELECT @CUSTOMER_WEEKLY_EXPIRY;

select * from CUSTOMER_WEEKLY_EXPIRY20140505172733_1



