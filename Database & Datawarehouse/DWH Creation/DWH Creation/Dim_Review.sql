-- Step 1: Select the desired columns
use Real_Estate_DB;

select reviews.Reviw_ID, 
	customers.lead_id,
	reviews.[Compound_Resort],
	reviews.Review_Date,
	reviews.Sentiment

from customers
left join reviews
on customers.customer_id = reviews.cust_id;

-- Step 2: Creating the dimension
use Real_Estate_DWH;

create table dim_reviews
(
	review_key int primary key identity(1,1),  --surrogate key
	review_id_bk nvarchar(50) not null, -- buisness key
	lead_id_bk nvarchar(50) not null, -- buisness key
	compound_resort nvarchar(100),
	review_date date,
	sentiment nvarchar(50),

	--Metadata
	source_system_code tinyint not null,
	-- SCD
	start_date datetime,
	end_date datetime,
	is_current tinyint not null,
);

-- Step 3: select the dimension after the assignment
select * from dim_reviews;
select * from dim_reviews where review_id_bk = 1;