-- version 1.2 -- sdate:012/06/2014 -- edate:12/06/2014 -- issue:738 -- commentno:#18 -- desc:IMPLEMENTING TRIGGER CHANGES FOR NOT UPDATING PRIMARY KEY IN TICKLER_HISTORY BY: RAJA
-- version:1.1 -- sdate:05/06/2014 -- edate:05/06/2014 -- issue:529 -- comment no:196 -- desc:ADDED ULD_ID & TIMESTAMP OLD VALUE & NEW VALUE -- done by:RL
-- > version 1.0 -- >start date:07/04/2014 end date:07/04/2014-- >issueno:797 -- >desc:replaced tablename and header name doneby:sasikala
-- version:0.9 -- sdate:26/02/2014 -- edate:26/02/2014 -- issue:529 -- commentno:132 -- done by:RL
-- version:0.8 -- sdate:10/02/2014 -- edate:10/02/2014 -- issue:529 -- desc:add comma after 1 header value is completed -- doneby:RL
-- version:0.7 -- sdate:08/02/2014 -- edate:08/02/2014 -- issue:738 -- desc:ADDED ONE CONDITION FOR NOT CREATING NULL ROW IN TICKLER_HISTORY -- doneby:RL
-- version 0.6 -- sd:18/11/2013 -- ed:18/11/2013 -- issue:657 -- commentno:5 -- desc:added one condition to insert values in tickler_history table by rl
-- version 0.5 -- sd:08/11/2013 -- ed:08/11/2013 -- issue:636 -- commentno:47 -- desc:trigger name changed by rl
-- > version 0.4 -- >start date:07/10/2013 end date:10/10/2013-- >issueno:636 -- >desc:changed variable name O as old_value and N as new_value and added comments
-- >doneby:dhivya
-- > version 0.3 -- >date:07/08/2013 -- >issueno:587 -- >commentno:23 -- >desc:changed null condition for customer_id field
-- >doneby:dhivya
-- > version 0.2 -- >date:03/08/2013 -- >issueno:529 -- >commentno:23 -- >desc:changes ECN_SNO TO ECN_ID & added one condition for null fields
-- >doneby:dhivya

-- after update on EXPENSE_UNIT table this trigger will be executed
DROP TRIGGER IF EXISTS TRG_BIZDLY_UNITEXP_UPDATE;
CREATE TRIGGER TRG_BIZDLY_UNITEXP_UPDATE  
AFTER UPDATE ON EXPENSE_UNIT
FOR EACH ROW
BEGIN 
-- declaration for old_value and new_value to store it in TICKLER_HISTORY table
DECLARE OLD_VALUE TEXT DEFAULT '';
DECLARE NEW_VALUE TEXT DEFAULT '';
IF ((OLD.UNIT_ID!= NEW.UNIT_ID) OR (OLD.ECN_ID!= NEW.ECN_ID) OR (OLD.CUSTOMER_ID IS NULL AND NEW.CUSTOMER_ID IS NOT NULL) OR (OLD.CUSTOMER_ID IS NOT NULL AND NEW.CUSTOMER_ID IS NULL) OR (OLD.CUSTOMER_ID !=NEW.CUSTOMER_ID)
OR (OLD.EU_INVOICE_DATE!= NEW.EU_INVOICE_DATE) OR (OLD.EU_AMOUNT!= NEW.EU_AMOUNT) OR (OLD.EU_INVOICE_ITEMS!= NEW.EU_INVOICE_ITEMS) OR (OLD.EU_INVOICE_FROM!= NEW.EU_INVOICE_FROM)
OR (OLD.EU_COMMENTS IS NULL AND NEW.EU_COMMENTS IS NOT NULL) OR (OLD.EU_COMMENTS IS NOT NULL AND NEW.EU_COMMENTS IS NULL) OR (OLD.EU_COMMENTS != NEW.EU_COMMENTS)
OR (OLD.ULD_ID!= NEW.ULD_ID)) THEN  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'EU_ID=', OLD.EU_ID,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for UNIT_ID to store it in TICKLER_HISTORY table
IF (OLD.UNIT_ID!= NEW.UNIT_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'UNIT_ID=', OLD.UNIT_ID,','); 
END IF;
IF (OLD.UNIT_ID!= NEW.UNIT_ID) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'UNIT_ID=', NEW.UNIT_ID,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for UNIT_ID to store it in TICKLER_HISTORY table
IF (OLD.ECN_ID!= NEW.ECN_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ECN_ID=', OLD.ECN_ID,','); 
END IF;
IF (OLD.ECN_ID!= NEW.ECN_ID) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'ECN_ID=', NEW.ECN_ID,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for CUSTOMER_ID to store it in TICKLER_HISTORY table
IF (OLD.CUSTOMER_ID IS NULL AND NEW.CUSTOMER_ID IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'CUSTOMER_ID=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'CUSTOMER_ID=',NEW.CUSTOMER_ID,',');
ELSEIF(OLD.CUSTOMER_ID IS NOT NULL AND NEW.CUSTOMER_ID IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'CUSTOMER_ID=',OLD.CUSTOMER_ID,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'CUSTOMER_ID=','<NULL>,');
ELSEIF (OLD.CUSTOMER_ID!= NEW.CUSTOMER_ID) THEN 
SET OLD_VALUE = CONCAT(OLD_VALUE,'CUSTOMER_ID=', OLD.CUSTOMER_ID,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'CUSTOMER_ID=', NEW.CUSTOMER_ID,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for EU_INVOICE_DATE to store it in TICKLER_HISTORY table
IF (OLD.EU_INVOICE_DATE!= NEW.EU_INVOICE_DATE) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EU_INVOICE_DATE=', OLD.EU_INVOICE_DATE,','); 
END IF;
IF (OLD.EU_INVOICE_DATE!= NEW.EU_INVOICE_DATE) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EU_INVOICE_DATE=', NEW.EU_INVOICE_DATE,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for EU_AMOUNT to store it in TICKLER_HISTORY table
IF (OLD.EU_AMOUNT!= NEW.EU_AMOUNT) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EU_AMOUNT=', OLD.EU_AMOUNT,','); 
END IF;
IF (OLD.EU_AMOUNT!= NEW.EU_AMOUNT) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EU_AMOUNT=', NEW.EU_AMOUNT,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for EU_INVOICE_ITEMS to store it in TICKLER_HISTORY table
IF (OLD.EU_INVOICE_ITEMS!= NEW.EU_INVOICE_ITEMS) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EU_INVOICE_ITEMS=', OLD.EU_INVOICE_ITEMS,','); 
END IF;
IF (OLD.EU_INVOICE_ITEMS!= NEW.EU_INVOICE_ITEMS) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EU_INVOICE_ITEMS=', NEW.EU_INVOICE_ITEMS,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for EU_INVOICE_FROM to store it in TICKLER_HISTORY table
IF (OLD.EU_INVOICE_FROM!= NEW.EU_INVOICE_FROM) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EU_INVOICE_FROM=', OLD.EU_INVOICE_FROM,','); 
END IF;
IF (OLD.EU_INVOICE_FROM!= NEW.EU_INVOICE_FROM) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EU_INVOICE_FROM=', NEW.EU_INVOICE_FROM,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for EU_COMMENTS to store it in TICKLER_HISTORY table
IF (OLD.EU_COMMENTS IS NULL AND NEW.EU_COMMENTS IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EU_COMMENTS=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EU_COMMENTS=',NEW.EU_COMMENTS,',');
ELSEIF(OLD.EU_COMMENTS IS NOT NULL AND NEW.EU_COMMENTS IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EU_COMMENTS=',OLD.EU_COMMENTS,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EU_COMMENTS=','<NULL>,');
ELSEIF (OLD.EU_COMMENTS!= NEW.EU_COMMENTS) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EU_COMMENTS=', OLD.EU_COMMENTS,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EU_COMMENTS=', NEW.EU_COMMENTS,','); 
END IF;

IF (OLD.ULD_ID!= NEW.ULD_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
END IF;
IF (OLD.EU_TIMESTAMP!= NEW.EU_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EU_TIMESTAMP=', OLD.EU_TIMESTAMP,','); 
END IF;

-- inserting old_values and new_values in the TICKLER_HISTORY table with their corresponding TTIP_ID in TICKLER_TABID_PROFILE
IF (OLD_VALUE IS NOT NULL AND NEW_VALUE IS NOT NULL) THEN
IF(OLD_VALUE != NEW_VALUE)THEN
SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
INSERT INTO TICKLER_HISTORY
(ULD_ID,TP_ID,TTIP_ID,CUSTOMER_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
((SELECT ULD_ID FROM EXPENSE_UNIT WHERE EU_ID=NEW.EU_ID),
(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='EXPENSE_UNIT'),
(SELECT CUSTOMER_ID FROM EXPENSE_UNIT WHERE CUSTOMER_ID=NEW.CUSTOMER_ID AND EU_ID=NEW.EU_ID),OLD_VALUE,NEW_VALUE);
END IF;
END IF;
END;

