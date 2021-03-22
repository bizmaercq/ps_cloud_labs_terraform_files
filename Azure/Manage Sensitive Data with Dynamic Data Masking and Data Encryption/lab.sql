--run in master
CREATE LOGIN [data_analyst] WITH PASSWORD = 'wb#rR1Aks4ZGv2S#'
GO
CREATE USER [data_analyst] FOR LOGIN [data_analyst];

-- run at user database level
CREATE USER [data_analyst] FOR LOGIN [data_analyst] WITH DEFAULT_SCHEMA=[globomanticsDB];
ALTER ROLE db_datareader ADD MEMBER [data_analyst]; 


select top 5 CustomerID,EmailAddress,CompanyName, Phone, PasswordHash, PasswordSalt from SalesLT.Customer