
---Sql  Query
-----------marketing_campaign-----------

  --Cost_Per_Click,
SELECT 
    Campaign_Source,
    SUM(Cost) AS Total_Cost,
    SUM(Clicks) AS Total_Clicks,
    SUM(Engagement_Score) AS Total_Engagement,
    ROUND(SUM(Cost) / NULLIF(SUM(Clicks), 0), 2) AS Cost_Per_Click,
    ROUND(SUM(Cost) / NULLIF(SUM(Engagement_Score), 0), 2) AS Cost_Per_Engagement
FROM MARKETING_CAMPAIGN
GROUP BY Campaign_Source
ORDER BY Cost_Per_Click ASC;
------------------------------------------------
--1. The most common campaign objectives
SELECT Objective, COUNT(*) AS Total_Campaigns
FROM marketing_campaign
GROUP BY Objective
ORDER BY Total_Campaigns DESC;
--------------------------------
--2. Campaigns with the highest engagement rate

SELECT *
FROM (
    SELECT campaign_id, company_name, Engagement_Score
    FROM marketing_campaign
    ORDER BY Engagement_Score DESC
)
WHERE ROWNUM <= 10;
------------------------------------------
--3. Average cost by type of order

SELECT Campaign_Type, ROUND(AVG(Cost), 2) AS Avg_Cost
FROM marketing_campaign
GROUP BY Campaign_Type
ORDER BY Avg_Cost DESC;
-----------------------------------
--4. Distributing campaigns by month

SELECT Month_Of_Year, COUNT(*) AS Campaign_Count
FROM marketing_campaign
GROUP BY Month_Of_Year
ORDER BY Month_Of_Year;
-----------------------------------------
--5 -Campaign performance by city (average engagement rate)
SELECT Location, AVG(Engagement_Score) AS Avg_Engagement
FROM marketing_campaign
GROUP BY Location
ORDER BY Avg_Engagement DESC;
----------------------------------------------------
--6 - Comparing the rate of interaction between companies
SELECT Company_name, AVG(Engagement_Score) AS Avg_Engagement
FROM marketing_campaign
GROUP BY Company_name
ORDER BY Avg_Engagement DESC;
------------------------------------------------
--7 - Filter campaigns by target audience and source
SELECT campaign_id, Company_name, Objective, Engagement_Score
FROM marketing_campaign
WHERE Target_Audience = 'Women 25-34'
  AND Campaign_Source = 'Instagram';
  -----------------------------------------
  ----------------------Marketing Channel Performance Summary
SELECT 
    Campaign_Source,
    SUM(Cost) AS Total_Cost,
    SUM(Clicks) AS Total_Clicks,
    SUM(Impressions) AS Total_Impressions,
    SUM(Engagement_Score) AS Total_Engagement,
    
    ROUND(SUM(Cost) / NULLIF(SUM(Clicks), 0), 2) AS Cost_Per_Click,
    ROUND(SUM(Cost) / NULLIF(SUM(Engagement_Score), 0), 2) AS Cost_Per_Engagement,
    ROUND((SUM(Clicks) / NULLIF(SUM(Impressions), 0)) * 100, 2) AS CTR_Percentage,
    ROUND((SUM(Engagement_Score) / NULLIF(SUM(Impressions), 0)) * 100, 2) AS Engagement_Rate_Percentage

FROM MARKETING_CAMPAIGN
GROUP BY Campaign_Source
ORDER BY Cost_Per_Click ASC;
  ----------------------agent------------------------------

  --8. Calculate the number of closed leads per agent
--A list of agents (Agent_ID and contact_person) and the number of closed leads (Hot Leads) for each agent, 
--sorted in descending order by the number of closed leads.

SELECT a.Agent_ID, COUNT(l.Lead_ID) AS ClosedLeads
FROM Agents a
JOIN Leads l ON a.Agent_ID = l.Agent_ID
WHERE l.Lead_Status = 'Hot'
GROUP BY a.Agent_ID
ORDER BY ClosedLeads DESC;  
--------------------------------------
--?The number of leads is calculated for each agent?
SELECT 
    a.Agent_ID,
    COUNT(CASE WHEN l.Lead_Status = 'Hot' THEN 1 END) AS HotLeads,
    COUNT(CASE WHEN l.Lead_Status = 'Warm' THEN 1 END) AS WarmLeads
FROM Agents a
JOIN Leads l ON a.Agent_ID = l.Agent_ID
GROUP BY a.Agent_ID
ORDER BY HotLeads DESC;

---------------------------------------------
--10. Show the top 10 agents by performance
SELECT *
FROM (
    SELECT a.agent_id, a.contact_person, COUNT(s.sale_id) AS Total_Sales
    FROM Agents a
    JOIN Sales s ON a.agent_id = s.agent_id
    GROUP BY a.agent_id, a.contact_person
    ORDER BY COUNT(s.sale_id) DESC
)
WHERE ROWNUM <= 10;
---------------------------------------
-- ? Display the Top 5 Agents Based on Years of Experience

SELECT *
FROM (
    SELECT * 
    FROM Agents 
    ORDER BY EXPERIENCE_YEARS DESC
)
WHERE ROWNUM <= 5;
---------------------------------------
--? Insight Total revenue per agent?
SELECT agent_id, SUM(sold_price) AS total_revenue
FROM Sales
GROUP BY agent_id
ORDER BY total_revenue DESC;
------------------------------------
-- ? Extract the Top 5 Agents based on their performance in sales,
-- taking into account both total commission and years of experience.

SELECT *
FROM (
    SELECT 
        a.CONTACT_PERSON,
        a.EXPERIENCE_YEARS,
        SUM(s.COMMISSION_VALUE) AS PERFORMANCE_SCORE
    FROM Agents a
    JOIN Sales s ON a.Agent_ID = s.Agent_ID
    GROUP BY a.CONTACT_PERSON, a.EXPERIENCE_YEARS

    ORDER BY PERFORMANCE_SCORE DESC, a.EXPERIENCE_YEARS DESC
)
WHERE ROWNUM <= 5;
--------------------------------------
--? Insight Average commission percentage per agent?
SELECT agent_id, AVG(commission_rate) AS avg_rate
FROM Sales
GROUP BY agent_id
ORDER BY avg_rate DESC;
----------------------------------------
-- ?? Goal: Display the Top 10 Agents ranked by their total earned commission.
SELECT *
FROM (
    SELECT 
        a.CONTACT_PERSON,                  
        SUM(s.COMMISSION_VALUE) AS PERFORMANCE_SCORE  -- Total commission earned
    FROM Agents a
    JOIN Sales s ON a.Agent_ID = s.Agent_ID    
    GROUP BY a.CONTACT_PERSON

    ORDER BY PERFORMANCE_SCORE DESC
)
WHERE ROWNUM <= 10;

------------------------------------------
 --Agent Performance Summary
WITH AgentSales AS (
    SELECT 
        a.agent_id,
        a.company_name,
        COUNT(s.sale_id) AS Total_Sales,
        SUM(s.sold_price) AS Total_Revenue,
        AVG(l.days_on_market) AS Avg_Days_On_Market
    FROM Agents a
    LEFT JOIN Sales s ON a.agent_id = s.agent_id
    LEFT JOIN Listings l ON s.listing_id = l.listing_id
    GROUP BY a.agent_id, a.company_name
),
AgentLeads AS (
    SELECT 
        agent_id,
        COUNT(lead_id) AS Total_Leads,
        SUM(converted_flag) AS Leads_Converted,
        ROUND(SUM(converted_flag)*100.0/COUNT(lead_id),2) AS Conversion_Rate
    FROM Leads
    GROUP BY agent_id
)
SELECT 
    a.agent_id,
    a.company_name,
    COALESCE(s.Total_Sales,0) AS Total_Sales,
    COALESCE(s.Total_Revenue,0) AS Total_Revenue,
    COALESCE(s.Avg_Days_On_Market,0) AS Avg_Days_On_Market,
    COALESCE(l.Total_Leads,0) AS Total_Leads,
    COALESCE(l.Leads_Converted,0) AS Leads_Converted,
    COALESCE(l.Conversion_Rate,0) AS Conversion_Rate
FROM Agents a
LEFT JOIN AgentSales s ON a.agent_id = s.agent_id
LEFT JOIN AgentLeads l ON a.agent_id = l.agent_id
ORDER BY Total_Revenue DESC;
-------------------------------------------------------------
--?Top 5 Companies?? Based on Performance (Total Commission) and Number of Sales?

SELECT *
FROM (
    SELECT 
        a.COMPANY_NAME,
        SUM(s.commission_value) AS Total_Commission,
        COUNT(s.Sale_ID) AS Sales_Count
    FROM Agents a
    JOIN Sales s ON a.Agent_ID = s.Agent_ID
    GROUP BY a.COMPANY_NAME 
    ORDER BY Total_Commission DESC, Sales_Count DESC
)
WHERE ROWNUM <= 3;
-----------------Leads-------------------
--? Insight Number of leads per case?
SELECT
    Lead_Status,
    COUNT(*) AS LeadCount
FROM Leads
GROUP BY Lead_Status
ORDER BY LeadCount DESC;
--------------------------
--Cost per Lead
SELECT 
    m.CAMPAIGN_SOURCE AS Lead_Source,
    SUM(m.COST) AS Total_Cost,
    COUNT(l.LEAD_ID) AS Total_Leads,
    ROUND(SUM(m.COST) / NULLIF(COUNT(l.LEAD_ID), 0), 2) AS Cost_Per_Lead
FROM MARKETING_CAMPAIGN m
JOIN LEADS l ON m.CAMPAIGN_ID = l.CAMPAIGN_ID
GROUP BY m.CAMPAIGN_SOURCE
ORDER BY Cost_Per_Lead ASC;
------------------------------------------
-- Insight ?Agents with more than 10 "Hot" leads?
SELECT
    a.Agent_ID,
    COUNT(l.Lead_ID) AS HotLeadCount
FROM Agents a
JOIN Leads l ON a.Agent_ID = l.Agent_ID
WHERE l.Lead_Status = 'Hot'
GROUP BY a.Agent_ID
HAVING COUNT(l.Lead_ID) > 10
ORDER BY HotLeadCount DESC;
-------------------------------------------
--Lead Source Effectiveness
SELECT 
    m.Campaign_Source AS Lead_Source,
    COUNT(l.Lead_ID) AS Total_Leads,
    SUM(l.Converted_Flag) AS Converted_Leads,
    ROUND(SUM(l.Converted_Flag) * 100.0 / COUNT(l.Lead_ID), 2) AS Conversion_Rate_Percentage,
    ROUND(SUM(m.Cost) / NULLIF(SUM(l.Converted_Flag), 0), 2) AS Cost_Per_Converted_Lead
FROM Leads l
JOIN Marketing_Campaign m 
    ON l.Campaign_ID = m.Campaign_ID
GROUP BY m.Campaign_Source
ORDER BY Conversion_Rate_Percentage DESC;
-------------------------------------------------------
--9. Calculate the number of Contacted leads per agent
SELECT TO_CHAR(l.created_date, 'YYYY-MM') AS Month,
       a.contact_person,
       COUNT(l.Lead_ID) AS Contacted_Count
FROM Leads l
JOIN Agents a ON l.Agent_ID = a.Agent_ID
WHERE l.Lead_Status = 'Contacted'
GROUP BY TO_CHAR(l.created_date, 'YYYY-MM'), a.contact_person
ORDER BY Month, Contacted_Count ASC;
----------------------------------------------
--Lead Conversion Analysis
SELECT 
    lead_status,
    COUNT(*) AS total_leads,
    SUM(converted_flag) AS converted_leads,
    ROUND(SUM(converted_flag) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM Leads
GROUP BY lead_status
ORDER BY conversion_rate DESC;
-------------------------------------------------
--Total Leads Generated
SELECT COUNT(*) AS Total_Leads FROM Leads;
------------------------------
--Conversion Rate (Leads ? Sales)
SELECT ROUND(SUM(converted_flag)*100.0/COUNT(*),2) AS Conversion_Rate FROM Leads;
---------------------------------------

--------------------Listings---------
--Active Listings by Status and Region
SELECT city, LISTING_STATUS, COUNT(*) FROM Listings GROUP BY city, LISTING_STATUS;
-----------------------------------------------------------
-- Insight ?Average final price by property type?
SELECT property_type, AVG(final_price) AS avg_final_price
FROM Listings
GROUP BY property_type
ORDER BY avg_final_price DESC;
----------------------------------------
--? Insight Number of properties sold per agent? 
SELECT agent_id, COUNT(*) AS sold_count
FROM Listings
WHERE listing_status = 'Sold'
GROUP BY agent_id
ORDER BY sold_count DESC;
------------------------------------
--?Most Compounds/Resorts by Number of Listed Properties?
SELECT compound_resort, COUNT(*) AS listing_count
FROM Listings
GROUP BY compound_resort
ORDER BY listing_count DESC;
-----------------------------------------
--City Performance (Top City)
SELECT 
    l.city AS City_Name,
    COUNT(s.sale_id) AS Total_Sales,
    COUNT(DISTINCT l.listing_id) AS Total_Listings,
    SUM(s.sold_price) AS Total_Revenue,
    ROUND(AVG(s.sold_price), 2) AS Avg_Sold_Price,
    ROUND(AVG(l.days_on_market), 2) AS Avg_Days_On_Market
FROM Listings l
LEFT JOIN Sales s ON l.listing_id = s.listing_id
GROUP BY l.city
ORDER BY Total_Revenue DESC;
----------------------------

-- Insight ?Number of properties by property type?
SELECT property_type, COUNT(*) AS total_listings
FROM Listings
GROUP BY property_type
ORDER BY total_listings DESC;
------------------------------
--? Insight Average price required by property type
SELECT property_type, AVG(asking_price) AS avg_asking_price
FROM Listings
GROUP BY property_type
ORDER BY avg_asking_price DESC;
---------------------------------------------
-- Insight ?Properties that have stayed the longest on the market?
SELECT listing_id, days_on_market
FROM Listings
WHERE days_on_market IS NOT NULL
ORDER BY days_on_market DESC;
----------------------------------------
-- Insight ?The most common type of property in each city?
SELECT city, property_type, COUNT(*) AS count
FROM Listings
GROUP BY city, property_type
ORDER BY city, count DESC;
----------------------------------------
--  #I Insight: Helps identify which property types sell fastest and for how much.
  SELECT 
    property_type,
    AVG(asking_price) AS avg_asking_price,
    AVG(final_price) AS avg_final_price,
    AVG(days_on_market) AS avg_days_on_market
FROM Listings
GROUP BY property_type
ORDER BY avg_final_price DESC;
-----------------------------------------

--------------------------sales----------------
--Average Property Value Sold
SELECT ROUND(AVG(sold_price),2) AS Avg_Property_Value FROM Sales;
-----------------------------------------
--Revenue per Agent
SELECT agent_id, SUM(sold_price) AS Revenue FROM Sales GROUP BY agent_id;
---------------------------------------------------
--Average Sales Cycle Duration
SELECT ROUND(AVG(s.sale_date - l.listing_date),2) AS Avg_Sales_Cycle FROM Sales s JOIN Listings l ON s.listing_id=l.listing_id;
---------------------------------------------
--? Insight Total sales by city?
SELECT l.city, COUNT(*) AS total_sales
FROM Sales s
JOIN Listings l ON s.listing_id = l.listing_id
GROUP BY l.city
ORDER BY total_sales DESC;
------------------------------
--?Agents who have not made any sales?
SELECT a.Agent_ID, a.Contact_Person
FROM Agents a
LEFT JOIN Sales s ON a.Agent_ID = s.Agent_ID
WHERE s.Sale_ID IS NULL;
-----------------------------
--Insight: Geographic Performance by City
SELECT 
    l.city,
    COUNT(s.sale_id) AS total_sales,
    SUM(s.sold_price) AS total_revenue,
    AVG(s.commission_value) AS avg_commission,
    COUNT(DISTINCT l.listing_id) AS total_listings
FROM Sales s
JOIN Listings l ON s.listing_id = l.listing_id
JOIN Agents a ON s.agent_id = a.agent_id
GROUP BY l.city
ORDER BY total_revenue DESC;
-------------------------------------------
-------------Sales and revenue trends over time (monthly or quarterly)

SELECT 
    TO_CHAR(s.sale_date, 'YYYY-MM') AS Month,
    COUNT(s.sale_id) AS Total_Sales,
    SUM(s.sold_price) AS Total_Revenue
FROM Sales s
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY Month;
-------------------------------
--Market Insights & Pricing Distribution  Helps visualize property pricing ranges per city or type.
SELECT 
    l.city,
    l.property_type,
    ROUND(AVG(s.sold_price), 2) AS Avg_Price,
    MIN(s.sold_price) AS Min_Price,
    MAX(s.sold_price) AS Max_Price
FROM Listings l
JOIN Sales s ON l.listing_id = s.listing_id
GROUP BY l.city, l.property_type
ORDER BY Avg_Price DESC;
------------------------
--Best cities by sales
SELECT 
    l.city,
    COUNT(s.sale_id) AS total_sales,
    AVG(s.sold_price) AS avg_sold_price
FROM Listings l
JOIN Sales s ON l.listing_id = s.listing_id
GROUP BY l.city
ORDER BY total_sales DESC;
---------------------------------------------
--Commission vs Speed Correlation
SELECT 
    a.agent_id,
    a.company_name,
    CORR(s.commission_rate, l.days_on_market) AS correlation_commission_speed
FROM Agents a
JOIN Listings l ON a.agent_id = l.agent_id
JOIN Sales s ON l.listing_id = s.listing_id
GROUP BY a.agent_id, a.company_name
ORDER BY correlation_commission_speed ASC;
-------------------------------------------------
--Pareto 80/20 – Property Type Revenue
WITH PropertyRevenue AS (
    SELECT 
        property_type,
        SUM(s.sold_price) AS total_revenue
    FROM Sales s
    JOIN Listings l ON s.listing_id = l.listing_id
    GROUP BY property_type
),
Ranked AS (
    SELECT 
        property_type,
        total_revenue,
        ROUND(100 * SUM(total_revenue) OVER (ORDER BY total_revenue DESC) / SUM(total_revenue) OVER (), 2) AS cumulative_percentage
    FROM PropertyRevenue
)
SELECT 
    property_type,
    total_revenue,
    cumulative_percentage,
    CASE WHEN cumulative_percentage <= 80 THEN 'Top 20% Drivers' ELSE 'Long Tail' END AS category
FROM Ranked;
------------------------------------------------------
----------------------Customers----------
--Insight: Repeat Customers
SELECT 
    c.customer_id,
    c.name,
    COUNT(s.sale_id) AS total_purchases,
    SUM(s.sold_price) AS total_spent,
    AVG(s.sold_price) AS avg_purchase_value,
    Max(s.sale_date) AS sale_date,
    MIN(l.LISTING_date) AS listing_date
FROM Customers c
JOIN Sales s 
    ON c.customer_id = s.customer_id
JOIN Listings l 
    ON s.listing_id = l.listing_id
GROUP BY c.customer_id, c.name
HAVING COUNT(s.sale_id) > 1
ORDER BY total_purchases DESC;
--------------------------------------
-- City × Agent × Loyal Customers Insight
WITH loyal_customers AS (
    SELECT  c.customer_id
    FROM Customers c
    JOIN Sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id
    HAVING COUNT(s.sale_id) > 1
)
SELECT 
    a.city,
    a.agent_id,
    a.COMPANY_NAME AS COMPANY_NAME,
    COUNT(DISTINCT lc.customer_id) AS loyal_customers_count,
    COUNT(s.sale_id) AS total_sales_to_loyals,
    SUM(s.sold_price) AS total_revenue_from_loyals,
    AVG(s.commission_value) AS avg_commission
FROM Sales s
JOIN Agents a ON s.agent_id = a.agent_id
JOIN loyal_customers lc ON s.customer_id = lc.customer_id
GROUP BY a.city, a.agent_id, a.COMPANY_NAME
ORDER BY a.city, total_revenue_from_loyals DESC;
------------------------------------------------------
-- Insight: Top 5 Loyal Customers ()
SELECT *
FROM (
    SELECT 
        c.customer_id,
        c.name,
        COUNT(s.sale_id) AS total_purchases,
        SUM(s.sold_price) AS total_spent,
        AVG(s.sold_price) AS avg_purchase_value,
        MAX(s.sale_date) AS last_purchase,
        MIN(l.listing_date) AS first_listing_date
    FROM Customers c
    JOIN Sales s 
        ON c.customer_id = s.customer_id
    JOIN Listings l 
        ON s.listing_id = l.listing_id
    GROUP BY c.customer_id, c.name
    HAVING COUNT(s.sale_id) > 1
    ORDER BY total_purchases DESC, total_spent DESC
)
WHERE ROWNUM <= 5;
---------------------------------------------

--Average Waiting Time
SELECT 
    c.customer_id,
    c.name,
    ROUND(AVG(s.sale_date - l.listing_date), 2) AS avg_days_to_purchase
FROM Customers c
JOIN Sales s ON c.customer_id = s.customer_id
JOIN LISTINGS l ON s.listing_id = l.listing_id
GROUP BY c.customer_id, c.name
ORDER BY avg_days_to_purchase;
----------------------------------------------
---------------------------Reviews--------------------------
--Review Sentiment Analysis
SELECT 
    COMPOUND_RESORT,
    AVG(Rating_mock) AS avg_rating,
    SUM(CASE WHEN Sentiment='Positive' THEN 1 ELSE 0 END) AS positive_reviews,
    SUM(CASE WHEN Sentiment='Negative' THEN 1 ELSE 0 END) AS negative_reviews,
    SUM(CASE WHEN Sentiment='Neutral' THEN 1 ELSE 0 END) AS neutral_reviews,
COUNT(*) AS total_reviews
FROM Reviews
GROUP BY COMPOUND_RESORT
ORDER BY avg_rating DESC;


--------------------------------------
--Analytical Sql Part
------------------------
--1. Ranking campaigns according to engagement rate within each company
SELECT
    campaign_id,
    Company_name,
    Engagement_Score,
    RANK() OVER (PARTITION BY Company_name ORDER BY Engagement_Score DESC) AS Rank_Within_Company
FROM marketing_campaign;
------------------------------------------------------------------------------------------
--2. Calculate the moving average of the reaction rate for each month
SELECT
    Month_Of_Year,
    Engagement_Score,
    AVG(Engagement_Score) OVER (
        PARTITION BY Month_Of_Year 
        ORDER BY campaign_id 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS Moving_Avg_Score
FROM marketing_campaign;
------------------------------------------------------------------------------------------
--3. Identify the highest campaign for each campaign type using ROW_NUMBER
SELECT *
FROM (
    SELECT 
        campaign_id,
        Campaign_Type,
        Engagement_Score,
        ROW_NUMBER() OVER (PARTITION BY Campaign_Type ORDER BY Engagement_Score DESC) AS rn
    FROM marketing_campaign
) ranked
WHERE rn = 1;
------------------------------------------------------------------------------------------
--4. Compare the cost of each campaign to the average cost of the same campaign type.
SELECT
    campaign_id,
    Campaign_Type,
    Cost,
    AVG(Cost) OVER (PARTITION BY Campaign_Type) AS Avg_Cost_By_Type,
    Cost - AVG(Cost) OVER (PARTITION BY Campaign_Type) AS Cost_Difference
FROM marketing_campaign;
------------------------------------------------------------------------------------------
--5. Use LAG to compare engagement rate with previous campaigns within the same company
SELECT
    campaign_id,
    Company_name,
    Engagement_Score,
    LAG(Engagement_Score) OVER (PARTITION BY Company_name ORDER BY campaign_id) AS Prev_Engagement_Score,
    Engagement_Score - LAG(Engagement_Score) OVER (PARTITION BY Company_name ORDER BY campaign_id) AS Engagement_Change
FROM marketing_campaign;
------------------------------------------------------------------------------------------
--6. Use LEAD to compare engagement rates with the next campaign within the same campaign type.
SELECT
    campaign_id,
    Campaign_Type,
    Engagement_Score,
    LEAD(Engagement_Score) OVER (PARTITION BY Campaign_Type ORDER BY campaign_id) AS Next_Engagement_Score,
    LEAD(Engagement_Score) OVER (PARTITION BY Campaign_Type ORDER BY campaign_id) - Engagement_Score AS Engagement_Change_Next
FROM marketing_campaign;
------------------------------------------------------------------------------------------
--7. Cost change analysis using LAG by month
SELECT
    campaign_id,
    Month_Of_Year,
    Cost,
    LAG(Cost) OVER (PARTITION BY Month_Of_Year ORDER BY campaign_id) AS Prev_Cost,
    Cost - LAG(Cost) OVER (PARTITION BY Month_Of_Year ORDER BY campaign_id) AS Cost_Change
FROM marketing_campaign;
------------------------------------------------------------------------------------------

