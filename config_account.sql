-- setup the profile with email address , default database, schema and warehouse. 


use role accountadmin
-- enable cortex analyst
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE attendee_role;
GRANT CREATE AGENT ON SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS TO role attendee_role;

ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION'

-- ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'AZURE_US';
-- for aws
-- ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'AWS_US';
-- for region like EU
-- ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'AWS_EU'
-- for all region
-- ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION'




/* 
for reference only
to grant access to other role
USAGE on the snowflake_intelligence database
USAGE on the snowflake_intelligence.agents schema
SELECT on any semantic views used by the agent
SELECT on any tables defined in the semantic views
USAGE on any cortex search services used by the agent
read on any stage that is storing a semantic model yaml
*/


--- for cortex ai sql and model usage
use role accountadmin;


--list all available models
-- show models in account;
show models in schema snowflake.models;

-- Show application roles for models
SHOW APPLICATION ROLES IN APPLICATION SNOWFLAKE;

--grant model access to a specific role
--grant access on specific model to role sysadmin, for example, snowflake-arctic
grant application role SNOWFLAKE."CORTEX-MODEL-ROLE-OPENAI-O4-MINI" to role attendee_role;

--grant access on all models to role sysadmin
grant application role SNOWFLAKE."cortex-model-role-all" to role sysadmin;

--below refresh call may take few minutes to complete
--call snowflake.models.cortex_base_models_refresh();


CREATE NETWORK RULE policy_db.policies.open_network_rule
  TYPE = IPV4
  MODE = INGRESS
  VALUE_LIST = ('0.0.0.0/0')
  COMMENT = 'Allows all public IPv4 addresses.';


CREATE  NETWORK POLICY account_level
        ALLOWED_NETWORK_RULE_LIST = ('"POLICY_DB"."POLICIES"."OPEN_NETWORK_RULE"')
        BLOCKED_NETWORK_RULE_LIST = ()
        ALLOWED_IP_LIST = ()
        BLOCKED_IP_LIST = ()
      ;

ALTER ACCOUNT SET NETWORK_POLICY = ACCOUNT_LEVEL;

grant role attendee_role to role accountadmin;

show agents in account;

-- python and steramlit

-- https://github.com/umeshsf/sfguide-getting-started-with-cortex-agents/
