-- version 1.1 -- sdate:13/06/2014 -- edate:13/06/2014 -- issue:738 -- commentno:#27 -- desc:IMPLEMENTING TRIGGER CHANGES FOR NOT UPDATING ULD_ID,TIMESTAMP IN TICKLER_HISTORY BY: RAJA
-- version 1.0 -- sdate:12/06/2014 -- edate:12/06/2014 -- issue:738 -- commentno:#18 -- desc:IMPLEMENTING TRIGGER CHANGES FOR NOT UPDATING PRIMARY KEY IN TICKLER_HISTORY BY: RAJA
-- VERSION :0.9, TRACKER: 529, START DATE: 05-06-2014, END DATE: 05-06-2014, DESC: ADDED USERSTAMP AND TIMESTAMP OLD_VALUE IN TICKLER_HISTORY TABLE   DONE BY: DHIVYA.A
-- version:0.8-- sdate:07/04/2014 -- edate:07/04/2014 -- issue:797 -- commentno:28 -- done by:RAGHUNATHU
-- version:0.7 -- sdate:10/02/2014 -- edate:10/02/2014 -- issue:529 -- desc:add comma after 1 header value is completed -- doneby:RL
-- version:0.6 -- sdate:07/02/2014 -- edate:07/02/2014 -- issue:738 -- desc:ADDED ONE CONDITION FOR NOT CREATING NULL ROW IN TICKLER_HISTORY -- doneby:RL
-- version 0.5 -- sd:08/11/2013 -- ed:08/11/2013 -- issue:636 -- commentno:47 -- desc:trigger name changed by rl
-- version 0.4 -- >start date:10/10/2013 end date:10/10/2013-- >issueno:639 -- >desc:ADDED UASD_ID HEADER
-- >doneby:dhivya
-- version 0.3 -- >start date:07/10/2013 end date:10/10/2013-- >issueno:636 -- >desc:changed variable name O as old_value and N as new_value and added comments
-- >doneby:dhivya
-- > version 0.2 -- >date:02/08/2013 -- >issueno:529 -- >commentno:23 -- > changes ECN_SNO TO ECN_ID &added one condition for null fields
-- >doneby:dhivya

-- after update on EMPLOYEE_DETAILS table this trigger will be executed
DROP TRIGGER IF EXISTS TRG_EMPLOYEE_DETAILS_UPDATE;
CREATE TRIGGER TRG_EMPLOYEE_DETAILS_UPDATE  
AFTER UPDATE ON EMPLOYEE_DETAILS
FOR EACH ROW
BEGIN 
-- declaration for old_value and new_value to store it in TICKLER_HISTORY table
DECLARE OLD_VALUE TEXT DEFAULT '';
DECLARE NEW_VALUE TEXT DEFAULT '';
IF ((OLD.EMP_FIRST_NAME!= NEW.EMP_FIRST_NAME) OR (OLD.EMP_LAST_NAME!= NEW.EMP_LAST_NAME) OR (OLD.ECN_ID != NEW.ECN_ID) OR (OLD.EMP_MOBILE!= NEW.EMP_MOBILE)
OR (OLD.EMP_EMAIL IS NULL AND NEW.EMP_EMAIL IS NOT NULL) OR (OLD.EMP_EMAIL IS NOT NULL AND NEW.EMP_EMAIL IS NULL) OR (OLD.EMP_EMAIL != NEW.EMP_EMAIL)
OR (OLD.EMP_COMMENTS IS NULL AND NEW.EMP_COMMENTS IS NOT NULL) OR (OLD.EMP_COMMENTS IS NOT NULL AND NEW.EMP_COMMENTS IS NULL) OR (OLD.EMP_COMMENTS != NEW.EMP_COMMENTS)) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EMP_ID=', OLD.EMP_ID,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for EMP_FIRST_NAME to store it in TICKLER_HISTORY table
IF (OLD.EMP_FIRST_NAME!= NEW.EMP_FIRST_NAME) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EMP_FIRST_NAME=', OLD.EMP_FIRST_NAME,','); 
END IF;
IF (OLD.EMP_FIRST_NAME!= NEW.EMP_FIRST_NAME) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EMP_FIRST_NAME=', NEW.EMP_FIRST_NAME,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for EMP_LAST_NAME to store it in TICKLER_HISTORY table
IF (OLD.EMP_LAST_NAME!= NEW.EMP_LAST_NAME) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EMP_LAST_NAME=', OLD.EMP_LAST_NAME,','); 
END IF;
IF (OLD.EMP_LAST_NAME!= NEW.EMP_LAST_NAME) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EMP_LAST_NAME=', NEW.EMP_LAST_NAME,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for ECN_ID to store it in TICKLER_HISTORY table
IF (OLD.ECN_ID!= NEW.ECN_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ECN_ID=', OLD.ECN_ID,','); 
END IF;
IF (OLD.ECN_ID!= NEW.ECN_ID) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'ECN_ID=', NEW.ECN_ID,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for EMP_MOBILE to store it in TICKLER_HISTORY table
IF (OLD.EMP_MOBILE!= NEW.EMP_MOBILE) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EMP_MOBILE=', OLD.EMP_MOBILE,','); 
END IF;
IF (OLD.EMP_MOBILE!= NEW.EMP_MOBILE) THEN SET 
NEW_VALUE = CONCAT(NEW_VALUE,'EMP_MOBILE=', NEW.EMP_MOBILE,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for EMP_EMAIL to store it in TICKLER_HISTORY table
IF (OLD.EMP_EMAIL IS NULL AND NEW.EMP_EMAIL IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EMP_EMAIL=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EMP_EMAIL=',NEW.EMP_EMAIL,',');
ELSEIF (OLD.EMP_EMAIL IS NOT NULL AND NEW.EMP_EMAIL IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EMP_EMAIL=',OLD.EMP_EMAIL,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EMP_EMAIL=','<NULL>,');
ELSEIF (OLD.EMP_EMAIL!= NEW.EMP_EMAIL) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EMP_EMAIL=', OLD.EMP_EMAIL,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EMP_EMAIL=', NEW.EMP_EMAIL,','); 
END IF;
-- get the OLD VALUE & NEW_VALUE for EMP_COMMENTS to store it in TICKLER_HISTORY table
IF (OLD.EMP_COMMENTS IS NULL AND NEW.EMP_COMMENTS IS NOT NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EMP_COMMENTS=','<NULL>,');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EMP_COMMENTS=',NEW.EMP_COMMENTS,',');
ELSEIF(OLD.EMP_COMMENTS IS NOT NULL AND NEW.EMP_COMMENTS IS NULL) THEN
SET OLD_VALUE=CONCAT(OLD_VALUE,'EMP_COMMENTS=',OLD.EMP_COMMENTS,',');
SET NEW_VALUE=CONCAT(NEW_VALUE,'EMP_COMMENTS=','<NULL>,');
ELSEIF (OLD.EMP_COMMENTS!= NEW.EMP_COMMENTS) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EMP_COMMENTS=', OLD.EMP_COMMENTS,','); 
SET NEW_VALUE = CONCAT(NEW_VALUE,'EMP_COMMENTS=', NEW.EMP_COMMENTS,','); 
END IF;
IF ((OLD.EMP_FIRST_NAME!= NEW.EMP_FIRST_NAME) OR (OLD.EMP_LAST_NAME!= NEW.EMP_LAST_NAME) OR (OLD.ECN_ID != NEW.ECN_ID) OR (OLD.EMP_MOBILE!= NEW.EMP_MOBILE)
OR (OLD.EMP_EMAIL IS NULL AND NEW.EMP_EMAIL IS NOT NULL) OR (OLD.EMP_EMAIL IS NOT NULL AND NEW.EMP_EMAIL IS NULL) OR (OLD.EMP_EMAIL != NEW.EMP_EMAIL)
OR (OLD.EMP_COMMENTS IS NULL AND NEW.EMP_COMMENTS IS NOT NULL) OR (OLD.EMP_COMMENTS IS NOT NULL AND NEW.EMP_COMMENTS IS NULL) OR (OLD.EMP_COMMENTS != NEW.EMP_COMMENTS)) THEN
IF (OLD.ULD_ID!= NEW.ULD_ID) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,','); 
END IF;
IF (OLD.EMP_TIMESTAMP!= NEW.EMP_TIMESTAMP) THEN SET 
OLD_VALUE = CONCAT(OLD_VALUE,'EMP_TIMESTAMP=', OLD.EMP_TIMESTAMP,','); 
END IF;
END IF;
-- inserting old_values and new_values in the TICKLER_HISTORY table with their corresponding POSTTAP_ID in TICKLER_TABID_PROFILE
IF (OLD_VALUE!='' AND NEW_VALUE!='') THEN
IF (OLD_VALUE != NEW_VALUE)THEN
SET OLD_VALUE = SUBSTRING(OLD_VALUE,1,CHAR_LENGTH(OLD_VALUE)-1);
SET NEW_VALUE = SUBSTRING(NEW_VALUE,1,CHAR_LENGTH(NEW_VALUE)-1);
INSERT INTO TICKLER_HISTORY
(ULD_ID,TP_ID,TTIP_ID,TH_OLD_VALUE,TH_NEW_VALUE)VALUES
((SELECT ULD_ID FROM EMPLOYEE_DETAILS WHERE EMP_ID=NEW.EMP_ID),
(SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='UPDATION'),
(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='EMPLOYEE_DETAILS'),OLD_VALUE,NEW_VALUE);
END IF;
END IF;
END;
