DROP PROCEDURE IF EXISTS SP_TEMP_BIZ_DETAIL_SCDB_FORMAT;
CREATE PROCEDURE SP_TEMP_BIZ_DETAIL_SCDB_FORMAT(IN SOURCESCHEMA  VARCHAR(40),IN DESTINATIONSCHEMA  VARCHAR(40))
BEGIN
SET FOREIGN_KEY_CHECKS=0;
    SET @DROP_TEMP_BIZ_DETAIL_SCDB_FORMAT=(SELECT CONCAT('DROP TABLE IF EXISTS ',DESTINATIONSCHEMA,'.TEMP_BIZ_DETAIL_SCDB_FORMAT'));
    PREPARE TEMP_BIZ_DETAIL_SCDB_FORMAT_STMT FROM @DROP_TEMP_BIZ_DETAIL_SCDB_FORMAT;
    EXECUTE TEMP_BIZ_DETAIL_SCDB_FORMAT_STMT;
	SET @CREATE_TEMP_RENTAL_SCDB_FORMAT=(SELECT CONCAT('CREATE TABLE ',DESTINATIONSCHEMA,'.TEMP_BIZ_DETAIL_SCDB_FORMAT LIKE ',SOURCESCHEMA,'.BIZ_DETAIL_SCDB_FORMAT'));
    PREPARE CREATE_TEMP_RENTAL_SCDB_FORMAT_STMT FROM @CREATE_TEMP_RENTAL_SCDB_FORMAT;
    EXECUTE CREATE_TEMP_RENTAL_SCDB_FORMAT_STMT;
	SET @INSERT_TEMP_BIZ_DETAIL_SCDB_FORMAT=(SELECT CONCAT('INSERT INTO ',DESTINATIONSCHEMA,'.TEMP_BIZ_DETAIL_SCDB_FORMAT SELECT * FROM ',SOURCESCHEMA,'.BIZ_DETAIL_SCDB_FORMAT'));
	PREPARE INSERT_TEMP_BIZ_DETAIL_SCDB_FORMAT_STMT FROM @INSERT_TEMP_BIZ_DETAIL_SCDB_FORMAT;
    EXECUTE INSERT_TEMP_BIZ_DETAIL_SCDB_FORMAT_STMT;
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