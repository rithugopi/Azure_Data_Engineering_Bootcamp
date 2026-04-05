CREATE SCHEMA dbo

CREATE TABLE dbo.fact_transaction
(
    TransactionID INT NOT NULL,
    AccountID INT NOT NULL,
    Amount DECIMAL(18,2),
    TransactionType VARCHAR(50),
    ModifiedDate DATETIME2,

    CONSTRAINT PK_fact_transaction
    PRIMARY KEY NONCLUSTERED (TransactionID) NOT ENFORCED
)
WITH
(
    DISTRIBUTION = HASH(AccountID),
    CLUSTERED COLUMNSTORE INDEX
);
GO


CREATE TABLE dbo.Loan
(
    LoanID INT,
    CustomerID INT,
    BranchID INT,
    LoanAmount DECIMAL(18,2),
    LoanType VARCHAR(50),
    ModifiedDate DATETIME2

    CONSTRAINT PK_dim_loan
        PRIMARY KEY NONCLUSTERED (LoanID) NOT ENFORCED
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);

--drop table dbo.Loan

CREATE TABLE dbo.Account
(
    AccountID INT,
    CustomerID VARCHAR(50),
    BranchID VARCHAR(50),
    AccountType VARCHAR(50),
    Balance VARCHAR(50),
    ModifiedDate DATETIME2

    CONSTRAINT PK_dim_account 
        PRIMARY KEY NONCLUSTERED (AccountID) NOT ENFORCED
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
drop table dbo.Account

----------------------------------------------------------------------------------------------------------------------


-- MASTER KEY (run only once per database)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Encyclopedia@123';
GO

-- DATABASE SCOPED CREDENTIAL
CREATE DATABASE SCOPED CREDENTIAL bushracred
WITH
IDENTITY = 'Managed Identity';
GO

CREATE EXTERNAL DATA SOURCE data_source_silver
WITH (
    LOCATION = 'https://bootcampadlsg2.blob.core.windows.net/container1/Project3/Silver',
    CREDENTIAL = bushracred
);
GO

COPY INTO dbo.Loan
(
    LoanID        1,
    CustomerID    2,
    BranchID      3,
    LoanAmount    4,
    LoanType      5,
    ModifiedDate  6
)
FROM 'https://bootcampadlsg2.blob.core.windows.net/container1/Project3/Silver/Loan/'
WITH
(
    CREDENTIAL = (IDENTITY = 'Managed Identity'),
    FILE_TYPE = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIRSTROW = 2
);
GO

SELECT * FROM dbo.loan;

-----------------------------------------------------------------

COPY INTO dbo.Account
(
    AccountID     1,
    CustomerID    2,
    BranchID      3,
    AccountType   4,
    Balance       5,
    ModifiedDate  6
)
FROM 'https://bootcampadlsg2.blob.core.windows.net/container1/Project3/Silver/Account/'
WITH
(
    CREDENTIAL = (IDENTITY = 'Managed Identity'),
    FILE_TYPE = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIRSTROW = 2
);
GO

SELECT * FROM dbo.Account

-----------------------------------------


COPY INTO dbo.fact_transaction
(
    TransactionID   1,
    AccountID       2,
    Amount          3,
    TransactionType 4,
    ModifiedDate    5
)
FROM 'https://bootcampadlsg2.blob.core.windows.net/container1/Project3/Silver/Transaction/'
WITH
(
    CREDENTIAL = (IDENTITY = 'Managed Identity'),
    FILE_TYPE = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIRSTROW = 2
);
GO

SELECT * FROM dbo.fact_transaction;

