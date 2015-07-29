DROP PROCEDURE IF EXISTS SP_TS_EMPLOYEE_AND_COMPANY_PROPERTIES_DETAILS_INSERT;
CREATE PROCEDURE SP_TS_EMPLOYEE_AND_COMPANY_PROPERTIES_DETAILS_INSERT(
IN LOGIN_ID VARCHAR(50),
IN FIRST_NAME CHAR(30),
IN LAST_NAME CHAR(30),
IN DOB DATE,
IN DESIGNATION VARCHAR(20),
IN MOBILE_NUMBER VARCHAR(10),
IN NEXT_KIN_NAME CHAR(30),
IN RELATIONHOOD CHAR(30),
IN ALT_MOBILE_NO VARCHAR(10),
IN LAPTOP_NUMBER VARCHAR(25),
IN CHARGER_NUMBER VARCHAR(25),
IN LAPTOP_BAG CHAR(1),
IN MOUSE CHAR(1),
IN DOOR_ACCESS CHAR(1),
IN ID_CARD CHAR(1),
IN HEADSET CHAR(1),
IN USERSTAMP VARCHAR(50),
OUT SUCCESS_FLAG INT)
BEGIN
	DECLARE ULDID INT;
	DECLARE USERSTAMP_ID INT;
	DECLARE EMPID INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET SUCCESS_FLAG=0;
	END;
	START TRANSACTION;
	IF(LAPTOP_NUMBER='')THEN
		SET LAPTOP_NUMBER=NULL;
	END IF;
	IF(CHARGER_NUMBER='')THEN
		SET CHARGER_NUMBER=NULL;
	END IF;
	IF(LAPTOP_BAG='')THEN
		SET LAPTOP_BAG=NULL;
	END IF;
	IF(MOUSE='')THEN
		SET MOUSE=NULL;
	END IF;
	IF(DOOR_ACCESS='')THEN
		SET DOOR_ACCESS=NULL;
	END IF;
	IF(ID_CARD='')THEN
		SET ID_CARD=NULL;
	END IF;
	IF(HEADSET='')THEN
		SET HEADSET=NULL;
	END IF;
	CALL SP_TS_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULD_ID);
	SET USERSTAMP_ID=@ULD_ID;
	CALL SP_TS_CHANGE_USERSTAMP_AS_ULDID(LOGIN_ID,@ULD_ID);
	SET ULDID=@ULD_ID;
	SET SUCCESS_FLAG=0;
	IF NOT EXISTS(SELECT DISTINCT ULD_ID FROM EMPLOYEE_DETAILS WHERE ULD_ID=ULDID)THEN
		INSERT INTO EMPLOYEE_DETAILS (ULD_ID,EMP_FIRST_NAME,EMP_LAST_NAME,EMP_DOB,EMP_DESIGNATION,EMP_MOBILE_NUMBER,EMP_NEXT_KIN_NAME,EMP_RELATIONHOOD,EMP_ALT_MOBILE_NO,EMP_USERSTAMP_ID) VALUES
		(ULDID,FIRST_NAME,LAST_NAME,DOB,DESIGNATION,MOBILE_NUMBER,NEXT_KIN_NAME,RELATIONHOOD,ALT_MOBILE_NO,USERSTAMP_ID);    
		SELECT DISTINCT EMP_ID INTO EMPID FROM EMPLOYEE_DETAILS WHERE ULD_ID=ULDID;
		IF NOT EXISTS(SELECT DISTINCT EMP_ID FROM COMPANY_PROPERTIES_DETAILS WHERE EMP_ID=EMPID)THEN
			INSERT INTO COMPANY_PROPERTIES_DETAILS (EMP_ID,CPD_LAPTOP_NUMBER,CPD_CHARGER_NUMBER,CPD_LAPTOP_BAG,CPD_MOUSE,CPD_DOOR_ACCESS,CPD_ID_CARD,CPD_HEADSET,ULD_ID) VALUES
			(EMPID,LAPTOP_NUMBER,CHARGER_NUMBER,LAPTOP_BAG,MOUSE,DOOR_ACCESS,ID_CARD,HEADSET,USERSTAMP_ID);
			SET SUCCESS_FLAG=1;
		END IF;
	END IF;
	COMMIT;
END;