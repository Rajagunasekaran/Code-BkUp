DROP PROCEDURE IF EXISTS SP_TS_EMAIL_TEMPLATE_INSERT;
CREATE PROCEDURE SP_TS_EMAIL_TEMPLATE_INSERT(
IN EMAIL_SCRIPT VARCHAR(100),
IN EMAIL_SUBJECT VARCHAR(1000),
IN EMAIL_BODY VARCHAR(1000),
IN USERSTAMP VARCHAR(50),
OUT SUCCESS_FLAG INTEGER)
BEGIN
	DECLARE USERSTAMP_ID INTEGER(2);
	DECLARE ETID INTEGER;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK;
	END;
	START TRANSACTION;
	SET SUCCESS_FLAG=0;
	CALL SP_TS_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID=@ULDID;
	IF(EMAIL_SCRIPT IS NOT NULL AND EMAIL_SUBJECT IS NOT NULL AND EMAIL_BODY IS NOT NULL AND USERSTAMP IS NOT NULL)THEN
		IF NOT EXISTS(SELECT ET_EMAIL_SCRIPT FROM EMAIL_TEMPLATE WHERE ET_EMAIL_SCRIPT=EMAIL_SCRIPT)THEN
			INSERT INTO EMAIL_TEMPLATE(ET_EMAIL_SCRIPT)VALUES(EMAIL_SCRIPT);
			SET SUCCESS_FLAG=1;
		END IF;
		SET ETID=(SELECT ET_ID FROM EMAIL_TEMPLATE WHERE ET_EMAIL_SCRIPT=EMAIL_SCRIPT);
		IF NOT EXISTS(SELECT ET_ID FROM EMAIL_TEMPLATE_DETAILS WHERE ET_ID=ETID)THEN
			INSERT INTO EMAIL_TEMPLATE_DETAILS(ET_ID,ETD_EMAIL_SUBJECT,ETD_EMAIL_BODY,ULD_ID)VALUES(ETID,EMAIL_SUBJECT,EMAIL_BODY,USERSTAMP_ID);
			SET SUCCESS_FLAG=1;
		END IF;
	END IF;
	COMMIT;
END;