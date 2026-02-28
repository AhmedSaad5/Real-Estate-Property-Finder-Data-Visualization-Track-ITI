--A procedure  that retrieves the top 10 campaigns based on engagement rate.

CREATE OR REPLACE PROCEDURE Show_Top_Campaigns IS
BEGIN
   DBMS_OUTPUT.PUT_LINE('Top 10 Campaigns by Engagement Score:');
   
   FOR rec IN (
      SELECT campaign_id, Company_name, Engagement_Score
      FROM (
         SELECT campaign_id, Company_name, Engagement_Score
         FROM marketing_campaign
         ORDER BY Engagement_Score DESC
      )
      WHERE ROWNUM <= 10
   ) LOOP
      DBMS_OUTPUT.PUT_LINE('Campaign: ' || rec.campaign_id ||
                           ' | Company: ' || rec.Company_name ||
                           ' | Score: ' || rec.Engagement_Score);
   END LOOP;
END;



SET SERVEROUTPUT ON;
EXEC Show_Top_Campaigns;

---------------------------------------------------
--------------------------------------------- PROCEDURE analyze_sentiment_performance-----------------

CREATE OR REPLACE PROCEDURE analyze_sentiment_performance IS
    v_total_reviews NUMBER;
    v_positive NUMBER;
    v_negative NUMBER;
    v_neutral NUMBER;
    v_pos_ratio NUMBER;
    v_neg_ratio NUMBER;
    v_neu_ratio NUMBER;
    v_overall_sentiment VARCHAR2(20);
BEGIN
 
    SELECT 
        COUNT(*), 
        SUM(CASE WHEN sentiment='Positive' THEN 1 ELSE 0 END),
        SUM(CASE WHEN sentiment='Negative' THEN 1 ELSE 0 END),
        SUM(CASE WHEN sentiment='Neutral' THEN 1 ELSE 0 END)
    INTO 
        v_total_reviews, v_positive, v_negative, v_neutral
    FROM Reviews;

    v_pos_ratio := ROUND(v_positive * 100 / v_total_reviews, 2);
    v_neg_ratio := ROUND(v_negative * 100 / v_total_reviews, 2);
    v_neu_ratio := ROUND(v_neutral  * 100 / v_total_reviews, 2);

    IF v_pos_ratio > 70 THEN
        v_overall_sentiment := 'Excellent';
    ELSIF v_pos_ratio BETWEEN 40 AND 70 THEN
        v_overall_sentiment := 'Mixed';
    ELSE
        v_overall_sentiment := 'Poor';
    END IF;

    DBMS_OUTPUT.PUT_LINE('? Sentiment summary inserted successfully!');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total Reviews : ' || v_total_reviews);
    DBMS_OUTPUT.PUT_LINE('Positive       : ' || v_positive || ' (' || v_pos_ratio || '%)');
    DBMS_OUTPUT.PUT_LINE('Negative       : ' || v_negative || ' (' || v_neg_ratio || '%)');
    DBMS_OUTPUT.PUT_LINE('Neutral        : ' || v_neutral  || ' (' || v_neu_ratio || '%)');
    DBMS_OUTPUT.PUT_LINE('Overall Status : ' || v_overall_sentiment);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('? Error: ' || SQLERRM);
END;
/
BEGIN
    analyze_sentiment_performance;
END;
/
-------------------------------------------
---------------------------------------------

----CREATE PACKAGE 
--------------------------------------- Package Specification--------------
CREATE OR REPLACE PACKAGE RealEstate_Pkg AS
    PROCEDURE Show_Top_Agents(p_top_n IN NUMBER DEFAULT 5);
    PROCEDURE Campaign_Performance(p_top_n IN NUMBER DEFAULT 5);
    PROCEDURE Customer_Summary;
END RealEstate_Pkg;
/--------------------------------------- Package Body--------------

CREATE OR REPLACE PACKAGE BODY RealEstate_Pkg AS

-- Show Top Agents--------
PROCEDURE Show_Top_Agents(p_top_n IN NUMBER DEFAULT 5) IS
BEGIN
    FOR rec IN (
        SELECT * FROM (
            SELECT 
                a.agent_id,
                COUNT(s.sale_id) AS total_sales,
                SUM(s.sold_price) AS total_revenue,
                ROUND(SUM(s.sold_price)/COUNT(s.sale_id),2) AS avg_sale,
                ROW_NUMBER() OVER (ORDER BY SUM(s.sold_price) DESC) AS rn
            FROM sales s
            JOIN listings l ON s.listing_id = l.listing_id
            JOIN agents a ON s.agent_id = a.agent_id
            GROUP BY a.agent_id
        )
        WHERE rn <= p_top_n
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Agent: ' || rec.agent_id ||
            ' | Sales: ' || rec.total_sales ||
            ' | Revenue: ' || rec.total_revenue ||
            ' | Avg Sale: ' || rec.avg_sale
        );
    END LOOP;
END Show_Top_Agents;


--Campaign Performance
PROCEDURE Campaign_Performance(p_top_n IN NUMBER DEFAULT 5) IS
BEGIN
    FOR rec IN (
        SELECT * FROM (
            SELECT
                c.campaign_id,
                c.company_name,
                c.location,
                ROUND((c.clicks / NULLIF(c.impressions, 0)) * 100, 2) AS ctr_percent,
                ROUND(c.engagement_score, 2) AS engagement_score,
                ROW_NUMBER() OVER (ORDER BY c.engagement_score DESC) AS rn
            FROM marketing_campaign c
        )
        WHERE rn <= p_top_n
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Campaign: ' || rec.campaign_id ||
            ' | Company: ' || rec.company_name ||
            ' | Location: ' || rec.location ||
            ' | CTR: ' || rec.ctr_percent || '%' ||
            ' | Engagement: ' || rec.engagement_score
        );
    END LOOP;
END Campaign_Performance;


------Customer Summary
PROCEDURE Customer_Summary IS
BEGIN
    FOR rec IN (
        SELECT 
            customer_type,
            COUNT(*) AS total_customers,
            SUM(CASE WHEN support_status = 'Active' THEN 1 ELSE 0 END) AS active_customers
        FROM customers
        GROUP BY customer_type
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Customer Type: ' || rec.customer_type ||
            ' | Total: ' || rec.total_customers ||
            ' | Active: ' || rec.active_customers
        );
    END LOOP;
END Customer_Summary;

END RealEstate_Pkg;
/
SHOW ERRORS;
SET SERVEROUTPUT ON;
EXEC RealEstate_Pkg.Show_Top_Agents;
EXEC RealEstate_Pkg.Campaign_Performance;
EXEC RealEstate_Pkg.Customer_Summary;


--------------------------------------------------------
