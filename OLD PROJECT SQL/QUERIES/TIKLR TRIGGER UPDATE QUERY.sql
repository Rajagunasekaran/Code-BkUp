IF ((OLD.EMP_FIRST_NAME!= NEW.EMP_FIRST_NAME) OR (OLD.EMP_LAST_NAME!= NEW.EMP_LAST_NAME) OR (OLD.ECN_ID != NEW.ECN_ID) OR (OLD.EMP_MOBILE!= NEW.EMP_MOBILE)
OR (OLD.EMP_EMAIL IS NULL AND NEW.EMP_EMAIL IS NOT NULL) OR (OLD.EMP_EMAIL IS NOT NULL AND NEW.EMP_EMAIL IS NULL) OR (OLD.EMP_EMAIL != NEW.EMP_EMAIL)
OR (OLD.EMP_COMMENTS IS NULL AND NEW.EMP_COMMENTS IS NOT NULL) OR (OLD.EMP_COMMENTS IS NOT NULL AND NEW.EMP_COMMENTS IS NULL) OR (OLD.EMP_COMMENTS != NEW.EMP_COMMENTS)) THEN

UPDATE cheque_entry_details SET CHEQUE_DATE='2010-11-16', CHEQUE_TO='Sapien Consulting', CHEQUE_NO=956916, CHEQUE_FOR='Refund of deposit', CHEQUE_AMOUNT=6500.00, CHEQUE_UNIT_NO=3715, BCN_ID=10, CHEQUE_DEBITED_RETURNED_DATE='2010-11-26', CHEQUE_COMMENTS=NULL, ULD_ID=6 WHERE CHEQUE_ID=2;
UPDATE cheque_entry_details SET  CHEQUE_COMMENTS='HH', CHEQUE_UNIT_NO=NULL, ULD_ID=7 WHERE CHEQUE_ID=2;
SELECT * FROM cheque_entry_details;
SELECT*FROM tickler_history;

UPDATE email_template_details SET ET_ID=8,ETD_EMAIL_SUBJECT='RAA',ETD_EMAIL_BODY='FNE',ULD_ID=9 WHERE ETD_ID=3;
UPDATE email_template_details SET ET_ID=3,ETD_EMAIL_SUBJECT='REQUEST FOR PAYMENT',ETD_EMAIL_BODY='PLEASE PAY THE AMT',ULD_ID=2 WHERE ETD_ID=3;
UPDATE email_template_details SET ULD_ID=3 WHERE ETD_ID=3;
SELECT * FROM email_template_details;
SELECT*FROM tickler_history;

UPDATE EMAIL_LIST SET EP_ID=2, EL_EMAIL_ID='kumar.r@ssomens.com', ULD_ID=6 WHERE EL_ID=2;
UPDATE EMAIL_LIST SET EP_ID=5, EL_EMAIL_ID='RAJA@GMAIL.COM', ULD_ID=5 WHERE EL_ID=2;
UPDATE EMAIL_LIST SET ULD_ID=4 WHERE EL_ID=2;
SELECT * FROM EMAIL_LIST;
SELECT*FROM tickler_history;

UPDATE employee_details SET EMP_FIRST_NAME='CY', EMP_LAST_NAME='CY', ECN_ID=74, EMP_MOBILE=111111, EMP_EMAIL='EEE', EMP_COMMENTS=NULL, ULD_ID=2 WHERE EMP_ID=1
UPDATE employee_details SET EMP_EMAIL=NULL WHERE EMP_ID=1
UPDATE employee_details SET ULD_ID=7 WHERE EMP_ID=1
SELECT * FROM employee_details;
SELECT * FROM tickler_history;

UPDATE erm_entry_details SET ERM_CUST_NAME='MARK' ,ERM_RENT=3000 ,ERM_MOVING_DATE='2013-1-11',ERM_MIN_STAY='1 MONTHS', ERMO_ID=101, NC_ID=32, ERM_NO_OF_GUESTS=NULL, ERM_AGE='MID 30S', ERM_CONTACT_NO=NULL, ERM_EMAIL_ID='REILLY2000@GMAIL.COM', ERM_COMMENTS='MAIL HIM PHOTO ASAP', ULD_ID=2 WHERE ERM_ID=1
UPDATE ERM_ENTRY_DETAILS SET NC_ID=NULL, ERM_NO_OF_GUESTS=NULL, ERM_AGE=NULL, ERM_CONTACT_NO=88767, ERM_EMAIL_ID=NULL, ULD_ID=3 WHERE ERM_ID=1
UPDATE ERM_ENTRY_DETAILS SET ULD_ID=9 WHERE ERM_ID=1
SELECT * FROM erm_entry_details;
SELECT*FROM tickler_history;

UPDATE expense_unit SET UNIT_ID=33, ECN_ID=36, EU_COMMENTS='SDFD', CUSTOMER_ID=NULL, ULD_ID=5 WHERE EU_ID =1;
UPDATE expense_unit SET EU_COMMENTS=NULL, CUSTOMER_ID=NULL ,ULD_ID=2 WHERE EU_ID =1;
SELECT * FROM expense_unit;
SELECT*FROM tickler_history;

