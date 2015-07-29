DROP PROCEDURE IF EXISTS SP_REPLACE_ID_TO_DATA;
CREATE PROCEDURE SP_REPLACE_ID_TO_DATA(IN USERSTAMP VARCHAR(50),OUT NEW_STR TEXT,OUT F INT)
BEGIN
SET @STR='UARD_PDID=1,2,4,3,4,5,6,7,8,9,10,ULD_ID=1';
SET NEW_STR=@STR;
UARD_NEW_LOOP : LOOP
  CALL SP_TS_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@STR,@VALUE,@REMAINING_STRING);
  SELECT @REMAINING_STRING INTO @STR;   
  CALL SP_TS_GET_SPECIAL_CHARACTER_SEPERATED_VALUES('=',@VALUE,@COLUMN_NAME,@COLUMN_VALUE);
  IF (@VALUE REGEXP '^[0-9]') THEN
    IF (@COLUMN_NAME REGEXP '^[0-9]' AND @COLUMN_VALUE IS NULL) THEN              
      SELECT PD_PROJECT_NAME INTO @PROJECTNAME FROM PROJECT_DETAILS WHERE PD_ID=@COLUMN_NAME;
  		SET @REPLACE_STRING=(SELECT CONCAT(',',@PROJECTNAME));
      SET @VALUE=(SELECT CONCAT(',',@VALUE));
  		SELECT REPLACE(NEW_STR,@VALUE,@REPLACE_STRING) INTO NEW_STR;
      SET F=1;
    END IF;
  END IF;
  IF (UPPER(@COLUMN_NAME)='UARD_PDID') THEN
		SELECT PD_PROJECT_NAME INTO @PROJECTNAME FROM PROJECT_DETAILS WHERE PD_ID=@COLUMN_VALUE;
		SET @REPLACE_STRING=CONCAT('PD_PROJECT_NAME=',@PROJECTNAME);
		SELECT REPLACE(NEW_STR,@VALUE,@REPLACE_STRING) INTO NEW_STR;
    SET F=1;
	END IF;
  IF (UPPER(@COLUMN_NAME)='ULD_ID') THEN
  	SELECT ULD_LOGINID INTO @LOGINID FROM USER_LOGIN_DETAILS WHERE ULD_ID=@COLUMN_VALUE;
  	SET @REPLACE_STRING=CONCAT('ULD_LOGINID=',@LOGINID);
  	SELECT REPLACE(NEW_STR,@VALUE,@REPLACE_STRING) INTO NEW_STR;
  END IF;
  IF (@STR IS NULL) THEN
  	LEAVE UARD_NEW_LOOP;
  END IF;
END LOOP;
END;
/*
CALL SP_REPLACE_ID_TO_DATA('dhandapani.sattanathan@ssomens.com',@NEW_STR,@F);
SELECT @NEW_STR,@F;
*/