-------------------------------CREATE TRIGGER  UPDATE ON sales------------------------------------------------------------------
------------------------------------CREATE TABLE-----------------------------
CREATE TABLE sales_audit (
    audit_id NUMBER PRIMARY KEY,
    sale_id VARCHAR2(20),
    old_sold_price NUMBER,
    old_commission_rate NUMBER,
    old_commission_value NUMBER,
    modified_date DATE,
    modified_by VARCHAR2(50)
);
---------------------------------------------------
CREATE SEQUENCE sales_audit_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;
------------------------------------------
CREATE OR REPLACE TRIGGER trg_sales_update_audit
BEFORE UPDATE ON sales
FOR EACH ROW
BEGIN
    INSERT INTO sales_audit (
        audit_id,
        sale_id,
        old_sold_price,
        old_commission_rate,
        old_commission_value,
        modified_date,
        modified_by
    )
    VALUES (
        sales_audit_seq.NEXTVAL,  
        :OLD.sale_id,
        :OLD.sold_price,
        :OLD.commission_rate,
        :OLD.commission_value,
        SYSDATE,   
        USER       
    );
END;
/
UPDATE sales
SET sold_price = sold_price + 1000
WHERE sale_id = 'S000001';

SELECT * FROM sales_audit
ORDER BY audit_id DESC;




----------------------------------------------  TRIGGER INSERT ON sales---------------------------------------
----------------------------CREATE TABLE-----
CREATE TABLE sales_log (
   log_id NUMBER PRIMARY KEY,
   sale_id VARCHAR2(20),
   listing_id VARCHAR2(20),
   customer_id VARCHAR2(20),
   agent_id VARCHAR2(20),
   sale_date DATE,
   sold_price NUMBER,
   commission_rate NUMBER,
   commission_value NUMBER,
   payment_status VARCHAR2(20),
   log_date DATE DEFAULT SYSDATE
);


---------------------
CREATE SEQUENCE sales_log_seq START WITH 1 INCREMENT BY 1;
---------------------------------
CREATE OR REPLACE TRIGGER trg_sales_log_id
BEFORE INSERT ON sales_log
FOR EACH ROW
BEGIN
   IF :NEW.log_id IS NULL THEN
      SELECT sales_log_seq.NEXTVAL INTO :NEW.log_id FROM dual;
   END IF;
END;
/

-------------------------
-- Trigger Name: lopg_new_sale
-- Purpose: Automatically logs every new sale inserted into the 'sales' table.
-- Functionality:
--   1. Prints a confirmation message to the SQL output window when a new sale is added.
--   2. Inserts the new sale details into the 'sales_log' table for tracking and auditing.
-- Trigger Type: AFTER INSERT (row-level)


CREATE OR REPLACE TRIGGER lopg_new_sale
AFTER INSERT ON sales
FOR EACH ROW
BEGIN
   DBMS_OUTPUT.PUT_LINE(
      '? New Sale Added: ' || :NEW.sale_id || 
      ' | Agent: ' || :NEW.agent_id ||
      ' | Price: ' || :NEW.sold_price
   );

   INSERT INTO sales_log (
      sale_id,
      listing_id,
      customer_id,
      agent_id,
      sale_date,
      sold_price,
      commission_rate,
      commission_value,
      payment_status
   ) VALUES (
      :NEW.sale_id,
      :NEW.listing_id,
      :NEW.customer_id,
      :NEW.agent_id,
      :NEW.sale_date,
      :NEW.sold_price,
      :NEW.commission_rate,
      :NEW.commission_value,
      :NEW.payment_status
   );
END;
/
show error
------------------------
--? Output Window
SET SERVEROUTPUT ON;
INSERT INTO sales (
   sale_id,
   agent_id,
   listing_id,
   customer_id,
   sold_price,
   sale_date,
   commission_rate,
   commission_value,
   payment_status
)
VALUES (
   'S00015',          
   'A0257',           
   'LST-00233', 
   'C000392',    
   95000,        
   SYSDATE,
   0.05,         
   4750,       
   'Paid'
);

SELECT * FROM sales_log ORDER BY log_id DESC;
listings