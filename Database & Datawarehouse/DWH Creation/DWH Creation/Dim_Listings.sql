-- Step 1: Select the desired columns
use Real_Estate_DB;

select listings.listing_id, 
	customers.lead_id,
	listings.customer_id,
	listings.agent_id,
	listings.city,
	listings.compound_resort,
	listings.property_type,
	listings.bedrooms,
	listings.bathrooms,
	listings.area,
	listings.latitude,
	listings.longitude,
	listings.listing_date,
	listings.listing_status,
	listings.listing_type,
	listings.days_on_market

from customers right outer join listings
on listings.customer_id = customers.customer_id;

-- Step 2: Creating the dimension
use Real_Estate_DWH;

create table dim_listings
(
	listing_key int primary key identity(1,1),  --surrogate key
	listing_id_bk nvarchar(50) not null, -- buisness key
	customer_id_bk nvarchar(50), -- buisness key
	lead_id_bk nvarchar(50),
	agent_id_bk nvarchar(50),
	city nvarchar(50),
	compound_resort nvarchar(100),
	property_type nvarchar(50),
	bedrooms tinyint,
	bathrooms tinyint,
	area nvarchar(50),
	latitude decimal(18,10),
	longitude decimal(18,10),
	listing_date date,
	listing_status nvarchar(50),
	listing_type nvarchar(50),
	days_on_market smallint,


	--Metadata
	source_system_code tinyint not null,
	-- SCD
	start_date datetime,
	end_date datetime,
	is_current tinyint not null,
);

--Step 3: select the dimension after the assignment
select * from dim_listings;
select * from dim_listings where listing_id_bk = 1;