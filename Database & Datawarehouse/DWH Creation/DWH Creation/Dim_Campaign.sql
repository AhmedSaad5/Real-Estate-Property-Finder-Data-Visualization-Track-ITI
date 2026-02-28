-- Step 1: Select the desired columns
use Real_Estate_DB;

select campaigns.campaign_id, 
	campaigns.Company,
	campaigns.Objective,
	campaigns.Campaign_Type,
	campaigns.Target_Audience,
	campaigns.Campaign_Source,
	campaigns.Location,
	campaigns.start_date,
	campaigns.End_Date,
	campaigns.Cost,
	campaigns.Clicks,
	campaigns.Impressions,
	campaigns.Engagement_Score

from campaigns;

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT campaign_id) AS distinct_campaigns
FROM Campaigns;



-- Step 2: Creating the dimension
use Real_Estate_DWH;

create table dim_campaigns
(
	campaign_key int primary key identity(1,1),  --surrogate key
	campaign_id_bk nvarchar(50) not null, -- buisness key
	company nvarchar(100),
	objective nvarchar(100),
	campaign_type nvarchar(50),
	target_audience nvarchar(50),
	campaign_Source nvarchar(50),
	location nvarchar(50),
	campaign_start_date date,
	campaign_end_Date date,
	Cost int,
	Clicks smallint,
	Impressions smallint,
	Engagement_Score tinyint,

	--Metadata
	source_system_code tinyint not null,
	-- SCD
	start_date datetime,
	end_date datetime,
	is_current tinyint not null,
);

--Step 3: select the dimension after the assignment
select * from dim_campaigns;
select * from dim_campaigns where campaign_id_bk = 1;