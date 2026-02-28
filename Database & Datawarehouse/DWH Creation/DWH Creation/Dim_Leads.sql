-- Step 1: Select the desired columns
use Real_Estate_DB;

select leads.lead_id,
	customers.customer_id,
	leads.name,
	leads.contact_phone,
	leads.budget_min,
	leads.budget_max,
	leads.preferred_city,
	leads.interest,
	leads.lead_status,
	leads.created_date,
	customers.purchase_details,
	customers.contract_date,
	customers.payment_plan,
	customers.customer_type,
	customers.support_status

from leads 
left outer join customers 
on leads.lead_id = customers.lead_id;

-- Step 2: Creating the dimension
use Real_Estate_DWH;

create table dim_leads
(
	lead_key int primary key identity(1,1),  --surrogate key
	lead_id_bk nvarchar(50) not null, -- buisness key
	customer_id_bk nvarchar(50), -- buisness key
	lead_name nvarchar(50),
	lead_phone nvarchar(50),
	budget_min int,
	budget_max int,
	preferred_city nvarchar(50),
	interest nvarchar(50),
	lead_status nvarchar(50),
	created_date date,
	purchase_details nvarchar(50),
	contract_date date,
	payment_plan nvarchar(50),
	customer_type nvarchar(50),
	support_status nvarchar(50),

	--Metadata
	source_system_code tinyint not null,
	-- SCD
	start_date datetime,
	end_date datetime,
	is_current tinyint not null,
);

--Step 3: select the dimension after the assignment
select * from dim_leads;
select * from dim_leads where lead_id_bk = 'L00001';

select * from dim_agents;