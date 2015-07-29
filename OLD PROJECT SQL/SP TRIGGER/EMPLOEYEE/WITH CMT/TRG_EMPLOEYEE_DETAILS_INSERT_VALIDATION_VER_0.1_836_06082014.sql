-- VERSION 0.1 STARTDATE:06/08/2014 ENDDATE:06/08/2014 ISSUE NO:836  DESC:IMPLEMENTED CONSTRAINTS TRIGGER FOR INSERT. DONE BY :RAJA
DROP TRIGGER IF EXISTS TRG_EMPLOEYEE_DETAILS_INSERT_VALIDATION;
CREATE TRIGGER TRG_EMPLOEYEE_DETAILS_INSERT_VALIDATION
BEFORE INSERT ON EMPLOYEE_DETAILS
FOR EACH ROW
BEGIN
	CALL SP_TRG_EMPLOEYEE_DETAILS_VALIDATION (NEW.EMP_MOBILE,'INSERT');
END;