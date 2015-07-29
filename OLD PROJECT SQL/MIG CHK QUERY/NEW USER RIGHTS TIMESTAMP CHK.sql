SELECT*FROM SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT WHERE MROLES='SUPER ADMIN';
SELECT* FROM SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT WHERE MROLES='ADMIN';
SELECT* FROM SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT WHERE MROLES='USER';
SELECT * FROM SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT WHERE MROLES='USER1';

SELECT TIMESTAMP, MROLES FROM SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT WHERE MROLES='ADMIN';
SELECT  *FROM USER_MENU_DETAILS WHERE RC_ID=1;

SELECT TIMESTAMP, MROLES FROM SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT WHERE MROLES='SUPER ADMIN';
SELECT DISTINCT RC_ID, MD_TIMESTAMP FROM USER_MENU_DETAILS WHERE RC_ID=2;

SELECT DISTINCT TIMESTAMP, MROLES FROM SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT WHERE MROLES='USER';
SELECT DISTINCT RC_ID, MD_TIMESTAMP FROM USER_MENU_DETAILS WHERE RC_ID=3;

SELECT DISTINCT TIMESTAMP, MROLES FROM SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT WHERE MROLES='USER1';
SELECT  DISTINCT RC_ID, MD_TIMESTAMP FROM USER_MENU_DETAILS WHERE RC_ID=4;

-- ADMIN
SELECT SUBTIME('2013-04-08 01:06:19','08:00:00')-> 2013-04-07 17:06:19
-- SUP. ADMIN
SELECT SUBTIME('2013-05-08 03:46:34','08:00:00')-> 2013-05-07 19:46:34
SELECT SUBTIME('2013-05-08 03:46:28','08:00:00')-> 2013-05-07 19:46:28
SELECT SUBTIME('2013-05-08 03:46:27','08:00:00')-> 2013-05-07 19:46:27
SELECT SUBTIME('2013-05-08 03:46:26','08:00:00')-> 2013-05-07 19:46:26
SELECT SUBTIME('2013-04-10 03:57:30','08:00:00')-> 2013-04-09 19:57:30
SELECT SUBTIME('2013-04-08 01:06:19','08:00:00')-> 2013-04-07 17:06:19
-- USER
SELECT SUBTIME('2013-05-10 12:36:24','08:00:00')-> 2013-05-10 04:36:24
SELECT SUBTIME('2013-05-10 12:36:29','08:00:00')-> 2013-05-10 04:36:29
-- USER1
SELECT SUBTIME('2014-02-10 01:36:00','08:00:00')-> 2014-02-09 17:36:00
SELECT SUBTIME('2014-02-10 01:36:01','08:00:00')-> 2014-02-09 17:36:01
SELECT ADDTIME('2013-4-7 17:06:19','08:00:00')

SELECT*FROM USER_ACCESS;
SELECT*FROM USER_LOGIN_DETAILS;
SELECT*FROM ROLE_CREATION;

SELECT*FROM USER_ACCESS WHERE RC_ID=1;
SELECT*FROM USER_LOGIN_DETAILS;
SELECT*FROM ROLE_CREATION;

SELECT SUBTIME(C.TIMESTAMP,'08:00:00') ,A.UA_TIMESTAMP, B.ULD_TIMESTAMP
FROM SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT C ,USER_ACCESS A, USER_LOGIN_DETAILS B 
WHERE URECVER=1 ORDER BY URROLES -> 2013-05-10 04:51:36

SELECT URROLES ,URECVER, SUBTIME(TIMESTAMP,'08:00:00') FROM  SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT WHERE URROLES='ADMIN' AND URECVER=1;

SELECT RC_ID , UA_REC_VER ,UA_TIMESTAMP FROM USER_ACCESS WHERE RC_ID=1;

SELECT URROLES ,URECVER, SUBTIME(TIMESTAMP,'08:00:00') FROM  SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT WHERE URROLES='SUPER ADMIN' AND URECVER=1;

SELECT RC_ID , UA_REC_VER ,UA_TIMESTAMP FROM USER_ACCESS WHERE RC_ID=2;
SELECT URROLES ,URECVER, SUBTIME(TIMESTAMP,'08:00:00') FROM  SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT WHERE URROLES='USER' AND URECVER=1;

SELECT RC_ID , UA_REC_VER ,UA_TIMESTAMP FROM USER_ACCESS WHERE RC_ID=3;
SELECT URROLES ,URECVER, SUBTIME(TIMESTAMP,'08:00:00') FROM  SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT WHERE URROLES='USER1' AND URECVER=1;

SELECT RC_ID , UA_REC_VER ,UA_TIMESTAMP FROM USER_ACCESS WHERE RC_ID=4;
SELECT URROLES ,URECVER, SUBTIME(TIMESTAMP,'08:00:00') FROM  SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT WHERE URROLES='SUPER ADMIN' AND URECVER=1;

SELECT RC_ID , UA_REC_VER ,UA_TIMESTAMP FROM USER_ACCESS WHERE RC_ID=2;

SELECT*FROM SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT WHERE URECVER=1;

SELECT DISTINCT A.UA_TIMESTAMP, B.ULD_TIMESTAMP FROM USER_ACCESS A, USER_LOGIN_DETAILS B WHERE A.UA_TIMESTAMP=B.ULD_TIMESTAMP

SELECT DISTINCT RC.RC_ID, RC.RC_NAME,  RC. RC_TIMESTAMP, SUBTIME(SC.TIMESTAMP, '08:00:00') 
FROM ROLE_CREATION RC, SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT SC
WHERE RC.RC_TIMESTAMP=SUBTIME(SC.TIMESTAMP, '08:00:00');

SELECT TIMESTAMP,URROLES  ,MROLES,ROLES
FROM SAFI_SOURCE.USER_RIGHTS_SCDB_FORMAT WHERE `TIMESTAMP`='2013-04-08 01:06:19';

SELECT UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP('2007-03-19 09:50:00');
