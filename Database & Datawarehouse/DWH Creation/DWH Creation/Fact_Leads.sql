-- Lead Fact Table
-- Step 1: Select the desired columns
use Real_Estate_DB;

SELECT 
    L.lead_id,
    L.agent_id,
    L.campaign_id,
    LS.listing_id,
    R.Reviw_ID,
    L.converted_flag,
    LS.listing_converted_flag,
    R.Rating_mock,
	L.created_date
FROM Leads L
LEFT JOIN Customers C 
    ON L.lead_id = C.lead_id
LEFT JOIN Listings LS
    ON C.customer_id = LS.customer_id
LEFT JOIN Reviews R
    ON C.customer_id = R.cust_id;

-- Step 2: Creating the dimension
use Real_Estate_DWH;

create table fact_leads
(
	lead_sk int primary key identity(1,1),  --surrogate key
	lead_id_bk nvarchar(50) not null, -- buisness key,
    agent_id_bk nvarchar(50) not null, -- buisness key,
    campaign_id_bk nvarchar(50) not null, -- buisness key,
    listing_id_bk nvarchar(50), -- buisness key,
    review_id_bk nvarchar(50), -- buisness key,
	lead_key int,
	agent_key int,
	campaign_key int,
	listing_key int,
	review_key int,
	date_key int,
    lead_converted_flag bit not null,
    listing_converted_flag bit,
    count_lst_per_lead INT,
    rating_mock float
);

---*******************************
UPDATE f
SET count_lst_per_lead = x.cnt
FROM fact_leads f
JOIN (
  SELECT lead_id_bk,
         COUNT(*) AS cnt
  FROM fact_leads
  WHERE listing_converted_flag = 1
  GROUP BY lead_id_bk
) x ON x.lead_id_bk = f.lead_id_bk;
---*******************************

--Step 3: select the dimension after the assignment
select * from fact_leads;
select * from fact_leads where lead_id_bk = 'L00001';





