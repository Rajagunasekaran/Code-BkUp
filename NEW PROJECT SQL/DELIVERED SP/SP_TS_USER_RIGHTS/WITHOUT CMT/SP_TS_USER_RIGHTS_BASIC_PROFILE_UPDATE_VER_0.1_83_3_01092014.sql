DROP PROCEDURE IF EXISTS SP_TS_USER_RIGHTS_BASIC_PROFILE_UPDATE;
CREATE PROCEDURE SP_TS_USER_RIGHTS_BASIC_PROFILE_UPDATE (
IN USERSTAMP VARCHAR(50), 
IN ROLE VARCHAR(255),
IN BASIC_ROLES VARCHAR(255),
IN MENUS TEXT(255),
OUT UR_FLAG INTEGER ) 
BEGIN
	DECLARE URCID INT;
	DECLARE STR_LEN1 INT DEFAULT 0;
	DECLARE STR_LEN2 INT DEFAULT 0;
	DECLARE STR_LEN3 INT DEFAULT 0;
	DECLARE SUBSTR_LEN1 INT DEFAULT 0;
	DECLARE SUBSTR_LEN2 INT DEFAULT 0;
	DECLARE SUBSTR_LEN3 INT DEFAULT 0;
	DECLARE MENUID INT;
	DECLARE COUNT_1 INT;
	DECLARE COUNT_2 INT;
	DECLARE BASICROLES_ID2 INT;
	DECLARE BASICROLES_ID1 INT;
	DECLARE BASICROLES_2 VARCHAR(255);  
	DECLARE BASICROLES_1 VARCHAR(255); 
	DECLARE BS_ID TEXT(100) DEFAULT '';
	DECLARE BASIC_ROLES1 VARCHAR(255);
	DECLARE BASIC_ROLES2 VARCHAR(255);
	DECLARE USERSTAMP_ID INTEGER(2);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
	END;
	SET AUTOCOMMIT = 0;
	START TRANSACTION;
	SET URCID = (SELECT URC_ID FROM USER_RIGHTS_CONFIGURATION WHERE URC_DATA = ROLE);
	CALL SP_TS_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID = (SELECT @ULDID);
	SET UR_FLAG=0;
	IF BASIC_ROLES IS NULL THEN
		SET BASIC_ROLES = '';
	END IF;
	SET BASIC_ROLES1 = BASIC_ROLES;
	DO_THIS_DELETE:
	LOOP
		SET STR_LEN1 = CHAR_LENGTH(BASIC_ROLES1); 
		SET BASICROLES_1 = SUBSTRING_INDEX(BASIC_ROLES1, ',', 1); 
		SET BASICROLES_ID1 = (SELECT URC_ID FROM USER_RIGHTS_CONFIGURATION WHERE URC_DATA = BASICROLES_1);
		SET BS_ID = CONCAT (BS_ID,"'",BASICROLES_ID1,"',");
		SET SUBSTR_LEN1 = CHAR_LENGTH(SUBSTRING_INDEX(BASIC_ROLES1, ',', 1)) + 2;
		SET BASIC_ROLES1 = MID(BASIC_ROLES1, SUBSTR_LEN1, STR_LEN1);
		IF BASIC_ROLES1 = '' THEN
			LEAVE DO_THIS_DELETE;
		END IF;
	END LOOP DO_THIS_DELETE;
	SET BS_ID = SUBSTRING(BS_ID,1,(CHAR_LENGTH(BS_ID)-1) );
	SET @DELETE_BASIC_ROLE_PROFILE = CONCAT('DELETE FROM BASIC_ROLE_PROFILE WHERE BRP_BR_ID NOT IN (', BS_ID ,') AND URC_ID =',URCID);
	PREPARE DELETE_BASIC_ROLE_PROFILE_STMT FROM @DELETE_BASIC_ROLE_PROFILE;
	EXECUTE DELETE_BASIC_ROLE_PROFILE_STMT;
	SET UR_FLAG=1;
	DO_THIS_FIRST:
	LOOP
		SET STR_LEN2 = CHAR_LENGTH(BASIC_ROLES); 
		SET BASICROLES_2 = SUBSTRING_INDEX(BASIC_ROLES, ',', 1); 
		SET BASICROLES_ID2 = (SELECT URC_ID FROM USER_RIGHTS_CONFIGURATION WHERE URC_DATA = BASICROLES_2);
		SELECT COUNT(BRP_ID) INTO COUNT_1 FROM BASIC_ROLE_PROFILE WHERE BRP_BR_ID = BASICROLES_ID2 AND URC_ID = URCID;
		IF (COUNT_1 = 0) THEN
			INSERT INTO BASIC_ROLE_PROFILE (URC_ID, BRP_BR_ID, ULD_ID) VALUES (URCID, BASICROLES_ID2, USERSTAMP_ID);
		END IF;
		SET UR_FLAG=1;
		SET SUBSTR_LEN2 = CHAR_LENGTH(SUBSTRING_INDEX(BASIC_ROLES, ',', 1)) + 2;
		SET BASIC_ROLES = MID(BASIC_ROLES, SUBSTR_LEN2, STR_LEN2);
		IF BASIC_ROLES = '' THEN
			LEAVE DO_THIS_FIRST;
		END IF;
	END LOOP DO_THIS_FIRST;
	IF MENUS IS NULL THEN
		SET MENUS = '';
	END IF;
	SET @DELETE_BASIC_MENU_PROFILE = CONCAT('DELETE FROM BASIC_MENU_PROFILE WHERE MP_ID NOT IN (',MENUS,') AND URC_ID =', URCID);
	PREPARE DELETE_BASIC_MENU_PROFILE_STMT FROM @DELETE_BASIC_MENU_PROFILE;
	EXECUTE DELETE_BASIC_MENU_PROFILE_STMT;
	SET UR_FLAG=1;
	DO_THIS:
	LOOP
		SET STR_LEN3 = CHAR_LENGTH(MENUS);
		SET MENUID = SUBSTRING_INDEX(MENUS, ',', 1);
		SELECT COUNT(BMP_ID) INTO COUNT_2 FROM BASIC_MENU_PROFILE WHERE MP_ID = MENUID AND URC_ID = URCID;
		IF (COUNT_2 = 0) THEN
			INSERT INTO BASIC_MENU_PROFILE (URC_ID, MP_ID, ULD_ID) VALUES (URCID, MENUID, USERSTAMP_ID);    
		END IF;
		SET UR_FLAG=1;
		SET SUBSTR_LEN3 = CHAR_LENGTH(SUBSTRING_INDEX(MENUS, ',', 1)) + 2;
		SET MENUS = MID(MENUS, SUBSTR_LEN3, STR_LEN3);
		IF MENUS = '' THEN
			LEAVE DO_THIS;
		END IF;
	END LOOP DO_THIS;
	COMMIT;
END;
CALL SP_TS_USER_RIGHTS_BASIC_PROFILE_UPDATE(USERSTAMP,ROLE,BASIC_ROLES,MENUS,UR_FLAG);