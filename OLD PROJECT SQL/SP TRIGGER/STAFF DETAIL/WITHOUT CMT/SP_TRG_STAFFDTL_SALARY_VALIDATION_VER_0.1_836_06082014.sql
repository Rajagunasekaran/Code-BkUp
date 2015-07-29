DROP PROCEDURE IF EXISTS SP_TRG_STAFFDTL_SALARY_VALIDATION;
CREATE PROCEDURE SP_TRG_STAFFDTL_SALARY_VALIDATION(
IN NEWCPFNUMBER VARCHAR(20),
IN NEW_CPF_AMOUNT INTEGER,
IN NEW_LEVY_AMOUNT INTEGER,
IN NEW_SALARY_AMOUNT INTEGER,
IN PROCESS TEXT)
BEGIN
	DECLARE ERRORMSG TEXT;
	DECLARE MESSAGE_TEXT VARCHAR(50);
	IF ((PROCESS = 'INSERT') OR (PROCESS = 'UPDATE')) THEN  
		IF (NEWCPFNUMBER IS NOT NULL) THEN
			IF ((LENGTH(NEWCPFNUMBER) < 9) OR (LENGTH(NEWCPFNUMBER) > 9)) THEN
				SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=171);
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT=ERRORMSG;
			END IF;
		END IF;
		IF (NEW_CPF_AMOUNT IS NOT NULL) THEN
			SET @CPF_AMT=(SELECT SUBSTRING_INDEX(NEW_CPF_AMOUNT, '.', 1));
			IF(LENGTH(@CPF_AMT)>5) THEN
				SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=567);
				SET ERRORMSG=(SELECT REPLACE (ERRORMSG,'[DIGIT]','5'));
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERRORMSG;
			END IF;
		END IF;
		IF (NEW_LEVY_AMOUNT IS NOT NULL) THEN
			SET @LEVY_AMT=(SELECT SUBSTRING_INDEX(NEW_LEVY_AMOUNT, '.', 1));
			IF(LENGTH(@LEVY_AMT)>5) THEN
				SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=567);
				SET ERRORMSG=(SELECT REPLACE (ERRORMSG,'[DIGIT]','5'));
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERRORMSG;
			END IF;
		END IF;
		IF (NEW_SALARY_AMOUNT IS NOT NULL) THEN
			SET @SALARY_AMT=(SELECT SUBSTRING_INDEX(NEW_SALARY_AMOUNT, '.', 1));
			IF(LENGTH(@SALARY_AMT)>5) THEN
				SET ERRORMSG=(SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID=567);
				SET ERRORMSG=(SELECT REPLACE (ERRORMSG,'[DIGIT]','5'));
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = ERRORMSG;
			END IF;
		END IF;
	END IF;
END;