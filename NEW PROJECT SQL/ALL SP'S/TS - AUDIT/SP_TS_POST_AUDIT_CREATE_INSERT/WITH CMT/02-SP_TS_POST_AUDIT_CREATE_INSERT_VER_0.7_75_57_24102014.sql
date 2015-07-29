-- VERSION 0.7 STARTDATE:24/10/2014 ENDDATE:24/10/2014 ISSUE NO:75 COMMENT NO:57 DESC:ADDED EMAIL TEMPLATE TABLE NAME. DONE BY :RAJA
-- VERSION 0.6 STARTDATE:13/10/2014 ENDDATE:13/10/2014 ISSUE NO:78 COMMENT NO:155 DESC:REMOVED TABLE CREATION QUERIES. DONE BY :RAJA
-- VERSION 0.4 STARTDATE:25/09/2014 ENDDATE:25/09/2014 ISSUE NO:78 COMMENT NO:89 DESC:ADDED PROJECT_CONFIGURATION,PROJECT_STATUS TABLE NAME IN POST_AUDIT_PROFILE,PRE_ADIT_SUB_PROFILE  INSERT QUERY DONE BY :RL
-- VERSION 0.3 STARTDATE:01/09/2014 ENDDATE:01/09/2014 ISSUE NO:78 COMMENT NO:14 DESC:ALTER THE AUTO INCREMENT ID OF THE TABLES. DONE BY :RAJA
-- VERSION 0.2 STARTDATE:18/08/2014 ENDDATE:18/08/2014 ISSUE NO:78 COMMENT NO:6 DESC:ADDED THE INSERT QUERY,DATA FOR PRE_AUDIT_SUB_PROFILE,POST_AUDIT_PROFILE. DONE BY :RAJA
-- VERSION 0.1 STARTDATE:14/08/2014 ENDDATE:14/08/2014 ISSUE NO:78 COMMENT NO:6 DESC:CREATED SP FOR TS AUDIT GET SOURCE TO DESTINATION DYNAMICALLY. DONE BY :RAJA
DROP PROCEDURE IF EXISTS SP_TS_POST_AUDIT_CREATE_INSERT;
CREATE PROCEDURE SP_TS_POST_AUDIT_CREATE_INSERT(
IN DESTINATIONSCHEMA VARCHAR(50))
BEGIN
DECLARE MAX_ID INT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;
    START TRANSACTION;
    SET FOREIGN_KEY_CHECKS=0;
    DROP TABLE IF EXISTS PRE_AUDIT_MAIN_PROFILE;
    CREATE TABLE PRE_AUDIT_MAIN_PROFILE( 
    PREAMP_ID INTEGER NOT NULL AUTO_INCREMENT, 
    PREAMP_DATA VARCHAR(50) NOT NULL,
    PRIMARY KEY(PREAMP_ID));
    DROP TABLE IF EXISTS PRE_AUDIT_SUB_PROFILE;
    CREATE TABLE PRE_AUDIT_SUB_PROFILE(
    PREASP_ID INTEGER NOT NULL AUTO_INCREMENT,
    PREAMP_ID INTEGER NOT NULL, 
    PREASP_DATA VARCHAR(50) NOT NULL,
    PREASP_NO_OF_REC INTEGER NULL,
    PRIMARY KEY(PREASP_ID),
    FOREIGN KEY(PREAMP_ID) REFERENCES PRE_AUDIT_MAIN_PROFILE (PREAMP_ID));
    DROP TABLE IF EXISTS PRE_AUDIT_HISTORY;
    SET @CREATE_PRE_AUDIT_HISTORY=(SELECT CONCAT('CREATE TABLE PRE_AUDIT_HISTORY(
    PREAH_ID INTEGER NOT NULL AUTO_INCREMENT, 
    PREAMP_DATA VARCHAR(20) NOT NULL,
    PREAMP_PROJ_KEY VARCHAR(50) NULL,
    PREAMP_STATUS INTEGER NOT NULL,
    PREAMP_SCDB_REC_BDUMP INTEGER NULL ,
    PREAMP_SCDB_AREC INTEGER NULL , 
    PREAMP_SQL_REC INTEGER NOT NULL,
    PREAMP_PSTIME TIME NOT NULL ,
    PREAMP_PETIME TIME NOT NULL, 
    PREAMP_EXE_TIME TIME NOT NULL, 
    ULD_ID INTEGER NOT NULL, 
    PREAMP_TIMESTAMP TIMESTAMP NOT NULL, 
    PRIMARY KEY(PREAH_ID),
    FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS (ULD_ID))'));
    PREPARE CREATE_PRE_AUDIT_HISTORY_STMT FROM @CREATE_PRE_AUDIT_HISTORY;
    EXECUTE CREATE_PRE_AUDIT_HISTORY_STMT;
    DROP TABLE IF EXISTS POST_AUDIT_PROFILE;
    CREATE TABLE POST_AUDIT_PROFILE (
    POSTAP_ID INTEGER NOT NULL AUTO_INCREMENT,
    POSTAP_DATA VARCHAR(50) NOT NULL,
    PRIMARY KEY(POSTAP_ID));
    DROP TABLE IF EXISTS POST_AUDIT_HISTORY;
    SET @CREATE_POST_AUDIT_HISTORY=(SELECT CONCAT('CREATE TABLE POST_AUDIT_HISTORY( 
    POSTAH_ID INTEGER NOT NULL AUTO_INCREMENT, 
    POSTAP_ID INTEGER NOT NULL, 
    POSTAH_NO_OF_REC INTEGER NOT NULL,
    PREASP_ID INTEGER NOT NULL, 
    PREAMP_ID INTEGER NOT NULL,
    POSTAH_DURATION TIME NOT NULL, 
    POSTAH_NO_OF_REJ INTEGER NOT NULL, 
    ULD_ID INTEGER NOT NULL,
    POSTAH_TIMESTAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    PRIMARY KEY(POSTAH_ID), 
    FOREIGN KEY(POSTAP_ID) REFERENCES POST_AUDIT_PROFILE (POSTAP_ID),
    FOREIGN KEY(PREASP_ID) REFERENCES PRE_AUDIT_SUB_PROFILE (PREASP_ID), 
    FOREIGN KEY(PREAMP_ID) REFERENCES PRE_AUDIT_MAIN_PROFILE (PREAMP_ID),
    FOREIGN KEY(ULD_ID) REFERENCES ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS (ULD_ID))'));
    PREPARE CREATE_POST_AUDIT_HISTORY_STMT FROM @CREATE_POST_AUDIT_HISTORY;
    EXECUTE CREATE_POST_AUDIT_HISTORY_STMT;
    INSERT INTO PRE_AUDIT_MAIN_PROFILE(PREAMP_DATA) VALUES ('CONFIGURATION'),('USER RIGHTS'),('REPORTS'),('EMAIL');
    SELECT MAX(PREAMP_ID) INTO @PREAMP_MAX_ID FROM PRE_AUDIT_MAIN_PROFILE;
    SET MAX_ID=@PREAMP_MAX_ID;
    IF (MAX_ID IS NOT NULL) THEN    
        SET @ALTER_PRE_AUDIT_MAIN_PROFILE =(SELECT CONCAT('ALTER TABLE PRE_AUDIT_MAIN_PROFILE AUTO_INCREMENT=',MAX_ID));
        PREPARE ALTER_PRE_AUDIT_MAIN_PROFILE_STMT FROM @ALTER_PRE_AUDIT_MAIN_PROFILE;
        EXECUTE ALTER_PRE_AUDIT_MAIN_PROFILE_STMT;
    END IF;
    INSERT INTO PRE_AUDIT_SUB_PROFILE(PREAMP_ID,PREASP_DATA) VALUES 
    (1,'CONFIGURATION_PROFILE'),(1,'CONFIGURATION'),(1,'ERROR_MESSAGE_CONFIGURATION'),(1,'USER_RIGHTS_CONFIGURATION'),(1,'REPORT_CONFIGURATION'),(1,'ATTENDANCE_CONFIGURATION'),
    (1,'PROJECT_CONFIGURATION'),(1,'TICKLER_PROFILE'),(1,'TICKLER_TABID_PROFILE'),(2,'MENU_PROFILE'),(2,'ROLE_CREATION'),(2,'USER_LOGIN_DETAILS'),(2,'USER_ACCESS'),
    (2,'USER_MENU_DETAILS'),(2,'PUBLIC_HOLIDAY'),(2,'BASIC_ROLE_PROFILE'),(2,'BASIC_MENU_PROFILE'),(3,'USER_ADMIN_REPORT_DETAILS'),(3,'ADMIN_WEEKLY_REPORT_DETAILS'),
    (3,'ONDUTY_ENTRY_DETAILS'),(3,'EMPLOYEE_DETAILS'),(3,'PROJECT_DETAILS'),(3,'PROJECT_STATUS'),(3,'COMPANY_PROPERTIES_DETAILS'),(4,'EMAIL_TEMPLATE'),(4,'EMAIL_TEMPLATE_DETAILS');
    SELECT MAX(PREASP_ID) INTO @PREASP_MAX_ID FROM PRE_AUDIT_SUB_PROFILE;
    SET MAX_ID=@PREASP_MAX_ID;
    IF (MAX_ID IS NOT NULL) THEN    
        SET @ALTER_PRE_AUDIT_SUB_PROFILE =(SELECT CONCAT('ALTER TABLE PRE_AUDIT_SUB_PROFILE AUTO_INCREMENT=',MAX_ID));
        PREPARE ALTER_PRE_AUDIT_SUB_PROFILE_STMT FROM @ALTER_PRE_AUDIT_SUB_PROFILE;
        EXECUTE ALTER_PRE_AUDIT_SUB_PROFILE_STMT;
    END IF;
    SET @TRUNCATE_USER_LOGIN_DETAILS=(SELECT CONCAT('TRUNCATE ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS'));
    PREPARE TRUNCATE_USER_LOGIN_DETAILS_STMT FROM @TRUNCATE_USER_LOGIN_DETAILS;
    EXECUTE TRUNCATE_USER_LOGIN_DETAILS_STMT;
    SET @INSERT_USER_LOGIN_DETAILS = (SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS (ULD_LOGINID,ULD_USERSTAMP) VALUES
    ("dhandapani.sattanathan@ssomens.com","dhandapani.sattanathan@ssomens.com")'));
    PREPARE INSERT_USER_LOGIN_DETAILS_STMT FROM @INSERT_USER_LOGIN_DETAILS;
    EXECUTE INSERT_USER_LOGIN_DETAILS_STMT;    
    SET @USER_LOGIN_DETAILS_MAX_ID = (SELECT CONCAT('SELECT MAX(ULD_ID) INTO @ULD_MAX_ID FROM ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS'));
    PREPARE USER_LOGIN_DETAILS_MAX_ID_STMT FROM @USER_LOGIN_DETAILS_MAX_ID;
    EXECUTE USER_LOGIN_DETAILS_MAX_ID_STMT;
    SET MAX_ID=@ULD_MAX_ID;
    IF (MAX_ID IS NOT NULL) THEN    
        SET @ALTER_USER_LOGIN_DETAILS =(SELECT CONCAT('ALTER TABLE ',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS AUTO_INCREMENT=',MAX_ID));
        PREPARE ALTER_USER_LOGIN_DETAILS_STMT FROM @ALTER_USER_LOGIN_DETAILS;
        EXECUTE ALTER_USER_LOGIN_DETAILS_STMT;
    END IF;
    INSERT INTO POST_AUDIT_PROFILE(POSTAP_DATA) VALUES ('PROJECT_DETAILS'),('USER_ADMIN_REPORT_DETAILS'),('ADMIN_WEEKLY_REPORT_DETAILS'),('ONDUTY_ENTRY_DETAILS'),
    ('EMPLOYEE_DETAILS'),('MENU_PROFILE'),('ROLE_CREATION'),('USER_LOGIN_DETAILS'),('USER_ACCESS'),('USER_MENU_DETAILS'),('PUBLIC_HOLIDAY'),('CONFIGURATION_PROFILE'),
    ('CONFIGURATION'),('ERROR_MESSAGE_CONFIGURATION'),('USER_RIGHTS_CONFIGURATION'),('REPORT_CONFIGURATION'),('ATTENDANCE_CONFIGURATION'),('TICKLER_PROFILE'),
    ('TICKLER_TABID_PROFILE'),('BASIC_ROLE_PROFILE'),('BASIC_MENU_PROFILE'),('PROJECT_CONFIGURATION'),('PROJECT_STATUS'),('COMPANY_PROPERTIES_DETAILS'),('EMAIL_TEMPLATE'),('EMAIL_TEMPLATE_DETAILS');
    SELECT MAX(POSTAP_ID) INTO @POSTAP_MAX_ID FROM POST_AUDIT_PROFILE;
    SET MAX_ID=@POSTAP_MAX_ID;
    IF (MAX_ID IS NOT NULL) THEN    
        SET @ALTER_POST_AUDIT_PROFILE =(SELECT CONCAT('ALTER TABLE POST_AUDIT_PROFILE AUTO_INCREMENT=',MAX_ID));
        PREPARE ALTER_POST_AUDIT_PROFILE_STMT FROM @ALTER_POST_AUDIT_PROFILE;
        EXECUTE ALTER_POST_AUDIT_PROFILE_STMT;
    END IF;
    DROP TABLE IF EXISTS POST_MIGRATION_OBJECT_CREATION;
    CREATE TABLE POST_MIGRATION_OBJECT_CREATION(
    PMOC_ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    PMOC_MODULE_NAME VARCHAR(50)NOT NULL,
    PMOC_FOLDER_ID VARCHAR(60));
    INSERT INTO POST_MIGRATION_OBJECT_CREATION(PMOC_MODULE_NAME,PMOC_FOLDER_ID) VALUES 
    ('COMMON SP','0B_f0d7mdbV_UYW5Ibzh5Sk1lY2M'),('EMAIL','0Bwv4Rd7ZecjPS0RSZHAtS010Rms'),('REPORT','0B_f0d7mdbV_UZ3pXN24yOW1aYVU'),('USER RIGHTS','0B_f0d7mdbV_UYzN3Z2ctYlRkR2M'),('ALL VIEWS','0B70UK3Ne43XpQzE5Q0tLQzNsR2s');
    SELECT MAX(PMOC_ID) INTO @PMOC_ID_MAX_ID FROM POST_MIGRATION_OBJECT_CREATION;
    SET MAX_ID=@PMOC_ID_MAX_ID;
    IF (MAX_ID IS NOT NULL) THEN    
        SET @ALTER_POST_MIGRATION_OBJECT_CREATION =(SELECT CONCAT('ALTER TABLE POST_MIGRATION_OBJECT_CREATION AUTO_INCREMENT=',MAX_ID));
        PREPARE ALTER_POST_MIGRATION_OBJECT_CREATION_STMT FROM @ALTER_POST_MIGRATION_OBJECT_CREATION;
        EXECUTE ALTER_POST_MIGRATION_OBJECT_CREATION_STMT;
    END IF;
    DROP TABLE IF EXISTS POST_MIGRATION_MODULE_OBJECTCREATION_HISTORY;
    CREATE TABLE POST_MIGRATION_MODULE_OBJECTCREATION_HISTORY(
    PMMOH_ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    PMOC_ID INT NOT NULL,
    PMMOCH_EXC_TIME TIME,
    PMOC_STATUS VARCHAR(15)NOT NULL,
    ULD_ID INT NOT NULL,
    PMMOCH_TIMESTAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP);
    SELECT MAX(PMMOH_ID) INTO @PMMOH_ID_MAX_ID FROM POST_MIGRATION_MODULE_OBJECTCREATION_HISTORY;
    SET MAX_ID=@PMMOH_ID_MAX_ID;
    IF (MAX_ID IS NOT NULL) THEN    
        SET @ALTER_POST_MIGRATION_MODULE_OBJECTCREATION_HISTORY =(SELECT CONCAT('ALTER TABLE POST_MIGRATION_MODULE_OBJECTCREATION_HISTORY AUTO_INCREMENT=',MAX_ID));
        PREPARE ALTER_POST_MIGRATION_MODULE_OBJECTCREATION_HISTORY_STMT FROM @ALTER_POST_MIGRATION_MODULE_OBJECTCREATION_HISTORY;
        EXECUTE ALTER_POST_MIGRATION_MODULE_OBJECTCREATION_HISTORY_STMT;
    END IF;
    DROP TABLE IF EXISTS POST_MIGRATION_MODULE_HISTORY;
    CREATE TABLE POST_MIGRATION_MODULE_HISTORY(
    PMMH_ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    PMM_ID INT NOT NULL,
    PMM_EXC_TIME TIME NOT NULL,
    STATUS VARCHAR(15) NOT NULL,
    ULD_ID INT NOT NULL,
    TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP);
    SELECT MAX(PMMH_ID) INTO @PMMH_ID_MAX_ID FROM POST_MIGRATION_MODULE_HISTORY;
    SET MAX_ID=@PMMH_ID_MAX_ID;
    IF (MAX_ID IS NOT NULL) THEN    
        SET @ALTER_POST_MIGRATION_MODULE_HISTORY=(SELECT CONCAT('ALTER TABLE POST_MIGRATION_MODULE_HISTORY AUTO_INCREMENT=',MAX_ID));
        PREPARE ALTER_POST_MIGRATION_MODULE_HISTORY_STMT FROM @ALTER_POST_MIGRATION_MODULE_HISTORY;
        EXECUTE ALTER_POST_MIGRATION_MODULE_HISTORY_STMT;
    END IF;
    SET @PRE_AUDIT_HIS=(SELECT CONCAT('CREATE OR REPLACE VIEW VW_TS_PRE_AUDIT_HISTORY AS SELECT PAH.PREAH_ID,PAH.PREAMP_DATA,
    PAH.PREAMP_PROJ_KEY,IF(PAH.PREAMP_STATUS=1,"SUCCESS","FAILURE")AS STATUS,PAH.PREAMP_SQL_REC,PAH.PREAMP_EXE_TIME,ULD.ULD_LOGINID,PAH.PREAMP_TIMESTAMP 
    FROM PRE_AUDIT_HISTORY PAH,',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD WHERE ULD.ULD_ID=PAH.ULD_ID ORDER BY PAH.PREAMP_TIMESTAMP ASC'));
    PREPARE PRE_AUDIT_HIS_STMT FROM @PRE_AUDIT_HIS;
    EXECUTE PRE_AUDIT_HIS_STMT;
    SET @VW_POST_MIG_OBJ=(SELECT CONCAT('CREATE OR REPLACE VIEW VW_POST_MIGRATION_OBJECTCREATION AS SELECT PMOC.PMOC_MODULE_NAME,PMOC.PMOC_FOLDER_ID,PMMOCH.PMMOCH_EXC_TIME,PMMOCH.PMOC_STATUS,ULD.ULD_LOGINID,PMMOCH_TIMESTAMP
    FROM POST_MIGRATION_OBJECT_CREATION PMOC,POST_MIGRATION_MODULE_OBJECTCREATION_HISTORY PMMOCH,',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD WHERE PMOC.PMOC_ID=PMMOCH.PMMOH_ID AND ULD.ULD_ID=PMMOCH.ULD_ID'));
    PREPARE VW_POST_MIG_OBJ_STMT FROM @VW_POST_MIG_OBJ;
    EXECUTE VW_POST_MIG_OBJ_STMT;
    SET @VW_POST_MIG=(SELECT CONCAT('CREATE OR REPLACE VIEW VW_POST_MIGRATION_HISTORY AS SELECT PMM.PMM_MODULE_NAME,PMM.PMM_FOLDER_ID,PMMH.PMM_EXC_TIME,PMMH.STATUS,ULD.ULD_LOGINID,PMMH.TIMESTAMP 
    FROM POST_MIGRATION_MODULE PMM,POST_MIGRATION_MODULE_HISTORY PMMH,',DESTINATIONSCHEMA,'.USER_LOGIN_DETAILS ULD WHERE PMM.PMM_ID=PMMH.PMM_ID AND ULD.ULD_ID=PMMH.ULD_ID'));
    PREPARE VW_POST_MIG_STMT FROM @VW_POST_MIG;
    EXECUTE VW_POST_MIG_STMT;
    SET FOREIGN_KEY_CHECKS=1;
COMMIT;
END;
/*
CALL SP_TS_POST_AUDIT_CREATE_INSERT('RAJA_DEST');
*/