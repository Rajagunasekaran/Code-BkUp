DROP TRIGGER IF EXISTS TRG_TS_USER_ADMIN_REPORT_DETAILS_AFTER_DELETION;
CREATE TRIGGER TRG_TS_USER_ADMIN_REPORT_DETAILS_AFTER_DELETION
AFTER DELETE ON USER_ADMIN_REPORT_DETAILS
FOR EACH ROW
BEGIN
  DECLARE OLD_VALUE TEXT DEFAULT '';
  
  -- FOR GET OLDVALUES
  SET OLD_VALUE = CONCAT(OLD_VALUE,'UARD_ID=', OLD.UARD_ID,',');
  
  IF (OLD.UARD_REPORT IS NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'UARD_REPORT=','<NULL>,');
  ELSEIF (OLD.UARD_REPORT IS NOT NULL) THEN
    SET OLD_VALUE=CONCAT(OLD_VALUE,'UARD_REPORT=',OLD.UARD_REPORT,',');
  END IF;

  IF (OLD.UARD_REASON IS NULL) THEN
  	SET OLD_VALUE=CONCAT(OLD_VALUE,'UARD_REASON=','<NULL>,');
  ELSEIF (OLD.UARD_REASON IS NOT NULL) THEN
  	SET OLD_VALUE=CONCAT(OLD_VALUE,'UARD_REASON=',OLD.UARD_REASON,',');
  END IF;

  SET OLD_VALUE = CONCAT(OLD_VALUE,'UARD_DATE=', OLD.UARD_DATE,','); 

  SET OLD_VALUE = CONCAT(OLD_VALUE,'URC_ID=', OLD.URC_ID,','); 

  SET OLD_VALUE = CONCAT(OLD_VALUE,'ULD_ID=', OLD.ULD_ID,',');

  IF (OLD.UARD_PERMISSION IS NULL) THEN
  	SET OLD_VALUE=CONCAT(OLD_VALUE,'UARD_PERMISSION=','<NULL>,');
  ELSEIF (OLD.UARD_PERMISSION IS NOT NULL) THEN
  	SET OLD_VALUE=CONCAT(OLD_VALUE,'UARD_PERMISSION=',OLD.UARD_PERMISSION,',');
  END IF;

  SET OLD_VALUE = CONCAT(OLD_VALUE,'UARD_ATTENDANCE=', OLD.UARD_ATTENDANCE,','); 

  IF (OLD.UARD_PDID IS NULL) THEN
  	SET OLD_VALUE=CONCAT(OLD_VALUE,'UARD_PDID=','<NULL>,');
  ELSEIF (OLD.UARD_PDID IS NOT NULL) THEN
  	SET OLD_VALUE=CONCAT(OLD_VALUE,'UARD_PDID=',OLD.UARD_PDID,',');
  END IF;

  SET OLD_VALUE = CONCAT(OLD_VALUE,'UARD_AM_SESSION=', OLD.UARD_AM_SESSION,','); 

  SET OLD_VALUE = CONCAT(OLD_VALUE,'UARD_PM_SESSION=', OLD.UARD_PM_SESSION,','); 

  SET OLD_VALUE = CONCAT(OLD_VALUE,'UARD_BANDWIDTH=', OLD.UARD_BANDWIDTH,',');
  
	SET OLD_VALUE = CONCAT(OLD_VALUE,'UARD_USERSTAMP_ID=', OLD.UARD_USERSTAMP_ID,','); 
  
  SET OLD_VALUE = CONCAT(OLD_VALUE,'UARD_TIMESTAMP=', OLD.UARD_TIMESTAMP,','); 
  
  -- FOR INSERT INTO TICKLER HISTORY 
  INSERT INTO TICKLER_HISTORY(TP_ID,ULD_ID,TTIP_ID,TH_OLD_VALUE,TH_USERSTAMP_ID) VALUES
	((SELECT TP_ID FROM TICKLER_PROFILE WHERE TP_TYPE='DELETION'),
	(SELECT ULD_ID FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=OLD.ULD_ID AND UARD_ID=OLD.UARD_ID),
	(SELECT TTIP_ID FROM TICKLER_TABID_PROFILE WHERE TTIP_DATA='USER_ADMIN_REPORT_DETAILS'),OLD_VALUE,
  (SELECT UARD_USERSTAMP_ID FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=OLD.UARD_ID));
END;

DELETE FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=8150;