-- VER 0.2 TRACKER NO:817 COMMENT #35 STARTDATE:06/05/2014 ENDDATE:06/05/2014 DESC: CHANGED TEMP TABLE FOR DYNAMIC PURPOSE DONE BY:RAJA
-- VER 0.1 TRACKER NO:595 COMMENT #39 STARTDATE:17/01/2014 ENDDATE:17/01/2014 DESC:SP FOR CHARTS GROSS REVENUES FOR PER UNIT. DONE BY:MANIKANDAN.S
DROP PROCEDURE IF EXISTS SP_CHARTS_GROSS_REVENUE_PERUNIT;
CREATE PROCEDURE SP_CHARTS_GROSS_REVENUE_PERUNIT(IN UNIT_NO INT,IN FROM_DATE VARCHAR(20),IN TO_DATE VARCHAR(20),IN USERSTAMP VARCHAR(50),OUT TEMPTBL_CHARTS_GROSS_REVENUE_PERUNIT TEXT)
BEGIN
DECLARE FROM_PERIOD_YEAR VARCHAR(20);
DECLARE FROM_PERIOD_MONTH VARCHAR(20);
DECLARE FROM_PERIOD_MONTHNO INTEGER;
DECLARE FINAL_FROM_DATE VARCHAR(20);

DECLARE TO_PERIOD_YEAR VARCHAR(20);
DECLARE TO_PERIOD_MONTH VARCHAR(20);
DECLARE TO_PERIOD_MONTHNO INTEGER;
DECLARE FINAL_TO_DATE VARCHAR(20);

DECLARE USERSTAMP_ID INT;
DECLARE CHARTS_GROSS_REVENUE_PERUNIT TEXT;
DECLARE TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT TEXT;
DECLARE TMPTBL_INTERMEDIATE_GROSS_REVENUE TEXT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
 ROLLBACK;
END;     
  
  IF (FROM_DATE IS NOT NULL) THEN
    
    SET FROM_PERIOD_YEAR    =(SELECT SUBSTRING_INDEX(FROM_DATE,'-',-1));-- SPLIT YEAR FOR PASSING FOR PERIOD
    SET FROM_PERIOD_MONTH   =(SELECT SUBSTRING(FROM_DATE,1,3));
    
    SET FROM_PERIOD_MONTHNO =(select month(str_to_date(FROM_PERIOD_MONTH,'%b')));-- GET MONTHNO FOR PASSING FOR PERIOD

    SET FINAL_FROM_DATE = CONCAT(FROM_PERIOD_YEAR,'-',FROM_PERIOD_MONTHNO,'-','01');
  ELSE
    SET FINAL_FROM_DATE   = CURDATE();
    SET FROM_PERIOD_YEAR  = YEAR(CURDATE());
    SET FROM_PERIOD_MONTHNO = MONTH(CURDATE());
  END IF;
  
  IF (TO_DATE IS NOT NULL) THEN
    
    SET TO_PERIOD_YEAR=(SELECT SUBSTRING_INDEX(TO_DATE,'-',-1));-- SPLIT YEAR FOR PASSING FOR PERIOD
    SET TO_PERIOD_MONTH=(SELECT SUBSTRING(TO_DATE,1,3));
    
    SET TO_PERIOD_MONTHNO=(select month(str_to_date(TO_PERIOD_MONTH,'%b')));-- GET MONTHNO FOR PASSING FOR PERIOD

    SET FINAL_TO_DATE = CONCAT(TO_PERIOD_YEAR,'-',TO_PERIOD_MONTHNO,'-','31');
  ELSE
    SET FINAL_TO_DATE = CONCAT(FROM_PERIOD_YEAR,'-',FROM_PERIOD_MONTHNO,'-','31');
  END IF;
  
--  TEMP TABLE NAME START
CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
SET USERSTAMP_ID=(SELECT @ULDID);
SET CHARTS_GROSS_REVENUE_PERUNIT=(SELECT CONCAT('TEMPTBL_CHARTS_GROSS_REVENUE_PERUNIT',SYSDATE()));
--  temp table name
SET CHARTS_GROSS_REVENUE_PERUNIT=(SELECT REPLACE(CHARTS_GROSS_REVENUE_PERUNIT,' ',''));
SET CHARTS_GROSS_REVENUE_PERUNIT=(SELECT REPLACE(CHARTS_GROSS_REVENUE_PERUNIT,'-',''));
SET CHARTS_GROSS_REVENUE_PERUNIT=(SELECT REPLACE(CHARTS_GROSS_REVENUE_PERUNIT,':',''));
SET TEMPTBL_CHARTS_GROSS_REVENUE_PERUNIT=(SELECT CONCAT(CHARTS_GROSS_REVENUE_PERUNIT,'_',USERSTAMP_ID));   
  
  -- CREATING MAIN TEMP TABLE FOR FINAL OUTPUT
  -- DROP TABLE IF EXISTS TEMP_CHARTS_GROSS_REVEUE_PERUNIT;
  SET @CREATE_TEMP_CHARTS_GROSS_REVENUE_PERUNIT=(SELECT CONCAT ('CREATE TABLE ',TEMPTBL_CHARTS_GROSS_REVENUE_PERUNIT,' (MONTH_YEAR VARCHAR(20),GROSS_REVENUE DECIMAL(20,2))'));
  PREPARE CREATE_TEMP_CHARTS_GROSS_REVENUE_PERUNIT_STMT FROM @CREATE_TEMP_CHARTS_GROSS_REVENUE_PERUNIT;
	EXECUTE CREATE_TEMP_CHARTS_GROSS_REVENUE_PERUNIT_STMT;
      
  --  TEMP TABLE NAME START
SET TMPTBL_INTERMEDIATE_GROSS_REVENUE=(SELECT CONCAT('TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT',SYSDATE()));
--  temp table name
SET TMPTBL_INTERMEDIATE_GROSS_REVENUE=(SELECT REPLACE(TMPTBL_INTERMEDIATE_GROSS_REVENUE,' ',''));
SET TMPTBL_INTERMEDIATE_GROSS_REVENUE=(SELECT REPLACE(TMPTBL_INTERMEDIATE_GROSS_REVENUE,'-',''));
SET TMPTBL_INTERMEDIATE_GROSS_REVENUE=(SELECT REPLACE(TMPTBL_INTERMEDIATE_GROSS_REVENUE,':',''));
SET TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT=(SELECT CONCAT(TMPTBL_INTERMEDIATE_GROSS_REVENUE,'_',USERSTAMP_ID));   
  
  -- CREATING INTERMEDIATE TEMP TABLE 
  -- DROP TABLE IF EXISTS TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE;
  SET @CREATE_TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT=(SELECT CONCAT ('CREATE TABLE ',TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT,' (MONTH_YEAR VARCHAR(20),GROSS_REVENUE DECIMAL(7,2),DATE DATE)'));
  PREPARE CREATE_TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT_STMT FROM @CREATE_TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT;
	EXECUTE CREATE_TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT_STMT;

  SET @INSERT_TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT=(SELECT CONCAT ('INSERT INTO ',TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT,' (MONTH_YEAR, GROSS_REVENUE, DATE) SELECT DATE_FORMAT(PD.PD_FOR_PERIOD,"%M-%Y"),PD.PD_AMOUNT, PD.PD_FOR_PERIOD FROM PAYMENT_DETAILS PD,UNIT UN WHERE PD.PD_FOR_PERIOD BETWEEN ','"',FINAL_FROM_DATE,'"',' AND ','"',FINAL_TO_DATE,'"',' AND PD.UNIT_ID = UN.UNIT_ID AND UN.UNIT_NO = ',UNIT_NO));
  PREPARE INSERT_TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT_STMT FROM @INSERT_TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT;
	EXECUTE INSERT_TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT_STMT;
    
  -- INSERTING INTO FINAL TEMP TABLE GROUPING BY MONTH AND YEAR
  SET @INSERT_TEMP_CHARTS_GROSS_REVENUE_PERUNIT =(SELECT CONCAT ('INSERT INTO ',TEMPTBL_CHARTS_GROSS_REVENUE_PERUNIT,' (MONTH_YEAR , GROSS_REVENUE) (SELECT MONTH_YEAR,SUM(COALESCE(GROSS_REVENUE,"0")) FROM ',TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT,' GROUP BY MONTH_YEAR ORDER BY DATE)'));
  PREPARE INSERT_TEMP_CHARTS_GROSS_REVENUE_PERUNIT_STMT FROM @INSERT_TEMP_CHARTS_GROSS_REVENUE_PERUNIT;
	EXECUTE INSERT_TEMP_CHARTS_GROSS_REVENUE_PERUNIT_STMT;
  
  SET @DROP_TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT=(SELECT CONCAT('DROP TABLE ',TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT));
	PREPARE DROP_TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT_STMT FROM @DROP_TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT;
	EXECUTE DROP_TMPTBL_INTERMEDIATE_GROSS_REVENUE_PERUNIT_STMT;
  -- DROP TABLE IF EXISTS INTERMEDIATE_GROSS_REVENUE_PERUNIT;
 COMMIT;
END;

/*
CALL SP_CHARTS_GROSS_REVENUE_PERUNIT(422,'November-2013','January-2014','admin@expatsint.com',@TEMPTBL_CHARTS_GROSS_REVENUE_PERUNIT);
SELECT @TEMPTBL_CHARTS_GROSS_REVENUE_PERUNIT;
SELECT * FROM TEMPTBL_CHARTS_GROSS_REVENUE_PERUNIT20140510180138_1;
*/