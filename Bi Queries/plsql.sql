
--  Display the top 20 properties with a price greater than 500,000 using a CURSOR
SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
   CURSOR cur_high_price IS
      SELECT LISTING_ID, property_type, BASE_PRICE
      FROM listings
      WHERE BASE_PRICE > 500000
        AND ROWNUM <= 20
      ORDER BY BASE_PRICE DESC;

   rec cur_high_price%ROWTYPE;
BEGIN
   OPEN cur_high_price;

   LOOP
      FETCH cur_high_price INTO rec;
      EXIT WHEN cur_high_price%NOTFOUND;

      DBMS_OUTPUT.PUT_LINE(
         'Property ID: ' || rec.LISTING_ID ||
         ' | Type: ' || rec.property_type ||
         ' | Price: ' || rec.BASE_PRICE
      );
   END LOOP;

   CLOSE cur_high_price;
END;
/
------------------------------------------------------------------------------------------
--PL/SQL example: Printing 10 high-engagement campaigns
SET SERVEROUTPUT ON;
BEGIN
   FOR rec IN (
      SELECT campaign_id, Company_name, Engagement_Score
      FROM (
         SELECT campaign_id, Company_name, Engagement_Score
         FROM marketing_campaign
         WHERE Engagement_Score = 10
         ORDER BY campaign_id
      )
      WHERE ROWNUM <= 10
   ) LOOP
      DBMS_OUTPUT.PUT_LINE('Campaign: ' || rec.campaign_id ||
                           ' - Company: ' || rec.Company_name ||
                           ' - Score: ' || rec.Engagement_Score);
   END LOOP;
END;

------------------------------------------------------------------------------------------


-- Purpose: Display the top 10 customers based on total purchase value.

SET SERVEROUTPUT ON;

BEGIN
   FOR rec IN (
      SELECT customer_id, total_spent
      FROM (
         SELECT customer_id, SUM(sold_price) AS total_spent
         FROM sales
         GROUP BY customer_id
         ORDER BY total_spent DESC
      )
      WHERE ROWNUM <= 10
   ) LOOP
      DBMS_OUTPUT.PUT_LINE(
         '?? Customer ID: ' || rec.customer_id ||
         ' | Total Spent: ' || rec.total_spent
      );
   END LOOP;
END;
/

