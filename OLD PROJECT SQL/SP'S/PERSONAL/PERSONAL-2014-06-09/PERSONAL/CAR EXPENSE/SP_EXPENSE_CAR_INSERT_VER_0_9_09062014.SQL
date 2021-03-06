-- version:0.9 -- sdate:09/06/2014 -- edate:09/06/2014 -- issue:566 --COMMENT NO: 12--desc:IMPLEMENTED ROLL BACK AND COMMIT --doneby:RAJA
-- version:0.8 -- sdate:28/03/2014 -- edate:28/03/2014 -- issue:765 --desc: SOURCE ND DESTINATION SCHEMA GET DYNAMICALLY --doneby:RL
-- version:0.7 -- sdate:17/03/2014 -- edate:17/03/2014 -- issue:765 --desc:droped temp table --doneby:RL
--version:0.6--sdate:22/02/2014 --edate:22/02/2014 --issue:750 -desc:changes source timestamp and userstamp as uld_id done by:dhivya
--version:0.5--sdate:22/02/2014 --edate:22/02/2014 --issue:750 -desc:added preaudit and post audit queries done by:dhivya
--version:0.4 --sdate:04/02/2014 --edate:04/02/2014 --desc:removed main table updation sp  --doneby:RL 
--version:0.3 --sdate:01/02/2014 --edate:01/02/2014 --desc:looping changed as cursor --doneby:RL --issue:718
--QUERY FOR INSERT VALUES EXPENSE_CAR TABLE   
DROP PROCEDURE IF EXISTS SP_EXPENSE_CAR_INSERT;
CREATE PROCEDURE SP_EXPENSE_CAR_INSERT(IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN

	DECLARE DONE INT DEFAULT FALSE;
	DECLARE PEID INTEGER;
	DECLARE CAREXPENSE TEXT;
	DECLARE INVOICEDATE DATE;
	DECLARE CARAMOUNT DECIMAL(7,2);
	DECLARE INVOICEITEM TEXT;
	DECLARE INVOICEFROM VARCHAR(200);
	DECLARE COMMENTS TEXT;
	DECLARE CAR_USERSTAMP VARCHAR(50);
	DECLARE CAR_TIMESTAMP TIMESTAMP;

	DECLARE FILTER_CURSOR CURSOR FOR 

	SELECT TPSF.PE_ID,TPSF.PE_CAR_EXP_TYPE,TPSF.PE_CAR_EXP_INVOICE_DATE,TPSF.PE_CAR_EXP_AMOUNT, TPSF.USERSTAMP,TPSF.TIMESTAMP
	FROM TEMP_PERSONAL_SCDB_FORMAT TPSF WHERE TPSF.PE_TYPE_OF_EXPENSE='CAR EXPENSE';

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
	END;
	START TRANSACTION;
	OPEN FILTER_CURSOR;
		
		read_loop: LOOP
	
			FETCH FILTER_CURSOR INTO PEID,CAREXPENSE,INVOICEDATE,CARAMOUNT,CAR_USERSTAMP,CAR_TIMESTAMP;

			IF DONE THEN
		
				LEAVE read_loop;

			END IF;
			
			SET @CARPERSONALID = PEID;
			SET @CARCATEGORY = CAREXPENSE;
			SET @CARINVOICEDATE = INVOICEDATE;
			SET @CAR_AMOUNT = CARAMOUNT;
			SET @CARUSERSTAMP = CAR_USERSTAMP;
			SET @CARTIMESTAMP = CAR_TIMESTAMP;
			
			SET @EXPENSECARINSERT = (SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.EXPENSE_CAR(ECN_ID,EC_INVOICE_DATE,EC_AMOUNT,EC_INVOICE_ITEMS,EC_INVOICE_FROM,EC_COMMENTS,ULD_ID,EC_TIMESTAMP)
			VALUES ((SELECT ECN_ID FROM ',DESTINATIONSCHEMA,'.EXPENSE_CONFIGURATION WHERE ECN_DATA=@CARCATEGORY AND CGN_ID=21),@CARINVOICEDATE,@CAR_AMOUNT,
			(SELECT DISTINCT PE_INVOICE_ITEMS FROM TEMP_CAR_INVOICE_ITEM_FROM_SPLITTED_TABLE WHERE PE_ID=@CARPERSONALID),
			(SELECT DISTINCT PE_INVOICE_FROM FROM TEMP_CAR_INVOICE_ITEM_FROM_SPLITTED_TABLE WHERE PE_ID=@CARPERSONALID),
			(SELECT DISTINCT PE_COMMENTS FROM TEMP_CAR_INVOICE_ITEM_FROM_SPLITTED_TABLE WHERE PE_ID=@CARPERSONALID),
			(SELECT ULD_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS WHERE ULD_LOGINID=@CARUSERSTAMP),@CARTIMESTAMP)'));
			PREPARE EXPENSECARINSERTSTMT FROM @EXPENSECARINSERT;
			EXECUTE EXPENSECARINSERTSTMT;
	
		END LOOP;

	CLOSE FILTER_CURSOR;
COMMIT;
END;
