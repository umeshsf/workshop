
--Prerequistie: Run following code copy and paste in new worksheet
-- https://github.com/umeshsf/publiccode/blob/main/cortexin5min.sql

use role accountadmin;
use policy_db.policies;


CREATE  or replace NETWORK POLICY  open_internet_policy
        ALLOWED_IP_LIST = ('0.0.0.0/0');
ALTER USER user set network_policy=open_internet_policy;

ALTER USER IF EXISTS user ADD PROGRAMMATIC ACCESS TOKEN token_for_mcp
ROLE_RESTRICTION = 'CORTEX_ROLE';

-- copy the token
/*
xxxxxxxx
*/



USE ROLE CORTEX_ROLE;
USE WAREHOUSE CORTEX_WH;
USE SNOWFLAKE_INTELLIGENCE.TOOLS;




CREATE OR REPLACE MCP SERVER snowflake_mcp_server FROM SPECIFICATION
$$
            tools:
              - name: "Snowflake Documentation Search"
                identifier: "SNOWFLAKE_DOCUMENTATION.SHARED.CKE_SNOWFLAKE_DOCS_SERVICE"
                type: "CORTEX_SEARCH_SERVICE_QUERY"
                description: "Tool for Snowflake documentation and code help."
                title: "Snowflake Documentation"
              - name: "query_semanctic_view"
                type: "CORTEX_ANALYST_MESSAGE"
                identifier: "SNOWFLAKE_INTELLIGENCE.TOOLS.COST_PERFORMANCE_ASSISTANT_SVW"
                description: "Semantic view for all queries executed in Snowflake"
                title: "Snowflake Query History"
                config:
                    warehouse: "cortex_wh"

            $$;


curl -X POST "https://sfsehol-figma_cortex_wrokshop_xemwyi.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/tools/mcp-servers/snowflake_mcp_server" --header 'Content-Type: application/json' --header 'Accept: application/json' --header "Authorization: Bearer xxxxxxxx" --data '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {}
  }'

  curl -X POST "https://sfsehol-figma_cortex_wrokshop_xemwyi.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/tools/mcp-servers/snowflake_mcp_server" --header 'Content-Type: application/json' --header 'Accept: application/json' --header "Authorization: Bearer xxxxxxxx" --data '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/list",
    "params": {}
  }'

 curl -X POST "https://sfsehol-figma_cortex_wrokshop_xemwyi.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/tools/mcp-servers/snowflake_mcp_server" --header 'Content-Type: application/json' --header 'Accept: application/json' --header "Authorization: Bearer xxxxxxxx" --data '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/list",
    "params": {}
  }'



  curl -X POST "https://sfsehol-figma_cortex_wrokshop_xemwyi.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/tools/mcp-servers/snowflake_mcp_server" \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --header "Authorization: Bearer xxxxxxxx" \
  --data '{
    "jsonrpc": "2.0",
    "id": 12345,
    "method": "tools/call",
    "params": {
        "name": "Snowflake Documentation Search",
        "arguments": {
            "query": "How to create hybrid table?"
        }
    }
  }'
