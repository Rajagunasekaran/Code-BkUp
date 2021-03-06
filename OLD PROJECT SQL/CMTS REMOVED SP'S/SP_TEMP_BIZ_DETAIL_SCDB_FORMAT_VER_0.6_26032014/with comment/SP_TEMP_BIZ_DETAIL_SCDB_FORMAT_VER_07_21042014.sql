-- version:0.7 -- sdate:21/04/2014 -- edate:21/03/2014 -- issue:765 --desc:UPDATED SP timestamp --doneby:raja
-- version:0.6 -- sdate:25/03/2014 -- edate:25/03/2014 -- issue:765 --COMMENT NO: 8--desc:UPDATED SP DYNAMICALLY --doneby:SAFI
-- version:0.5 -- sdate:17/03/2014 -- edate:17/03/2014 -- issue:765 --desc:droped temp table --doneby:RL
--version:0.4 --sdate:28/02/2014 --edate:28/02/2014 --issue:750 --desc:changed userstamp as ULD_ID and timestamp get from scdb done by:RL
--version:0.3 --sdate:21/02/2014 --edate:21/02/2014 --issue:750 --desc:added preaudit and post audit queries done by:dhivya
--version:0.2 --sdate:21/01/2014 --edate:21/01/2014 --issue:594 --commentno:50 & 54 --doneby:RL


DROP PROCEDURE IF EXISTS SP_TEMP_BIZ_DETAIL_SCDB_FORMAT;
CREATE PROCEDURE SP_TEMP_BIZ_DETAIL_SCDB_FORMAT(IN SOURCESCHEMA  VARCHAR(40),IN DESTINATIONSCHEMA  VARCHAR(40))
BEGIN
--QUERY FOR CREATE TEMP_BIZ_DETAIL_SCDB_FORMAT TABLE
SET FOREIGN_KEY_CHECKS=0;
    SET @DROP_TEMP_BIZ_DETAIL_SCDB_FORMAT=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_BIZ_DETAIL_SCDB_FORMAT'));
    PREPARE TEMP_BIZ_DETAIL_SCDB_FORMAT_STMT FROM @DROP_TEMP_BIZ_DETAIL_SCDB_FORMAT;
    EXECUTE TEMP_BIZ_DETAIL_SCDB_FORMAT_STMT;
	
	SET @CREATE_TEMP_RENTAL_SCDB_FORMAT=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_BIZ_DETAIL_SCDB_FORMAT LIKE ',SOURCESCHEMA,'.BIZ_DETAIL_SCDB_FORMAT'));
    PREPARE CREATE_TEMP_RENTAL_SCDB_FORMAT_STMT FROM @CREATE_TEMP_RENTAL_SCDB_FORMAT;
    EXECUTE CREATE_TEMP_RENTAL_SCDB_FORMAT_STMT;
	
--INSERT QUERY FOR TEMP_BIZ_DETAIL_SCDB_FORMAT TABLE
	SET @INSERT_TEMP_BIZ_DETAIL_SCDB_FORMAT=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_BIZ_DETAIL_SCDB_FORMAT SELECT * FROM ',SOURCESCHEMA,'.BIZ_DETAIL_SCDB_FORMAT'));
	PREPARE INSERT_TEMP_BIZ_DETAIL_SCDB_FORMAT_STMT FROM @INSERT_TEMP_BIZ_DETAIL_SCDB_FORMAT;
    EXECUTE INSERT_TEMP_BIZ_DETAIL_SCDB_FORMAT_STMT;
--UPDATE QUERY FOR TEMP_BIZ_DETAIL_SCDB_FORMAT TABLE
	SET @UPDATE_TEMP_BIZ_DETAIL_SCDB_FORMAT=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_BIZ_DETAIL_SCDB_FORMAT SET EXPD_AIRCON_SERVICED_BY=',"'LORAC AIRCON AND ENGINEERING PTE LTD'",' WHERE  EXPD_AIRCON_SERVICED_BY=',"'LORAC AIRCON'"));
	PREPARE UPDATE_TEMP_BIZ_DETAIL_SCDB_FORMAT_STMT FROM @UPDATE_TEMP_BIZ_DETAIL_SCDB_FORMAT;
    EXECUTE UPDATE_TEMP_BIZ_DETAIL_SCDB_FORMAT_STMT;
	SET @UPDATE_EXPD_AIRCON_SERVICED_BY=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_BIZ_DETAIL_SCDB_FORMAT SET EXPD_AIRCON_SERVICED_BY=',"'BCS Aircon Engineering Pte Ltd'",' WHERE  EXPD_AIRCON_SERVICED_BY=',"'BCS AIRCON ENGINEERING'"));
	PREPARE UPDATE_EXPD_AIRCON_SERVICED_BY_STMT FROM @UPDATE_EXPD_AIRCON_SERVICED_BY;
    EXECUTE UPDATE_EXPD_AIRCON_SERVICED_BY_STMT;
	SET @UPDATETIMESTAMP=(SELECT CONCAT('UPDATE ',DESTINATIONSCHEMA,'.TEMP_BIZ_DETAIL_SCDB_FORMAT SET TIMESTAMP=(SELECT CONVERT_TZ(TIMESTAMP, "+08:00","+0:00"))'));
PREPARE UPDATETIMESTAMPSTMT FROM @UPDATETIMESTAMP;
EXECUTE UPDATETIMESTAMPSTMT;
	SET FOREIGN_KEY_CHECKS=1;
END;