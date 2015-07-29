SELECT * FROM CUSTOMER_LP_DETAILS WHERE UASD_ID=8;
SELECT * FROM UNIT_ACCESS_STAMP_DETAILS;
SELECT * FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CUSTOMER_ID=156;
DROP TABLE CUSTOMER_ACCESS_CARD_DETAILS;
DROP SCHEMA TEST;
CREATE SCHEMA NEWPROD;

CREATE TABLE PATCH_HISTORY LIKE TEST_CARDS.PATCH_HISTORY;
CREATE TABLE PATCH_OBJECTS LIKE TEST_CARDS.PATCH_OBJECTS;
INSERT INTO PATCH_HISTORY (SELECT*FROM TEST_CARDS.PATCH_HISTORY);
INSERT INTO PATCH_OBJECTS (SELECT*FROM TEST_CARDS.PATCH_OBJECTS);
TRUNCATE ERROR_MESSAGE_CONFIGURATION;
INSERT INTO ERROR_MESSAGE_CONFIGURATION SELECT * FROM TEST_CARDS.ERROR_MESSAGE_CONFIGURATION;
SET FOREIGN_KEY_CHECKS=0;
TRUNCATE UNIT_ACCESS_STAMP_DETAILS;
INSERT INTO UNIT_ACCESS_STAMP_DETAILS SELECT * FROM TEST_CARDS.UNIT_ACCESS_STAMP_DETAILS;
TRUNCATE CUSTOMER ;
INSERT INTO CUSTOMER SELECT * FROM TEST_CARDS.CUSTOMER;

INSERT INTO TEMP_DUPLICATE_CARDS_20140730221632
(SELECT * FROM TEMP_CARD_20140730221700_223 WHERE UASD_ID=296
AND ((STARTDATE BETWEEN DATE_SUB('2013-05-31', INTERVAL 1 DAY) AND DATE_SUB('2013-06-30', INTERVAL 1 DAY)) 
OR (ENDDATE BETWEEN DATE_SUB('2013-05-31', INTERVAL 1 DAY)
AND DATE_SUB('2013-06-30', INTERVAL 1 DAY))) AND ID > 5);

SELECT DISTINCT CLD.CLP_ID,CLD.CUSTOMER_ID,CLD.CED_REC_VER,CLD.UASD_ID,CLD.CLP_STARTDATE,CLD.CLP_ENDDATE,CLD.CLP_PRETERMINATE_DATE,CLD.CLP_TERMINATE,CLD.CLP_GUEST_CARD 
FROM CUSTOMER_LP_DETAILS CLD,TEMP_DUPLICATE_CARDS_20140731093155 TDI 
WHERE CLD.CLP_ID=TDI.CLP_ID AND CLD.CUSTOMER_ID=TDI.CUSTOMER_ID AND CLD.UASD_ID=TDI.UASD_ID;

SELECT IF( CC_LAST_NAME IS NOT NULL,CONCAT(CC_FIRST_NAME,' ', CC_LAST_NAME),CONCAT(CC_FIRST_NAME))AS NAME,  CC_STARTDATE, CC_ENDDATE, CC_CARD_NO, CC_UNIT_NO  
FROM CUSTOMER_SCDB_FORMAT WHERE CC_CARD_NO IS NOT NULL;

SELECT CC_FIRST_NAME,CC_LAST_NAME,CC_STARTDATE, CC_ENDDATE, CC_CARD_NO, CC_UNIT_NO  
FROM CUSTOMER_SCDB_FORMAT WHERE CC_CARD_NO IS NOT NULL;

SELECT CC_FIRST_NAME,CC_LAST_NAME,CC_STARTDATE, CC_ENDDATE, CC_CARD_NO, CC_UNIT_NO , CC_REC_VER
FROM CUSTOMER_SCDB_FORMAT WHERE CC_FIRST_NAME='VINCENZO';

-- SELECT CC_FIRST_NAME,CC_LAST_NAME,CC_STARTDATE, CC_ENDDATE, CC_CARD_NO, CC_UNIT_NO , CC_REC_VER
-- FROM CUSTOMER_SCDB_FORMAT WHERE CC_CARD_NO=13191 AND  CC_UNIT_NO =2317
-- AND CC_STARTDATE >= '2011-04-29' AND CC_ENDDATE <= '2011-11-25';

SELECT UNIT_ACC_NAME, UNIT_NO,UNIT_ACCESS_CARD, UNIT_ACCESS_INVENTORY, UNIT_START_DATE, UNIT_END_DATE
FROM UNIT_SCDB_FORMAT WHERE UNIT_ACCESS_INVENTORY='X' AND UNIT_NO=422;

SELECT CC_FIRST_NAME,CC_LAST_NAME,CC_STARTDATE, CC_ENDDATE, CC_CARD_NO, CC_UNIT_NO , CC_REC_VER
FROM CUSTOMER_SCDB_FORMAT WHERE CC_CARD_NO=16324 AND  CC_UNIT_NO =422
AND ((CC_STARTDATE BETWEEN '2011-10-01' AND '2012-11-30') OR (CC_ENDDATE BETWEEN '2011-10-01' AND '2012-11-30'));

-- SELECT INVNTRY CRD

SELECT UNIT_ID FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=274 AND CED_REC_VER=2;

SELECT UASD_ID,UASD_ACCESS_CARD FROM UNIT_ACCESS_STAMP_DETAILS WHERE UNIT_ID=29 AND UASD_ACCESS_INVENTORY='X';

SELECT UASD_ID,UASD_ACCESS_CARD FROM UNIT_ACCESS_STAMP_DETAILS WHERE UNIT_ID=35 AND UASD_ACCESS_ACTIVE='X';

SELECT * FROM CUSTOMER_LP_DETAILS WHERE UASD_ID=69 AND ((CLP_STARTDATE BETWEEN '2010-10-05' AND '2013-12-04')
OR (CLP_ENDDATE BETWEEN '2010-10-05' AND '2013-12-04'));

SELECT * FROM CUSTOMER_LP_DETAILS WHERE UASD_ID=82 AND ((CLP_STARTDATE BETWEEN  '2010-06-27' AND '2011-04-20')
OR (CLP_ENDDATE BETWEEN '2010-06-27' AND '2011-04-20'));

SELECT * FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ID=140;
SELECT * FROM CUSTOMER_LP_DETAILS WHERE UASD_ID=518;
SELECT*FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CUSTOMER_ID=274;
SELECT * FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=274;
SELECT UASD_ID,UASD_ACCESS_CARD FROM UNIT_ACCESS_STAMP_DETAILS WHERE UASD_ACCESS_CARD IS NOT NULL;

UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=528 WHERE CUSTOMER_ID=285 AND CLP_ID=527;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=518 WHERE CUSTOMER_ID=274 AND CLP_ID=506;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=69 WHERE CUSTOMER_ID=121 AND CLP_ID IN(215,216,217,218,219);
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=82 WHERE CUSTOMER_ID=142 AND CLP_ID=252;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=215 WHERE CUSTOMER_ID=112 AND CLP_ID=199;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=65 WHERE CUSTOMER_ID=286 AND CLP_ID=528;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=233 WHERE CUSTOMER_ID=259 AND CLP_ID=483;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=292 WHERE CUSTOMER_ID=12 AND CLP_ID=27;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=292 WHERE CUSTOMER_ID=7 AND CLP_ID=18;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=296 WHERE CUSTOMER_ID=152 AND CLP_ID=278;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=296 WHERE CUSTOMER_ID=152 AND CLP_ID=279;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=232 WHERE CUSTOMER_ID=48 AND CLP_ID=96;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=159 WHERE CUSTOMER_ID=333 AND CLP_ID=615;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=106 WHERE CUSTOMER_ID=155 AND CLP_ID=287;

UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=149 WHERE CUSTOMER_ID=79 AND CLP_ID=146;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=197 WHERE CUSTOMER_ID=462 AND CLP_ID=1094;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=215 WHERE CUSTOMER_ID=112 AND CLP_ID=199;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=27 WHERE CUSTOMER_ID=247 AND CLP_ID=458;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=26 WHERE CUSTOMER_ID=194 AND CLP_ID=361;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=26 WHERE CUSTOMER_ID=194 AND CLP_ID=362;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=248 WHERE CUSTOMER_ID=80 AND CLP_ID=148;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=26 WHERE CUSTOMER_ID=199 AND CLP_ID=369;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=302 WHERE CUSTOMER_ID=199 AND CLP_ID=565;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=127 WHERE CUSTOMER_ID=307 AND CLP_ID=574;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=127 WHERE CUSTOMER_ID=307 AND CLP_ID=575;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=127 WHERE CUSTOMER_ID=307 AND CLP_ID=576;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=112 WHERE CUSTOMER_ID=435 AND CLP_ID=771;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=112 WHERE CUSTOMER_ID=435 AND CLP_ID=772;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=65 WHERE CUSTOMER_ID=185 AND CLP_ID=345;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=65 WHERE CUSTOMER_ID=185 AND CLP_ID=346;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=65 WHERE CUSTOMER_ID=185 AND CLP_ID=347;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=65 WHERE CUSTOMER_ID=185 AND CLP_ID=348;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=104 WHERE CUSTOMER_ID=182 AND CLP_ID=341;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=285 WHERE CUSTOMER_ID=198 AND CLP_ID=368;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=204 WHERE CUSTOMER_ID=209 AND CLP_ID=395;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=311 WHERE CUSTOMER_ID=214 AND CLP_ID=402;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=312 WHERE CUSTOMER_ID=86 AND CLP_ID=160;
UPDATE CUSTOMER_LP_DETAILS SET UASD_ID=313 WHERE CUSTOMER_ID=114 AND CLP_ID=1047;

-- SELECT RCD AFTR PATCH

SELECT * FROM CUSTOMER_LP_DETAILS WHERE UASD_ID = 225 ORDER BY CLP_STARTDATE,CUSTOMER_ID,CED_REC_VER;

SELECT * FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE UASD_ID = 225 ORDER BY  CACD_VALID_FROM,CACD_VALID_TILL;

-- FOR WRITE PATCH

SELECT * FROM CUSTOMER_LP_DETAILS WHERE CLP_ID=535;

SELECT * FROM CUSTOMER_ACCESS_CARD_DETAILS WHERE CACD_ID=655;

SELECT * FROM CUSTOMER_PERSONAL_DETAILS WHERE CUSTOMER_ID=141;

-- UPDATE PATCH CMT

SELECT UNIT_ID FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=291 AND CED_REC_VER=1;

SELECT UASD_ID, UASD_ACCESS_CARD FROM UNIT_ACCESS_STAMP_DETAILS WHERE UNIT_ID=36 AND UASD_ID=291;

SELECT UASD_ID,UASD_ACCESS_CARD FROM UNIT_ACCESS_STAMP_DETAILS WHERE UNIT_ID=36 AND UASD_ID=175 AND UASD_ACCESS_INVENTORY='X';

-- INSERT DUMMY CARDS

SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=21 AND CED_REC_VER=1;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=39 AND CED_REC_VER=1;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=133 AND CED_REC_VER=1;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=161 AND CED_REC_VER=1;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=223 AND CED_REC_VER=1;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=272 AND CED_REC_VER=1;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=337 AND CED_REC_VER=1;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=356 AND CED_REC_VER=1;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=156 AND CED_REC_VER=1;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=76 AND CED_REC_VER=1;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=235 AND CED_REC_VER=1;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=354 AND CED_REC_VER=1;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=271 AND CED_REC_VER=2;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=214 AND CED_REC_VER=1;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=86 AND CED_REC_VER=2;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=114 AND CED_REC_VER=1;
SELECT*FROM CUSTOMER_ENTRY_DETAILS WHERE CUSTOMER_ID=285 AND CED_REC_VER=1;

-- INSERT DUMMY CARDS

INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(29,7777,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(29,8888,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(29,9999,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(29,11111,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(29,22222,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(29,33333,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(29,44444,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(3,55555,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(29,66666,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(29,77777,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(29,88888,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(29,99999,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(19,111111,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(37,222222,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(37,333333,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(37,444444,'X','DUMMY CARD',2);
INSERT INTO UNIT_ACCESS_STAMP_DETAILS ( UNIT_ID, UASD_ACCESS_CARD, UASD_ACCESS_LOST, UASD_COMMENTS, ULD_ID)VALUES(18,555555,'X','DUMMY CARD',2);

