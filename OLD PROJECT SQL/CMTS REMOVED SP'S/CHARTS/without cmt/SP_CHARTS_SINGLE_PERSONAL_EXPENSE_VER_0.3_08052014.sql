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
  CALL SP_FORMAT_DATE(FROM_DATE,TO_DATE,@fd,@td);
  SELECT @fd INTO FINAL_FROM_DATE;
  SELECT @td INTO FINAL_TO_DATE;
  CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
  SET USERSTAMP_ID=(SELECT @ULDID);
  SET CHARTS_SINGLE_PERSONAL_EXPENSE=(SELECT CONCAT('TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE',SYSDATE()));
  SET CHARTS_SINGLE_PERSONAL_EXPENSE=(SELECT REPLACE(CHARTS_SINGLE_PERSONAL_EXPENSE,' ',''));
  SET CHARTS_SINGLE_PERSONAL_EXPENSE=(SELECT REPLACE(CHARTS_SINGLE_PERSONAL_EXPENSE,'-',''));
  SET CHARTS_SINGLE_PERSONAL_EXPENSE=(SELECT REPLACE(CHARTS_SINGLE_PERSONAL_EXPENSE,':',''));
  SET TEMP_CHARTS_SINGLE_PERSONAL_EXPENSE=(SELECT CONCAT(CHARTS_SINGLE_PERSONAL_EXPENSE,'_',USERSTAMP_ID));   
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