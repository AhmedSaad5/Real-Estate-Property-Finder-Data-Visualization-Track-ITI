-- Sales Fact Table
-- Step 1: Select the desired columns
use Real_Estate_DB;

select sales.sale_id, 
	sales.listing_id,
	customers.lead_id,
	sales.agent_id,
	listings.base_price,
	listings.asking_price,
	listings.final_price,
	sales.commission_rate,
	sales.commission_value,
	sales.sale_date

from sales
left join listings
on sales.listing_id = listings.listing_id
left join customers
on sales.customer_id = customers.customer_id;

-- Step 2: Creating the dimension
use Real_Estate_DWH;

create table fact_sales
(
	sales_sk int primary key identity(1,1),  --surrogate key
	sales_id_bk nvarchar(50) not null, -- buisness key
	lead_id_bk nvarchar(50) not null, -- buisness key
	listing_id_bk nvarchar(50) not null, -- buisness key
	agent_id_bk nvarchar(50) not null, -- buisness key
	listing_key int, 
	lead_key int,
	agent_key int,
	date_key int,
	base_price int,
	asking_price int,
	final_price int,
	commission_rate decimal(2,2),
	commission_value int
);


--Step 3: select the dimension after the assignment
select * from fact_sales;
select * from fact_sales where sales_id_bk = 'S000001';







