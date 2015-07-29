-- VER 0.1 TRACKER NO:595 COMMENT #39 STARTDATE:22/01/2014 ENDDATE:22/01/2014 DESC:SP FOR CHARTS BIZ NET REVENUE FOR ALL UNIT. DONE BY:MANIKANDAN.S
-- VER 0.2 TRACKER NO:595 COMMENT # STARTDATE:29/01/2014 ENDDATE:29/01/2014 DESC:INCLUDED DATE FORMAT SP. DONE BY:MANIKANDAN.S
-- VER 0.3 TRACKER NO:595 COMMENT # STARTDATE:30/01/2014 ENDDATE:30/01/2014 DESC:FIXED ISSUE IN ADDING UNIT RENTAL + BIZ EXPENSE. DONE BY:MANIKANDAN.S
-- VER 0.4 TRACKER NO:817 COMMENT #35 STARTDATE:07/05/2014 ENDDATE:07/05/2014 DESC:CHANGES IN TEMP TABLE FOR DYANMIC PURPOSE DONE BY:BHAVANI.R
-- VER 0.5 ISSUE NO:817 COMMENT #35 STARTDATE:20/05/2014 ENDDATE:20/05/2014 DESC: DROP THE TEMP TABLES. DONE BY:RAJA

DROP PROCEDURE IF EXISTS SP_CHARTS_BIZ_NET_REVENUE_ALLUNIT;
CREATE PROCEDURE SP_CHARTS_BIZ_NET_REVENUE_ALLUNIT(IN FROM_DATE VARCHAR(20), IN TO_DATE VARCHAR(20),IN USERSTAMP VARCHAR(50),OUT CHARTS_BIZ_NET_REVENUE_ALLUNIT_TEMPTBL TEXT)
BEGIN
DECLARE FINAL_FROM_DATE VARCHAR(20);
DECLARE FINAL_TO_DATE VARCHAR(20);
DECLARE USERSTAMP_ID INT;
DECLARE BIZ_EXPENSE_ALLUNIT1_TMPTBL TEXT;
DECLARE CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL TEXT;
DECLARE CHARTS_BIZ_NET_REVENUE_ALLUNIT TEXT;
DECLARE CHARTS_GROSS_REVEUE_ALLUNIT TEXT;
DECLARE CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL TEXT;
DECLARE CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT_TMPTBL TEXT;
DECLARE CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT TEXT;
DECLARE CHARTS_BIZ_EXPENSE_ALLUNIT TEXT;
DECLARE TEMPTBL_UNIT_RENTAL TEXT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
 ROLLBACK;
END;     
  
-- TEMP TABLE NAME START
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID=(SELECT @ULDID);
	SET BIZ_EXPENSE_ALLUNIT1_TMPTBL=(SELECT CONCAT('TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1',SYSDATE()));
	SET CHARTS_BIZ_NET_REVENUE_ALLUNIT=(SELECT CONCAT('TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT',SYSDATE()));
	SET CHARTS_GROSS_REVEUE_ALLUNIT=(SELECT CONCAT('TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1',SYSDATE()));
	SET CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT=(SELECT CONCAT('TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1',SYSDATE()));
-- NAME FOR MAIN TEMP TABLE
	SET BIZ_EXPENSE_ALLUNIT1_TMPTBL=(SELECT REPLACE(BIZ_EXPENSE_ALLUNIT1_TMPTBL,' ',''));
	SET BIZ_EXPENSE_ALLUNIT1_TMPTBL=(SELECT REPLACE(BIZ_EXPENSE_ALLUNIT1_TMPTBL,'-',''));
	SET BIZ_EXPENSE_ALLUNIT1_TMPTBL=(SELECT REPLACE(BIZ_EXPENSE_ALLUNIT1_TMPTBL,':',''));
	SET CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL=(SELECT CONCAT(BIZ_EXPENSE_ALLUNIT1_TMPTBL,'_',USERSTAMP_ID)); 
-- NAME FOR INTERMEDIATE TEMP TABLE
	SET CHARTS_BIZ_NET_REVENUE_ALLUNIT=(SELECT REPLACE(CHARTS_BIZ_NET_REVENUE_ALLUNIT,' ',''));
	SET CHARTS_BIZ_NET_REVENUE_ALLUNIT=(SELECT REPLACE(CHARTS_BIZ_NET_REVENUE_ALLUNIT,'-',''));
	SET CHARTS_BIZ_NET_REVENUE_ALLUNIT=(SELECT REPLACE(CHARTS_BIZ_NET_REVENUE_ALLUNIT,':',''));
	SET CHARTS_BIZ_NET_REVENUE_ALLUNIT_TEMPTBL=(SELECT CONCAT(CHARTS_BIZ_NET_REVENUE_ALLUNIT,'_',USERSTAMP_ID));
-- NAME FOR INTERMEDIATE TEMP TABLE
	SET CHARTS_GROSS_REVEUE_ALLUNIT=(SELECT REPLACE(CHARTS_GROSS_REVEUE_ALLUNIT,' ',''));
	SET CHARTS_GROSS_REVEUE_ALLUNIT=(SELECT REPLACE(CHARTS_GROSS_REVEUE_ALLUNIT,'-',''));
	SET CHARTS_GROSS_REVEUE_ALLUNIT=(SELECT REPLACE(CHARTS_GROSS_REVEUE_ALLUNIT,':',''));
	SET CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL=(SELECT CONCAT(CHARTS_GROSS_REVEUE_ALLUNIT,'_',USERSTAMP_ID));
-- NAME FOR INTERMEDIATE TEMP TABLE
	SET CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT=(SELECT REPLACE(CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT,' ',''));
	SET CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT=(SELECT REPLACE(CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT,'-',''));
	SET CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT=(SELECT REPLACE(CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT,':',''));
	SET CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT_TMPTBL=(SELECT CONCAT(CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT,'_',USERSTAMP_ID));
--   TEMP TABLE NAME END 
  -- Format the input date into proper date format.
  CALL SP_FORMAT_DATE(FROM_DATE,TO_DATE,@fd,@td);
  SELECT @fd INTO FINAL_FROM_DATE;
  SELECT @td INTO FINAL_TO_DATE;
  
  -- BIZ EXPENSE 
  CALL SP_CHARTS_BIZ_EXPENSE_ALLUNIT(FROM_DATE, TO_DATE,USERSTAMP,@CHARTS_BIZ_EXPENSE_ALLUNIT_TMPTBL);
  SET CHARTS_BIZ_EXPENSE_ALLUNIT=(SELECT @CHARTS_BIZ_EXPENSE_ALLUNIT_TMPTBL);
   -- TOTAL BIZ EXPENSE WITHOUT UNIT RENTAL
  
  SET @CREATE_VIEW_TOTAL_BIZ_EXPENSE=(SELECT CONCAT('CREATE OR REPLACE VIEW VIEW_TOTAL_BIZ_EXPENSE AS (SELECT UNIT_NUMBER, SUM(COALESCE(CAR_PARK,'"0"'))+SUM(COALESCE(DIGITAL_VOICE,'"0"'))+ SUM(COALESCE(ELECTRICITY,'"0"'))+ SUM(COALESCE(FACILITY_USE,'"0"'))+ SUM(COALESCE(MOVE_IN_OUT,'"0"'))+ SUM(COALESCE(STARHUB,'"0"'))+ SUM(COALESCE(UNIT_EXPENSE,'"0"')) AS TOTAL_BIZ_EXP FROM ',CHARTS_BIZ_EXPENSE_ALLUNIT,' GROUP BY UNIT_NUMBER)'));
  PREPARE CREATE_VIEW_TOTAL_BIZ_EXPENSE_STMT FROM @CREATE_VIEW_TOTAL_BIZ_EXPENSE;
	EXECUTE CREATE_VIEW_TOTAL_BIZ_EXPENSE_STMT;
  
  -- GETTING UNIT RENTAL CALCULATED FOR ALL MONTHS BETWEEN FROM DATE AND TO DATE.VALUES WILL BE AVAILABLE IN TEMP_UNIT_RENTAL_ALLUNIT TABLE
	CALL SP_CHARTS_GET_UNIT_RENTAL_ALLUNIT(FINAL_FROM_DATE, FINAL_TO_DATE,USERSTAMP,@TEMPTBL_UNIT_RENTAL_ALLUNIT);
	SET TEMPTBL_UNIT_RENTAL=(SELECT @TEMPTBL_UNIT_RENTAL_ALLUNIT);

    SET @CREATE_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1=(SELECT CONCAT('CREATE TABLE ',CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL,'(UNIT_NUMBER SMALLINT(4) UNSIGNED ZEROFILL,TOTAL_BIZ_EXP DECIMAL(20,2))'));
	PREPARE CREATE_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1_STMT FROM @CREATE_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1;
	EXECUTE CREATE_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1_STMT;


   -- TOTAL BIZ EXPENSE WITH UNIT RENTAL
   
   	SET @INSERT_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1=(SELECT CONCAT('INSERT INTO ',CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL,' (UNIT_NUMBER , TOTAL_BIZ_EXP)SELECT UD.UNIT_NO , IFNULL(TB.TOTAL_BIZ_EXP,0) + IFNULL(UD.UD_PAYMENT, 0) FROM ',TEMPTBL_UNIT_RENTAL,' UD LEFT JOIN VIEW_TOTAL_BIZ_EXPENSE TB ON UD.UNIT_NO = TB.UNIT_NUMBER'));
		PREPARE INSERT_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1_STMT FROM @INSERT_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1;
		EXECUTE INSERT_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1_STMT;
		
      
    DROP VIEW IF EXISTS VIEW_TOTAL_BIZ_EXPENSE;
   
   /* GETTING GROSS REVENUE*/
   
   -- CREATING MAIN TEMP TABLE FOR FINAL OUTPUT
    SET @CREATE_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1=(SELECT CONCAT('CREATE TABLE ',CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL,'(ID INT NOT NULL AUTO_INCREMENT, UNIT_NUMBER SMALLINT(4) UNSIGNED ZEROFILL,GROSS_REVENUE DECIMAL(20,2), PRIMARY KEY (ID))'));
	PREPARE CREATE_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT FROM @CREATE_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1;
	EXECUTE CREATE_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT;
	
     -- CREATING INTERMEDIATE TEMP TABLE 
    SET @CREATE_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1=(SELECT CONCAT('CREATE TABLE ',CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT_TMPTBL,'(UNIT_NUMBER SMALLINT(4) UNSIGNED ZEROFILL,GROSS_REVENUE DECIMAL(7,2))'));
	PREPARE CREATE_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1_STMT FROM @CREATE_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1;
	EXECUTE CREATE_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1_STMT;
	
   		SET @INSERT_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1=(SELECT CONCAT('INSERT INTO ',CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT_TMPTBL,' (UNIT_NUMBER, GROSS_REVENUE )SELECT UN.UNIT_NO,PD.PD_AMOUNT FROM PAYMENT_DETAILS PD,UNIT UN ,UNIT_DETAILS UD WHERE UD.UD_OBSOLETE IS NULL AND UD.UD_NON_EI IS NULL AND UD.UD_END_DATE>CURDATE() AND UD.UNIT_ID=UN.UNIT_ID AND UN.UNIT_ID = PD.UNIT_ID AND PD.PD_FOR_PERIOD BETWEEN ','"',FINAL_FROM_DATE,'"', ' AND ','"',FINAL_TO_DATE,'"'));
		PREPARE INSERT_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1_STMT FROM @INSERT_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1;
		EXECUTE INSERT_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1_STMT;
    
  -- INSERTING INTO FINAL TEMP TABLE FOR GROSS REVENUE GROUPING BY UNIT NUMBER
  
     	SET @INSERT_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1=(SELECT CONCAT('INSERT INTO ',CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL,' (UNIT_NUMBER , GROSS_REVENUE)(SELECT UNIT_NUMBER,SUM(COALESCE(GROSS_REVENUE,'"0"')) FROM ',CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT_TMPTBL,' GROUP BY UNIT_NUMBER ORDER BY UNIT_NUMBER ASC)'));
		PREPARE INSERT_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT FROM @INSERT_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1;
		EXECUTE INSERT_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT;
  
  
		 SET @DROP_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1=(SELECT CONCAT('DROP TABLE IF EXISTS ',CHARTS_INTERMEDIATE_GROSS_REVEUE_ALLUNIT_TMPTBL));
		PREPARE DROP_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1_STMT FROM @DROP_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1;
		EXECUTE DROP_TEMP_INTERMEDIATE_CHARTS_GROSS_REVEUE1_STMT;

   
   /*CALCULATE BIZ NET REVENUE = GROSS - TOT BIZ EXP */
      SET @CREATE_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT=(SELECT CONCAT('CREATE TABLE ',CHARTS_BIZ_NET_REVENUE_ALLUNIT_TEMPTBL,'(UNIT_NUMBER SMALLINT(4) UNSIGNED ZEROFILL,REVENUE DECIMAL(20,2))'));
	PREPARE CREATE_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT_STMT FROM @CREATE_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT;
	EXECUTE CREATE_TEMP_CHARTS_BIZ_NET_REVENUE_ALLUNIT_STMT;

	SET @VW_BIZ_NET_REVENUE_ALLUNIT=(SELECT CONCAT('CREATE OR REPLACE VIEW VIEW_BIZ_NET_REVENUE_ALLUNIT AS
    SELECT t1.UNIT_NUMBER, (t1.GROSS_REVENUE-ifnull(t2.TOTAL_BIZ_EXP,0)) AS REVENUE FROM ',CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL,' t1
    LEFT JOIN ',CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL,' t2 ON t1.UNIT_NUMBER = t2.UNIT_NUMBER
    UNION
    SELECT t2.UNIT_NUMBER, (ifnull(t1.GROSS_REVENUE,0)-t2.TOTAL_BIZ_EXP) AS REVENUE FROM ',CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL,' t1
    RIGHT JOIN ',CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL,' t2 ON t1.UNIT_NUMBER = t2.UNIT_NUMBER'));
	PREPARE CREATE_VW_BIZ_NET_REVENUE_ALLUNIT_STMT FROM @VW_BIZ_NET_REVENUE_ALLUNIT;
	EXECUTE CREATE_VW_BIZ_NET_REVENUE_ALLUNIT_STMT;

   -- INSERTING THE FINAL DATA ASCENDING ORDER OF UNIT NUMBER
        SET @INSERT_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1=(SELECT CONCAT('INSERT INTO ',CHARTS_BIZ_NET_REVENUE_ALLUNIT_TEMPTBL,' (UNIT_NUMBER, REVENUE)(SELECT UNIT_NUMBER, REVENUE FROM VIEW_BIZ_NET_REVENUE_ALLUNIT ORDER BY UNIT_NUMBER)'));
		PREPARE INSERT_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT FROM @INSERT_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1;
		EXECUTE INSERT_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT;

   SET @DROP_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1=(SELECT CONCAT('DROP TABLE IF EXISTS ',CHARTS_GROSS_REVEUE_ALLUNIT_TEMPTBL));
		PREPARE DROP_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT FROM @DROP_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1;
		EXECUTE DROP_TEMP_CHARTS_GROSS_REVEUE_ALLUNIT1_STMT;
		
		SET @DROP_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1=(SELECT CONCAT('DROP TABLE IF EXISTS ',CHARTS_BIZ_EXPENSE_ALLUNIT1_TMPTBL));
		PREPARE DROP_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1_STMT FROM @DROP_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1;
		EXECUTE DROP_TEMP_CHARTS_BIZ_EXPENSE_ALLUNIT1_STMT;
    
    DROP VIEW IF EXISTS VIEW_BIZ_NET_REVENUE_ALLUNIT;
     
    SET @DROP_CHARTS_BIZ_EXPENSE_ALLUNIT=(SELECT CONCAT('DROP TABLE IF EXISTS ',CHARTS_BIZ_EXPENSE_ALLUNIT));
    PREPARE DROP_CHARTS_BIZ_EXPENSE_ALLUNIT_STMT FROM @DROP_CHARTS_BIZ_EXPENSE_ALLUNIT;
    EXECUTE DROP_CHARTS_BIZ_EXPENSE_ALLUNIT_STMT;
    
    SET @DROP_TEMPTBL_UNIT_RENTAL=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMPTBL_UNIT_RENTAL));
    PREPARE DROP_TEMPTBL_UNIT_RENTAL_STMT FROM @DROP_TEMPTBL_UNIT_RENTAL;
    EXECUTE DROP_TEMPTBL_UNIT_RENTAL_STMT;
    
 COMMIT;
END;
 
  /*
  CALL SP_CHARTS_BIZ_NET_REVENUE_ALLUNIT('December-2013' , 'December-2013','EXPATSINTEGRATED@GMAIL.COM',@CHARTS_BIZ_NET_REVENUE_ALLUNIT_TEMPTBL);
  SELECT @CHARTS_BIZ_NET_REVENUE_ALLUNIT_TEMPTBL;*/
   