-- Step 1: Select the desired columns
use Real_Estate_DB;

select agents.agent_id, 
	agents.contact_person,
	agents.email,
	agents.area,
	agents.experience_years,
	agents.city

from agents;

-- Step 2: Creating the dimension
use Real_Estate_DWH;

create table dim_agents
(
	agent_key int primary key identity(1,1),  --surrogate key
	agent_id_bk nvarchar(50) not null, -- buisness key
	contact_person nvarchar(50),
	email nvarchar(100),
	area nvarchar(50),
	city nvarchar(50),
	experience_years tinyint,

	--Metadata
	source_system_code tinyint not null,
	-- SCD
	start_date datetime,
	end_date datetime,
	is_current tinyint not null,
);

--Step 3: select the dimension after the assignment
select * from dim_agents;
select * from dim_agents where agent_id_bk = 1;