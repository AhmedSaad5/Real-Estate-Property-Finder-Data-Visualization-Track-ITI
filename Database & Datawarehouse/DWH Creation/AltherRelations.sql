
Create database Real_Estate_DB;

/* LEADS */
ALTER TABLE Leads
ADD CONSTRAINT FK_Leads_Agents
FOREIGN KEY (agent_id) REFERENCES Agents(agent_id);

ALTER TABLE Leads
ADD CONSTRAINT FK_Leads_Campaigns
FOREIGN KEY (campaign_id) REFERENCES Campaigns(Campaign_ID);

/* CUSTOMERS */
ALTER TABLE Customers
ADD CONSTRAINT FK_Customers_Leads
FOREIGN KEY (lead_id) REFERENCES Leads(lead_id);

/* LISTINGS */
ALTER TABLE Listings
ADD CONSTRAINT FK_Listings_Customers
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id);

ALTER TABLE Listings
ADD CONSTRAINT FK_Listings_Agents
FOREIGN KEY (agent_id) REFERENCES Agents(agent_id);

/* CAMPAIGNS → AGENTS (M:M handled earlier by Leads table mapping) */

/* SALES */
ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Listings
FOREIGN KEY (listing_id) REFERENCES Listings(listing_id);

ALTER TABLE Sales /*############*/
ADD CONSTRAINT FK_Sales_Customers
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id);

ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Agents
FOREIGN KEY (agent_id) REFERENCES Agents(agent_id);

/* REVIEWS */
ALTER TABLE Reviews /*############*/
ADD CONSTRAINT FK_Reviews_Customers
FOREIGN KEY (Cust_ID) REFERENCES Customers(customer_id);

--**********************************************************
/* LEADS */
ALTER TABLE Leads    DROP CONSTRAINT FK_Leads_Agents;
ALTER TABLE Leads    DROP CONSTRAINT FK_Leads_Campaigns;

/* CUSTOMERS */
ALTER TABLE Customers DROP CONSTRAINT FK_Customers_Leads;

/* LISTINGS */
ALTER TABLE Listings DROP CONSTRAINT FK_Listings_Customers;
ALTER TABLE Listings DROP CONSTRAINT FK_Listings_Agents;

/* SALES */
ALTER TABLE Sales     DROP CONSTRAINT FK_Sales_Listings;
ALTER TABLE Sales     DROP CONSTRAINT FK_Sales_Customers;
ALTER TABLE Sales     DROP CONSTRAINT FK_Sales_Agents;

/* REVIEWS */
ALTER TABLE Reviews   DROP CONSTRAINT FK_Reviews_Customers;
--**********************************************************




/* OTHERS */
SELECT COUNT(*)
FROM Sales s
LEFT JOIN Customers c ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

DELETE s
FROM Sales s
LEFT JOIN Customers c ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- ****************************

use real_estate_db;
ALTER TABLE listings
ADD listing_converted_flag INT;

UPDATE listings
SET listing_converted_flag = CASE 
    WHEN customer_id IS NOT NULL THEN 1
    ELSE 0
END;

ALTER TABLE leads
ADD converted_flag INT;

UPDATE L
SET L.converted_flag =
    CASE 
        WHEN C.lead_id IS NOT NULL THEN 1
        ELSE 0
    END
FROM leads L
LEFT JOIN customers C
    ON L.lead_id = C.lead_id;

ALTER TABLE reviews
ALTER COLUMN Cust_ID NVARCHAR(50);



