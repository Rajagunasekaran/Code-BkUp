DROP PROCEDURE IF EXISTS SP_CONFIG_SDATE_EDATE;
CREATE PROCEDURE SP_CONFIG_SDATE_EDATE(
IN UNITID INTEGER,
OUT S_CONFIGDATE DATE,
OUT E_CONFIGDATE DATE
)
BEGIN

DECLARE S_UNITMONTH INTEGER;
DECLARE S_UNIT_MONTH INTEGER;
DECLARE UNITSDATE DATE;
DECLARE STARTDATE DATE;
DECLARE S_CONFIG_YEAR INTEGER;
DECLARE S_CONFIG_MONTH INTEGER;
DECLARE S_CONFIG_DAY INTEGER;
DECLARE S_CONFIGMONTH INTEGER;

DECLARE E_UNITMONTH INTEGER;
DECLARE E_UNIT_MONTH INTEGER;
DECLARE UNITEDATE DATE;
DECLARE ENDDATE DATE;
DECLARE E_CONFIG_YEAR INTEGER;
DECLARE E_CONFIG_MONTH INTEGER;
DECLARE E_CONFIG_DAY INTEGER;
DECLARE E_CONFIGMONTH INTEGER;

SET UNITSDATE=(SELECT UD_START_DATE FROM UNIT_DETAILS WHERE UNIT_ID=UNITID);
SET STARTDATE=UNITSDATE;
SET S_UNITMONTH=(SELECT ECN_DATA FROM EXPENSE_CONFIGURATION WHERE ECN_ID=201);

SET UNITEDATE=(SELECT UD_END_DATE FROM UNIT_DETAILS WHERE UNIT_ID=UNITID);
SET ENDDATE=UNITEDATE;
SET E_UNITMONTH=(SELECT ECN_DATA FROM EXPENSE_CONFIGURATION WHERE ECN_ID=200);

SET S_UNIT_MONTH=0;
WHILE S_UNIT_MONTH<=S_UNITMONTH DO

	SET S_CONFIGDATE=(SELECT DATE_SUB(UNITSDATE,INTERVAL 1 MONTH));
	  IF S_UNIT_MONTH<S_UNITMONTH THEN
			SET S_CONFIGDATE=(SELECT LAST_DAY(S_CONFIGDATE));
			SET UNITSDATE=S_CONFIGDATE;
		END IF;
		IF S_UNIT_MONTH=S_UNITMONTH THEN
			SET S_CONFIG_YEAR=(SELECT YEAR(UNITSDATE));
			SET S_CONFIG_MONTH=(SELECT MONTH(UNITSDATE));
			SET S_CONFIG_DAY=(SELECT DAY(STARTDATE));
			SET S_CONFIGMONTH=(SELECT MONTH(STARTDATE));
  			IF LENGTH(S_CONFIG_MONTH)=1 THEN
  			  SET S_CONFIG_MONTH=(SELECT CONCAT('0',S_CONFIG_MONTH));
  			END IF;
  			IF LENGTH(S_CONFIG_DAY)=1 THEN
  			  SET S_CONFIG_DAY=(SELECT CONCAT('0',S_CONFIG_DAY));
  			END IF;
			
        IF  (S_CONFIG_MONTH=02) THEN
		IF(S_CONFIG_DAY BETWEEN 1 AND 28) THEN
		  SET S_CONFIGDATE=(SELECT CONCAT(S_CONFIG_YEAR,'-',S_CONFIG_MONTH,'-',S_CONFIG_DAY));
		  END IF;
		  IF (S_CONFIG_DAY=29) THEN
			IF(((S_CONFIG_YEAR) % 4 = 0 AND (S_CONFIG_YEAR) % 100 != 0) OR (S_CONFIG_YEAR) % 400 = 0)THEN
            SET S_CONFIGDATE=(SELECT LAST_DAY(UNITSDATE));         
          ELSE
  			  SET S_CONFIGDATE=(SELECT CONCAT(S_CONFIG_YEAR,'-',S_CONFIG_MONTH,'-28'));
          END IF;
        END IF;
		END IF;
  			IF (S_CONFIG_DAY=31) OR (S_CONFIG_DAY=30) THEN
  			  SET S_CONFIGDATE=(SELECT LAST_DAY(UNITSDATE));
  			ELSEIF((S_CONFIG_DAY<=29) AND (S_CONFIG_MONTH!=02)) THEN
  			  SET S_CONFIGDATE=(SELECT CONCAT(S_CONFIG_YEAR,'-',S_CONFIG_MONTH,'-',S_CONFIG_DAY));
  			END IF;
		END IF;
SET S_UNIT_MONTH=S_UNIT_MONTH+1;
END WHILE;
  
SET E_UNIT_MONTH=0;
WHILE  E_UNIT_MONTH<=E_UNITMONTH DO

  SET E_CONFIGDATE=(SELECT DATE_ADD(UNITEDATE,INTERVAL 1 MONTH));
  	IF E_UNIT_MONTH<E_UNITMONTH THEN
  		SET E_CONFIGDATE=(SELECT LAST_DAY(E_CONFIGDATE));
  		SET UNITEDATE=E_CONFIGDATE;
  	END IF;
  	IF E_UNIT_MONTH=E_UNITMONTH THEN
  		SET E_CONFIG_YEAR=(SELECT YEAR(UNITEDATE));
  		SET E_CONFIG_MONTH=(SELECT MONTH(UNITEDATE));
  		SET E_CONFIG_DAY=(SELECT DAY(ENDDATE));
  		SET E_CONFIGMONTH=(SELECT MONTH(ENDDATE));
    		IF LENGTH(E_CONFIG_MONTH)=1 THEN
    		  SET E_CONFIG_MONTH=(SELECT CONCAT('0',E_CONFIG_MONTH));
    		END IF;
    		IF LENGTH(E_CONFIG_DAY)=1 THEN
    		  SET E_CONFIG_DAY=(SELECT CONCAT('0',E_CONFIG_DAY));
    		END IF;
		        IF  (E_CONFIG_MONTH=02) THEN
		IF(E_CONFIG_DAY BETWEEN 1 AND 28) THEN
		  SET E_CONFIGDATE=(SELECT CONCAT(E_CONFIG_YEAR,'-',E_CONFIG_MONTH,'-',E_CONFIG_DAY));
		  END IF;
		  IF (E_CONFIG_DAY=29) THEN
			IF(((E_CONFIG_YEAR) % 4 = 0 AND (E_CONFIG_YEAR) % 100 != 0) OR (E_CONFIG_YEAR) % 400 = 0)THEN
            SET E_CONFIGDATE=(SELECT LAST_DAY(UNITEDATE));         
          ELSE
  			  SET E_CONFIGDATE=(SELECT CONCAT(E_CONFIG_YEAR,'-',E_CONFIG_MONTH,'-28'));
          END IF;
        END IF;
		END IF;
        
    		IF (E_CONFIG_DAY=31) OR (E_CONFIG_DAY=30) THEN
    		  SET E_CONFIGDATE=(SELECT LAST_DAY(UNITEDATE));
         
    		ELSEIF((E_CONFIG_DAY<=29) AND (E_CONFIG_MONTH!=02)) THEN
    		  SET E_CONFIGDATE=(SELECT CONCAT(E_CONFIG_YEAR,'-',E_CONFIG_MONTH,'-',E_CONFIG_DAY));

    		END IF;
  	END IF;
    
	SET E_UNIT_MONTH=E_UNIT_MONTH+1;
END WHILE;
END;

CALL SP_CONFIG_SDATE_EDATE(14,@S_CONFIGDATE,@E_CONFIGDATE);
SELECT @S_CONFIGDATE,@E_CONFIGDATE;