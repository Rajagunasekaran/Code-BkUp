-- version 0.7 srartdate:14/07/2014 -- enddate:14/07/2014-- - issueno 817 desc: REMOVE THE s FROM TABLE NAME TEMP_BANKTT_SEARCsH_TABLE done by RAJA.
-- version 0.6 srartdate:21/06/2014 -- enddate:21/06/2014-- - issueno 817 desc: DROP THE TEMP TABLES IF ROLLBACK OCCURS done by RAJA.
-- version 0.5 srartdate:01/06/2014 -- enddate:01/06/2014-- - issueno 675 desc:CHANGED ACC_NAME DATATYPE VARCHAR(25)TO VARCHAR(40) done by KUMAR R.
-- version 0.4 startdate:15/05/2014 -- enddate:15/05/2014-- - issueno 817 desc:Gave 2 temp table in output parameter. 
-- version 0.3 startdate:02/05/2014 -- enddate:02/05/2014-- - issueno 817 commentno:15 -- >desc:changed temp table for dynamic running purpose 
-- version 0.2 startdate:28/02/2014 -- enddate:28/02/2014-- - issueno 754 commentno:36-- >desc:changed userstamp variable as uld_loginid done by:Dhivya 
-- version 0.1-- >startdate:25/01/2014 enddate:27/01/2014 -- >issue no:536 comment no:#39 desc:temp table sp for banktt domain updation by:DHIVYA.A
DROP PROCEDURE IF EXISTS SP_TEMP_TABLE_BANKTT;
CREATE PROCEDURE SP_TEMP_TABLE_BANKTT(
BANKTT_FROM_INPUT VARCHAR(50),
BANK_TT_TO_INPUT VARCHAR(100),
BANK_TT_SEARCH_OPTION INTEGER,
IN USERSTAMP VARCHAR(50),
OUT BANKTT_SEARCH_TEMPTBLNAME TEXT,
OUT BANKTT_TEMP_TABLE_NAME TEXT)
BEGIN
DECLARE MAX_ID INTEGER;
DECLARE BANK_TT_LIST_TEMPTBL TEXT;
DECLARE BANK_TT_SEARCH_TEMPTBL TEXT;
DECLARE BANKTT_TEMPTBL TEXT;
DECLARE BANKTT_LIST_TEMPTBLNAME TEXT;
DECLARE USERSTAMP_ID INT;
--  DECLARE BANKTT_TEMP_TABLE_NAME TEXT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
IF(BANKTT_LIST_TEMPTBLNAME IS NOT NULL)THEN
	SET @DROP_BANK_TT_LIST =(SELECT CONCAT('DROP TABLE IF EXISTS ',BANKTT_LIST_TEMPTBLNAME));
	PREPARE DROP_BANK_TT_LIST_STMT FROM @DROP_BANK_TT_LIST;
	EXECUTE DROP_BANK_TT_LIST_STMT;
END IF;
END;
START TRANSACTION;

--    TEMP TABLE NAME START
    CALL SP_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULDID);
	SET USERSTAMP_ID=(SELECT @ULDID);
	SET BANK_TT_LIST_TEMPTBL=(SELECT CONCAT('TEMP_BANKTT_LIST',SYSDATE()));
	SET BANK_TT_SEARCH_TEMPTBL=(SELECT CONCAT('TEMP_BANKTT_SEARCH_TABLE',SYSDATE()));
--    temp table name
	SET BANK_TT_LIST_TEMPTBL=(SELECT REPLACE(BANK_TT_LIST_TEMPTBL,' ',''));
	SET BANK_TT_LIST_TEMPTBL=(SELECT REPLACE(BANK_TT_LIST_TEMPTBL,'-',''));
	SET BANK_TT_LIST_TEMPTBL=(SELECT REPLACE(BANK_TT_LIST_TEMPTBL,':',''));
	SET BANKTT_LIST_TEMPTBLNAME=(SELECT CONCAT(BANK_TT_LIST_TEMPTBL,'_',USERSTAMP_ID)); 
--    TEMP TABLE NAME END

--  CREATE QUERY FOR BANKTT_LIST_TEMPTBLNAME

	SET @CREATE_TEMP_BANKTT_LIST=(SELECT CONCAT('CREATE TABLE ',BANKTT_LIST_TEMPTBLNAME,'(ID INTEGER AUTO_INCREMENT PRIMARY KEY,BTID INTEGER)'));
	PREPARE CREATE_TEMP_BANKTT_LIST_STMT FROM @CREATE_TEMP_BANKTT_LIST;
	EXECUTE CREATE_TEMP_BANKTT_LIST_STMT;

	IF (BANK_TT_SEARCH_OPTION=1)THEN
		--  IF THE SEARCH OPTION S UNIT MEANS INSERT QUERY FOR BANKTT_LIST_TEMPTBLNAME
			SET @INSERT_TEMP_BANKTT_LIST=(SELECT CONCAT('INSERT INTO ',BANKTT_LIST_TEMPTBLNAME,' (BTID)SELECT BT_ID FROM BANK_TRANSFER_DETAIL WHERE UNIT_ID=(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=',BANKTT_FROM_INPUT,')'));
			PREPARE INSERT_TEMP_BANKTT_LIST_STMT FROM @INSERT_TEMP_BANKTT_LIST;
			EXECUTE INSERT_TEMP_BANKTT_LIST_STMT;
	END IF;
--  IF THE SEARCH OPTION S CUSTOMER MEANS INSERT QUERY FOR BANKTT_LIST_TEMPTBLNAME

	IF (BANK_TT_SEARCH_OPTION=2)THEN
		SET @INSERT_TEMP_BANKTT_LIST=(SELECT CONCAT('INSERT INTO ',BANKTT_LIST_TEMPTBLNAME,' (BTID)SELECT DISTINCT BT_ID FROM BANK_TRANSFER_DETAIL WHERE CUSTOMER_ID IN (SELECT CUSTOMER_ID FROM CUSTOMER WHERE CUSTOMER_FIRST_NAME=(SELECT SUBSTRING_INDEX(','"',BANK_TT_TO_INPUT,'"',',''_'',1)) AND CUSTOMER_LAST_NAME=(SELECT SUBSTRING_INDEX(','"',BANK_TT_TO_INPUT,'"',',''_'',-1)) AND UNIT_ID IN(SELECT UNIT_ID FROM UNIT WHERE UNIT_NO=',BANKTT_FROM_INPUT,'))'));
		PREPARE INSERT_TEMP_BANKTT_LIST_STMT FROM @INSERT_TEMP_BANKTT_LIST;
		EXECUTE INSERT_TEMP_BANKTT_LIST_STMT;
	END IF;
	
--  IF THE SEARCH OPTION S DATE RANGE MEANS INSERT QUERY FOR BANKTT_LIST_TEMPTBLNAME

	IF (BANK_TT_SEARCH_OPTION=3)THEN
		SET @INSERT_TEMP_BANKTT_LIST=(SELECT CONCAT('INSERT INTO ',BANKTT_LIST_TEMPTBLNAME,' (BTID)SELECT DISTINCT BT_ID FROM BANK_TRANSFER WHERE BT_DATE BETWEEN ','"',BANKTT_FROM_INPUT,'"', ' AND ' ,'"',BANK_TT_TO_INPUT,'"'));
		PREPARE INSERT_TEMP_BANKTT_LIST_STMT FROM @INSERT_TEMP_BANKTT_LIST;
		EXECUTE INSERT_TEMP_BANKTT_LIST_STMT;
	END IF;

--  IF THE SEARCH OPTION S ACCOUNT NAME MEANS INSERT QUERY FOR TEMP_BANKTT_LIST

	IF (BANK_TT_SEARCH_OPTION=4)THEN
		SET @INSERT_TEMP_BANKTT_LIST=(SELECT CONCAT('INSERT INTO ',BANKTT_LIST_TEMPTBLNAME,' (BTID) SELECT DISTINCT BT_ID FROM BANK_TRANSFER WHERE BT_ACC_NAME=','"',BANKTT_FROM_INPUT,'"'));
		PREPARE INSERT_TEMP_BANKTT_LIST_STMT FROM @INSERT_TEMP_BANKTT_LIST;
		EXECUTE INSERT_TEMP_BANKTT_LIST_STMT;
	END IF;

--  IF THE SEARCH OPTION S AMOUNT RANGE MEANS INSERT QUERY FOR TEMP_BANKTT_LIST

	IF (BANK_TT_SEARCH_OPTION=5)THEN
   		SET @INSERT_TEMP_BANKTT_LIST=(SELECT CONCAT('INSERT INTO ',BANKTT_LIST_TEMPTBLNAME,' (BTID) SELECT DISTINCT BT_ID FROM BANK_TRANSFER WHERE BT_AMOUNT BETWEEN ','"',BANKTT_FROM_INPUT,'"', ' AND ' ,'"',BANK_TT_TO_INPUT,'"'));
		PREPARE INSERT_TEMP_BANKTT_LIST_STMT FROM @INSERT_TEMP_BANKTT_LIST;
		EXECUTE INSERT_TEMP_BANKTT_LIST_STMT;
	END IF;
	
--  IF THE SEARCH OPTION S MODEL MEANS INSERT QUERY FOR TEMP_BANKTT_LIST

	IF (BANK_TT_SEARCH_OPTION=6)THEN
    	SET @INSERT_TEMP_BANKTT_LIST=(SELECT CONCAT('INSERT INTO ',BANKTT_LIST_TEMPTBLNAME,' (BTID) SELECT DISTINCT BT_ID FROM BANK_TRANSFER WHERE BTM_ID=(SELECT BTM_ID FROM BANK_TRANSFER_MODELS WHERE BTM_DATA=','"',BANKTT_FROM_INPUT,'"',')'));
		PREPARE INSERT_TEMP_BANKTT_LIST_STMT FROM @INSERT_TEMP_BANKTT_LIST;
		EXECUTE INSERT_TEMP_BANKTT_LIST_STMT;
	END IF;
 
 
--    temp table name
	SET BANK_TT_SEARCH_TEMPTBL=(SELECT REPLACE(BANK_TT_SEARCH_TEMPTBL,' ',''));
	SET BANK_TT_SEARCH_TEMPTBL=(SELECT REPLACE(BANK_TT_SEARCH_TEMPTBL,'-',''));
	SET BANK_TT_SEARCH_TEMPTBL=(SELECT REPLACE(BANK_TT_SEARCH_TEMPTBL,':',''));
	SET BANKTT_SEARCH_TEMPTBLNAME=(SELECT CONCAT(BANK_TT_SEARCH_TEMPTBL,'_',USERSTAMP_ID)); 
--    TEMP TABLE NAME END

--  CREATE QUERY FOR BANKTT_SEARCH_TEMPTBLNAME
		SET @CREATE_TEMP_BANKTT_SEARCH_TABLE=(SELECT CONCAT('CREATE TABLE ',BANKTT_SEARCH_TEMPTBLNAME,'(BT_ID INTEGER,BANK_TRANSFER_TYPE VARCHAR(30),TRANSACTION_STATUS VARCHAR(30),BANK_TRANSFER_CHARGES_TO VARCHAR(30),BANK_TRANSFER_CREATED_BY VARCHAR(30))'));
		PREPARE CREATE_TEMP_BANKTT_SEARCH_TABLE_STMT FROM @CREATE_TEMP_BANKTT_SEARCH_TABLE;
		EXECUTE CREATE_TEMP_BANKTT_SEARCH_TABLE_STMT;

		SET @LIST_MAX_ID=(SELECT CONCAT('SELECT MAX(ID) INTO @MAXID FROM ',BANKTT_LIST_TEMPTBLNAME));
		PREPARE LIST_MAX_ID_STMT FROM @LIST_MAX_ID;
		EXECUTE LIST_MAX_ID_STMT;
		SET MAX_ID=@MAXID;
	
		WHILE MAX_ID!=0 DO
     
			--  INSERT QUERY FOR TEMP_BANKTT_SEARCH_TABLE
	 
				SET @INSERT_TEMP_BANKTT_SEARCH_TABLE=(SELECT CONCAT('INSERT INTO ',BANKTT_SEARCH_TEMPTBLNAME,' (BT_ID,BANK_TRANSFER_TYPE,TRANSACTION_STATUS,BANK_TRANSFER_CHARGES_TO,BANK_TRANSFER_CREATED_BY)VALUES((SELECT BTID FROM ',BANKTT_LIST_TEMPTBLNAME,' WHERE ID=',MAX_ID,'),(SELECT BCN_DATA FROM BANKTT_CONFIGURATION WHERE BCN_ID=(SELECT BCN_ID FROM BANK_TRANSFER_STATUS_DETAILS WHERE BT_ID=(SELECT BTID FROM ',BANKTT_LIST_TEMPTBLNAME,' WHERE ID=',MAX_ID,')AND CGN_ID=69)),(SELECT BCN_DATA FROM BANKTT_CONFIGURATION WHERE BCN_ID=(SELECT BCN_ID FROM BANK_TRANSFER_STATUS_DETAILS WHERE BT_ID=(SELECT BTID FROM ',BANKTT_LIST_TEMPTBLNAME,' WHERE ID=',MAX_ID,')AND CGN_ID=70)),(SELECT BCN_DATA FROM BANKTT_CONFIGURATION WHERE BCN_ID=(SELECT BCN_ID FROM BANK_TRANSFER_STATUS_DETAILS WHERE BT_ID=(SELECT BTID FROM ',BANKTT_LIST_TEMPTBLNAME,' WHERE ID=',MAX_ID,')AND CGN_ID=71)),(SELECT BCN_DATA FROM BANKTT_CONFIGURATION WHERE BCN_ID=(SELECT BCN_ID FROM BANK_TRANSFER_STATUS_DETAILS WHERE BT_ID=(SELECT BTID FROM ',BANKTT_LIST_TEMPTBLNAME,' WHERE ID=',MAX_ID,')AND CGN_ID=72)))'));
				PREPARE INSERT_TEMP_BANKTT_SEARCH_TABLE_STMT FROM @INSERT_TEMP_BANKTT_SEARCH_TABLE;
				EXECUTE INSERT_TEMP_BANKTT_SEARCH_TABLE_STMT;
	 
				SET @UPDATE_TEMP_BANKTT_SEARCH_TABLE=(SELECT CONCAT('UPDATE ',BANKTT_SEARCH_TEMPTBLNAME,' SET BANK_TRANSFER_TYPE=(SELECT BTM_DATA FROM BANK_TRANSFER_MODELS WHERE BTM_ID=(SELECT BTM_ID FROM BANK_TRANSFER WHERE BT_ID=(SELECT BTID FROM ',BANKTT_LIST_TEMPTBLNAME,' WHERE ID=',MAX_ID,'))) WHERE BANK_TRANSFER_TYPE IS NULL'));
				PREPARE UPDATE_TEMP_BANKTT_SEARCH_TABLE_STMT FROM @UPDATE_TEMP_BANKTT_SEARCH_TABLE;
				EXECUTE UPDATE_TEMP_BANKTT_SEARCH_TABLE_STMT;
				SET MAX_ID=MAX_ID-1;
		END WHILE;
		
IF (BANK_TT_SEARCH_OPTION=3 OR BANK_TT_SEARCH_OPTION=5 OR BANK_TT_SEARCH_OPTION=6)THEN
	--    TEMP TABLE NAME START
		SET BANKTT_TEMPTBL=(SELECT CONCAT('BANKTT_TEMP_TABLE',SYSDATE()));
	--    temp table name
		SET BANKTT_TEMPTBL=(SELECT REPLACE(BANKTT_TEMPTBL,' ',''));
		SET BANKTT_TEMPTBL=(SELECT REPLACE(BANKTT_TEMPTBL,'-',''));
		SET BANKTT_TEMPTBL=(SELECT REPLACE(BANKTT_TEMPTBL,':',''));
		SET BANKTT_TEMP_TABLE_NAME=(SELECT CONCAT(BANKTT_TEMPTBL,'_',USERSTAMP_ID)); 
	--    TEMP TABLE NAME END
		SET @CREATE_BANKTT_TEMP_TABLE=(SELECT CONCAT('CREATE TABLE ',BANKTT_TEMP_TABLE_NAME,'(SNO INTEGER AUTO_INCREMENT NOT NULL PRIMARY KEY,BT_ID INTEGER,BANK_TRANSFER_TYPE VARCHAR(50),BT_DATE DATE,UNIT_NO INTEGER,CUSTOMERNAME VARCHAR(100),BT_ACC_NO VARCHAR(25),BT_ACC_NAME VARCHAR(40),BT_AMOUNT DECIMAL(7,2),TRANSACTION_STATUS VARCHAR(20),BT_DEBITED_ON DATE,BT_BANK_CODE VARCHAR(4),BT_BRANCH_CODE VARCHAR(4),BT_BANK_ADDRESS TEXT,BT_SWIFT_CODE VARCHAR(25),BANK_TRANSFER_CHARGES_TO VARCHAR(20),BT_CUST_REF VARCHAR(50),BT_INV_DETAILS TEXT,BANK_TRANSFER_CREATED_BY VARCHAR(50),BT_COMMENTS TEXT,ULD_LOGINID VARCHAR(50),BT_TIMESTAMP TIMESTAMP)'));
		PREPARE CREATE_BANKTT_TEMP_TABLE_STMT FROM @CREATE_BANKTT_TEMP_TABLE;
		EXECUTE CREATE_BANKTT_TEMP_TABLE_STMT;
		IF BANK_TT_SEARCH_OPTION=3 THEN
			SET @INSERT_BANKTT_TEMP_TABLE=(SELECT CONCAT('INSERT INTO ',BANKTT_TEMP_TABLE_NAME,' (BT_ID,BANK_TRANSFER_TYPE,BT_DATE,UNIT_NO,CUSTOMERNAME,BT_ACC_NO,BT_ACC_NAME,BT_AMOUNT,TRANSACTION_STATUS,BT_DEBITED_ON,BT_BANK_CODE,BT_BRANCH_CODE,BT_BANK_ADDRESS,BT_SWIFT_CODE,BANK_TRANSFER_CHARGES_TO,BT_CUST_REF,BT_INV_DETAILS,BANK_TRANSFER_CREATED_BY,BT_COMMENTS,ULD_LOGINID,BT_TIMESTAMP)SELECT BT.BT_ID,TBST.BANK_TRANSFER_TYPE,BT.BT_DATE,U.UNIT_NO,CONCAT(C.CUSTOMER_FIRST_NAME,',"' '",',CUSTOMER_LAST_NAME)AS CUSTOMERNAME,BT.BT_ACC_NO,BT.BT_ACC_NAME,BT.BT_AMOUNT,TBST.TRANSACTION_STATUS,BT.BT_DEBITED_ON,BT.BT_BANK_CODE,BT.BT_BRANCH_CODE,BT.BT_BANK_ADDRESS,BT.BT_SWIFT_CODE,TBST.BANK_TRANSFER_CHARGES_TO,BT.BT_CUST_REF,BT.BT_INV_DETAILS,TBST.BANK_TRANSFER_CREATED_BY,BT.BT_COMMENTS,ULD.ULD_LOGINID,BT.BT_TIMESTAMP FROM BANK_TRANSFER BT,BANK_TRANSFER_DETAIL BTD,UNIT U,CUSTOMER C,',BANKTT_SEARCH_TEMPTBLNAME,' TBST,USER_LOGIN_DETAILS ULD WHERE BT.BT_ID=BTD.BT_ID AND U.UNIT_ID=BTD.UNIT_ID AND C.CUSTOMER_ID=BTD.CUSTOMER_ID AND TBST.BT_ID=BTD.BT_ID AND BT.ULD_ID=ULD.ULD_ID'));
			PREPARE INSERT_BANKTT_TEMP_TABLE_STMT FROM @INSERT_BANKTT_TEMP_TABLE;
			EXECUTE INSERT_BANKTT_TEMP_TABLE_STMT;	
			SET @INSERT_BANKTT_TEMP_TABLE=(SELECT CONCAT('INSERT INTO ',BANKTT_TEMP_TABLE_NAME,' (BT_ID,BANK_TRANSFER_TYPE,BT_DATE,BT_AMOUNT,TRANSACTION_STATUS,BT_DEBITED_ON,BT_BANK_ADDRESS,BT_CUST_REF,BT_INV_DETAILS,BT_COMMENTS,ULD_LOGINID,BANK_TRANSFER_CREATED_BY,BT_TIMESTAMP)SELECT BT.BT_ID,TBST.BANK_TRANSFER_TYPE,BT.BT_DATE,BT.BT_AMOUNT,TBST.TRANSACTION_STATUS,BT_DEBITED_ON,BT.BT_BANK_ADDRESS,BT.BT_CUST_REF,BT.BT_INV_DETAILS,BT.BT_COMMENTS,ULD.ULD_LOGINID,TBST.BANK_TRANSFER_CREATED_BY,BT.BT_TIMESTAMP FROM BANK_TRANSFER BT,',BANKTT_SEARCH_TEMPTBLNAME,' TBST,BANK_TRANSFER_MODELS BTM,USER_LOGIN_DETAILS ULD WHERE TBST.BT_ID=BT.BT_ID AND BT.BTM_ID=BTM.BTM_ID AND ULD.ULD_ID=BT.ULD_ID;'));
			PREPARE INSERT_BANKTT_TEMP_TABLE_STMT FROM @INSERT_BANKTT_TEMP_TABLE;
			EXECUTE INSERT_BANKTT_TEMP_TABLE_STMT;	
		END IF;
		
		IF BANK_TT_SEARCH_OPTION=5 THEN
			SET @INSERT_BANKTT_TEMP_TABLE=(SELECT CONCAT('INSERT INTO ',BANKTT_TEMP_TABLE_NAME,' (BT_ID,BANK_TRANSFER_TYPE,BT_DATE,UNIT_NO,CUSTOMERNAME,BT_ACC_NO,BT_ACC_NAME,BT_AMOUNT,TRANSACTION_STATUS,BT_DEBITED_ON,BT_BANK_CODE,BT_BRANCH_CODE,BT_BANK_ADDRESS,BT_SWIFT_CODE,BANK_TRANSFER_CHARGES_TO,BT_CUST_REF,BT_INV_DETAILS,BANK_TRANSFER_CREATED_BY,BT_COMMENTS,ULD_LOGINID,BT_TIMESTAMP)SELECT BT.BT_ID,TBST.BANK_TRANSFER_TYPE,BT.BT_DATE,U.UNIT_NO,CONCAT(C.CUSTOMER_FIRST_NAME,',"' '",',CUSTOMER_LAST_NAME)AS CUSTOMERNAME,BT.BT_ACC_NO,BT.BT_ACC_NAME,BT.BT_AMOUNT,TBST.TRANSACTION_STATUS,BT.BT_DEBITED_ON,BT.BT_BANK_CODE,BT.BT_BRANCH_CODE,BT.BT_BANK_ADDRESS,BT.BT_SWIFT_CODE,TBST.BANK_TRANSFER_CHARGES_TO,BT.BT_CUST_REF,BT.BT_INV_DETAILS,TBST.BANK_TRANSFER_CREATED_BY,BT.BT_COMMENTS,ULD.ULD_LOGINID,BT.BT_TIMESTAMP FROM BANK_TRANSFER BT,BANK_TRANSFER_DETAIL BTD,UNIT U,CUSTOMER C,',BANKTT_SEARCH_TEMPTBLNAME,' TBST,USER_LOGIN_DETAILS ULD WHERE BT.BT_ID=BTD.BT_ID AND U.UNIT_ID=BTD.UNIT_ID AND C.CUSTOMER_ID=BTD.CUSTOMER_ID AND TBST.BT_ID=BTD.BT_ID AND BT.ULD_ID=ULD.ULD_ID'));
			PREPARE INSERT_BANKTT_TEMP_TABLE_STMT FROM @INSERT_BANKTT_TEMP_TABLE;
			EXECUTE INSERT_BANKTT_TEMP_TABLE_STMT;

			SET @INSERT_BANKTT_TEMP_TABLE=(SELECT CONCAT('INSERT INTO ',BANKTT_TEMP_TABLE_NAME,' (BT_ID,BANK_TRANSFER_TYPE,BT_DATE,BT_AMOUNT,TRANSACTION_STATUS,BT_DEBITED_ON,BT_BANK_ADDRESS,BT_CUST_REF,BT_INV_DETAILS,BT_COMMENTS,ULD_LOGINID,BANK_TRANSFER_CREATED_BY,BT_TIMESTAMP)SELECT BT.BT_ID,TBST.BANK_TRANSFER_TYPE,BT.BT_DATE,BT.BT_AMOUNT,TBST.TRANSACTION_STATUS,BT_DEBITED_ON,BT.BT_BANK_ADDRESS,BT.BT_CUST_REF,BT.BT_INV_DETAILS,BT.BT_COMMENTS,ULD.ULD_LOGINID,TBST.BANK_TRANSFER_CREATED_BY,BT.BT_TIMESTAMP FROM BANK_TRANSFER BT,',BANKTT_SEARCH_TEMPTBLNAME,' TBST,BANK_TRANSFER_MODELS BTM,USER_LOGIN_DETAILS ULD WHERE TBST.BT_ID=BT.BT_ID AND BT.BTM_ID=BTM.BTM_ID AND ULD.ULD_ID=BT.ULD_ID'));
			PREPARE INSERT_BANKTT_TEMP_TABLE_STMT FROM @INSERT_BANKTT_TEMP_TABLE;
			EXECUTE INSERT_BANKTT_TEMP_TABLE_STMT;
		END IF;
	
		IF BANK_TT_SEARCH_OPTION=6 THEN
			SET @INSERT_BANKTT_TEMP_TABLE=(SELECT CONCAT('INSERT INTO ',BANKTT_TEMP_TABLE_NAME,' (BT_ID,BANK_TRANSFER_TYPE,BT_DATE,BT_AMOUNT,TRANSACTION_STATUS,BT_DEBITED_ON,BT_BANK_ADDRESS,BT_CUST_REF,BT_INV_DETAILS,BT_COMMENTS,ULD_LOGINID,BANK_TRANSFER_CREATED_BY,BT_TIMESTAMP) SELECT BT.BT_ID,TBST.BANK_TRANSFER_TYPE,BT.BT_DATE,BT.BT_AMOUNT,TBST.TRANSACTION_STATUS,BT_DEBITED_ON,BT.BT_BANK_ADDRESS,BT.BT_CUST_REF,BT.BT_INV_DETAILS,BT.BT_COMMENTS,ULD.ULD_LOGINID,TBST.BANK_TRANSFER_CREATED_BY,BT.BT_TIMESTAMP FROM BANK_TRANSFER BT,',BANKTT_SEARCH_TEMPTBLNAME,' TBST,BANK_TRANSFER_MODELS BTM,USER_LOGIN_DETAILS ULD WHERE TBST.BT_ID=BT.BT_ID AND BT.BTM_ID=BTM.BTM_ID AND BT.ULD_ID=ULD.ULD_ID'));
			PREPARE INSERT_BANKTT_TEMP_TABLE_STMT FROM @INSERT_BANKTT_TEMP_TABLE;
			EXECUTE INSERT_BANKTT_TEMP_TABLE_STMT;
		END IF;
END IF;
	SET @DROP_BANK_TT_LIST =(SELECT CONCAT('DROP TABLE IF EXISTS ',BANKTT_LIST_TEMPTBLNAME));
	PREPARE DROP_BANK_TT_LIST_STMT FROM @DROP_BANK_TT_LIST;
	EXECUTE DROP_BANK_TT_LIST_STMT;
COMMIT;
END;