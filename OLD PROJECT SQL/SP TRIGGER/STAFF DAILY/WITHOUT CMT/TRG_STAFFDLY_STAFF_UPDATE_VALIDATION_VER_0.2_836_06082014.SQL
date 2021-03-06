DROP TRIGGER IF EXISTS TRG_STAFFDLY_STAFF_UPDATE_VALIDATION;
CREATE TRIGGER TRG_STAFFDLY_STAFF_UPDATE_VALIDATION
BEFORE UPDATE ON EXPENSE_STAFF
FOR EACH ROW
BEGIN
	CALL SP_TRG_STAFFDLY_STAFF_VALIDATION(NEW.ECN_ID,NEW.ES_INVOICE_DATE,NEW.ES_INVOICE_AMOUNT,'UPDATE');
END;