DROP PROCEDURE IF EXISTS SP_TS_DAILY_REPORT_SEARCH_UPDATE;
CREATE PROCEDURE SP_TS_DAILY_REPORT_SEARCH_UPDATE(
IN UARDID INTEGER,
IN REPORT TEXT,
IN REASON TEXT,
IN FINALDATE DATE, 
IN URCID INTEGER, 
IN LOGIN_ID TEXT, 
IN URE_PERMISSION TEXT,
IN URE_ATTENDANCE TEXT,
IN URE_PDID TEXT, 
IN URE_MORNING_SESSION TEXT, 
IN URE_AFTERNOON_SESSION TEXT,
IN BANDWIDTH DECIMAL(6,2), 
IN URE_ULD_ID TEXT,
IN ABSENTFLAG CHAR(1),
OUT REPORT_UPDATE INTEGER)
BEGIN
	DECLARE OLD_REPORT TEXT;
	DECLARE OLD_REASON TEXT;
	DECLARE OLD_FINALDATE DATE;
	DECLARE OLD_URCID INTEGER;
	DECLARE OLD_LOGIN_ID TEXT;
	DECLARE OLD_URE_PERMISSION TEXT;
	DECLARE OLD_URE_ATTENDANCE TEXT;
	DECLARE OLD_URE_PDID TEXT;
	DECLARE OLD_URE_MORNING_SESSION TEXT;
	DECLARE OLD_URE_AFTERNOON_SESSION TEXT;
	DECLARE OLD_BANDWIDTH DECIMAL(6,2);
	DECLARE OLD_URE_ULD_ID TEXT;
  	DECLARE OLD_ABSENTFLAG CHAR(1);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN 
		ROLLBACK;
		SET REPORT_UPDATE=0;
	END;
	SET AUTOCOMMIT=0;
	START TRANSACTION;
	SET REPORT_UPDATE=0;
	IF (REPORT='') THEN
		SET REPORT=NULL;
	END IF;
	IF (REASON='') THEN
		SET REASON=NULL;
	END IF;
	IF (URE_PERMISSION='') THEN
		SET URE_PERMISSION=NULL;
	END IF;
	IF (ABSENTFLAG='') THEN
		SET ABSENTFLAG=NULL;
	END IF;
	IF (URCID=1) THEN
		SET OLD_REPORT=(SELECT UARD_REPORT FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		SET OLD_REASON=(SELECT UARD_REASON FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		SET OLD_FINALDATE=(SELECT UARD_DATE FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		SET OLD_URCID=(SELECT URC_ID FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		SET OLD_LOGIN_ID=(SELECT ULD_LOGINID FROM USER_LOGIN_DETAILS WHERE ULD_ID=(SELECT ULD_ID FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID));
		SET OLD_URE_PERMISSION=(SELECT UARD_PERMISSION FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		SET OLD_URE_ATTENDANCE=(SELECT UARD_ATTENDANCE FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		SET OLD_URE_PDID=(SELECT UARD_PDID FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		SET OLD_URE_MORNING_SESSION=(SELECT AC_DATA FROM ATTENDANCE_CONFIGURATION WHERE AC_ID=(SELECT UARD_AM_SESSION FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID));
		SET OLD_URE_AFTERNOON_SESSION=(SELECT AC_DATA FROM ATTENDANCE_CONFIGURATION WHERE AC_ID=(SELECT UARD_PM_SESSION FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID));
		SET OLD_BANDWIDTH=(SELECT UARD_BANDWIDTH FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID= UARDID);
		SET OLD_URE_ULD_ID=(SELECT UARD_USERSTAMP_ID FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		SET OLD_ABSENTFLAG=(SELECT ABSENT_FLAG FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		IF ((REPORT!=OLD_REPORT)OR(REASON!=OLD_REASON)OR(FINALDATE!=OLD_FINALDATE)OR(URCID!=OLD_URCID)OR(LOGIN_ID!=OLD_LOGIN_ID)OR(URE_PERMISSION!=OLD_URE_PERMISSION)OR(URE_ATTENDANCE!=OLD_URE_ATTENDANCE)
		OR(URE_PDID!=OLD_URE_PDID)OR(URE_MORNING_SESSION!=OLD_URE_MORNING_SESSION)OR(URE_AFTERNOON_SESSION!=OLD_URE_AFTERNOON_SESSION)OR(BANDWIDTH!=OLD_BANDWIDTH)OR(URE_ULD_ID!=OLD_URE_ULD_ID)OR(ABSENTFLAG!=OLD_ABSENTFLAG)) THEN
			UPDATE USER_ADMIN_REPORT_DETAILS SET UARD_REPORT=REPORT, UARD_REASON=REASON, UARD_DATE=FINALDATE, URC_ID=URCID, ULD_ID=(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=LOGIN_ID), 
			UARD_PERMISSION=(SELECT AC_ID FROM ATTENDANCE_CONFIGURATION WHERE CGN_ID=6 AND AC_DATA=URE_PERMISSION), UARD_ATTENDANCE=(SELECT AC_ID FROM ATTENDANCE_CONFIGURATION WHERE CGN_ID=5 AND AC_DATA=URE_ATTENDANCE),UARD_PDID=URE_PDID,
			UARD_AM_SESSION=(SELECT AC_ID FROM ATTENDANCE_CONFIGURATION WHERE CGN_ID=4 AND AC_DATA= URE_MORNING_SESSION), UARD_PM_SESSION=(SELECT AC_ID FROM ATTENDANCE_CONFIGURATION WHERE CGN_ID=4 AND AC_DATA= URE_AFTERNOON_SESSION),
			UARD_BANDWIDTH=BANDWIDTH, UARD_USERSTAMP_ID=(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=URE_ULD_ID),ABSENT_FLAG=ABSENTFLAG WHERE UARD_ID=UARDID;
			SET REPORT_UPDATE=1;		
		END IF;
  	ELSE
		SET OLD_REPORT=(SELECT UARD_REPORT FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		SET OLD_REASON=(SELECT UARD_REASON FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		SET OLD_FINALDATE=(SELECT UARD_DATE FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		SET OLD_URCID=(SELECT URC_ID FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		SET OLD_LOGIN_ID=(SELECT ULD_LOGINID FROM USER_LOGIN_DETAILS WHERE ULD_ID=(SELECT ULD_ID FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID));
		SET OLD_URE_PERMISSION=(SELECT UARD_PERMISSION FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		SET OLD_URE_ATTENDANCE=(SELECT UARD_ATTENDANCE FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		SET OLD_URE_PDID=(SELECT UARD_PDID FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		SET OLD_URE_MORNING_SESSION=(SELECT AC_DATA FROM ATTENDANCE_CONFIGURATION WHERE AC_ID=(SELECT UARD_AM_SESSION FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID));
		SET OLD_URE_AFTERNOON_SESSION=(SELECT AC_DATA FROM ATTENDANCE_CONFIGURATION WHERE AC_ID=(SELECT UARD_PM_SESSION FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID));
		SET OLD_BANDWIDTH=(SELECT UARD_BANDWIDTH FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID= UARDID);
		SET OLD_URE_ULD_ID=(SELECT UARD_USERSTAMP_ID FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_ID=UARDID);
		IF ((REPORT!=OLD_REPORT)OR(REASON!=OLD_REASON)OR(FINALDATE!=OLD_FINALDATE)OR(URCID!=OLD_URCID)OR(LOGIN_ID!=OLD_LOGIN_ID)OR(URE_PERMISSION!=OLD_URE_PERMISSION)OR(URE_ATTENDANCE!=OLD_URE_ATTENDANCE)
		OR(URE_PDID!=OLD_URE_PDID)OR(URE_MORNING_SESSION!=OLD_URE_MORNING_SESSION)OR(URE_AFTERNOON_SESSION!=OLD_URE_AFTERNOON_SESSION)OR(BANDWIDTH!=OLD_BANDWIDTH)OR(URE_ULD_ID!=OLD_URE_ULD_ID)) THEN
			UPDATE USER_ADMIN_REPORT_DETAILS SET UARD_REPORT=REPORT, UARD_REASON=REASON, UARD_DATE=FINALDATE, URC_ID=URCID, ULD_ID=(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=LOGIN_ID), 
			UARD_PERMISSION=(SELECT AC_ID FROM ATTENDANCE_CONFIGURATION WHERE CGN_ID=6 AND AC_DATA=URE_PERMISSION), UARD_ATTENDANCE=(SELECT AC_ID FROM ATTENDANCE_CONFIGURATION WHERE CGN_ID=5 AND AC_DATA=URE_ATTENDANCE),UARD_PDID=URE_PDID,
			UARD_AM_SESSION=(SELECT AC_ID FROM ATTENDANCE_CONFIGURATION WHERE CGN_ID=4 AND AC_DATA= URE_MORNING_SESSION), UARD_PM_SESSION=(SELECT AC_ID FROM ATTENDANCE_CONFIGURATION WHERE CGN_ID=4 AND AC_DATA= URE_AFTERNOON_SESSION),
			UARD_BANDWIDTH=BANDWIDTH, UARD_USERSTAMP_ID=(SELECT ULD_ID FROM USER_LOGIN_DETAILS WHERE ULD_LOGINID=URE_ULD_ID) WHERE UARD_ID=UARDID;
			SET REPORT_UPDATE=1;		
		END IF;  
	END IF;
	COMMIT;
END;