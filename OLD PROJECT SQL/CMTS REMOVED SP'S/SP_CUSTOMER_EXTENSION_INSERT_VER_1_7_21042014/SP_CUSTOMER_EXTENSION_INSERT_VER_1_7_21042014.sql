DROP PROCEDURE IF EXISTS SP_CUSTOMER_EXTENSION_INSERT;
CREATE PROCEDURE SP_CUSTOMER_EXTENSION_INSERT(
IN EX_CUSTOMER_ID INTEGER,
IN EX_COMPANY_NAME VARCHAR(50),
IN EX_COMPANY_ADDR VARCHAR(50),
IN EX_POSTAL_CODE VARCHAR(6),
IN EX_OFFICE_NO VARCHAR(8),
IN EX_UNIT_NO SMALLINT(4),
IN EX_SAMEUNIT_FLAG CHAR(1),
IN EX_ROOM_TYPE VARCHAR(30),
IN EX_SD_STIME TIME,
IN EX_SD_ETIME TIME,
IN EX_ED_STIME TIME,
IN EX_ED_ETIME TIME,
IN EX_LEASE_PERIOD VARCHAR(30),
IN EX_QUARTERS DECIMAL(5,2),
IN EX_PROCESSING_WAIVED CHAR(1),
IN EX_PRORATED	CHAR(1),
IN EX_NOTICE_PERIOD TINYINT(1),
IN EX_NOTICE_START_DATE DATE,
IN EX_RENT DECIMAL(7,2),
IN EX_DEPOSIT DECIMAL(7,2),
IN EX_PROCESSING_FEE DECIMAL(7,2),
IN EX_AIRCON_FIXED_FEE DECIMAL(7,2),
IN EX_AIRCON_QUARTELY_FEE DECIMAL(7,2),
IN EX_ELECTRICITY_CAP DECIMAL(7,2),
IN EX_CHECKOUT_CLEANING_FEE DECIMAL(7,2),
IN EX_DRYCLEAN_FEE DECIMAL(7,2),
IN EX_CARD_NO TEXT,
IN EX_VALID_FROM DATE,
IN USERSTAMP VARCHAR(50),
IN EX_STARTDATE DATE,
IN EX_ENDDATE DATE,
IN EX_GUEST_CARD TEXT,
IN EX_NATIONALITY TEXT,
IN EX_MOBILE VARCHAR(8),
IN EX_INTL_MOBILE VARCHAR(20),
IN EX_EMAIL VARCHAR(40),
IN EX_PASSPORT_NO VARCHAR(15),
IN EX_PASSPORT_DATE DATE,
IN EX_DOB DATE,
IN EX_EP_NO VARCHAR(15),
IN EX_EP_DATE DATE,
IN EX_COMMENTS TEXT,
OUT EX_SUCCESSFLAG TEXT)
BEGIN
	DECLARE ROOM_TYPE_ID INT;
	DECLARE RE_UNIT_ID INT;
	DECLARE NATIONALITY_DETAILS INT;
	DECLARE REC_VER INT;
	DECLARE TEMP_ACCESS_CARD TEXT;
	DECLARE ACCESS_CARD_NO INTEGER(7);
	DECLARE ACCESS_POSITION INTEGER;
	DECLARE ACCESS_LOCATION INTEGER;
	DECLARE ACCESS_LENGTH INTEGER;
	DECLARE GUEST_ACCESS_LENGTH INTEGER;
	DECLARE GUEST_FLAG CHAR(1);
	DECLARE FLAG CHAR(1);
	DECLARE USERSTAMP_ID INTEGER(2);
	DECLARE CURRENT_RV INT DEFAULT 0;
	DECLARE MIN_CRV INT DEFAULT 0;
	DECLARE MAX_CRV INT DEFAULT 0;
	DECLARE RVCOUNT INT DEFAULT 0;
	DECLARE EX_ACTIVEFLAG CHAR(1);
	DECLARE EX_LOSTFLAG CHAR(1);
	DECLARE EX_INVENTORYFLAG CHAR(1);
	DECLARE EX_ACTIVECARD_COUNT INTEGER;
	DECLARE LOCATION INTEGER;
	DECLARE CUSTOMER_LENGTH INTEGER;
	DECLARE EXACTIVECARDNO INTEGER;
	DECLARE UASDID INTEGER;
	DECLARE ECDID INTEGER;
	DECLARE PRETERMINATE VARCHAR(15);
	DECLARE OLDPRETERMINATE TEXT;
	DECLARE NEWPRETERMINATE TEXT;
	DECLARE OLD_CCDID INTEGER;
    DECLARE OLD_COMPANYNAME TEXT;
    DECLARE OLD_COMPANYADDR TEXT;
	DECLARE OLD_POSTALCODE TEXT;
	DECLARE OLD_OFFICENO TEXT;
    DECLARE NEW_COMPANYNAME TEXT;
    DECLARE NEW_COMPANYADDR TEXT;
	DECLARE NEW_POSTALCODE TEXT;
	DECLARE NEW_OFFICENO TEXT;
    DECLARE OLD_COMPANYTABLEDETAILS TEXT;
    DECLARE NEW_COMPANYTABLEDETAILS TEXT;
    DECLARE COMPANY_HEADERNAME TEXT;
    DECLARE CCD_LENGTH INTEGER;
    DECLARE OLDCOMPANYPOSITION INTEGER;
    DECLARE OLD_COMPANYS TEXT;
    DECLARE NEWCOMPANYPOSITION INTEGER;
    DECLARE NEW_COMPANYS TEXT;
    DECLARE COMPANYHEADPOSITION INTEGER;
    DECLARE COMPANYHEADNAME TEXT;
    DECLARE NEWCOMPANYRECORDS TEXT ;
    DECLARE OLDCOMPANYRECORDS TEXT ;
    DECLARE COMPANYHEADERNAMES TEXT;
    DECLARE CUSTCOMPANY_ID VARCHAR(30);
    DECLARE OLD_COMPANYDTL TEXT;
    DECLARE NEW_COMPANYDTL TEXT;
    DECLARE CUSTCOMPANYHEADERNAME TEXT;
    DECLARE COMPANY_LOCATION INTEGER;
	DECLARE OLD_CPDID INTEGER;
	DECLARE OLD_NCID TEXT;
	DECLARE OLD_MOBILE TEXT;
	DECLARE OLD_INTL_MOBILE TEXT;
	DECLARE OLD_EMAIL TEXT;
	DECLARE OLD_PASSPORTNO TEXT;
	DECLARE OLD_PASSPORTDATE TEXT;
	DECLARE OLD_DOB TEXT;
	DECLARE OLD_EPNO TEXT;
	DECLARE OLD_EPDATE TEXT;
	DECLARE OLD_COMMENTS TEXT;
    DECLARE NEW_NCID TEXT;
    DECLARE NEW_MOBILE TEXT;
	DECLARE NEW_INTL_MOBILE TEXT;
	DECLARE NEW_EMAIL TEXT;
	DECLARE NEW_PASSPORTNO TEXT;
	DECLARE NEW_PASSPORTDATE TEXT;
	DECLARE NEW_DOB TEXT;
	DECLARE NEW_EPNO TEXT;
	DECLARE NEW_EPDATE TEXT;
	DECLARE NEW_COMMENTS TEXT;
    DECLARE OLD_PERSONALTABLEDETAILS TEXT;
    DECLARE NEW_PERSONALTABLEDETAILS TEXT;
    DECLARE PERSONAL_HEADERNAME TEXT;
    DECLARE CPD_LENGTH INTEGER;
    DECLARE OLDPERSONALPOSITION INTEGER;
    DECLARE OLD_CUSTOMERPERSONALS TEXT;
    DECLARE NEWPERSONALPOSITION INTEGER;
    DECLARE NEW_CUSTOMERPERSONALS TEXT;
    DECLARE PERSONALHEADPOSITION INTEGER;
    DECLARE PERSONALHEADNAME TEXT;
    DECLARE NEWPERSONALRECORDS TEXT ;
    DECLARE OLDPERSONALRECORDS TEXT ;
    DECLARE PERSONALHEADERNAMES TEXT;
    DECLARE CUSTPERSONAL_ID VARCHAR(30);
    DECLARE OLD_PERSONALDTL TEXT;
    DECLARE NEW_PERSONALDTL TEXT;
    DECLARE CUSTPERSONALHEADERNAME TEXT;
    DECLARE PERSONAL_LOCATION INTEGER;
	DECLARE MINID INTEGER;
	DECLARE MAXID INTEGER;
	DECLARE OLDRECVERFEE TEXT;
    DECLARE NEWRECVERFEE TEXT;
    DECLARE MAX_FEE_ID INTEGER;
    DECLARE MIN_FEE_ID INTEGER;
    DECLARE OLDRECVERENTRY TEXT;
    DECLARE NEWRECVERENTRY TEXT;
    DECLARE MIN_ENTRY_ID INTEGER;
    DECLARE MAX_ENTRY_ID INTEGER;
    DECLARE OLDRECVERLP TEXT;
    DECLARE NEWRECVERLP TEXT;
    DECLARE MIN_LP_ID INTEGER;
    DECLARE MAX_LP_ID INTEGER;
    DECLARE CCDID INTEGER;
    DECLARE THID INTEGER;
    DECLARE CEDID INTEGER;
	DECLARE CLPID INTEGER;
	DECLARE CFDID INTEGER;
    DECLARE EX_PRETERM_FLAG INT DEFAULT 0;
	DECLARE MINLPID INT DEFAULT 0;
	DECLARE MAXLPID INT DEFAULT 0;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK; 
		SET EX_SUCCESSFLAG = 0;
	END;
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID = (SELECT @ULDID);
	IF EX_COMPANY_NAME='' THEN
		SET EX_COMPANY_NAME=NULL;
	END IF;
	IF EX_COMPANY_ADDR='' THEN
		SET EX_COMPANY_ADDR=NULL;
	END IF;
	IF EX_POSTAL_CODE='' THEN
		SET EX_POSTAL_CODE=NULL;
	END IF;
	IF EX_OFFICE_NO='' THEN
		SET EX_OFFICE_NO=NULL;
	END IF;
	IF EX_PROCESSING_WAIVED='' THEN
		SET EX_PROCESSING_WAIVED=NULL;
	END IF;
	IF EX_PRORATED='' THEN
		SET EX_PRORATED=NULL;
	END IF;
	IF EX_NOTICE_PERIOD='' THEN
		SET EX_NOTICE_PERIOD=NULL;
	END IF;
	IF EX_ROOM_TYPE='' THEN
		SET EX_ROOM_TYPE=NULL;
	END IF;
	IF EX_COMMENTS='' THEN
		SET EX_COMMENTS=NULL;
	END IF;
	IF EX_CARD_NO='' THEN
		SET EX_CARD_NO=NULL;
	END IF;
	IF EX_GUEST_CARD='' THEN
		SET EX_GUEST_CARD=NULL;
	END IF;
	IF EX_MOBILE='' THEN
		SET EX_MOBILE=NULL;
	END IF;
	IF EX_INTL_MOBILE='' THEN
		SET EX_INTL_MOBILE=NULL;
	END IF;
	IF EX_PASSPORT_NO='' THEN
		SET EX_PASSPORT_NO=NULL;
	END IF;
	IF EX_EP_NO='' THEN
		SET EX_EP_NO=NULL;
	END IF;
	IF EX_SAMEUNIT_FLAG='' THEN
		SET EX_SAMEUNIT_FLAG=NULL;
	END IF;
	SET ROOM_TYPE_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE URTD_ID=(SELECT URTD_ID FROM UNIT_ROOM_TYPE_DETAILS WHERE URTD_ROOM_TYPE=EX_ROOM_TYPE) AND UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=EX_UNIT_NO));
	SET RE_UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=EX_UNIT_NO);
	SET NATIONALITY_DETAILS=(SELECT NC_ID FROM NATIONALITY_CONFIGURATION WHERE NC_DATA=EX_NATIONALITY);
	SET REC_VER=(SELECT MAX(CED_REC_VER) FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID);
	SET FLAG='X';
	SET CURRENT_RV=(SELECT CED_REC_VER FROM VW_EXTENSION_CUSTOMER WHERE CUSTOMER_ID=EX_CUSTOMER_ID);
	START TRANSACTION;
	SET EX_SUCCESSFLAG='';
	SET EX_ACTIVECARD_COUNT = 0;
	SET CUSTOMER_LENGTH = 1;
	SET @TEMP_EX_CARD_NO = EX_CARD_NO;
	IF(EX_CARD_NO IS NOT NULL AND EX_SAMEUNIT_FLAG IS NULL)THEN
		DROP TABLE IF EXISTS TEMP_EXTENSION_CARD_NO;
		CREATE TABLE TEMP_EXTENSION_CARD_NO(
		EX_ID INTEGER AUTO_INCREMENT,
		EX_CARDNO INTEGER(7),
		EX_ACTIVE CHAR(1),
		EX_LOST CHAR(1),
		EX_INVENTORY CHAR(1),
		PRIMARY KEY(EX_ID));
		MAIN_LOOP : LOOP
			CALL SP_GET_SPECIAL_CHARACTER_SEPERATED_VALUES(',',@TEMP_EX_CARD_NO,@VALUE,@REMAINING_STRING);
			SELECT @VALUE INTO ACCESS_CARD_NO;
			SELECT @REMAINING_STRING INTO @TEMP_EX_CARD_NO;
			SET EX_ACTIVEFLAG = (SELECT UASD_ACCESS_ACTIVE FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO);
			SET EX_LOSTFLAG = (SELECT UASD_ACCESS_LOST FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO);
			SET EX_INVENTORYFLAG = (SELECT UASD_ACCESS_INVENTORY FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO);
			INSERT INTO TEMP_EXTENSION_CARD_NO(EX_CARDNO,EX_ACTIVE,EX_LOST,EX_INVENTORY) VALUES(ACCESS_CARD_NO,EX_ACTIVEFLAG,EX_LOSTFLAG,EX_INVENTORYFLAG);
			IF @TEMP_EX_CARD_NO IS NULL THEN
				LEAVE  MAIN_LOOP;
			END IF;
		END LOOP;
		SET EX_ACTIVECARD_COUNT = (SELECT COUNT(*) FROM TEMP_EXTENSION_CARD_NO WHERE EX_ACTIVE IS NOT NULL OR EX_LOST IS NOT NULL);
	END IF;
	IF(EX_ACTIVECARD_COUNT>0) THEN
		SET MINID = (SELECT MIN(EX_ID) FROM TEMP_EXTENSION_CARD_NO);
		SET MAXID = (SELECT MAX(EX_ID) FROM TEMP_EXTENSION_CARD_NO);
		WHILE (MINID <= MAXID)DO
			SET EXACTIVECARDNO = (SELECT EX_CARDNO FROM TEMP_EXTENSION_CARD_NO WHERE EX_ID = MINID AND (EX_ACTIVE IS NOT NULL OR EX_LOST IS NOT NULL));
			IF (EXACTIVECARDNO IS NOT NULL)THEN
				SET EX_SUCCESSFLAG = (SELECT CONCAT(EX_SUCCESSFLAG,',',EXACTIVECARDNO));
			END IF;
			SET MINID = MINID+1;
		END WHILE;
		SET LOCATION=(SELECT LOCATE(',', EX_SUCCESSFLAG,CUSTOMER_LENGTH));
		SET EX_SUCCESSFLAG=(SELECT SUBSTRING(EX_SUCCESSFLAG,LOCATION+1));
		SET EX_SUCCESSFLAG = (SELECT CONCAT(EX_SUCCESSFLAG, ' - ACTIVE CARD(S)SHLD NOT BE ASSIGNED'));
	END IF;
	IF(EX_ACTIVECARD_COUNT=0)THEN
		SET RVCOUNT=(SELECT COUNT(*) FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID);
		IF RVCOUNT>1 THEN
			SET MIN_CRV=(CURRENT_RV+1);
			SET MAX_CRV=REC_VER;
				IF (SELECT COUNT(*) FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=MIN_CRV AND UNIT_ID=RE_UNIT_ID)>0 THEN
					SET EX_PRETERM_FLAG=1;
				END IF;
			WHILE MAX_CRV>=MIN_CRV DO
					DROP TABLE IF EXISTS TEMP_EXTN_TICKLER_LP_DTS;
					CREATE TABLE TEMP_EXTN_TICKLER_LP_DTS(LPID INTEGER NOT NULL);
					SET CFDID=(SELECT CFD_ID FROM CUSTOMER_FEE_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=MAX_CRV);
					SET CEDID=(SELECT CED_ID FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=MAX_CRV);
					SET OLDRECVERFEE=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CFD_ID=',CFDID,',','CED_REC_VER=',MAX_CRV)));
					SET NEWRECVERFEE=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CED_REC_VER=',MAX_CRV+1)));
					INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_FEE_DETAILS'),OLDRECVERFEE,NEWRECVERFEE,USERSTAMP_ID,EX_CUSTOMER_ID);
					SET EX_SUCCESSFLAG=1;	
					UPDATE CUSTOMER_FEE_DETAILS SET CED_REC_VER=(MAX_CRV+1) WHERE CED_REC_VER=MAX_CRV AND CUSTOMER_ID=EX_CUSTOMER_ID;
					SET EX_SUCCESSFLAG=1;
					INSERT INTO TEMP_EXTN_TICKLER_LP_DTS (SELECT CLP_ID FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=MAX_CRV);
					SET MINLPID=(SELECT MIN(LPID) FROM TEMP_EXTN_TICKLER_LP_DTS);
					SET MAXLPID=(SELECT MAX(LPID) FROM TEMP_EXTN_TICKLER_LP_DTS);
					SET NEWRECVERLP=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CED_REC_VER=',MAX_CRV+1)));
					WHILE(MINLPID<=MAXLPID)DO					
						SET OLDRECVERLP=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CLP_ID=',MINLPID,',','CED_REC_VER=',MAX_CRV)));						
						INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_LP_DETAILS'),OLDRECVERLP,NEWRECVERLP,USERSTAMP_ID,EX_CUSTOMER_ID);
						SET EX_SUCCESSFLAG=1;
						SET MINLPID=MINLPID+1;
					END WHILE;
					UPDATE CUSTOMER_LP_DETAILS SET CED_REC_VER=(MAX_CRV+1) WHERE CED_REC_VER=MAX_CRV AND CUSTOMER_ID=EX_CUSTOMER_ID;
					SET EX_SUCCESSFLAG=1;
					SET OLDRECVERENTRY=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CED_ID=',CEDID,',','CED_REC_VER=',MAX_CRV)));
					SET NEWRECVERENTRY=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CED_REC_VER=',MAX_CRV+1)));
					INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ENTRY_DETAILS'),OLDRECVERENTRY,NEWRECVERENTRY,USERSTAMP_ID,EX_CUSTOMER_ID);
					SET EX_SUCCESSFLAG=1;
					UPDATE CUSTOMER_ENTRY_DETAILS SET CED_REC_VER=(MAX_CRV+1) WHERE CED_REC_VER=MAX_CRV AND CUSTOMER_ID=EX_CUSTOMER_ID;
					SET EX_SUCCESSFLAG=1;
				SET MAX_CRV=MAX_CRV-1;
			END WHILE;
			SET REC_VER=CURRENT_RV;
		END IF;
		SET CUSTCOMPANY_ID = '';
		SET OLD_CCDID = (SELECT CCD_ID FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		SET OLD_COMPANYNAME = (SELECT CCD_COMPANY_NAME FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		IF(OLD_COMPANYNAME IS NULL)THEN
			SET OLD_COMPANYNAME = 'null';
		END IF;
		SET OLD_COMPANYADDR = (SELECT CCD_COMPANY_ADDR FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		IF(OLD_COMPANYADDR IS NULL)THEN
			SET OLD_COMPANYADDR = 'null';
		END IF;
		SET OLD_POSTALCODE = (SELECT CCD_POSTAL_CODE FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		IF(OLD_POSTALCODE IS NULL)THEN
			SET OLD_POSTALCODE = 'null';
		END IF;
		SET OLD_OFFICENO = (SELECT CCD_OFFICE_NO FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		IF(OLD_OFFICENO IS NULL)THEN
			SET OLD_OFFICENO = 'null';
		END IF;
		SET NEW_COMPANYNAME = EX_COMPANY_NAME;
		IF(NEW_COMPANYNAME IS NULL)THEN
			SET NEW_COMPANYNAME = 'null';
		END IF;
		SET NEW_COMPANYADDR = EX_COMPANY_ADDR;
		IF(NEW_COMPANYADDR IS NULL)THEN
			SET NEW_COMPANYADDR = 'null';
		END IF;
		SET NEW_POSTALCODE = EX_POSTAL_CODE;
		IF(NEW_POSTALCODE IS NULL)THEN
			SET NEW_POSTALCODE = 'null';
		END IF;
		SET NEW_OFFICENO = EX_OFFICE_NO;
		IF(NEW_OFFICENO IS NULL)THEN
			SET NEW_OFFICENO = 'null';
		END IF;
		SET COMPANYHEADERNAMES = 'CCD_ID,CCD_COMPANY_NAME,CCD_COMPANY_ADDR,CCD_POSTAL_CODE,CCD_OFFICE_NO';
		SET OLD_COMPANYTABLEDETAILS = (SELECT CONCAT(OLD_CCDID,'^','^',OLD_COMPANYNAME,'^','^',OLD_COMPANYADDR,'^','^',OLD_POSTALCODE,'^','^',OLD_OFFICENO));
		SET NEW_COMPANYTABLEDETAILS = (SELECT CONCAT(OLD_CCDID,'^','^',NEW_COMPANYNAME,'^','^',NEW_COMPANYADDR,'^','^',NEW_POSTALCODE,'^','^',NEW_OFFICENO));
		IF(OLD_COMPANYTABLEDETAILS != NEW_COMPANYTABLEDETAILS)THEN
			SET OLDCOMPANYRECORDS = OLD_COMPANYTABLEDETAILS;
			SET NEWCOMPANYRECORDS = NEW_COMPANYTABLEDETAILS;
			SET COMPANYHEADNAME = COMPANYHEADERNAMES;
			SET OLD_COMPANYS = (SELECT CONCAT('CCD_ID=',OLD_CCDID));
			SET NEW_COMPANYS = '';
			SET CCD_LENGTH = 1;
			loop_label : LOOP
				SET OLDCOMPANYPOSITION = (SELECT LOCATE('^^',OLDCOMPANYRECORDS,CCD_LENGTH));
				IF (OLDCOMPANYPOSITION=0) THEN
					SET OLD_COMPANYDTL = OLDCOMPANYRECORDS;
				ELSE
					SET OLD_COMPANYDTL =(SELECT SUBSTRING(OLDCOMPANYRECORDS,CCD_LENGTH,OLDCOMPANYPOSITION-1));
					SET OLDCOMPANYRECORDS=(SELECT SUBSTRING(OLDCOMPANYRECORDS,OLDCOMPANYPOSITION+2));
				END IF;
				SET NEWCOMPANYPOSITION = (SELECT LOCATE('^^',NEWCOMPANYRECORDS,CCD_LENGTH));
				IF (NEWCOMPANYPOSITION=0) THEN
					SET NEW_COMPANYDTL = NEWCOMPANYRECORDS;
				ELSE
					SET NEW_COMPANYDTL=(SELECT SUBSTRING(NEWCOMPANYRECORDS,CCD_LENGTH,NEWCOMPANYPOSITION-1));
					SET NEWCOMPANYRECORDS=(SELECT SUBSTRING(NEWCOMPANYRECORDS,NEWCOMPANYPOSITION+2));
				END IF;
				SET COMPANYHEADPOSITION = (SELECT LOCATE(',',COMPANYHEADNAME,CCD_LENGTH));
				IF (COMPANYHEADPOSITION=0) THEN
					SET CUSTCOMPANYHEADERNAME = COMPANYHEADNAME;
				ELSE
					SET CUSTCOMPANYHEADERNAME=(SELECT SUBSTRING(COMPANYHEADNAME,CCD_LENGTH,COMPANYHEADPOSITION-1));
					SET COMPANYHEADNAME=(SELECT SUBSTRING(COMPANYHEADNAME,COMPANYHEADPOSITION+1));
				END IF;
				IF(OLD_COMPANYDTL != NEW_COMPANYDTL)THEN
					SET OLD_COMPANYDTL=(SELECT CONCAT(CUSTCOMPANYHEADERNAME, '=', OLD_COMPANYDTL));
					SET NEW_COMPANYDTL=(SELECT CONCAT(CUSTCOMPANYHEADERNAME, '=' ,NEW_COMPANYDTL));
					SET NEW_COMPANYS=(SELECT CONCAT(NEW_COMPANYS,',',NEW_COMPANYDTL));
					SET OLD_COMPANYS=(SELECT CONCAT(OLD_COMPANYS,',',OLD_COMPANYDTL));
				END IF;  
				IF (COMPANYHEADPOSITION<=0) THEN
					LEAVE  loop_label;
				END IF;
			END LOOP;
			SET COMPANY_LOCATION=(SELECT LOCATE(',', NEW_COMPANYS,1));
			SET NEW_COMPANYS=(SELECT SUBSTRING(NEW_COMPANYS,COMPANY_LOCATION+1));
			IF EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID) THEN
				INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES
				((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
				(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_COMPANY_DETAILS'),
				OLD_COMPANYS,NEW_COMPANYS,USERSTAMP_ID,EX_CUSTOMER_ID);
				UPDATE CUSTOMER_COMPANY_DETAILS SET CCD_COMPANY_NAME=EX_COMPANY_NAME, CCD_COMPANY_ADDR=EX_COMPANY_ADDR, CCD_POSTAL_CODE=EX_POSTAL_CODE, CCD_OFFICE_NO=EX_OFFICE_NO WHERE CUSTOMER_ID=EX_CUSTOMER_ID;
				SET EX_SUCCESSFLAG=1;
			END IF;
		END IF;
		IF NOT EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID) THEN
			IF EX_COMPANY_NAME IS NOT NULL OR EX_COMPANY_ADDR IS NOT NULL OR EX_POSTAL_CODE IS NOT NULL OR EX_OFFICE_NO IS NOT NULL THEN
				INSERT INTO CUSTOMER_COMPANY_DETAILS(CUSTOMER_ID, CCD_COMPANY_NAME, CCD_COMPANY_ADDR, CCD_POSTAL_CODE, CCD_OFFICE_NO) VALUES(EX_CUSTOMER_ID, EX_COMPANY_NAME, EX_COMPANY_ADDR, EX_POSTAL_CODE, EX_OFFICE_NO);
				SET EX_SUCCESSFLAG=1;
			END IF;
		END IF;	
		IF (EX_COMPANY_NAME IS NULL AND EX_COMPANY_ADDR IS NULL AND EX_POSTAL_CODE IS NULL AND EX_OFFICE_NO IS NULL) THEN
			IF EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID) THEN
				SET CCDID = (SELECT CCD_ID FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID);
				CALL SP_SINGLE_TABLE_ROW_DELETION(9,CCDID,USERSTAMP,@FLAG);
				SET THID = (SELECT MAX(TH_ID) FROM TICKLER_HISTORY WHERE TTIP_ID = 9);
				UPDATE TICKLER_HISTORY SET CUSTOMER_ID=EX_CUSTOMER_ID WHERE TH_ID=THID;
				SET EX_SUCCESSFLAG=1;
			END IF;
		END IF;
			IF EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER_COMPANY_DETAILS WHERE CCD_COMPANY_NAME IS NULL AND CCD_COMPANY_ADDR IS NULL AND CCD_POSTAL_CODE IS NULL AND CCD_OFFICE_NO IS NULL) THEN
				DELETE FROM CUSTOMER_COMPANY_DETAILS WHERE CCD_COMPANY_NAME IS NULL AND CCD_COMPANY_ADDR IS NULL AND CCD_POSTAL_CODE IS NULL AND CCD_OFFICE_NO IS NULL;
				SET CCDID=(SELECT CCD_ID FROM CUSTOMER_COMPANY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID);
				CALL  SP_SINGLE_TABLE_ROW_DELETION(9,CCDID,USERSTAMP,@DELETION_FLAG);
				SET EX_SUCCESSFLAG=1;
			END IF;
			IF EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=(SELECT CUSTOMER_ID FROM CUSTOMER WHERE CUSTOMER_ID=EX_CUSTOMER_ID)) THEN
					IF EX_SAMEUNIT_FLAG IS NOT NULL THEN
						SET CEDID=(SELECT CED_ID FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=REC_VER);
						SET PRETERMINATE=(SELECT IF(CED_PRETERMINATE IS NULL,'NULL',CED_PRETERMINATE) FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=REC_VER);
						IF(PRETERMINATE!=FLAG) THEN
							LABEL1:BEGIN		
								IF (PRETERMINATE IS NULL AND FLAG IS NULL) THEN
									LEAVE LABEL1;
								ELSE
								SET OLDPRETERMINATE=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CED_ID=',CEDID,',','CED_PRETERMINATE=',PRETERMINATE)));
								SET NEWPRETERMINATE=(SELECT GROUP_CONCAT(CONCAT_WS(' ','CED_PRETERMINATE=',FLAG)));
								INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ENTRY_DETAILS'),OLDPRETERMINATE,NEWPRETERMINATE,USERSTAMP_ID,EX_CUSTOMER_ID);
								END IF;
							END LABEL1;
						END IF;
						UPDATE CUSTOMER_ENTRY_DETAILS SET CED_PRETERMINATE=FLAG WHERE CUSTOMER_ID=EX_CUSTOMER_ID AND CED_REC_VER=REC_VER;
						SET EX_SUCCESSFLAG=1;
					END IF;
				IF EX_PRETERM_FLAG=1 THEN
					INSERT INTO CUSTOMER_ENTRY_DETAILS(CUSTOMER_ID, UNIT_ID, UASD_ID, CED_REC_VER, CED_SD_STIME, CED_SD_ETIME, CED_ED_STIME, CED_ED_ETIME, CED_LEASE_PERIOD, CED_QUARTERS, CED_EXTENSION,CED_PRETERMINATE, CED_PROCESSING_WAIVED, CED_PRORATED, CED_NOTICE_PERIOD, CED_NOTICE_START_DATE) VALUES(EX_CUSTOMER_ID, RE_UNIT_ID, ROOM_TYPE_ID, REC_VER+1, (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_SD_STIME), (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_SD_ETIME), (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_ED_STIME), (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_ED_ETIME), EX_LEASE_PERIOD, EX_QUARTERS, FLAG,FLAG,EX_PROCESSING_WAIVED, EX_PRORATED, EX_NOTICE_PERIOD, EX_NOTICE_START_DATE);
				ELSE
					INSERT INTO CUSTOMER_ENTRY_DETAILS(CUSTOMER_ID, UNIT_ID, UASD_ID, CED_REC_VER, CED_SD_STIME, CED_SD_ETIME, CED_ED_STIME, CED_ED_ETIME, CED_LEASE_PERIOD, CED_QUARTERS, CED_EXTENSION, CED_PROCESSING_WAIVED, CED_PRORATED, CED_NOTICE_PERIOD, CED_NOTICE_START_DATE) VALUES(EX_CUSTOMER_ID, RE_UNIT_ID, ROOM_TYPE_ID, REC_VER+1, (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_SD_STIME), (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_SD_ETIME), (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_ED_STIME), (SELECT CTP_ID FROM CUSTOMER_TIME_PROFILE WHERE CTP_DATA=EX_ED_ETIME), EX_LEASE_PERIOD, EX_QUARTERS, FLAG, EX_PROCESSING_WAIVED, EX_PRORATED, EX_NOTICE_PERIOD, EX_NOTICE_START_DATE);
				END IF;
				SET EX_SUCCESSFLAG=1;
			END IF;
		SET CUSTPERSONAL_ID = '';
		SET OLD_CPDID = (SELECT CPD_ID FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		SET OLD_NCID = (SELECT NC_ID FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		SET OLD_EMAIL = (SELECT CPD_EMAIL FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		SET OLD_MOBILE = (SELECT CPD_MOBILE FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		IF(OLD_MOBILE IS NULL)THEN
			SET OLD_MOBILE = 'null';
		END IF;
		SET OLD_INTL_MOBILE = (SELECT CPD_INTL_MOBILE FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		IF(OLD_INTL_MOBILE IS NULL)THEN
			SET OLD_INTL_MOBILE = 'null';
		END IF;
		SET OLD_PASSPORTNO = (SELECT CPD_PASSPORT_NO FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		IF(OLD_PASSPORTNO IS NULL)THEN
			SET OLD_PASSPORTNO = 'null';
		END IF;
		SET OLD_PASSPORTDATE = (SELECT CPD_PASSPORT_DATE FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		IF(OLD_PASSPORTDATE IS NULL)THEN
			SET OLD_PASSPORTDATE = 'null';
		END IF;
		SET OLD_DOB = (SELECT CPD_DOB FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		IF(OLD_DOB IS NULL)THEN
			SET OLD_DOB = 'null';
		END IF;
		SET OLD_EPNO = (SELECT CPD_EP_NO FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		IF(OLD_EPNO IS NULL)THEN
			SET OLD_EPNO = 'null';
		END IF;
		SET OLD_EPDATE = (SELECT CPD_EP_DATE FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		IF(OLD_EPDATE IS NULL)THEN
			SET OLD_EPDATE = 'null';
		END IF;
		SET OLD_COMMENTS = (SELECT CPD_COMMENTS FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID = EX_CUSTOMER_ID);
		IF(OLD_COMMENTS IS NULL)THEN
			SET OLD_COMMENTS = 'null';
		END IF;
		SET NEW_NCID = NATIONALITY_DETAILS;
		SET NEW_EMAIL = EX_EMAIL;
		SET NEW_MOBILE = EX_MOBILE;
		IF(NEW_MOBILE IS NULL)THEN
			SET NEW_MOBILE = 'null';
		END IF;
		SET NEW_INTL_MOBILE = EX_INTL_MOBILE;
		IF(NEW_INTL_MOBILE IS NULL)THEN
			SET NEW_INTL_MOBILE = 'null';
		END IF;
		SET NEW_PASSPORTNO = EX_PASSPORT_NO;
		IF(NEW_PASSPORTNO IS NULL)THEN
			SET NEW_PASSPORTNO = 'null';
		END IF;
		SET NEW_PASSPORTDATE = EX_PASSPORT_DATE;
		IF(NEW_PASSPORTDATE IS NULL)THEN
			SET NEW_PASSPORTDATE = 'null';
		END IF;
		SET NEW_DOB = EX_DOB;
		IF(NEW_DOB IS NULL)THEN
			SET NEW_DOB = 'null';
		END IF;
		SET NEW_EPNO = EX_EP_NO;
		IF(NEW_EPNO IS NULL)THEN
			SET NEW_EPNO = 'null';
		END IF;
		SET NEW_EPDATE = EX_EP_DATE;
		IF(NEW_EPDATE IS NULL)THEN
			SET NEW_EPDATE = 'null';
		END IF;
		SET NEW_COMMENTS = EX_COMMENTS;
		IF(NEW_COMMENTS IS NULL)THEN
			SET NEW_COMMENTS = 'null';
		END IF;
		SET PERSONALHEADERNAMES = 'CPD_ID,NC_ID,CPD_MOBILE,CPD_INTL_MOBILE,CPD_EMAIL,CPD_PASSPORT_NO,CPD_PASSPORT_DATE,CPD_DOB,CPD_EP_NO,CPD_EP_DATE,CPD_COMMENTS';
		SET OLD_PERSONALTABLEDETAILS = (SELECT CONCAT(OLD_CPDID,'^','^',OLD_NCID,'^','^',OLD_MOBILE,'^','^',OLD_INTL_MOBILE,'^','^',OLD_EMAIL,'^','^',OLD_PASSPORTNO,'^','^',OLD_PASSPORTDATE,'^','^',OLD_DOB,'^','^',OLD_EPNO,'^','^',OLD_EPDATE,'^','^',OLD_COMMENTS));
		SET NEW_PERSONALTABLEDETAILS = (SELECT CONCAT(OLD_CPDID,'^','^',NEW_NCID,'^','^',NEW_MOBILE,'^','^',NEW_INTL_MOBILE,'^','^',NEW_EMAIL,'^','^',NEW_PASSPORTNO,'^','^',NEW_PASSPORTDATE,'^','^',NEW_DOB,'^','^',NEW_EPNO,'^','^',NEW_EPDATE,'^','^',NEW_COMMENTS));
		IF(OLD_PERSONALTABLEDETAILS != NEW_PERSONALTABLEDETAILS)THEN
			SET OLDPERSONALRECORDS = OLD_PERSONALTABLEDETAILS;
			SET NEWPERSONALRECORDS = NEW_PERSONALTABLEDETAILS;
			SET PERSONALHEADNAME = PERSONALHEADERNAMES;
			SET OLD_CUSTOMERPERSONALS = (SELECT CONCAT('CPD_ID=',OLD_CPDID));
			SET NEW_CUSTOMERPERSONALS = '';
			SET CPD_LENGTH = 1;
			loop_label : LOOP
				SET OLDPERSONALPOSITION = (SELECT LOCATE('^^',OLDPERSONALRECORDS,CPD_LENGTH));
				IF (OLDPERSONALPOSITION=0) THEN
					SET OLD_PERSONALDTL = OLDPERSONALRECORDS;
				ELSE
					SET OLD_PERSONALDTL =(SELECT SUBSTRING(OLDPERSONALRECORDS,CPD_LENGTH,OLDPERSONALPOSITION-1));
					SET OLDPERSONALRECORDS=(SELECT SUBSTRING(OLDPERSONALRECORDS,OLDPERSONALPOSITION+2));
				END IF;
				SET NEWPERSONALPOSITION = (SELECT LOCATE('^^',NEWPERSONALRECORDS,CPD_LENGTH));
				IF (NEWPERSONALPOSITION=0) THEN
					SET NEW_PERSONALDTL = NEWPERSONALRECORDS;
				ELSE
					SET NEW_PERSONALDTL=(SELECT SUBSTRING(NEWPERSONALRECORDS,CPD_LENGTH,NEWPERSONALPOSITION-1));
					SET NEWPERSONALRECORDS=(SELECT SUBSTRING(NEWPERSONALRECORDS,NEWPERSONALPOSITION+2));
				END IF;
				SET PERSONALHEADPOSITION = (SELECT LOCATE(',',PERSONALHEADNAME,CPD_LENGTH));
				IF (PERSONALHEADPOSITION=0) THEN
					SET CUSTPERSONALHEADERNAME = PERSONALHEADNAME;
				ELSE
					SET CUSTPERSONALHEADERNAME=(SELECT SUBSTRING(PERSONALHEADNAME,CPD_LENGTH,PERSONALHEADPOSITION-1));
					SET PERSONALHEADNAME=(SELECT SUBSTRING(PERSONALHEADNAME,PERSONALHEADPOSITION+1));
				END IF;
				IF(OLD_PERSONALDTL != NEW_PERSONALDTL)THEN
					SET OLD_PERSONALDTL=(SELECT CONCAT(CUSTPERSONALHEADERNAME, '=', OLD_PERSONALDTL));
					SET NEW_PERSONALDTL=(SELECT CONCAT(CUSTPERSONALHEADERNAME, '=' ,NEW_PERSONALDTL));
					SET NEW_CUSTOMERPERSONALS=(SELECT CONCAT(NEW_CUSTOMERPERSONALS,',',NEW_PERSONALDTL));
					SET OLD_CUSTOMERPERSONALS=(SELECT CONCAT(OLD_CUSTOMERPERSONALS,',',OLD_PERSONALDTL));
				END IF;  
				IF (PERSONALHEADPOSITION<=0) THEN
					LEAVE  loop_label;
				END IF;
			END LOOP;
			SET PERSONAL_LOCATION=(SELECT LOCATE(',', NEW_CUSTOMERPERSONALS,1));
			SET NEW_CUSTOMERPERSONALS=(SELECT SUBSTRING(NEW_CUSTOMERPERSONALS,PERSONAL_LOCATION+1));
			IF EXISTS(SELECT CUSTOMER_ID FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=EX_CUSTOMER_ID) THEN
				INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES
				((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
				(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_PERSONAL_DETAILS'),
				OLD_CUSTOMERPERSONALS,NEW_CUSTOMERPERSONALS,USERSTAMP_ID,EX_CUSTOMER_ID);
				UPDATE CUSTOMER_PERSONAL_DETAILS SET NC_ID=NATIONALITY_DETAILS, CPD_MOBILE=EX_MOBILE, CPD_INTL_MOBILE=EX_INTL_MOBILE, CPD_EMAIL=EX_EMAIL, CPD_PASSPORT_NO=EX_PASSPORT_NO, CPD_PASSPORT_DATE=EX_PASSPORT_DATE, CPD_DOB=EX_DOB, CPD_EP_NO=EX_EP_NO, CPD_EP_DATE=EX_EP_DATE, CPD_COMMENTS=EX_COMMENTS WHERE CUSTOMER_ID=EX_CUSTOMER_ID;
				SET EX_SUCCESSFLAG=1;
			END IF;
		END IF;
		IF EX_CARD_NO IS NOT NULL AND EX_VALID_FROM IS NOT NULL AND EX_SAMEUNIT_FLAG IS NULL THEN
			SET TEMP_ACCESS_CARD = EX_CARD_NO;
			SET ACCESS_LENGTH=1;
			loop_label:  LOOP
				SET ACCESS_POSITION=(SELECT LOCATE(',', TEMP_ACCESS_CARD,ACCESS_LENGTH));
				IF ACCESS_POSITION<=0 THEN
					SET ACCESS_CARD_NO=TEMP_ACCESS_CARD;
				ELSE
					SELECT SUBSTRING(TEMP_ACCESS_CARD,ACCESS_LENGTH,ACCESS_POSITION-1) INTO ACCESS_CARD_NO;
					SET TEMP_ACCESS_CARD=(SELECT SUBSTRING(TEMP_ACCESS_CARD,ACCESS_POSITION+1));
				END IF;
				SET ACCESS_LOCATION=(SELECT LOCATE(ACCESS_CARD_NO, EX_GUEST_CARD));
				SET GUEST_ACCESS_LENGTH=(SELECT LENGTH(ACCESS_CARD_NO));
				SET GUEST_FLAG=(SELECT SUBSTRING(EX_GUEST_CARD,ACCESS_LOCATION+GUEST_ACCESS_LENGTH+1,1));
				SET GUEST_FLAG=TRIM(GUEST_FLAG);
				IF GUEST_FLAG='' THEN
					SET GUEST_FLAG=NULL;
				END IF;
				SET UASDID = (SELECT UASD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO));
				IF(UASDID IS NOT NULL) THEN
					SET ECDID = (SELECT ECD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID = UASDID);
					CALL SP_SINGLE_TABLE_ROW_DELETION(40,ECDID,USERSTAMP,@FLAG);
					SET EX_SUCCESSFLAG=1;
				END IF;
				INSERT INTO CUSTOMER_ACCESS_CARD_DETAILS (CUSTOMER_ID,UASD_ID,CACD_VALID_FROM,CACD_GUEST_CARD,ULD_ID) VALUES(EX_CUSTOMER_ID,(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO AND UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=EX_UNIT_NO)),EX_VALID_FROM,GUEST_FLAG,USERSTAMP_ID);
				UPDATE UNIT_ACCESS_STAMP_DETAILS SET UASD_ACCESS_ACTIVE=FLAG,UASD_ACCESS_INVENTORY=NULL WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO AND UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=EX_UNIT_NO);
				SET EX_SUCCESSFLAG=1;
				IF ACCESS_POSITION<=0 THEN
					LEAVE  loop_label;
				END IF;
			END LOOP;
		END IF;
		IF EX_STARTDATE IS NOT NULL AND EX_ENDDATE IS NOT NULL THEN
			IF EX_CARD_NO IS NOT NULL THEN
				SET TEMP_ACCESS_CARD = EX_CARD_NO;
				SET ACCESS_LENGTH=1;
				loop_label:  LOOP
					SET ACCESS_POSITION=(SELECT LOCATE(',', TEMP_ACCESS_CARD,ACCESS_LENGTH));
					IF ACCESS_POSITION<=0 THEN
						SET ACCESS_CARD_NO=TEMP_ACCESS_CARD;
					ELSE
						SELECT SUBSTRING(TEMP_ACCESS_CARD,ACCESS_LENGTH,ACCESS_POSITION-1) INTO ACCESS_CARD_NO;
						SET TEMP_ACCESS_CARD=(SELECT SUBSTRING(TEMP_ACCESS_CARD,ACCESS_POSITION+1));
					END IF;
					SET ACCESS_LOCATION=(SELECT LOCATE(ACCESS_CARD_NO, EX_GUEST_CARD));
					SET GUEST_ACCESS_LENGTH=(SELECT LENGTH(ACCESS_CARD_NO));
					SET GUEST_FLAG=(SELECT SUBSTRING(EX_GUEST_CARD,ACCESS_LOCATION+GUEST_ACCESS_LENGTH+1,1));
					SET GUEST_FLAG=TRIM(GUEST_FLAG);
					IF GUEST_FLAG='' THEN
						SET GUEST_FLAG=NULL;
					END IF;
					SET UASDID = (SELECT UASD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO));
					IF(UASDID IS NOT NULL) THEN
						SET ECDID = (SELECT ECD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID = UASDID);
						CALL SP_SINGLE_TABLE_ROW_DELETION(40,ECDID,USERSTAMP,@FLAG);
						SET EX_SUCCESSFLAG=1;
					END IF;
					INSERT INTO CUSTOMER_LP_DETAILS (CUSTOMER_ID,CED_REC_VER,UASD_ID,CLP_STARTDATE,CLP_ENDDATE,CLP_GUEST_CARD,ULD_ID) VALUES (EX_CUSTOMER_ID,REC_VER+1,(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=ACCESS_CARD_NO AND UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=EX_UNIT_NO)),EX_STARTDATE,EX_ENDDATE,GUEST_FLAG,USERSTAMP_ID);
					SET EX_SUCCESSFLAG=1;
					IF ACCESS_POSITION<=0 THEN
						LEAVE  loop_label;
					END IF;
				END LOOP;
			ELSE
					INSERT INTO CUSTOMER_LP_DETAILS (CUSTOMER_ID,CED_REC_VER,UASD_ID,CLP_STARTDATE,CLP_ENDDATE,CLP_GUEST_CARD,ULD_ID) VALUES (EX_CUSTOMER_ID,REC_VER+1,EX_CARD_NO,EX_STARTDATE,EX_ENDDATE,GUEST_FLAG,USERSTAMP_ID);
					SET EX_SUCCESSFLAG=1;
			END IF;
		END IF;
		IF EX_RENT IS NOT NULL THEN
			INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,1,EX_RENT);
			SET EX_SUCCESSFLAG=1;
		END IF;
		IF EX_DEPOSIT IS NOT NULL THEN
			INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,2,EX_DEPOSIT);
			SET EX_SUCCESSFLAG=1;
		END IF;
		IF EX_PROCESSING_FEE IS NOT NULL THEN
			INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,3,EX_PROCESSING_FEE);
			SET EX_SUCCESSFLAG=1;
		END IF;
		IF EX_AIRCON_FIXED_FEE IS NOT NULL THEN
			INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,4,EX_AIRCON_FIXED_FEE);
			SET EX_SUCCESSFLAG=1;
		END IF;
		IF EX_ELECTRICITY_CAP IS NOT NULL THEN
			INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,5,EX_ELECTRICITY_CAP);
			SET EX_SUCCESSFLAG=1;
		END IF;
		IF EX_DRYCLEAN_FEE IS NOT NULL THEN
			INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,6,EX_DRYCLEAN_FEE);
			SET EX_SUCCESSFLAG=1;
		END IF;
		IF EX_AIRCON_QUARTELY_FEE IS NOT NULL THEN
			INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,7,EX_AIRCON_QUARTELY_FEE);
			SET EX_SUCCESSFLAG=1;
		END IF;
		IF EX_CHECKOUT_CLEANING_FEE IS NOT NULL THEN
			INSERT INTO CUSTOMER_FEE_DETAILS (CUSTOMER_ID,CED_REC_VER,CPP_ID,CFD_AMOUNT) VALUES (EX_CUSTOMER_ID,REC_VER+1,8,EX_CHECKOUT_CLEANING_FEE);
			SET EX_SUCCESSFLAG=1;
		END IF;
	END IF;
	DROP TABLE IF EXISTS TEMP_EXTN_TICKLER_LP_DTS;
COMMIT;
END;