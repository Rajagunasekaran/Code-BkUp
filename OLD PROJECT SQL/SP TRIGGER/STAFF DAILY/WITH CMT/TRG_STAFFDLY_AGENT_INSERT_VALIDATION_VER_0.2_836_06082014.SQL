-- VERSION 0.2 STARTDATE:06/08/2014 ENDDATE:06/08/2014 ISSUE NO: 836  DESC:IMPLEMENTED AMOUNT VALIDATION FOR INSERT TRIGGER. DONE BY :RAJA
-- version:0.1 --sdate:20-06-2014 --edate:20-06-2014 --issue:593 --commentno#75 --desc:invoice date validation --doneby:RL

DROP TRIGGER IF EXISTS TRG_STAFFDLY_AGENT_INSERT_VALIDATION;
CREATE TRIGGER TRG_STAFFDLY_AGENT_INSERT_VALIDATION
BEFORE INSERT ON EXPENSE_AGENT
FOR EACH ROW
BEGIN
	CALL SP_TRG_STAFFDLY_AGENT_VALIDATION(NEW.EA_DATE,NEW.EA_COMM_AMOUNT,'INSERT');
END;