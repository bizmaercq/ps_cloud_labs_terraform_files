--run in master
CREATE LOGIN [OpsMgr] WITH PASSWORD = 'Bh7pRbVp#q6fXV#'
GO
CREATE LOGIN [EngMgr] WITH PASSWORD = 'z326b#jT#2RM#zG#'
GO
CREATE LOGIN [HrMgr] WITH PASSWORD = 'wb#rR1Aks4ZGv2S#'
GO

CREATE USER [OpsMgr] FOR LOGIN [OpsMgr];
CREATE USER [EngMgr]  FOR LOGIN [EngMgr];
CREATE USER [HrMgr]  FOR LOGIN [HrMgr];


-- run at user database level
CREATE USER [OpsMgr] FOR LOGIN [OpsMgr] WITH DEFAULT_SCHEMA=[StaffAnalyticsDW];
CREATE USER [EngMgr] FOR LOGIN [EngMgr] WITH DEFAULT_SCHEMA=[StaffAnalyticsDW];
CREATE USER [HrMgr] FOR LOGIN [HrMgr] WITH DEFAULT_SCHEMA=[StaffAnalyticsDW];

-- create table 
CREATE TABLE [dbo].[DimStaffDetails]
(
	[staffID] [int] IDENTITY(1,1) NOT NULL,
	[firstName] [varchar](100) NOT NULL,
	[lastName] [varchar](100) NOT NULL,
	[phone] [varchar](16) NULL,
	[email] [varchar](100) NULL,
	[TIN] [varchar](10) NOT NULL,
	[role] [varchar](100) NULL,
	[salary] [int] NULL,
	[reportsTo] [sysname] NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO


INSERT INTO [dbo].[DimStaffDetails] VALUES ('Kofi', 'Baboni', '0201234567', 'k.baboni@globomantics.com', 'AX123A', 'Software Engineer', 15533, 'EngMgr');
INSERT INTO [dbo].[DimStaffDetails] VALUES ('Ama', 'Opuni', '0241244569', 'a.opuni@globomantics.com', 'AX193C', 'Data Engineer', 23452, 'EngMgr');
INSERT INTO [dbo].[DimStaffDetails] VALUES ('Yaw', 'Marfo', '0641244533', 'y.marfo@globomantics.com', 'AX993X', 'Data Scientist', 12123, 'EngMgr');
INSERT INTO [dbo].[DimStaffDetails] VALUES ('Akosua', 'Nanni', '0943344503', 'a.nanni@globomantics.com', 'AX193C', 'Data Analyst', 100, 'EngMgr');
INSERT INTO [dbo].[DimStaffDetails] VALUES ('Kwaku', 'Asante', '0115641563', 'k.asante@globomantics.com', 'AX113Z', 'Sales Agent', 1322, 'OpsMgr');
INSERT INTO [dbo].[DimStaffDetails] VALUES ('Kwame', 'Nti', '1234567890', 'k.nti@globomantics.com', 'AX002F', 'Sales Analyst', 112329, 'OpsMgr');
INSERT INTO [dbo].[DimStaffDetails] VALUES ('Kwasi', 'Fosu', '0987654321', 'k.fosu@globomantics.com', 'AX222H', 'Sales Agent', 123, 'OpsMgr');

-- view data in table
SELECT * FROM [dbo].[DimStaffDetails]


SELECT * 
INTO [dbo].[DimStaffDetailsSecured]
FROM [dbo].[DimStaffDetails]


-- Column level security
--Grant SELECT for the three users on the DimStaffDetailsSecured table that you created.
GRANT SELECT ON DimStaffDetailsSecured(staffID, firstName, lastName, phone, email, salary, role, reportsTo) TO HrMgr;
GRANT SELECT ON DimStaffDetailsSecured(firstName, lastName, phone, email, role, reportsTo) TO OpsMgr;
GRANT SELECT ON DimStaffDetailsSecured(firstName, lastName, phone, email, role, reportsTo) TO EngMgr;

-- excute query as HrMgr

execute as user = 'HrMgr'
SELECT * FROM [dbo].[DimStaffDetailsSecured]

--Failed to execute query. Error: 
--The SELECT permission was denied on the column 'TIN' of the object 'DimStaffDetailsSecured', database 'StaffAnalyticsDW', schema 'dbo'.
--The SELECT permission was denied on the column 'salary' of the object 'DimStaffDetailsSecured', database 'StaffAnalyticsDW', schema 'dbo'.

execute as user = 'HrMgr'
SELECT staffID, firstName, lastName, phone, email, role, salary, reportsTo FROM [dbo].[DimStaffDetailsSecured]
-- this will return records





--Create a new schema, and an inline table-valued function. 
--The function returns 1 when a row in the reportsTo column is the same as the user executing the query (@reportsTo = USER_NAME()) 
--or if the user executing the query is the HrMgr user (USER_NAME() = 'HrMgr').

CREATE SCHEMA Security;  
GO  
  
CREATE FUNCTION Security.fn_securitypredicate(@reportsTo AS sysname)  
    RETURNS TABLE  
WITH SCHEMABINDING  
AS  
    RETURN SELECT 1 AS fn_securitypredicate_result
WHERE @reportsTo = USER_NAME() OR USER_NAME() = 'HrMgr';


--Create a security policy on the DimStaffDetailsSecured table using the inline table-valued function above as a filter predicate. 
--The state must be set to ON to enable the policy.

CREATE SECURITY POLICY DimStaffDetailsFilter
ADD FILTER PREDICATE Security.fn_securitypredicate(reportsTo)
ON dbo.DimStaffDetailsSecured  
WITH (STATE = ON);




--Now test the filtering predicate, by selecting from the DimStaffDetailsSecured table. 
--Sign in as each user, HrMgr, EngMgr, and OpsMgr. Run the following command as each user.
SELECT staffID, firstName, lastName, phone, email, role, reportsTo FROM [dbo].[DimStaffDetailsSecured]

--Or run the below commands to switch user from your current login (globomantics_admin)
execute as user = 'HrMgr'
SELECT staffID, firstName, lastName, phone, email, role, reportsTo FROM [dbo].[DimStaffDetailsSecured]

execute as user = 'EngMgr'
SELECT firstName, lastName, phone, email, role, reportsTo FROM [dbo].[DimStaffDetailsSecured]

execute as user = 'OpsMgr'
SELECT firstName, lastName, phone, email, role, reportsTo FROM [dbo].[DimStaffDetailsSecured]

--The HrMgr should see all rows. The EngMgr and OpsMgr users should only see their team members.


--Alter the security policy to disable the policy.
ALTER SECURITY POLICY DimStaffDetailsFilter  
WITH (STATE = OFF);