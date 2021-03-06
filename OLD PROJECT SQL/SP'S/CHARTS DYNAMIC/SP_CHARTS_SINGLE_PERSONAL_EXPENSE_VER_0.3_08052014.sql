-- VERSION :0.3 TRACKER NO: 817 COMMENT #35 STARTDATE:08/05/2014 ENDDATE:08/05/2014 DESC: CHANGED TEMP TABLE FOR DYNAMIC PURPOSE DONE BY:RAJA
-- VERSION :0.2 TRACKER NO: 595, COMMENT: #  STARTDATE: 31-01-2014  ENDDATE: 31-01-2014. DESC: FIXED ISSUE, REMOVED IF CONDITION FOR CHECKING TABLE NAMES(ITS NOT REQUIRED SINCE THIS SP IS SPERATELY CALLED FOR EACH TABLE CHART). DONE BY: MANIKANDAN. S
-- VERSION :0.1 TRACKER NO: 595, COMMENT: #  STARTDATE: 30-01-2014  ENDDATE: 30-01-2014. DESC: CHARTS SINGLE PERSONAL EXPENSE. DONE BY: MANIKANDAN. S

DROP PROCEDURE IF EXISTS SP_CHARTS_SINGLE_PERSONAL_EXPENSE;
CREATE PROCEDURE SP_CHARTS_SINGLE_PERSONAL_EXPENSE
(IN FROM_DATE VARCHAR(20),
IN TO_DATE VARCHAR(20),
IN TABLENAME CHAR(100),
IN AMT TEXT,
IN INVOICE TEXT,
IN PR_ID TEXT,
IN USERSTAMP VARCHAR(50),
OUT TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE TEXT)
BEGIN
DECLARE FINAL_FROM_DATE VARCHAR(20);
DECLARE FINAL_TO_DATE VARCHAR(20);
DECLARE l_sql VARCHAR(4000);
DECLARE SQ VARCHAR(2000);
DECLARE USERSTAMP_ID INT;
DECLARE CHARTS_SINGLE_PERSONAL_EXPENSE TEXT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
  ROLLBACK;
END;
START TRANSACTION;

-- Format the input date into proper date format.
  CALL SP_FORMAT_DATE(FROM_DATE,TO_DATE,@fd,@td);
  SELECT @fd INTO FINAL_FROM_DATE;
  SELECT @td INTO FINAL_TO_DATE;
  
  --  TEMP TABLE NAME START
  CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
  SET USERSTAMP_ID=(SELECT @ULDID);
  SET CHARTS_SINGLE_PERSONAL_EXPENSE=(SELECT CONCAT('TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE',SYSDATE()));
  --  TEMP TABLE NAME
  SET CHARTS_SINGLE_PERSONAL_EXPENSE=(SELECT REPLACE(CHARTS_SINGLE_PERSONAL_EXPENSE,' ',''));
  SET CHARTS_SINGLE_PERSONAL_EXPENSE=(SELECT REPLACE(CHARTS_SINGLE_PERSONAL_EXPENSE,'-',''));
  SET CHARTS_SINGLE_PERSONAL_EXPENSE=(SELECT REPLACE(CHARTS_SINGLE_PERSONAL_EXPENSE,':',''));
  SET TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE=(SELECT CONCAT(CHARTS_SINGLE_PERSONAL_EXPENSE,'_',USERSTAMP_ID));   
  
-- DROP TABLE IF EXISTS TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE;
SET @CREATE_TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE=(SELECT CONCAT('CREATE TABLE ',TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE,'(MONTH_YEAR VARCHAR(20),AMOUNT DECIMAL(10,2))'));
PREPARE CREATE_TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE_STMT FROM @CREATE_TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE;
EXECUTE CREATE_TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE_STMT;
   
   SET l_sql= CONCAT_ws(' ','INSERT INTO ',TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE,' (MONTH_YEAR,AMOUNT) SELECT ','DATE_FORMAT(',INVOICE,',','''%M-%Y''','),','SUM( ',AMT,' ) FROM ',TABLENAME,' where ',INVOICE,' BETWEEN ''',FINAL_FROM_DATE,''' AND ''',FINAL_TO_DATE,''' GROUP BY YEAR(',INVOICE,'), MONTH(',INVOICE,') ASC');
   
   SET @sql=l_sql;
   PREPARE s1 FROM @sql;
   EXECUTE s1;
   DEALLOCATE PREPARE s1;
COMMIT;
END;
/*
CALL SP_CHARTS_SINGLE_PERSONAL_EXPENSE('January-2013','January-2014','EXPENSE_CAR','EC_AMOUNT','EC_INVOICE_DATE','EDE_ID','admin@expatsint.com',@TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE);
CALL SP_CHARTS_SINGLE_PERSONAL_EXPENSE('January-2009','January-2014','EXPENSE_STAFF_SALARY','ESS_SALARY_AMOUNT','ESS_INVOICE_DATE','ESS_ID','admin@expatsint.com',@TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE)
SELECT @TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE;
select * from TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE20140508154524_1;
*/;