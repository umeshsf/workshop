use role cortex_role;

create database workshop_db;

create schema workshop_db.sales;
create schema workshop_db.finance;
create schema workshop_db.marketing;
create schema workshop_db.hr;
create schema workshop_db.common;

use workshop_db.common;
CREATE OR REPLACE GIT REPOSITORY workshop_repo
        API_INTEGRATION = git_api_integration
        ORIGIN = 'https://github.com/umeshsf/workshop.git';

show git repositories in account;        

ALTER GIT REPOSITORY workshop_repo FETCH;  

CREATE OR REPLACE FILE FORMAT CSV_FORMAT
        TYPE = 'CSV'
        FIELD_DELIMITER = ','
        RECORD_DELIMITER = '\n'
        SKIP_HEADER = 1
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        TRIM_SPACE = TRUE
        ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
        ESCAPE = 'NONE'
        ESCAPE_UNENCLOSED_FIELD = '\134'
        DATE_FORMAT = 'YYYY-MM-DD'
        TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS'
        NULL_IF = ('NULL', 'null', '', 'N/A', 'n/a');



CREATE OR REPLACE STAGE internal_data_stage
        FILE_FORMAT = CSV_FORMAT
        COMMENT = 'Internal stage for copied demo data files'
        DIRECTORY = ( ENABLE = TRUE)
        ENCRYPTION = (   TYPE = 'SNOWFLAKE_SSE');

-- copy data file from git repo
COPY FILES
    INTO @internal_data_stage/demo_data/
    FROM @workshop_repo/branches/main/cortex2/data/;

-- copy unstructred data files from git repo

COPY FILES
    INTO @internal_data_stage/unstructured_docs/
    FROM @workshop_repo/branches/main/cortex2/docs/;


ALTER STAGE internal_data_stage refresh;
-- Verify files were copied
LS @internal_data_stage;




-- ========================================================================
-- DIMENSION TABLES
-- ========================================================================

-- Product Category Dimension
CREATE OR REPLACE TABLE common.product_category_dim (
    category_key INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    vertical VARCHAR(50) NOT NULL
);

COPY INTO common.product_category_dim
FROM @INTERNAL_DATA_STAGE/demo_data/product_category_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Product Dimension
CREATE OR REPLACE TABLE common.product_dim (
    product_key INT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category_key INT NOT NULL,
    category_name VARCHAR(100),
    vertical VARCHAR(50)
);

COPY INTO common.product_dim
FROM @INTERNAL_DATA_STAGE/demo_data/product_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Vendor Dimension
CREATE OR REPLACE TABLE common.vendor_dim (
    vendor_key INT PRIMARY KEY,
    vendor_name VARCHAR(200) NOT NULL,
    vertical VARCHAR(50) NOT NULL,
    address VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(10),
    zip VARCHAR(20)
);

COPY INTO common.vendor_dim
FROM @INTERNAL_DATA_STAGE/demo_data/vendor_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Customer Dimension
CREATE OR REPLACE TABLE common.customer_dim (
    customer_key INT PRIMARY KEY,
    customer_name VARCHAR(200) NOT NULL,
    industry VARCHAR(100),
    vertical VARCHAR(50),
    address VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(10),
    zip VARCHAR(20)
);

COPY INTO common.customer_dim
FROM @INTERNAL_DATA_STAGE/demo_data/customer_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Account Dimension (Finance)
CREATE OR REPLACE TABLE common.account_dim (
    account_key INT PRIMARY KEY,
    account_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(50)
);

COPY INTO common.account_dim
FROM @INTERNAL_DATA_STAGE/demo_data/account_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Department Dimension
CREATE OR REPLACE TABLE common.department_dim (
    department_key INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);


COPY INTO common.department_dim
FROM @INTERNAL_DATA_STAGE/demo_data/department_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';


-- Region Dimension
CREATE OR REPLACE TABLE common.region_dim (
    region_key INT PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL
);


COPY INTO common.region_dim
FROM @INTERNAL_DATA_STAGE/demo_data/region_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';
    
-- Sales Rep Dimension
CREATE OR REPLACE TABLE sales.sales_rep_dim (
    sales_rep_key INT PRIMARY KEY,
    rep_name VARCHAR(200) NOT NULL,
    hire_date DATE
);

COPY INTO sales.sales_rep_dim
FROM @INTERNAL_DATA_STAGE/demo_data/sales_rep_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Campaign Dimension (Marketing)
CREATE OR REPLACE TABLE marketing.campaign_dim (
    campaign_key INT PRIMARY KEY,
    campaign_name VARCHAR(300) NOT NULL,
    objective VARCHAR(100)
);

COPY INTO marketing.campaign_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/campaign_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';


-- Channel Dimension (Marketing)
CREATE OR REPLACE TABLE marketing.channel_dim (
    channel_key INT PRIMARY KEY,
    channel_name VARCHAR(100) NOT NULL
);


COPY INTO marketing.channel_dim
FROM @INTERNAL_DATA_STAGE/demo_data/channel_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';
-- Employee Dimension (HR)
CREATE OR REPLACE TABLE hr.employee_dim (
    employee_key INT PRIMARY KEY,
    employee_name VARCHAR(200) NOT NULL,
    gender VARCHAR(1),
    hire_date DATE
);

COPY INTO hr.employee_dim
FROM @INTERNAL_DATA_STAGE/demo_data/employee_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Job Dimension (HR)
CREATE OR REPLACE TABLE hr.job_dim (
    job_key INT PRIMARY KEY,
    job_title VARCHAR(100) NOT NULL,
    job_level INT
);

COPY INTO hr.job_dim
FROM @INTERNAL_DATA_STAGE/demo_data/job_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Location Dimension (HR)
CREATE OR REPLACE TABLE hr.location_dim (
    location_key INT PRIMARY KEY,
    location_name VARCHAR(200) NOT NULL
);


COPY INTO hr.location_dim
FROM @INTERNAL_DATA_STAGE/demo_data/location_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';
-- ========================================================================
-- FACT TABLES
-- ========================================================================

-- Sales Fact Table
CREATE OR REPLACE TABLE sales.sales_fact (
    sale_id INT PRIMARY KEY,
    date DATE NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    sales_rep_key INT NOT NULL,
    region_key INT NOT NULL,
    vendor_key INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    units INT NOT NULL
);


COPY INTO sales.sales_fact
FROM @INTERNAL_DATA_STAGE/demo_data/sales_fact.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';
    
-- Finance Transactions Fact Table
CREATE OR REPLACE TABLE finance.finance_transactions (
    transaction_id INT PRIMARY KEY,
    date DATE NOT NULL,
    account_key INT NOT NULL,
    department_key INT NOT NULL,
    vendor_key INT NOT NULL,
    product_key INT NOT NULL,
    customer_key INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    approval_status VARCHAR(20) DEFAULT 'Pending',
    procurement_method VARCHAR(50),
    approver_id INT,
    approval_date DATE,
    purchase_order_number VARCHAR(50),
    contract_reference VARCHAR(100),
    CONSTRAINT fk_approver FOREIGN KEY (approver_id) REFERENCES hr.employee_dim(employee_key)
) COMMENT = 'Financial transactions with compliance tracking. approval_status should be Approved/Pending/Rejected. procurement_method should be RFP/Quotes/Emergency/Contract';

COPY INTO finance.finance_transactions
FROM @INTERNAL_DATA_STAGE/demo_data/finance_transactions.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Marketing Campaign Fact Table
CREATE OR REPLACE TABLE marketing.marketing_campaign_fact (
    campaign_fact_id INT PRIMARY KEY,
    date DATE NOT NULL,
    campaign_key INT NOT NULL,
    product_key INT NOT NULL,
    channel_key INT NOT NULL,
    region_key INT NOT NULL,
    spend DECIMAL(10,2) NOT NULL,
    leads_generated INT NOT NULL,
    impressions INT NOT NULL
);

COPY INTO marketing.marketing_campaign_fact
FROM @INTERNAL_DATA_STAGE/demo_data/marketing_campaign_fact.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- HR Employee Fact Table
CREATE OR REPLACE TABLE hr.hr_employee_fact (
    hr_fact_id INT PRIMARY KEY,
    date DATE NOT NULL,
    employee_key INT NOT NULL,
    department_key INT NOT NULL,
    job_key INT NOT NULL,
    location_key INT NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    attrition_flag INT NOT NULL
);

COPY INTO hr.hr_employee_fact
FROM @INTERNAL_DATA_STAGE/demo_data/hr_employee_fact.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';


-- ========================================================================
-- SALESFORCE CRM TABLES
-- ========================================================================

-- Salesforce Accounts Table
CREATE OR REPLACE TABLE common.sf_accounts (
    account_id VARCHAR(20) PRIMARY KEY,
    account_name VARCHAR(200) NOT NULL,
    customer_key INT NOT NULL,
    industry VARCHAR(100),
    vertical VARCHAR(50),
    billing_street VARCHAR(200),
    billing_city VARCHAR(100),
    billing_state VARCHAR(10),
    billing_postal_code VARCHAR(20),
    account_type VARCHAR(50),
    annual_revenue DECIMAL(15,2),
    employees INT,
    created_date DATE
);

   COPY INTO common.sf_accounts
    FROM @INTERNAL_DATA_STAGE/demo_data/sf_accounts.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';


-- Salesforce Opportunities Table
CREATE OR REPLACE TABLE sales.sf_opportunities (
    opportunity_id VARCHAR(20) PRIMARY KEY,
    sale_id INT,
    account_id VARCHAR(20) NOT NULL,
    opportunity_name VARCHAR(200) NOT NULL,
    stage_name VARCHAR(100) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    probability DECIMAL(5,2),
    close_date DATE,
    created_date DATE,
    lead_source VARCHAR(100),
    type VARCHAR(100),
    campaign_id INT
);

COPY INTO sales.sf_opportunities
FROM @INTERNAL_DATA_STAGE/demo_data/sf_opportunities.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Salesforce Contacts Table
CREATE OR REPLACE TABLE common.sf_contacts (
    contact_id VARCHAR(20) PRIMARY KEY,
    opportunity_id VARCHAR(20) NOT NULL,
    account_id VARCHAR(20) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(50),
    title VARCHAR(100),
    department VARCHAR(100),
    lead_source VARCHAR(100),
    campaign_no INT,
    created_date DATE
);

COPY INTO common.sf_contacts
FROM @INTERNAL_DATA_STAGE/demo_data/sf_contacts.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

show tables in database workshop_db;
