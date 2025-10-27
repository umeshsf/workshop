use role accountadmin;

-- set verified email
set email_address='umesh.patel@snowflake.com';
ALTER USER USER SET EMAIL = $email_address;
SELECT SYSTEM$START_USER_EMAIL_VERIFICATION('"USER"');

-- to get access to all the models to use
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION' ;
-- enable cortex analyst
ALTER ACCOUNT SET ENABLE_CORTEX_ANALYST = TRUE;

-- CREATE SAMPLE DATABASE is not needed but needed if you want to do extra testing
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_SAMPLE_DATA FROM SHARE SFC_SAMPLES.SAMPLE_DATA;
GRANT IMPORTED PRIVILEGES ON DATABASE snowflake_sample_data  TO ROLE public;

-- YOUR CUSTOM ROLE FOR CORTEX ADMIN
set role_name='cortex_role';
set warehouse_name = 'cortex_wh';
set current_user=current_user();

create role if not exists identifier($role_name);
grant role identifier($role_name)  to role sysadmin;
GRANT ROLE identifier($role_name) TO USER IDENTIFIER($current_user);

grant create database on account to role identifier($role_name);
grant create warehouse on account to role identifier($role_name);
grant create role on account to role identifier($role_name);
grant MANAGE GRANTS on account to role identifier($role_name);
grant CREATE INTEGRATION on account to role identifier($role_name);
grant CREATE APPLICATION PACKAGE on account to role identifier($role_name);
grant CREATE APPLICATION on account to role identifier($role_name);
grant IMPORT SHARE on account to role identifier($role_name);

GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE identifier($role_name);

-- control who you want to use cortex
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE PUBLIC;

-- network polices;
CREATE OR REPLACE NETWORK RULE policy_db.policies.Snowflake_intelligence_WebAccessRule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('0.0.0.0:80', '0.0.0.0:443');
GRANT USAGE ON NETWORK RULE policy_db.policies.Snowflake_intelligence_WebAccessRule TO ROLE identifier($role_name);

-- show models
show models in schema snowflake.models;

-- to refresh all modesl use it , it will take few minutes to refresh
-- call snowflake.models.cortex_base_models_refresh();

-- if you do not see all the model run above command to do modelrefresh
SHOW APPLICATION ROLES  like '%model%' IN APPLICATION SNOWFLAKE ;
-- control which model to  use by whom, using following as example
--grant application role SNOWFLAKE."CORTEX-MODEL-ROLE-ALL" to role  identifier($role_name);

use role identifier($role_name);
-- main cortex database, DO NOT CHANGE NAME
CREATE DATABASE IF NOT EXISTS snowflake_intelligence;
--for agents used by Snowflake Intelligence
CREATE SCHEMA IF NOT EXISTS snowflake_intelligence.agents;
-- for tools used by agents
CREATE SCHEMA IF NOT EXISTS snowflake_intelligence.tools;
-- Allow anyone to see the agents in this schema
-- Please note that we are granting access to the public role,  so all users can see  the agents
GRANT USAGE ON DATABASE snowflake_intelligence TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA snowflake_intelligence.agents TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA snowflake_intelligence.tools TO ROLE PUBLIC;

create or replace warehouse identifier($warehouse_name) 
    AUTO_SUSPEND = 60;

GRANT CREATE AGENT ON SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS TO role identifier($role_name) ;

alter user identifier($current_user) set
    DEFAULT_ROLE = cortex_role, 
    DEFAULT_WAREHOUSE = cortex_wh;

CREATE OR REPLACE API INTEGRATION git_api_integration
        API_PROVIDER = git_https_api
        API_ALLOWED_PREFIXES = ('https://github.com/umeshsf/')
        ENABLED = TRUE;


CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION Snowflake_intelligence_ExternalAccess_Integration
ALLOWED_NETWORK_RULES = (Snowflake_intelligence_WebAccessRule)
ENABLED = true;


CREATE OR REPLACE NOTIFICATION INTEGRATION ai_email_int
  TYPE=EMAIL
  ENABLED=TRUE;



