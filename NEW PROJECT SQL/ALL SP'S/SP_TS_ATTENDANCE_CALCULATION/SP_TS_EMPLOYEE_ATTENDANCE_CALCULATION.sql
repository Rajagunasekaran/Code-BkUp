DROP PROCEDURE IF EXISTS SP_EMPLOYEE_ATTENDANCE_CALCULATION;
CREATE PROCEDURE SP_EMPLOYEE_ATTENDANCE_CALCULATION(
IN MONTH_YEAR VARCHAR(20),
IN LOGIN_ID VARCHAR(50),
IN USERSTAMP VARCHAR(50),
OUT TEMP_ATTENDANCE_CALCULATION TEXT,
OUT TOTAL_DAYS INT,
OUT TOTAL_WORKINGDAYS INT)
BEGIN
	DECLARE TEMPSUNDAY TEXT;
	DECLARE TEMP_SUNDAY TEXT;
	DECLARE SHORTMONTH VARCHAR(10);
	DECLARE MONTH_STARTDATE DATE;
	DECLARE MONTH_ENDDATE DATE;
	DECLARE TEMP_ATTENDANCECALCULATION TEXT;
	DECLARE USERSTAMP_ID INT(11);
	DECLARE ULDID INT(11);
	DECLARE I INT(2);
	DECLARE N INT(2);
	DECLARE T_PRESENT DECIMAL(3,1);
	DECLARE T_ABSENT DECIMAL(3,1);
	DECLARE T_ONDUTY DECIMAL(3,1);
	DECLARE T_PERMISSION DECIMAL(3,1);
	DECLARE TEMPATTENDANCE TEXT;
	DECLARE TEMP_ATTENDANCE TEXT;
	DECLARE TEMP_ATTENDANCECOUNT TEXT;
	DECLARE TEMP_ATTENDANCE_COUNT TEXT;
	DECLARE TEMP_USERSULDID TEXT;
	DECLARE TEMP_USERS_ULDID TEXT;
	DECLARE US_MIN_ID INT;
	DECLARE US_MAX_ID INT;
	DECLARE	WORKINGINHOLIDAY DECIMAL(3,1) ;
	DECLARE HALF_WORKING_DATA DECIMAL(4,1);
	DECLARE HOLIDAYWRKDAYS TEXT;
	DECLARE TEMP_YEAR INTEGER;
	DECLARE TEMP_MONTH INTEGER;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		IF(TEMP_ATTENDANCE_COUNT IS NOT NULL)THEN
			SET @DROP_TEMP_ATTENDANCE_COUNT = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_ATTENDANCE_COUNT));
			PREPARE DROP_TEMP_ATTENDANCE_COUNT_STMT FROM @DROP_TEMP_ATTENDANCE_COUNT;
			EXECUTE DROP_TEMP_ATTENDANCE_COUNT_STMT;
		END IF;
		IF(TEMP_ATTENDANCE IS NOT NULL)THEN
			SET @DROP_TEMP_ATTENDANCE = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_ATTENDANCE));
			PREPARE DROP_TEMP_ATTENDANCE_STMT FROM @DROP_TEMP_ATTENDANCE;
			EXECUTE DROP_TEMP_ATTENDANCE_STMT;
		END IF;
		IF(TEMP_USERS_ULDID IS NOT NULL)THEN
			SET @DROP_TEMP_USERS_ULDID = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_USERS_ULDID));
			PREPARE DROP_TEMP_USERS_ULDID_STMT FROM @DROP_TEMP_USERS_ULDID;
			EXECUTE DROP_TEMP_USERS_ULDID_STMT;
		END IF;
		IF TEMP_SUNDAY IS NOT NULL THEN
			SET @DROP_TEMP_SUNDAY = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_SUNDAY));
			PREPARE DROP_TEMP_SUNDAY_STMT FROM @DROP_TEMP_SUNDAY;
			EXECUTE DROP_TEMP_SUNDAY_STMT;
		END IF;
	END;
	START TRANSACTION;
	SET I=1;
	SET N=0;
	SET T_PRESENT=0;
	SET T_ABSENT=0;
	SET T_ONDUTY=0;
	SET T_PERMISSION=0;
	CALL SP_TS_CHANGE_USERSTAMP_AS_ULDID(USERSTAMP,@ULD_ID);
	SET USERSTAMP_ID=@ULD_ID;
	IF(LOGIN_ID='')THEN
		SET LOGIN_ID=NULL;
	END IF;
  	SET SHORTMONTH=(SELECT SUBSTRING(MONTH_YEAR,1,3));
	SET MONTH_STARTDATE=(SELECT CONCAT(SUBSTRING_INDEX(MONTH_YEAR,'-',-1),'-',(MONTH(STR_TO_DATE(SHORTMONTH,'%b'))),'-01'));
	SET MONTH_ENDDATE=(SELECT LAST_DAY(MONTH_STARTDATE));
	SET TEMP_YEAR=(SELECT YEAR(MONTH_ENDDATE));
	SET TEMP_MONTH=(SELECT MONTH(MONTH_ENDDATE));
	SET TOTAL_DAYS=(SELECT DAY(LAST_DAY(MONTH_STARTDATE)));
  	SET TOTAL_WORKINGDAYS=TOTAL_DAYS;
	SELECT COUNT(ROW+1) AS SUNDAYS INTO @SUNDAYCOUNT FROM	(SELECT @ROW := @ROW + 1 AS ROW FROM 
	(SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6) T1,
	(SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6) T2, (SELECT @ROW:=-1) T3 LIMIT 31) B
	WHERE DATE_ADD(MONTH_STARTDATE, INTERVAL ROW DAY) BETWEEN MONTH_STARTDATE AND MONTH_ENDDATE AND DAYOFWEEK(DATE_ADD(MONTH_STARTDATE, INTERVAL ROW DAY))=1;
	SET TOTAL_WORKINGDAYS=(TOTAL_WORKINGDAYS-@SUNDAYCOUNT);
	SET TOTAL_WORKINGDAYS=(TOTAL_WORKINGDAYS-(SELECT COUNT(*) FROM PUBLIC_HOLIDAY WHERE PH_DATE BETWEEN MONTH_STARTDATE AND MONTH_ENDDATE));
	SET TOTAL_WORKINGDAYS=(TOTAL_WORKINGDAYS-(SELECT COUNT(*) FROM ONDUTY_ENTRY_DETAILS WHERE OED_DATE BETWEEN MONTH_STARTDATE AND MONTH_ENDDATE));
	SET TEMPSUNDAY=(SELECT CONCAT('TEMP_SUNDAY_TABLE',SYSDATE()));
	SET TEMPSUNDAY=(SELECT REPLACE(TEMPSUNDAY,':',''));
	SET TEMPSUNDAY=(SELECT REPLACE(TEMPSUNDAY,'-',''));
	SET TEMPSUNDAY=(SELECT REPLACE(TEMPSUNDAY,' ',''));
	SET TEMP_SUNDAY=(SELECT CONCAT(TEMPSUNDAY,'_',USERSTAMP_ID)); 
	SET @CREATE_TEMP_SUNDAYS_TABLE=(SELECT CONCAT('CREATE TABLE ',TEMP_SUNDAY,'(ID INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,SUNDAY_DAY VARCHAR(10))'));
	PREPARE CREATE_TEMP_SUNDAYS_TABLE_STMT FROM @CREATE_TEMP_SUNDAYS_TABLE;
	EXECUTE CREATE_TEMP_SUNDAYS_TABLE_STMT;
	SET @INSERT_TEMP_SUNDAYS_TABLE=(SELECT CONCAT('INSERT INTO ',TEMP_SUNDAY,'(SUNDAY_DAY)  SELECT(ROW+1)  FROM	(SELECT @ROW := @ROW + 1 AS ROW FROM (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6) T1,
	(SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6) T2, (SELECT @ROW:=-1) T3 LIMIT 31) B
	WHERE DATE_ADD(','"',MONTH_STARTDATE,'"',', INTERVAL ROW DAY) BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND DAYOFWEEK(DATE_ADD(','"',MONTH_STARTDATE,'"',', INTERVAL ROW DAY))=1' ));
	PREPARE INSERT_TEMP_SUNDAYS_TABLE_STMT FROM @INSERT_TEMP_SUNDAYS_TABLE;
	EXECUTE INSERT_TEMP_SUNDAYS_TABLE_STMT;
	SET @UPDATE_TEMP_SUNDAYS_TABLE=(SELECT CONCAT('UPDATE ',TEMP_SUNDAY,' SET SUNDAY_DAY=(SELECT CONCAT("0",SUNDAY_DAY)) WHERE LENGTH(SUNDAY_DAY)=1'));
	PREPARE UPDATE_TEMP_SUNDAYS_TABLE_STMT FROM @UPDATE_TEMP_SUNDAYS_TABLE;
	EXECUTE UPDATE_TEMP_SUNDAYS_TABLE_STMT;
SET @SET_HOLIDAY_WRKING_DAYS=(SELECT CONCAT('UPDATE ',TEMP_SUNDAY,' SET SUNDAY_DAY=(SELECT CONCAT(',TEMP_YEAR,',','''-''',',',TEMP_MONTH,',','''-''',',SUNDAY_DAY))'));
	PREPARE SET_HOLIDAY_WRKING_DAYS_STMT FROM @SET_HOLIDAY_WRKING_DAYS;
	EXECUTE SET_HOLIDAY_WRKING_DAYS_STMT;
	SET HOLIDAYWRKDAYS=@HOLIDAY_WRK_DAYS;
	IF EXISTS (SELECT * FROM PUBLIC_HOLIDAY WHERE PH_DATE BETWEEN MONTH_STARTDATE AND MONTH_ENDDATE) THEN
		SET @INSERT_PUBLIC_HOLIDAY=(SELECT CONCAT('INSERT INTO ',TEMP_SUNDAY,'(SUNDAY_DAY) SELECT PH_DATE FROM PUBLIC_HOLIDAY WHERE PH_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"'));
		PREPARE INSERT_PUBLIC_HOLIDAY_STMT FROM @INSERT_PUBLIC_HOLIDAY;
		EXECUTE INSERT_PUBLIC_HOLIDAY_STMT;
	END IF;
	IF EXISTS(SELECT * FROM ONDUTY_ENTRY_DETAILS WHERE OED_DATE BETWEEN MONTH_STARTDATE AND MONTH_ENDDATE) THEN
		SET @INSERT_ONDUTY_HOLIDAY=(SELECT CONCAT('INSERT INTO ',TEMP_SUNDAY,'(SUNDAY_DAY) SELECT OED_DATE FROM ONDUTY_ENTRY_DETAILS WHERE OED_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"'));
		PREPARE INSERT_ONDUTY_HOLIDAY_STMT FROM @INSERT_ONDUTY_HOLIDAY;
		EXECUTE INSERT_ONDUTY_HOLIDAY_STMT;	
	END IF;
	SET @BB=HOLIDAYWRKDAYS;
	IF (LOGIN_ID IS NULL) THEN
		SET TEMP_ATTENDANCECALCULATION=(SELECT CONCAT('TEMP_ATTENDANCE_CALCULATION',SYSDATE()));
		SET TEMP_ATTENDANCECALCULATION=(SELECT REPLACE(TEMP_ATTENDANCECALCULATION,':',''));
		SET TEMP_ATTENDANCECALCULATION=(SELECT REPLACE(TEMP_ATTENDANCECALCULATION,'-',''));
		SET TEMP_ATTENDANCECALCULATION=(SELECT REPLACE(TEMP_ATTENDANCECALCULATION,' ',''));
		SET TEMP_ATTENDANCE_CALCULATION=(SELECT CONCAT(TEMP_ATTENDANCECALCULATION,'_',USERSTAMP_ID));  
		SET @CREATE_TEMP_ATTENDANCE_CALCULATION=(SELECT CONCAT('CREATE TABLE ',TEMP_ATTENDANCE_CALCULATION,' (
		ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
		LOGINID VARCHAR(50) NOT NULL,
		NO_OF_DAYS INTEGER NOT NULL,
		NO_OF_PRESENT DECIMAL(3,1) NOT NULL,
		NO_OF_ABSENT DECIMAL(3,1) NOT NULL,
		NO_OF_ONDUTY DECIMAL(3,1) NOT NULL,
		PERMISSION_HRS DECIMAL(3,1) NOT NULL,
		WORKING_IN_HOLIDAYS DECIMAL(4,1))'));
		PREPARE CREATE_TEMP_ATTENDANCE_CALCULATION_STMT FROM @CREATE_TEMP_ATTENDANCE_CALCULATION;
		EXECUTE CREATE_TEMP_ATTENDANCE_CALCULATION_STMT;
		SET TEMP_USERSULDID=(SELECT CONCAT('TEMP_USERS_ULDID',SYSDATE()));
		SET TEMP_USERSULDID=(SELECT REPLACE(TEMP_USERSULDID,':',''));
		SET TEMP_USERSULDID=(SELECT REPLACE(TEMP_USERSULDID,'-',''));
		SET TEMP_USERSULDID=(SELECT REPLACE(TEMP_USERSULDID,' ',''));
		SET TEMP_USERS_ULDID=(SELECT CONCAT(TEMP_USERSULDID,'_',USERSTAMP_ID));
		SET @CREATE_USERSULDID=(SELECT CONCAT('CREATE TABLE ',TEMP_USERS_ULDID,' (ID INT AUTO_INCREMENT PRIMARY KEY,ULD_ID INTEGER)'));
		PREPARE CREATE_USERSULDID_STMT FROM @CREATE_USERSULDID;
		EXECUTE CREATE_USERSULDID_STMT;
		SET @INSERT_USERSULDID=(SELECT CONCAT('INSERT INTO ',TEMP_USERS_ULDID,'(ULD_ID) SELECT DISTINCT ULD_ID FROM USER_ADMIN_REPORT_DETAILS WHERE UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"'));
		PREPARE INSERT_USERSULDID_STMT FROM @INSERT_USERSULDID;
		EXECUTE INSERT_USERSULDID_STMT;
		SET @USMINID=(SELECT CONCAT('SELECT MIN(ID) INTO @USMIN_ID FROM ',TEMP_USERS_ULDID));
		PREPARE USMINID_STMT FROM @USMINID;
		EXECUTE USMINID_STMT;
		SET @USMAXID=(SELECT CONCAT('SELECT MAX(ID) INTO @USMAX_ID FROM ',TEMP_USERS_ULDID)); 
		PREPARE USMAXID_STMT FROM @USMAXID;
		EXECUTE USMAXID_STMT;
		SET US_MIN_ID=@USMIN_ID;
		SET US_MAX_ID=@USMAX_ID;
		SET TEMP_ATTENDANCECOUNT=(SELECT CONCAT('TEMP_ATTENDANCE_COUNT',SYSDATE()));
		SET TEMP_ATTENDANCECOUNT=(SELECT REPLACE(TEMP_ATTENDANCECOUNT,':',''));
		SET TEMP_ATTENDANCECOUNT=(SELECT REPLACE(TEMP_ATTENDANCECOUNT,'-',''));
		SET TEMP_ATTENDANCECOUNT=(SELECT REPLACE(TEMP_ATTENDANCECOUNT,' ',''));
		SET TEMP_ATTENDANCE_COUNT=(SELECT CONCAT(TEMP_ATTENDANCECOUNT,'_',USERSTAMP_ID)); 
		SET @CREATE_TEMP_ATTENDANCE_COUNT=(SELECT CONCAT('CREATE TABLE ',TEMP_ATTENDANCE_COUNT,' (
		ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
		ULD_ID INT NOT NULL,
		PRESENT INT,
		ABSENT INT,
		ONDUTY INT,
		HALFDAY INT,
		HALFOD INT,
		PERMISSION INT)'));
		PREPARE CREATE_TEMP_ATTENDANCE_COUNT_STMT FROM @CREATE_TEMP_ATTENDANCE_COUNT;
		EXECUTE CREATE_TEMP_ATTENDANCE_COUNT_STMT;
		WHILE(US_MIN_ID<=US_MAX_ID)DO
			SET @SELECT_USER_ULDID = (SELECT CONCAT('SELECT ULD_ID INTO @UID FROM ',TEMP_USERS_ULDID,' WHERE ID=',US_MIN_ID));
			PREPARE SELECT_USER_ULDID_STMT FROM @SELECT_USER_ULDID;
			EXECUTE SELECT_USER_ULDID_STMT;
			SET @SELECT_LOGINID_ULDID = (SELECT CONCAT('SELECT ULD_ID,EMPLOYEE_NAME INTO @U_ID,@LOGID FROM VW_TS_ALL_EMPLOYEE_DETAILS WHERE ULD_ID=@UID'));
			PREPARE SELECT_LOGINID_ULDID_STMT FROM @SELECT_LOGINID_ULDID;
			EXECUTE SELECT_LOGINID_ULDID_STMT;
			SET ULDID=@U_ID;
			SET LOGIN_ID=@LOGID;
			SET @INSERT_TEMP_ATTENDANCE_COUNT=(SELECT CONCAT('INSERT INTO ',TEMP_ATTENDANCE_COUNT,'(ULD_ID,PRESENT,ABSENT,ONDUTY,HALFDAY,HALFOD,PERMISSION) VALUES
			((',ULDID,'),(SELECT COUNT(UARD_ATTENDANCE) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=5 AND UARD_DATE NOT IN (SELECT SUNDAY_DAY FROM ',TEMP_SUNDAY,')),
			(SELECT COUNT(UARD_ATTENDANCE) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=6),
			(SELECT COUNT(UARD_ATTENDANCE) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=7 AND UARD_DATE NOT IN (SELECT SUNDAY_DAY FROM ',TEMP_SUNDAY,')),
			(SELECT COUNT(UARD_ATTENDANCE) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=4),
			(SELECT COUNT(UARD_ATTENDANCE) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=8),
			(SELECT COUNT(UARD_PERMISSION) FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"','))'));
			PREPARE INSERT_TEMP_ATTENDANCE_COUNT_STMT FROM @INSERT_TEMP_ATTENDANCE_COUNT;
			EXECUTE INSERT_TEMP_ATTENDANCE_COUNT_STMT;
			SET @PRESENT_COUNT=(SELECT CONCAT('SELECT PRESENT,ABSENT,ONDUTY,HALFDAY,HALFOD,PERMISSION INTO @PRSNT,@ABSNT,@OD,@HALFDAYLEAVE,@HALFDAYOD,@PERMSN FROM ',TEMP_ATTENDANCE_COUNT));
			PREPARE PRESENT_COUNT_STMT FROM @PRESENT_COUNT;
			EXECUTE PRESENT_COUNT_STMT;
			SET T_PRESENT=@PRSNT;
			SET T_ABSENT=@ABSNT;
			SET T_ONDUTY=@OD;
			IF(@HALFDAYLEAVE!=0)THEN
				WHILE(I<=@HALFDAYLEAVE)DO
					SET T_PRESENT=(SELECT SUM(T_PRESENT+0.5));
					SET T_ABSENT=(SELECT SUM(T_ABSENT+0.5));
					SET I=I+1;					
				END WHILE;
			END IF;
			SET I=1;
			IF(@HALFDAYOD!=0)THEN
				WHILE(I<=@HALFDAYOD)DO
					SET T_PRESENT=(SELECT SUM(T_PRESENT+0.5));
					SET T_ONDUTY=(SELECT SUM(T_ONDUTY+0.5));
					SET I=I+1;
				END WHILE;
			END IF;
			SET I=1;
			IF(@PERMSN=0)THEN
				SET T_PERMISSION=@PERMSN;
			ELSE
				SET @TOTAL_PERMISSION=(SELECT CONCAT('SELECT SUM(AC.AC_DATA) INTO @TOTALPERMSN FROM USER_ADMIN_REPORT_DETAILS UARD,ATTENDANCE_CONFIGURATION AC 
				WHERE UARD.ULD_ID=',ULDID,' AND UARD.UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND ','"',MONTH_ENDDATE,'"',' AND UARD.UARD_PERMISSION IS NOT NULL AND UARD.UARD_PERMISSION=AC.AC_ID'));
				PREPARE TOTAL_PERMISSION_STMT FROM @TOTAL_PERMISSION;
				EXECUTE TOTAL_PERMISSION_STMT;
				SET T_PERMISSION=@TOTALPERMSN;
			END IF;
			SET @INSERT_TEMP_ATTENDANCE_CALCULATION=(SELECT CONCAT('INSERT INTO ',TEMP_ATTENDANCE_CALCULATION,'(LOGINID,NO_OF_DAYS,NO_OF_PRESENT,NO_OF_ABSENT,NO_OF_ONDUTY,PERMISSION_HRS) VALUES
			(','"',LOGIN_ID,'"',',',TOTAL_WORKINGDAYS,',',T_PRESENT,',',T_ABSENT,',',T_ONDUTY,',',T_PERMISSION,')'));
			PREPARE INSERT_TEMP_ATTENDANCE_CALCULATION_STMT FROM @INSERT_TEMP_ATTENDANCE_CALCULATION;
			EXECUTE INSERT_TEMP_ATTENDANCE_CALCULATION_STMT;
			SET @SET_WORKINGINHOLIDAY=(SELECT CONCAT('SELECT COUNT(UARD_ATTENDANCE) INTO @WRK_HOL FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND  ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=5 AND UARD_DATE IN (SELECT SUNDAY_DAY FROM ',TEMP_SUNDAY,')'));
			PREPARE SET_WORKINGINHOLIDAY_STMT FROM @SET_WORKINGINHOLIDAY;
			EXECUTE SET_WORKINGINHOLIDAY_STMT;
			SET WORKINGINHOLIDAY=@WRK_HOL;
			SET @SET_HALF_WORKING_DATA=(SELECT CONCAT('SELECT COUNT(UARD_ATTENDANCE) INTO @HALF_DAY FROM USER_ADMIN_REPORT_DETAILS WHERE ULD_ID=',ULDID,' AND UARD_DATE BETWEEN ','"',MONTH_STARTDATE,'"',' AND  ','"',MONTH_ENDDATE,'"',' AND UARD_ATTENDANCE=4 AND UARD_DATE IN (SELECT SUNDAY_DAY FROM ',TEMP_SUNDAY,')'));
			PREPARE SET_HALF_WORKING_DATA_STMT FROM @SET_HALF_WORKING_DATA;
			EXECUTE SET_HALF_WORKING_DATA_STMT;
			SET HALF_WORKING_DATA= @HALF_DAY;
			SET HALF_WORKING_DATA=(HALF_WORKING_DATA/2);
			SET WORKINGINHOLIDAY=(WORKINGINHOLIDAY+HALF_WORKING_DATA);
			SET @UPDATE_TEMP_ATTENDANCE_CALCULATION=(SELECT CONCAT('UPDATE ',TEMP_ATTENDANCE_CALCULATION,' SET WORKING_IN_HOLIDAYS=',WORKINGINHOLIDAY,' WHERE LOGINID=','"',LOGIN_ID,'"'));
			PREPARE UPDATE_TEMP_ATTENDANCE_CALCULATION_STMT FROM @UPDATE_TEMP_ATTENDANCE_CALCULATION;
			EXECUTE UPDATE_TEMP_ATTENDANCE_CALCULATION_STMT;
			SET @TRUNC_TEMP_USERS_ULDID = (SELECT CONCAT('TRUNCATE TABLE ',TEMP_ATTENDANCE_COUNT));
			PREPARE TRUNC_TEMP_USERS_ULDID_STMT FROM @TRUNC_TEMP_USERS_ULDID;
			EXECUTE TRUNC_TEMP_USERS_ULDID_STMT;
			SET @HALF_DAY=NULL;
			SET @WRK_HOL=NULL;
			SET US_MIN_ID=US_MIN_ID+1;
		END WHILE;
		SET TOTAL_WORKINGDAYS=NULL;
		SET @DROP_TEMP_ATTENDANCE_COUNT = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_ATTENDANCE_COUNT));
		PREPARE DROP_TEMP_ATTENDANCE_COUNT_STMT FROM @DROP_TEMP_ATTENDANCE_COUNT;
		EXECUTE DROP_TEMP_ATTENDANCE_COUNT_STMT;
		SET @DROP_TEMP_USERS_ULDID = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_USERS_ULDID));
		PREPARE DROP_TEMP_USERS_ULDID_STMT FROM @DROP_TEMP_USERS_ULDID;
		EXECUTE DROP_TEMP_USERS_ULDID_STMT;
		IF TEMP_SUNDAY IS NOT NULL THEN
			SET @DROP_TEMP_SUNDAY = (SELECT CONCAT('DROP TABLE IF EXISTS ',TEMP_SUNDAY));
			PREPARE DROP_TEMP_SUNDAY_STMT FROM @DROP_TEMP_SUNDAY;
			EXECUTE DROP_TEMP_SUNDAY_STMT;
		END IF;
	END IF;
	COMMIT;
END;
