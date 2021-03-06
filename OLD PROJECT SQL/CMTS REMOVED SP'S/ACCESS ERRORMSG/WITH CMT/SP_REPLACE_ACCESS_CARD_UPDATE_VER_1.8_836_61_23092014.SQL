-- VERSION 1.8 TARTDATE:23/09/2014 ENDDATE:23/09/2014 ISSUE NO:836 COMMENT NO:61 DESC:IMPLIMENTED ERROR MESSAGE GET FROM DB. DONE BY :RAJA
-- version:1.7 --sdate:08/09/2014 --edate:08/09/2014 --issue:791 --commentno#17 --desc: checking passing new card is inventory or not --doneby:RL
-- version 1.6-->startdate:31/07/2014 ensdate:31/07/2014---issue no:835--desc:IMPLEMENTED AUTOCOMMIT DONE BY:DHIVYA
-- version 1.5-->startdate:21/06/2014 ensdate:21/06/2014---issue no:817--desc:dropped temp table if rollback occur
--> version 1.4-->startdate:17/06/2014  enddate:18/06/2014 -->issueno:738 COMMENT:22 -->desc:ADDED ULD_ID AND TIMESTAMP IN TICKLER_HISTORY OLD_VALUE TABLE -->doneby:DHIVYA.A
--> version 1.3-->startdate:06/05/2014  enddate:06/05/2014 -->issueno:817 -->desc:TEMP TABLE CREATED DYNAMICALLY AND REPLACED CARD IN THE INVALID PERIOD ALSO -->doneby:DHIVYA.A
--VER 1.2 STARTDATE:03/04/2014 ENDDATE:03/04/2014 ISSUENO:797 COMMENTNO:#4 DESC:REPLACED HEADER ND TABLE NAME DONE BY:LALITHA
--version 1.1 startdate:28/02/2014 --enddate:28/02/2014--- issueno 754 commentno:36-->desc: APPLIED SUB_SP TO REPLACE USERSTAMP AS ID-SAFI
--version 1.0 startdate:27/02/2014 --enddate:27/02/2014--- issueno 754 commentno:22-->desc: REPLACE USERSTAMP DATATYPE AS INT-SAFI
--version 0.9 startdate:26/02/2014 --enddate:26/02/2014--- issueno 750 commentno:36-->desc: REPLACE USERSTAMP TO ULD_ID
-- version 0.8 startdate:19/02/2014 --enddate:19/02/2014---ISSUENO 345 COMMENTNO:594-->UPDATED TICKLER TABLE AND RETURNED FLAG
-->version 0.7-->startdate:02/12/2013 --enddate:02/12/2013 --issueno:615 commentno:#29 -->desc:added condition passing card customer is in future startdate in customer_access_card_details is that recver startdate--> done by :DHIVYA.A
-->version 0.6-->startdate:22/11/2013 --enddate:22/11/2013 --issueno:258 commentno:#110 -->desc:added guest card header in customer access card details--> done by :DHIVYA.A
-->version 0.5-->startdate:21/11/2013 --enddate:21/11/2013 --issueno:253 commentno:#111 -->desc:changed DATA TYPE (INTEGER (7)) FOR CURRENT_CARD & NEW_CARD--> modified by :DINESH.M 
-- version --> 0.4 startdtae -->06/11/2013 enddate --> 06/11/2013 description --> CARD IS ASSIGNED TO CUSTOMER, EMPLOYEE_DETAILS TABLE RECORD SHLD UPDATE AS NULL IF THAT CARD EXISTS FOR THE EMPLOYEE modified by & changed sp name & changed SYSDATE() as CURDATE() -->rl -->issue :345 -->commentno: 303
--> version 0.3-->startdate:11/10/2013  enddate:11/10/2013-->issueno:636 -->desc:added comments
-->doneby:DHIVYA.A
-->version 0.3--->issue no:608 desc:updated customer_access_card_details cacd_valid_till and acn_id done by:DHIVYA.A
-->version 0.2---> issue no:348 comment no:#26 desc:as per table updation card_replace for customer is created done by:DHIVYA.A
-- Created on 06.06.2013 ISSU_NO:348 VER 0.1 DESCRIPTION:CARD_REPLACE_FOR_CUSTOMER created by:loganathan

DROP PROCEDURE IF EXISTS SP_REPLACE_ACCESS_CARD_UPDATE;
CREATE PROCEDURE SP_REPLACE_ACCESS_CARD_UPDATE(
IN CUSTOMERID INTEGER,
IN CURRENT_CARD INTEGER(7),
IN NEW_CARD INTEGER(7),
IN REASON TEXT,
IN COMMENTS TEXT,
IN USERSTAMP VARCHAR(50),
OUT REPLACE_FLAG TEXT)
BEGIN

	DECLARE GUEST_FLAG CHAR(1);
	DECLARE REC_VER INTEGER;
	DECLARE VALIDFROM DATE;
	DECLARE STARTDATE DATE;
	DECLARE TICK_COMMENTS_OLD_VALUE TEXT;
	DECLARE TICK_COMMENTS_NEW_VALUE TEXT;
	DECLARE OLD_COMMENTS TEXT;
	DECLARE MINID INTEGER;
	DECLARE MAXID INTEGER;
	DECLARE TICK_TERMINATION_OLD_VALUE TEXT;
	DECLARE TICK_TERMINATION_NEW_VALUE TEXT;
	DECLARE TICK_ACCESS_OLD_VALUE TEXT;
	DECLARE TICK_ACCESS_NEW_VALUE TEXT;
	DECLARE USERSTAMP_ID INTEGER(2);
	DECLARE TEMP_REPLACE TEXT;
	DECLARE TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS TEXT;
	DECLARE TEMPRECVER INTEGER;
	DECLARE TEMPUASDID INTEGER;
	DECLARE TEMPULDID INTEGER;
	DECLARE TEMPTIMESTAMP TIMESTAMP;
	DECLARE CLPID INTEGER;
	DECLARE CACDID INTEGER;
	DECLARE CACDULDID INTEGER;
	DECLARE CACDTIMESTAMP TIMESTAMP;
	DECLARE CPDID INTEGER;
	DECLARE ACTIVE_CARDID INTEGER;
	DECLARE LOST_CARDID INTEGER;
	DECLARE REPLACE_MSG TEXT DEFAULT NULL;
	DECLARE ECDID INTEGER;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
	ROLLBACK;
		IF TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS IS NOT NULL THEN
			SET @DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS));
			PREPARE DROPQUERYSTMT FROM @DROPQUERY;
			EXECUTE DROPQUERYSTMT; 
		END IF; 
	END;
	
	SET AUTOCOMMIT=0;
	START TRANSACTION;
	SET REPLACE_FLAG=' ';
	
	IF COMMENTS=' ' THEN
		SET COMMENTS=NULL;
	END IF;
	
	CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID = (SELECT @ULDID);
	SET REPLACE_MSG = (SELECT EMC_DATA FROM ERROR_MESSAGE_CONFIGURATION WHERE EMC_ID = 571);
  
	SET ACTIVE_CARDID= (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=NEW_CARD AND UASD_ACCESS_ACTIVE='X');
	SET LOST_CARDID = (SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=NEW_CARD AND UASD_ACCESS_LOST='X');
	
	IF(ACTIVE_CARDID IS NOT NULL OR LOST_CARDID IS NOT NULL)THEN
		SET @ACCESS_FLAG=(SELECT REPLACE(REPLACE_MSG,'[CARD NO]',NEW_CARD));
		SET REPLACE_MSG=@ACCESS_FLAG;
	END IF;
	
	IF REPLACE_MSG IS NOT NULL THEN
		SET REPLACE_FLAG=REPLACE_MSG;
	END IF;
	
	IF (ACTIVE_CARDID IS NULL AND LOST_CARDID IS NULL) THEN
	
		SET GUEST_FLAG=(SELECT CACD_GUEST_CARD FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CURRENT_CARD)AND ACN_ID IS NULL AND CACD_VALID_TILL IS NULL);
		SET VALIDFROM=(SELECT CACD_VALID_FROM FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND ACN_ID IS NULL AND CACD_VALID_TILL IS NULL AND UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CURRENT_CARD));
		SET REC_VER=(SELECT CTD.CED_REC_VER FROM CUSTOMER_LP_DETAILS CTD,CUSTOMER_ACCESS_CARD_DETAILS CACD,CUSTOMER_ENTRY_DETAILS CED WHERE CED.CUSTOMER_ID=CTD.CUSTOMER_ID AND CED.CUSTOMER_ID=CACD.CUSTOMER_ID AND CTD.CED_REC_VER=CED.CED_REC_VER AND CED.CED_CANCEL_DATE IS NULL AND CTD.CUSTOMER_ID=CACD.CUSTOMER_ID AND CTD.CUSTOMER_ID=CUSTOMERID AND CTD.UASD_ID=CACD.UASD_ID AND CACD.UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CURRENT_CARD) AND IF (CTD.CLP_PRETERMINATE_DATE IS NOT NULL,CTD.CLP_PRETERMINATE_DATE>=VALIDFROM,CTD.CLP_ENDDATE>=VALIDFROM) AND CTD.CLP_TERMINATE IS NULL AND IF(CTD.CLP_PRETERMINATE_DATE IS NOT NULL,CTD.CLP_PRETERMINATE_DATE>CURDATE(),CLP_ENDDATE>CURDATE()) GROUP BY CTD.CUSTOMER_ID);
		SET STARTDATE=(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=REC_VER AND UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CURRENT_CARD ));
	
		IF EXISTS(SELECT UASD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=NEW_CARD))THEN
			SET ECDID = (SELECT ECD_ID FROM EMPLOYEE_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=NEW_CARD));
			CALL SP_CUSTOMER_ROW_DELETION(40,ECDID,USERSTAMP_ID);
		END IF;
		
		SET TEMP_REPLACE=(SELECT CONCAT('TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS','_',SYSDATE()));
		SET TEMP_REPLACE=(SELECT REPLACE(TEMP_REPLACE,' ',''));
		SET TEMP_REPLACE=(SELECT REPLACE(TEMP_REPLACE,'-',''));
		SET TEMP_REPLACE=(SELECT REPLACE(TEMP_REPLACE,':',''));
		SET TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS=(SELECT CONCAT(TEMP_REPLACE,'_',USERSTAMP_ID));
		
		SET @CREATE_TEMP_REPLACE=(SELECT CONCAT('CREATE TABLE ',TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS,'(ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,CLP_ID INTEGER,UASD_ID INTEGER,RECVER INTEGER,ULD_ID INTEGER,CLP_TIMESTAMP TIMESTAMP)'));
		PREPARE CREATE_TEMP_REPLACE_STMT FROM @CREATE_TEMP_REPLACE;
		EXECUTE CREATE_TEMP_REPLACE_STMT;
		
		SET @INSERT_TEMP_REPLACE=(SELECT CONCAT('INSERT INTO ',TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS,'(CLP_ID,RECVER,UASD_ID,ULD_ID,CLP_TIMESTAMP)SELECT CLP_ID,CED_REC_VER,UASD_ID,ULD_ID,CLP_TIMESTAMP FROM CUSTOMER_LP_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=',CURRENT_CARD,') AND CLP_TERMINATE IS NULL AND CUSTOMER_ID=',CUSTOMERID,'  AND CED_REC_VER>=',REC_VER,' AND IF(CLP_PRETERMINATE_DATE IS NOT NULL,CLP_PRETERMINATE_DATE>CURDATE(),CLP_ENDDATE>CURDATE())'));
		PREPARE INSERT_TEMP_REPLACE_STMT FROM @INSERT_TEMP_REPLACE;
		EXECUTE INSERT_TEMP_REPLACE_STMT;
		
		SET @SETMINID=(SELECT CONCAT('SELECT MIN(ID)INTO @MIN_ID FROM ',TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS));
		PREPARE SETMINIDSTMT FROM @SETMINID;
		EXECUTE SETMINIDSTMT;
		SET MINID=@MIN_ID;
		
		SET @SETMAXID=(SELECT CONCAT('SELECT MAX(ID)INTO @MAX_ID FROM ',TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS));
		PREPARE SETMAXIDSTMT FROM @SETMAXID;
		EXECUTE SETMAXIDSTMT;
		SET MAXID=@MAX_ID;
		
		WHILE(MINID<=MAXID)DO
		
			SET @SETTEMPRECVER=(SELECT CONCAT('SELECT RECVER INTO @TEMP_RECVER FROM ',TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS,' WHERE ID=',MINID));
			PREPARE SETTEMPRECVERSTMT FROM @SETTEMPRECVER;
			EXECUTE SETTEMPRECVERSTMT;
			SET TEMPRECVER=@TEMP_RECVER;
			
			SET @SETTEMPUASDID=(SELECT CONCAT('SELECT UASD_ID INTO @TEMP_UASDID FROM ',TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS,' WHERE ID=',MINID));
			PREPARE SETTEMPUASDIDSTMT FROM @SETTEMPUASDID;
			EXECUTE SETTEMPUASDIDSTMT;
			SET TEMPUASDID=@TEMP_UASDID;
			
			SET @SETTEMPULDID=(SELECT CONCAT('SELECT ULD_ID INTO @TEMP_ULDID FROM ',TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS,' WHERE ID=',MINID));
			PREPARE SETTEMPULDIDSTMT FROM @SETTEMPULDID;
			EXECUTE SETTEMPULDIDSTMT;
			SET TEMPULDID=@TEMP_ULDID ;
			
			SET @SETTEMPTIMESTAMP=(SELECT CONCAT('SELECT CLP_TIMESTAMP INTO @TEMP_TIMESTAMP FROM ',TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS,' WHERE ID=',MINID));
			PREPARE SETTEMPTIMESTAMPSTMT FROM @SETTEMPTIMESTAMP;
			EXECUTE SETTEMPTIMESTAMPSTMT;
			SET TEMPTIMESTAMP=@TEMP_TIMESTAMP ;
			
			SET @SETTEMPCLPID=(SELECT CONCAT('SELECT CLP_ID INTO @TEMP_CLPID FROM ',TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS,' WHERE ID=',MINID));
			PREPARE SETTEMPTIMESTAMPSTMT FROM @SETTEMPCLPID;
			EXECUTE SETTEMPTIMESTAMPSTMT;
			SET CLPID=@TEMP_CLPID;
			
			IF USERSTAMP_ID!=TEMPULDID THEN
				SET TICK_TERMINATION_OLD_VALUE=(SELECT CONCAT('CLP_ID=',CLPID,',CED_REC_VER=',TEMPRECVER,',UASD_ID=',TEMPUASDID,',ULD_ID=',TEMPULDID,',CLP_TIMESTAMP=',TEMPTIMESTAMP));
			ELSE
				SET TICK_TERMINATION_OLD_VALUE=(SELECT CONCAT('CLP_ID=',CLPID,',CED_REC_VER=',TEMPRECVER,',UASD_ID=',TEMPUASDID,',CLP_TIMESTAMP=',TEMPTIMESTAMP));
			END IF;
			
			SET TICK_TERMINATION_NEW_VALUE=(SELECT CONCAT('UASD_ID=',(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD= NEW_CARD)));
			INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_LP_DETAILS'),TICK_TERMINATION_OLD_VALUE,TICK_TERMINATION_NEW_VALUE,USERSTAMP_ID,CUSTOMERID);
			SET @TEMP_RECVER=NULL;
			SET @TEMP_UASDID=NULL;
			
			SET MINID=MINID+1;
	
		END WHILE;
		
		UPDATE CUSTOMER_LP_DETAILS CTD,CUSTOMER_ACCESS_CARD_DETAILS CACD SET CTD.UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD= NEW_CARD),CTD.ULD_ID=USERSTAMP_ID
		WHERE CTD.UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CURRENT_CARD)AND CTD.CLP_TERMINATE IS NULL AND CTD.CUSTOMER_ID=CUSTOMERID AND CTD.CUSTOMER_ID=CACD.CUSTOMER_ID AND CTD.UASD_ID=CACD.UASD_ID AND CTD.CED_REC_VER>=REC_VER AND IF(CTD.CLP_PRETERMINATE_DATE IS NOT NULL,CTD.CLP_PRETERMINATE_DATE>CURDATE(),CTD.CLP_ENDDATE>CURDATE()); 
		SET REPLACE_FLAG=1;
		
		SET CACDID=(SELECT CACD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CURRENT_CARD) AND CUSTOMER_ID=CUSTOMERID AND CACD_VALID_TILL IS NULL AND ACN_ID IS NULL); 
		SET CACDULDID=(SELECT ULD_ID FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CURRENT_CARD) AND CUSTOMER_ID=CUSTOMERID AND CACD_VALID_TILL IS NULL AND ACN_ID IS NULL); 
		SET CACDTIMESTAMP=(SELECT CACD_TIMESTAMP FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CURRENT_CARD) AND CUSTOMER_ID=CUSTOMERID AND CACD_VALID_TILL IS NULL AND ACN_ID IS NULL); 
	
		IF CACDULDID!=USERSTAMP_ID THEN
			SET TICK_ACCESS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',CACDID,',UASD_ID=',(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD= CURRENT_CARD),',CACD_VALID_TILL=NULL',',ACN_ID=NULL,ULD_ID=',CACDULDID,',CACD_TIMESTAMP=',CACDTIMESTAMP));
		ELSE
			SET TICK_ACCESS_OLD_VALUE=(SELECT CONCAT('CACD_ID=',CACDID,',UASD_ID=',(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD= CURRENT_CARD),',CACD_VALID_TILL=NULL',',ACN_ID=NULL,CACD_TIMESTAMP=',CACDTIMESTAMP));
		END IF;
		
		SET TICK_ACCESS_NEW_VALUE=(SELECT CONCAT('CACD_VALID_TILL=',CURDATE(),',ACN_ID=',(SELECT ACN_ID FROM ACCESS_CONFIGURATION WHERE ACN_DATA=REASON)));
		INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_ACCESS_CARD_DETAILS'),TICK_ACCESS_OLD_VALUE,TICK_ACCESS_NEW_VALUE,USERSTAMP_ID,CUSTOMERID);
		UPDATE CUSTOMER_ACCESS_CARD_DETAILS SET CACD_VALID_TILL=CURDATE(),ACN_ID=(SELECT ACN_ID FROM ACCESS_CONFIGURATION WHERE ACN_DATA=REASON),ULD_ID=USERSTAMP_ID WHERE UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=CURRENT_CARD) AND CUSTOMER_ID=CUSTOMERID AND CACD_VALID_TILL IS NULL AND ACN_ID IS NULL; 
		SET REPLACE_FLAG=1;
		
		UPDATE UNIT_ACCESS_STAMP_DETAILS SET UASD_ACCESS_LOST='X',UASD_ACCESS_ACTIVE = NULL,UASD_ACCESS_INVENTORY=NULL WHERE UASD_ACCESS_CARD=CURRENT_CARD;
		SET REPLACE_FLAG=1;
		
		UPDATE UNIT_ACCESS_STAMP_DETAILS SET UASD_ACCESS_ACTIVE='X' ,UASD_ACCESS_INVENTORY=NULL,UASD_ACCESS_LOST=NULL WHERE UASD_ACCESS_CARD=NEW_CARD;
		SET REPLACE_FLAG=1;
		SET STARTDATE=(SELECT CLP_STARTDATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=CUSTOMERID AND CED_REC_VER=REC_VER AND UASD_ID=(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD=NEW_CARD )); 
	
		IF GUEST_FLAG IS NOT NULL THEN
			IF STARTDATE>CURDATE() THEN
				INSERT INTO CUSTOMER_ACCESS_CARD_DETAILS(CUSTOMER_ID,UASD_ID,CACD_VALID_FROM,CACD_GUEST_CARD,ULD_ID)VALUES(CUSTOMERID,(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD= NEW_CARD),STARTDATE,'X',USERSTAMP_ID);
			ELSE
				INSERT INTO CUSTOMER_ACCESS_CARD_DETAILS(CUSTOMER_ID,UASD_ID,CACD_VALID_FROM,CACD_GUEST_CARD,ULD_ID)VALUES(CUSTOMERID,(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD= NEW_CARD),CURDATE(),'X',USERSTAMP_ID);
			END IF;
		ELSE
			IF STARTDATE>CURDATE() THEN
				INSERT INTO CUSTOMER_ACCESS_CARD_DETAILS(CUSTOMER_ID,UASD_ID,CACD_VALID_FROM,ULD_ID)VALUES(CUSTOMERID,(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD= NEW_CARD),STARTDATE,USERSTAMP_ID);
				SET REPLACE_FLAG=1;
			ELSE
				INSERT INTO CUSTOMER_ACCESS_CARD_DETAILS(CUSTOMER_ID,UASD_ID,CACD_VALID_FROM,ULD_ID)VALUES(CUSTOMERID,(SELECT UASD_ID FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD= NEW_CARD),CURDATE(),USERSTAMP_ID);
				SET REPLACE_FLAG=1;
			END IF;
		END IF;
		
		SET CPDID=(SELECT CPD_ID FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
		SET OLD_COMMENTS=(SELECT CPD_COMMENTS FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=CUSTOMERID);
		
		IF OLD_COMMENTS IS NULL THEN
			SET OLD_COMMENTS='NULL';
		END IF;
		IF COMMENTS IS NULL THEN
			SET COMMENTS='NULL';
		END IF;
		
		IF(OLD_COMMENTS!=COMMENTS)THEN
			SET TICK_COMMENTS_OLD_VALUE=(SELECT CONCAT('CPD_ID=',CPDID,',CPD_COMMENTS=',OLD_COMMENTS));
			SET TICK_COMMENTS_NEW_VALUE=(SELECT CONCAT('CPD_COMMENTS=',COMMENTS));
			INSERT INTO TICKLER_HISTORY(TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE,ULD_ID,CUSTOMER_ID)VALUES((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='CUSTOMER_PERSONAL_DETAILS'),TICK_COMMENTS_OLD_VALUE,TICK_COMMENTS_NEW_VALUE,USERSTAMP_ID,CUSTOMERID);
		END IF;
		
		IF(COMMENTS='NULL')THEN
			SET COMMENTS=NULL;
		END IF;
		
		UPDATE CUSTOMER_PERSONAL_DETAILS SET CPD_COMMENTS=COMMENTS WHERE CUSTOMER_ID=CUSTOMERID; 
		SET REPLACE_FLAG=1;
	
		IF TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS IS NOT NULL THEN 
			SET @DROPQUERY=(SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_REPLACE_CUSTOMER_TERMINATION_DETAILS));
			PREPARE DROPQUERYSTMT FROM @DROPQUERY;
			EXECUTE DROPQUERYSTMT;
		END IF;
	END IF;
	
COMMIT;

END;
/*
CALL SP_REPLACE_ACCESS_CARD_UPDATE (180,608418,609998,'LOST','NEW','expatsintegrated@gmail.com',select @A);
*/