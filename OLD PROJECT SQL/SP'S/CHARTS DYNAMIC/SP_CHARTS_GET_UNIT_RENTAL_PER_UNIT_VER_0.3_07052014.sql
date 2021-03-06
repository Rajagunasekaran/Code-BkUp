-- VER 0.3 TRACKER NO:817 COMMENT #35 STARTDATE:07/05/2014 ENDDATE:07/05/2014 DESC:CHANGED THE SP FOR DYNAMIC PURPOSE. DONE BY: RAJA.
-- VER 0.1 TRACKER NO:595 COMMENT #39 STARTDATE:23/01/2014 ENDDATE:23/01/2014 DESC:This UNIT RENTAL procedure is called in SP_CHARTS_UNIT_GROSS_AND_NET_REVENUE SP. DONE BY:MANIKANDAN.S
-- VER 0.2 TRACKER NO:595 COMMENT # STARTDATE:29/01/2014 ENDDATE:29/01/2014 DESC:MADE SOME MINOR MODIFICATIONS.CHANGED VARIABLE NAME. DONE BY:MANIKANDAN.S
DROP PROCEDURE IF EXISTS SP_GET_UNIT_RENTAL_PERUNIT;
CREATE PROCEDURE SP_GET_UNIT_RENTAL_PERUNIT(IN INPUT_UNIT_NO INT,IN FROM_DATE DATE,IN TO_DATE DATE,IN USERSTAMP VARCHAR(50),OUT TEMP_UNIT_RENTAL_PERUNIT TEXT)
BEGIN
DECLARE startdate VARCHAR(3);
DECLARE year      VARCHAR(10);
DECLARE numbmonths INT;
DECLARE li_ud_payment INT DEFAULT 0;
DECLARE unit_start_date DATE;
DECLARE unit_end_date DATE;
DECLARE i INT DEFAULT 0;
DECLARE unit_rental INT DEFAULT 0;
DECLARE mon INT DEFAULT 0;
DECLARE Rsdate DATE;
DECLARE Date DATE;
DECLARE USERSTAMP_ID INT;
DECLARE UNIT_RENTAL_PERUNIT TEXT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
 ROLLBACK;
END;
--   TEMP TABLE NAME START
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID=(SELECT @ULDID);
	SET UNIT_RENTAL_PERUNIT=(SELECT CONCAT('TEMP_UNIT_RENTAL_PERUNIT',SYSDATE()));
--    NAME FOR MAIN TEMP TABLE
	SET UNIT_RENTAL_PERUNIT=(SELECT REPLACE(UNIT_RENTAL_PERUNIT,' ',''));
	SET UNIT_RENTAL_PERUNIT=(SELECT REPLACE(UNIT_RENTAL_PERUNIT,'-',''));
	SET UNIT_RENTAL_PERUNIT=(SELECT REPLACE(UNIT_RENTAL_PERUNIT,':',''));
	SET TEMP_UNIT_RENTAL_PERUNIT=(SELECT CONCAT(UNIT_RENTAL_PERUNIT,'_',USERSTAMP_ID)); 
  
  -- TEMP TABLE FINAL, FOR SUM OF UNIT RENTAL ALL MONTH
  -- DROP TABLE IF EXISTS TEMP_UNIT_RENTAL_PERUNIT;
  SET @CREATE_TEMP_UNIT_RENTAL_PERUNIT=(SELECT CONCAT('CREATE TABLE ',TEMP_UNIT_RENTAL_PERUNIT,' (MONTH_YEAR VARCHAR(20), UD_PAYMENT INT)'));
  PREPARE CREATE_TEMP_UNIT_RENTAL_PERUNIT_STMT FROM @CREATE_TEMP_UNIT_RENTAL_PERUNIT;
  EXECUTE CREATE_TEMP_UNIT_RENTAL_PERUNIT_STMT;
  
  SET numbmonths =MONTH(TO_DATE) - MONTH(FROM_DATE) + (12 * ( YEAR(TO_DATE) - YEAR(FROM_DATE)))+1;

  select UD_PAYMENT, UD.UD_START_DATE, UD.UD_END_DATE INTO li_ud_payment,unit_start_date,unit_end_date 
  from UNIT_DETAILS UD,UNIT UN 
  WHERE UD.UNIT_ID=UN.UNIT_ID AND UN.UNIT_NO = INPUT_UNIT_NO;
  
  SET startdate = 01;
  SET year = YEAR(FROM_DATE);
  SET mon = MONTH(FROM_DATE);
  
  SET Date= concat(year,'-',mon,'-',startdate); 
      L2: LOOP
        
        SET unit_rental=0;          
         SET Rsdate = DATE_ADD(Date, INTERVAL i MONTH);
         
         IF(Rsdate BETWEEN DATE_FORMAT(unit_start_date,'%Y-%m-%01') AND DATE_FORMAT(unit_end_date,'%Y-%m-%31')) THEN
            SET unit_rental = li_ud_payment;
         END IF;
           
         SET@INSERT_TEMP_UNIT_RENTAL_PERUNIT=(SELECT CONCAT('INSERT INTO ',TEMP_UNIT_RENTAL_PERUNIT,' VALUES (date_format(','"',Rsdate,'"',',"%M-%Y"), ',unit_rental,')'));
         PREPARE INSERT_TEMP_UNIT_RENTAL_PERUNIT_STMT FROM @INSERT_TEMP_UNIT_RENTAL_PERUNIT;
         EXECUTE INSERT_TEMP_UNIT_RENTAL_PERUNIT_STMT;
         SET i = i+1;
         
         IF(i >= numbmonths) THEN
            LEAVE L2;
         END IF;  
      END LOOP L2;
 COMMIT;
END;
/*
CALL SP_GET_UNIT_RENTAL_PERUNIT(422,'2011-01-01','2012-12-31','admin@expatsint.com',@TEMP_UNIT_RENTAL_PERUNIT);
SELECT @TEMP_UNIT_RENTAL_PERUNIT;
select MONTH_YEAR, UD_PAYMENT from TEMP_UNIT_RENTAL_PERUNIT20140507105331_1;
*/