-- VERSION 0.6 STARTDATE:24/06/2014 ENDDATE:24/06/2014 DESC: CHECK CONSTRAINS FOR THE EP_DATE AND PASSPORT_DATE IN CUSTOMER PERSONAL DETAILS. DONE BY :RAJA

DROP PROCEDURE IF EXISTS SP_TRG_CUSTOMER_PERSONAL_DETAILS;
CREATE PROCEDURE SP_TRG_CUSTOMER_PERSONAL_DETAILS(
IN NEWCUSTOMERID INTEGER,
IN NEWNCID INTEGER,
IN NEWEPDATE DATE,
IN NEWPASSPORTDATE DATE,
IN PROCESS VARCHAR(20))
BEGIN
DECLARE CLPENDDATE DATE;
DECLARE CLPPREDATE DATE;
DECLARE END_DATE DATE;
DECLARE MAXRECVER INTEGER;
DECLARE MESSAGE_TEXT VARCHAR(50);

SET CLPENDDATE='';
SET CLPPREDATE='';

-- SELECT MAXRECVER,PRETERMINATION AND ENDDATE 
SET MAXRECVER=(SELECT MAX(CED_REC_VER) FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=NEWCUSTOMERID);
SET CLPPREDATE=(SELECT CLP_PRETERMINATE_DATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=NEWCUSTOMERID AND CED_REC_VER=MAXRECVER AND CLP_GUEST_CARD IS NULL);
SET CLPENDDATE=(SELECT CLP_ENDDATE FROM CUSTOMER_LP_DETAILS WHERE CUSTOMER_ID=NEWCUSTOMERID AND CED_REC_VER=MAXRECVER AND CLP_GUEST_CARD IS NULL);

IF(CLPPREDATE IS NOT NULL)THEN
SET END_DATE=CLPPREDATE;
ELSE
SET END_DATE=CLPENDDATE;
END IF;

-- THROWING ERROR MSG 

IF(PROCESS='INSERT') OR (PROCESS='UPDATE')THEN
  IF((END_DATE < NEWEPDATE) AND (END_DATE < NEWPASSPORTDATE))THEN
    IF(NEWEPDATE>CURDATE()) THEN 
      IF (NEWEPDATE > DATE_ADD(curdate(), INTERVAL 3 YEAR)) THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT= 'EP DATE SHOULD BE WITHIN 3 YEARS FROM THE CURRENT DATE';
      END IF;
    END IF;
    IF(NEWPASSPORTDATE>CURDATE())THEN  
      IF (NEWPASSPORTDATE > DATE_ADD(curdate(), INTERVAL 10 YEAR) ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT= 'PASSPORT DATE SHOULD BE WITHIN 10 YEARS FROM THE CURRENT DATE';    
      END IF;
    END IF;  
  END IF;
END IF;
END;