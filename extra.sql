

-- create a database that has Cortex search services in the marketplace as a part of Cortex knowledge extension

-- https://app.snowflake.com/marketplace/listing/GZSTZ67BY9OQ4/snowflake-snowflake-documentation?search=snowflake+documentation
-- click on GET to accept the standard terms
-- first time you must use get, next time you can create using the following command. 

create or replace DATABASE snowflake_documentation FROM LISTING GZSTZ67BY9OQ4;
GRANT IMPORTED PRIVILEGES ON DATABASE snowflake_documentation  TO ROLE public;



-- now you have Cortex search for Snowflake documentation available, check it out

show cortex search services in the account;

-- create semantic view for cortex analyst;

show semantic views in the account;

create or replace semantic view CORTEX_DB.PUBLIC.COST_PERFORMANCE_ASSISTANT
	tables (
		SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY,
		SNOWFLAKE.ACCOUNT_USAGE.QUERY_ATTRIBUTION_HISTORY
	)
	facts (
		QUERY_HISTORY.BYTES_DELETED as BYTES_DELETED comment='The total amount of data deleted from the database as a result of a query, measured in bytes.',
		QUERY_HISTORY.BYTES_READ_FROM_RESULT as BYTES_READ_FROM_RESULT comment='The total number of bytes read from the query results.',
		QUERY_HISTORY.BYTES_SCANNED as BYTES_SCANNED comment='The total number of bytes scanned by the query.',
		QUERY_HISTORY.BYTES_SENT_OVER_THE_NETWORK as BYTES_SENT_OVER_THE_NETWORK comment='The total amount of data transmitted over the network during the execution of a query, measured in bytes.',
		QUERY_HISTORY.BYTES_SPILLED_TO_LOCAL_STORAGE as BYTES_SPILLED_TO_LOCAL_STORAGE comment='The total amount of data, in bytes, that was spilled to local storage during query execution, indicating the amount of data that exceeded the available memory and had to be written to disk.',
		QUERY_HISTORY.BYTES_SPILLED_TO_REMOTE_STORAGE as BYTES_SPILLED_TO_REMOTE_STORAGE comment='The total amount of data (in bytes) that was spilled to remote storage during query execution, indicating the amount of data that exceeded the available memory and had to be written to disk.',
		QUERY_HISTORY.BYTES_WRITTEN as BYTES_WRITTEN comment='The total number of bytes written to storage as a result of a query.',
		QUERY_HISTORY.BYTES_WRITTEN_TO_RESULT as BYTES_WRITTEN_TO_RESULT comment='The total number of bytes written to the result set of a query.',
		QUERY_HISTORY.CHILD_QUERIES_WAIT_TIME as CHILD_QUERIES_WAIT_TIME comment='The total wait time for child queries in a query execution plan.',
		QUERY_HISTORY.CLUSTER_NUMBER as CLUSTER_NUMBER comment='The cluster number assigned to a query, indicating the specific cluster where the query was executed.',
		QUERY_HISTORY.COMPILATION_TIME as COMPILATION_TIME comment='The time taken to compile a query, measured in milliseconds.',
		QUERY_HISTORY.CREDITS_USED_CLOUD_SERVICES as CREDITS_USED_CLOUD_SERVICES comment='The total amount of credits used by cloud services for a query.',
		QUERY_HISTORY.DATABASE_ID as DATABASE_ID comment='Unique identifier for the database where the query was executed.',
		QUERY_HISTORY.EXECUTION_TIME as EXECUTION_TIME comment='The time taken to execute a query, measured in seconds.',
		QUERY_HISTORY.EXTERNAL_FUNCTION_TOTAL_INVOCATIONS as EXTERNAL_FUNCTION_TOTAL_INVOCATIONS comment='Total number of times an external function was invoked during query execution.',
		QUERY_HISTORY.EXTERNAL_FUNCTION_TOTAL_RECEIVED_BYTES as EXTERNAL_FUNCTION_TOTAL_RECEIVED_BYTES comment='Total number of bytes received by external functions during query execution.',
		QUERY_HISTORY.EXTERNAL_FUNCTION_TOTAL_RECEIVED_ROWS as EXTERNAL_FUNCTION_TOTAL_RECEIVED_ROWS comment='Total number of rows received by the external function.',
		QUERY_HISTORY.EXTERNAL_FUNCTION_TOTAL_SENT_BYTES as EXTERNAL_FUNCTION_TOTAL_SENT_BYTES comment='Total number of bytes sent by external functions during query execution.',
		QUERY_HISTORY.EXTERNAL_FUNCTION_TOTAL_SENT_ROWS as EXTERNAL_FUNCTION_TOTAL_SENT_ROWS comment='Total number of rows sent to external functions for processing.',
		QUERY_HISTORY.FAULT_HANDLING_TIME as FAULT_HANDLING_TIME comment='The time it takes to handle and resolve faults or errors in the system.',
		QUERY_HISTORY.INBOUND_DATA_TRANSFER_BYTES as INBOUND_DATA_TRANSFER_BYTES comment='The total number of bytes transferred into the system from an external source.',
		QUERY_HISTORY.LIST_EXTERNAL_FILES_TIME as LIST_EXTERNAL_FILES_TIME comment='The time it takes to list external files, measured in seconds, with values representing the minimum, average, and maximum times, respectively.',
		QUERY_HISTORY.OUTBOUND_DATA_TRANSFER_BYTES as OUTBOUND_DATA_TRANSFER_BYTES comment='The total number of bytes transferred out of the system during a query.',
		QUERY_HISTORY.PARTITIONS_SCANNED as PARTITIONS_SCANNED comment='The number of partitions scanned by the query.',
		QUERY_HISTORY.PARTITIONS_TOTAL as PARTITIONS_TOTAL comment='Total number of partitions in the system.',
		QUERY_HISTORY.PERCENTAGE_SCANNED_FROM_CACHE as PERCENTAGE_SCANNED_FROM_CACHE comment='The percentage of data that was retrieved from the cache instead of being re-computed or re-retrieved from the underlying data source, indicating the efficiency of the query''s caching mechanism.',
		QUERY_HISTORY.QUERY_ACCELERATION_BYTES_SCANNED as QUERY_ACCELERATION_BYTES_SCANNED comment='The total amount of data scanned from the query acceleration cache, in bytes, for the query.',
		QUERY_HISTORY.QUERY_ACCELERATION_PARTITIONS_SCANNED as QUERY_ACCELERATION_PARTITIONS_SCANNED comment='The number of partitions scanned by the query accelerator.',
		QUERY_HISTORY.QUERY_ACCELERATION_UPPER_LIMIT_SCALE_FACTOR as QUERY_ACCELERATION_UPPER_LIMIT_SCALE_FACTOR comment='The factor by which the query acceleration upper limit is scaled, with a value of 0 indicating no scaling.',
		QUERY_HISTORY.QUERY_HASH_VERSION as QUERY_HASH_VERSION comment='A unique identifier for a query, which can be used to track changes to the query over time, with the version number indicating the iteration of the query.',
		QUERY_HISTORY.QUERY_LOAD_PERCENT as QUERY_LOAD_PERCENT comment='The percentage of the system''s load that is currently being used to process queries.',
		QUERY_HISTORY.QUERY_PARAMETERIZED_HASH_VERSION as QUERY_PARAMETERIZED_HASH_VERSION comment='A unique identifier for a parameterized query, used to track the version of the query plan.',
		QUERY_HISTORY.QUERY_RETRY_TIME as QUERY_RETRY_TIME comment='The amount of time spent retrying a query due to errors or failures.',
		QUERY_HISTORY.QUEUED_OVERLOAD_TIME as QUEUED_OVERLOAD_TIME comment='The time spent waiting in the queue due to overload, in milliseconds.',
		QUERY_HISTORY.QUEUED_PROVISIONING_TIME as QUEUED_PROVISIONING_TIME comment='The time, in seconds, that a query spent in the queue waiting for resources to become available before provisioning began.',
		QUERY_HISTORY.QUEUED_REPAIR_TIME as QUEUED_REPAIR_TIME comment='The time a repair query spent in the queue before being executed.',
		QUERY_HISTORY.ROWS_DELETED as ROWS_DELETED comment='The number of rows deleted as a result of a query execution.',
		QUERY_HISTORY.ROWS_INSERTED as ROWS_INSERTED comment='The total number of rows inserted into a table as a result of a query execution.',
		QUERY_HISTORY.ROWS_PRODUCED as ROWS_PRODUCED comment='The total number of rows returned by a query.',
		QUERY_HISTORY.ROWS_UNLOADED as ROWS_UNLOADED comment='The number of rows that were unloaded or deleted from a table as a result of a query.',
		QUERY_HISTORY.ROWS_UPDATED as ROWS_UPDATED comment='The total number of rows updated by a query.',
		QUERY_HISTORY.ROWS_WRITTEN_TO_RESULT as ROWS_WRITTEN_TO_RESULT comment='The number of rows written to the result set of a query.',
		QUERY_HISTORY.SCHEMA_ID as SCHEMA_ID comment='Unique identifier for the schema in which the query was executed.',
		QUERY_HISTORY.SESSION_ID as SESSION_ID comment='Unique identifier for a query session, used to track and manage the execution of a specific query or set of queries.',
		QUERY_HISTORY.TOTAL_ELAPSED_TIME as TOTAL_ELAPSED_TIME comment='The total time taken to execute a query, from start to finish, measured in milliseconds.',
		QUERY_HISTORY.TRANSACTION_BLOCKED_TIME as TRANSACTION_BLOCKED_TIME comment='The time spent waiting for a transaction to be blocked, typically due to a lock or other resource contention, measured in seconds.',
		QUERY_HISTORY.TRANSACTION_ID as TRANSACTION_ID comment='Unique identifier for a specific database transaction.',
		QUERY_HISTORY.USER_DATABASE_ID as USER_DATABASE_ID comment='Unique identifier for the database that the query was executed against.',
		QUERY_HISTORY.USER_SCHEMA_ID as USER_SCHEMA_ID comment='Unique identifier for the schema that the user belongs to.',
		QUERY_HISTORY.WAREHOUSE_ID as WAREHOUSE_ID comment='Unique identifier for the warehouse associated with the query.',
		QUERY_ATTRIBUTION_HISTORY.CREDITS_ATTRIBUTED_COMPUTE as CREDITS_ATTRIBUTED_COMPUTE comment='The percentage of compute resources utilized that are attributed to the user or organization.',
		QUERY_ATTRIBUTION_HISTORY.CREDITS_USED_QUERY_ACCELERATION as CREDITS_USED_QUERY_ACCELERATION comment='The total amount of credits used for query acceleration.',
		QUERY_ATTRIBUTION_HISTORY.WAREHOUSE_ID as WAREHOUSE_ID comment='Unique identifier for the warehouse where the inventory is stored.'
	)
	dimensions (
		QUERY_HISTORY.DATABASE_NAME as DATABASE_NAME comment='The name of the database where the query was executed.',
		QUERY_HISTORY.END_TIME as END_TIME comment='The date and time when each query was completed, in ISO 8601 format.',
		QUERY_HISTORY.ERROR_CODE as ERROR_CODE comment='Error codes associated with query execution, indicating specific issues or failures that occurred during query processing.',
		QUERY_HISTORY.ERROR_MESSAGE as ERROR_MESSAGE comment='The error message returned when a query fails to execute due to a compilation issue, such as invalid syntax, unauthorized access, or non-existent objects.',
		QUERY_HISTORY.EXECUTION_STATUS as EXECUTION_STATUS comment='The status of a query''s execution, indicating whether it completed successfully or failed.',
		QUERY_HISTORY.INBOUND_DATA_TRANSFER_CLOUD as INBOUND_DATA_TRANSFER_CLOUD comment='The type of data transfer that occurred, specifically data being transferred into the system from a cloud-based source.',
		QUERY_HISTORY.INBOUND_DATA_TRANSFER_REGION as INBOUND_DATA_TRANSFER_REGION comment='The region where the data was transferred from, indicating the geographical location of the inbound data source.',
		QUERY_HISTORY.IS_CLIENT_GENERATED_STATEMENT as IS_CLIENT_GENERATED_STATEMENT comment='Indicates whether the query was generated by a client application or manually written by a user.',
		QUERY_HISTORY.OUTBOUND_DATA_TRANSFER_CLOUD as OUTBOUND_DATA_TRANSFER_CLOUD comment='The cloud platform used for outbound data transfers.',
		QUERY_HISTORY.OUTBOUND_DATA_TRANSFER_REGION as OUTBOUND_DATA_TRANSFER_REGION comment='The region where the data was transferred to, indicating the geographic location of the outbound data transfer.',
		QUERY_HISTORY.QUERY_HASH as QUERY_HASH comment='Unique identifier for a query, used to track and analyze query performance and usage patterns.',
		QUERY_HISTORY.QUERY_ID as QUERY_ID comment='Unique identifier for a query executed in the system.',
		QUERY_HISTORY.QUERY_PARAMETERIZED_HASH as QUERY_PARAMETERIZED_HASH comment='A unique hash value representing a parameterized query, allowing for the identification and tracking of similar queries with different parameter values.',
		QUERY_HISTORY.QUERY_RETRY_CAUSE as QUERY_RETRY_CAUSE comment='The reason why a query was retried, such as "Timeout", "Network Error", or "Resource Unavailable".',
		QUERY_HISTORY.QUERY_TAG as QUERY_TAG comment='A tag used to identify and categorize queries, allowing for filtering and grouping of query history by specific job or process names.',
		QUERY_HISTORY.QUERY_TEXT as QUERY_TEXT comment='The text of the query executed by the user, including the SQL command and any parameters or arguments passed to it.',
		QUERY_HISTORY.QUERY_TYPE as QUERY_TYPE comment='The type of query executed, such as retrieving information (SHOW), fetching files (GET_FILES), or listing files (LIST_FILES).',
		QUERY_HISTORY.RELEASE_VERSION as RELEASE_VERSION comment='The version of the software release that executed the query.',
		QUERY_HISTORY.ROLE_NAME as ROLE_NAME comment='The role of the user who executed the query.',
		QUERY_HISTORY.ROLE_TYPE as ROLE_TYPE comment='The type of role or application that executed the query.',
		QUERY_HISTORY.SCHEMA_NAME as SCHEMA_NAME comment='The name of the database schema where the query was executed.',
		QUERY_HISTORY.SECONDARY_ROLE_STATS as SECONDARY_ROLE_STATS comment='Stores the secondary role statistics for a query, including the count of secondary roles and their corresponding IDs.',
		QUERY_HISTORY.START_TIME as START_TIME comment='The date and time when each query was initiated, in ISO 8601 format.',
		QUERY_HISTORY.USER_DATABASE_NAME as USER_DATABASE_NAME comment='The name of the database that the user was connected to when the query was executed.',
		QUERY_HISTORY.USER_NAME as USER_NAME comment='The user who executed the query.',
		QUERY_HISTORY.USER_SCHEMA_NAME as USER_SCHEMA_NAME comment='The name of the schema that the user who executed the query belongs to.',
		QUERY_HISTORY.USER_TYPE as USER_TYPE comment='The type of user who executed the query, either a service account or a person.',
		QUERY_HISTORY.WAREHOUSE_NAME as WAREHOUSE_NAME comment='The name of the warehouse where the query was executed.',
		QUERY_HISTORY.WAREHOUSE_SIZE as WAREHOUSE_SIZE comment='The size of the warehouse used to execute the query, which can impact performance and resource allocation.',
		QUERY_HISTORY.WAREHOUSE_TYPE as WAREHOUSE_TYPE comment='The type of warehouse used to execute the query, indicating whether it was a standard warehouse or another type such as a serverless or enterprise warehouse.',
		QUERY_ATTRIBUTION_HISTORY.END_TIME as END_TIME comment='The date and time when the attribution event ended.',
		QUERY_ATTRIBUTION_HISTORY.PARENT_QUERY_ID as PARENT_QUERY_ID comment='Unique identifier of the parent query that triggered the attribution event.',
		QUERY_ATTRIBUTION_HISTORY.QUERY_HASH as QUERY_HASH comment='Unique identifier for a query, used to track changes and updates to the query over time.',
		QUERY_ATTRIBUTION_HISTORY.QUERY_ID as QUERY_ID comment='Unique identifier for a query, used to track and analyze the query''s attribution history.',
		QUERY_ATTRIBUTION_HISTORY.QUERY_PARAMETERIZED_HASH as QUERY_PARAMETERIZED_HASH comment='A unique identifier for a parameterized query, used to track the history of queries executed with varying parameters.',
		QUERY_ATTRIBUTION_HISTORY.QUERY_TAG as QUERY_TAG comment='This column stores metadata tags associated with a query, providing context about the query''s origin, including the pipeline, job, project, and environment in which it was executed.',
		QUERY_ATTRIBUTION_HISTORY.ROOT_QUERY_ID as ROOT_QUERY_ID comment='Unique identifier for the root query that triggered the attribution event.',
		QUERY_ATTRIBUTION_HISTORY.START_TIME as START_TIME comment='The timestamp when the attribution event started.',
		QUERY_ATTRIBUTION_HISTORY.USER_NAME as USER_NAME comment='The user or system that made the attribution change.',
		QUERY_ATTRIBUTION_HISTORY.WAREHOUSE_NAME as WAREHOUSE_NAME comment='The name of the warehouse where the data is stored.'
	)
	comment='Unlock hidden performance insights from your query history to drive measurable cost
savings and performance improvements.'
	with extension (CA='{"tables":[{"name":"QUERY_HISTORY","dimensions":[{"name":"DATABASE_NAME","sample_values":["SNOWFLAKE_INTELLIGENCE","CORTEX_DB"]},{"name":"ERROR_CODE","sample_values":["002140","002003"]},{"name":"ERROR_MESSAGE","sample_values":["SQL compilation error:\\nOrganization profile ''INTERNAL'' does not exist or not authorized.","SQL compilation error:\\nWorkspace ''\\"USER$\\".PUBLIC.\\"DEFAULT$\\"'' does not exist or not authorized."]},{"name":"EXECUTION_STATUS","sample_values":["SUCCESS","FAIL"]},{"name":"INBOUND_DATA_TRANSFER_CLOUD"},{"name":"INBOUND_DATA_TRANSFER_REGION"},{"name":"IS_CLIENT_GENERATED_STATEMENT","sample_values":["TRUE","FALSE"]},{"name":"OUTBOUND_DATA_TRANSFER_CLOUD","sample_values":["AZURE"]},{"name":"OUTBOUND_DATA_TRANSFER_REGION","sample_values":["westus2"]},{"name":"QUERY_HASH","sample_values":["942433b7f6946b737a0d03c71e7e7f09","78c1293dc407ae1d9ab6692ddd36a56a","3741300aa7652d8734f9dee4fe74e543"]},{"name":"QUERY_ID","sample_values":["01bf33b0-0206-b687-0003-66420001591a","01bf33b0-0206-b6c6-0003-664200013d56","01bf33b0-0206-b687-0003-6642000158fa"]},{"name":"QUERY_PARAMETERIZED_HASH","sample_values":["bcd1347509a72461cc6f0fdc0dae002b","0fe54efb178617f9a0f6f77572d84dce","29918b1976d7a9de68b3d20a52ee84a6"]},{"name":"QUERY_RETRY_CAUSE"},{"name":"QUERY_TAG","sample_values":["{Job_Name: ''DataOps FinObs''}","cortex-agent"]},{"name":"QUERY_TEXT","sample_values":["CALL SYSTEM$GET_RECENT_IN_APP_NOTIFICATIONS();","show terse SCHEMAS in DATABASE IDENTIFIER(''\\"DEFAULT_DATABASE\\"'') limit 10000","show terse DATABASES limit 10000"]},{"name":"QUERY_TYPE","sample_values":["SHOW","GET_FILES","LIST_FILES"]},{"name":"RELEASE_VERSION","sample_values":["9.28.1"]},{"name":"ROLE_NAME","sample_values":["PUBLIC","ATTENDEE_ROLE","ACCOUNTADMIN"]},{"name":"ROLE_TYPE","sample_values":["ROLE","APPLICATION"]},{"name":"SCHEMA_NAME","sample_values":["AGENTS","DATA"]},{"name":"SECONDARY_ROLE_STATS","sample_values":["{\\"roleCount\\":3,\\"roleIds\\":[121,4,102]}","{\\"roleCount\\":2,\\"roleIds\\":[1,4]}"]},{"name":"USER_DATABASE_NAME"},{"name":"USER_NAME","sample_values":["SYSTEM","WORKSHEETS_APP_USER","DATAOPS_SERVICE_ADMIN"]},{"name":"USER_SCHEMA_NAME"},{"name":"USER_TYPE","sample_values":["SERVICE","PERSON"]},{"name":"WAREHOUSE_NAME","sample_values":["COMPUTE_SERVICE_WH_SNOWFLAKEDB_UPGRADE_POOL_XLARGE_0","COMPUTE_SERVICE_WH_USER_TASKS_POOL_XSMALL_0"]},{"name":"WAREHOUSE_SIZE","sample_values":["X-Small","Large"]},{"name":"WAREHOUSE_TYPE","sample_values":["STANDARD"]}],"facts":[{"name":"BYTES_DELETED","sample_values":["109","153","107"]},{"name":"BYTES_READ_FROM_RESULT","sample_values":["0"]},{"name":"BYTES_SCANNED","sample_values":["31786752","31509024","33322864"]},{"name":"BYTES_SENT_OVER_THE_NETWORK","sample_values":["16846751","2632165","128595"]},{"name":"BYTES_SPILLED_TO_LOCAL_STORAGE","sample_values":["68128","67645","68053"]},{"name":"BYTES_SPILLED_TO_REMOTE_STORAGE","sample_values":["0"]},{"name":"BYTES_WRITTEN","sample_values":["0","96256","337920"]},{"name":"BYTES_WRITTEN_TO_RESULT","sample_values":["64","103","0"]},{"name":"CHILD_QUERIES_WAIT_TIME","sample_values":["0"]},{"name":"CLUSTER_NUMBER","sample_values":["6","1"]},{"name":"COMPILATION_TIME","sample_values":["42","791","695"]},{"name":"CREDITS_USED_CLOUD_SERVICES","sample_values":["0.000201","6.7e-05","0"]},{"name":"DATABASE_ID","sample_values":["1","9"]},{"name":"EXECUTION_TIME","sample_values":["10","717","13"]},{"name":"EXTERNAL_FUNCTION_TOTAL_INVOCATIONS","sample_values":["13","1","0"]},{"name":"EXTERNAL_FUNCTION_TOTAL_RECEIVED_BYTES","sample_values":["97","50","135"]},{"name":"EXTERNAL_FUNCTION_TOTAL_RECEIVED_ROWS","sample_values":["30","1","0"]},{"name":"EXTERNAL_FUNCTION_TOTAL_SENT_BYTES","sample_values":["1822","1836","1740"]},{"name":"EXTERNAL_FUNCTION_TOTAL_SENT_ROWS","sample_values":["400","0","30"]},{"name":"FAULT_HANDLING_TIME"},{"name":"INBOUND_DATA_TRANSFER_BYTES","sample_values":["0"]},{"name":"LIST_EXTERNAL_FILES_TIME","sample_values":["8","0","11"]},{"name":"OUTBOUND_DATA_TRANSFER_BYTES","sample_values":["0","112","160"]},{"name":"PARTITIONS_SCANNED","sample_values":["17","34","29"]},{"name":"PARTITIONS_TOTAL","sample_values":["15174243","0","15174371"]},{"name":"PERCENTAGE_SCANNED_FROM_CACHE","sample_values":["0.0007866414286","0.224487988","0.321304926"]},{"name":"QUERY_ACCELERATION_BYTES_SCANNED","sample_values":["0"]},{"name":"QUERY_ACCELERATION_PARTITIONS_SCANNED","sample_values":["0"]},{"name":"QUERY_ACCELERATION_UPPER_LIMIT_SCALE_FACTOR","sample_values":["0"]},{"name":"QUERY_HASH_VERSION","sample_values":["2"]},{"name":"QUERY_LOAD_PERCENT","sample_values":["13","100"]},{"name":"QUERY_PARAMETERIZED_HASH_VERSION","sample_values":["1"]},{"name":"QUERY_RETRY_TIME"},{"name":"QUEUED_OVERLOAD_TIME","sample_values":["167","0"]},{"name":"QUEUED_PROVISIONING_TIME","sample_values":["0","68","97"]},{"name":"QUEUED_REPAIR_TIME","sample_values":["0"]},{"name":"ROWS_DELETED","sample_values":["1","0"]},{"name":"ROWS_INSERTED","sample_values":["9626","400","10000"]},{"name":"ROWS_PRODUCED","sample_values":["4","29248","9"]},{"name":"ROWS_UNLOADED","sample_values":["0","1"]},{"name":"ROWS_UPDATED","sample_values":["3000000","629","1"]},{"name":"ROWS_WRITTEN_TO_RESULT","sample_values":["52","37","1"]},{"name":"SCHEMA_ID","sample_values":["41","40"]},{"name":"SESSION_ID","sample_values":["14600508993","14600513129","14600509021"]},{"name":"TOTAL_ELAPSED_TIME","sample_values":["33","444","414"]},{"name":"TRANSACTION_BLOCKED_TIME","sample_values":["0"]},{"name":"TRANSACTION_ID","sample_values":["1758320956315000000","1758319475930000000","0"]},{"name":"USER_DATABASE_ID"},{"name":"USER_SCHEMA_ID"},{"name":"WAREHOUSE_ID","sample_values":["38342038","4"]}],"time_dimensions":[{"name":"END_TIME","sample_values":["2025-09-21T15:41:43.994+0000","2025-09-21T15:41:27.921+0000","2025-09-21T15:41:41.840+0000"]},{"name":"START_TIME","sample_values":["2025-09-21T15:42:35.888+0000","2025-09-21T15:42:56.772+0000","2025-09-21T15:42:48.791+0000"]}]},{"name":"QUERY_ATTRIBUTION_HISTORY","dimensions":[{"name":"PARENT_QUERY_ID","sample_values":["01bf292e-0206-b6cd-0000-000366425b35","01bf2929-0206-b687-0000-0003664246d1"]},{"name":"QUERY_HASH","sample_values":["a4c5811f10a592259ee42a9343d1cb4d","c9410aee083c5aaa32ba7c1191c97fbd","ff253e480bec3b247dce4cbff39821c6"]},{"name":"QUERY_ID","sample_values":["01bf292b-0206-b6c6-0000-000366426d91","01bf292a-0206-b6c6-0000-000366426d19","01bf292c-0206-b6c6-0000-000366426e7d"]},{"name":"QUERY_PARAMETERIZED_HASH","sample_values":["c13c73aebd5b7eee45acf269a0f1e079","7ad08245b86fdc2d26c455f2f1af7d3b","28a4047e23020e250b7c871546db0864"]},{"name":"QUERY_TAG","sample_values":["{\\"DataOps_Pipeline_ID\\": \\"8266374\\", \\"Job_Name\\": \\"Configure Attendee Account\\", \\"Job_ID\\": \\"63844449\\", \\"Branch\\": \\"main\\", \\"Agent\\": \\"prod-ssc-pipeline-runner-2023, frostbyte-runner, prod-ssc-pipeline-runner\\", \\"Project_ID\\": \\"24496\\", \\"Project_Name\\": \\"snowflake-cortex-aisql-hol-pack\\", \\"Project_Path\\": \\"snowflake/hands-on-labs/snowflake-cortex-aisql-hol-pack\\"}","cortex-agent"]},{"name":"ROOT_QUERY_ID","sample_values":["01bf292d-0206-b6cd-0000-000366425999","01bf292a-0206-b6c6-0000-000366426ba1","01bf2929-0206-b687-0000-0003664246d1"]},{"name":"USER_NAME","sample_values":["USER","SYSTEM","DATAOPS_SERVICE_ADMIN"]},{"name":"WAREHOUSE_NAME","sample_values":["DEFAULT_WH"]}],"facts":[{"name":"CREDITS_ATTRIBUTED_COMPUTE","sample_values":["0.0006713571668","0.0005083140445","0.0002694675794"]},{"name":"CREDITS_USED_QUERY_ACCELERATION"},{"name":"WAREHOUSE_ID","sample_values":["4"]}],"time_dimensions":[{"name":"END_TIME","sample_values":["2025-09-19T18:52:50.861+0000","2025-09-18T21:44:42.353+0000","2025-09-19T18:51:26.588+0000"]},{"name":"START_TIME","sample_values":["2025-09-19T18:48:33.491+0000","2025-09-19T18:50:48.156+0000","2025-09-19T18:39:15.953+0000"]}]}],"verified_queries":[{"name":"What was the longest running query in the past week?","question":"What was the longest running query in the past week?","sql":"SELECT\\n  query_id,\\n  query_text,\\n  user_name,\\n  warehouse_name,\\n  start_time,\\n  end_time,\\n  total_elapsed_time\\nFROM\\n  query_history\\nWHERE\\n  start_time >= DATE_TRUNC(''WEEK'', CURRENT_DATE - INTERVAL ''1 WEEK'')\\n  AND start_time < DATE_TRUNC(''WEEK'', CURRENT_DATE)\\nORDER BY\\n  total_elapsed_time DESC NULLS LAST\\nLIMIT\\n  1","use_as_onboarding_question":false,"verified_by":"EVENT USER","verified_at":1758469957}]}');


-- NOW CREATE AGENT

CREATE or REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.SNOWFLAKE_COSTPERFORMANCE_AGENT
WITH PROFILE='{ "display_name": "Snowflake Cost Performance Agent" }'
    COMMENT=$$ I am your Snowflake Cost Performance Assistant, designed to help you optimize query
performance and resolve performance challenges. I analyze your actual query history
to provide personalized, actionable recommendations for your Snowflake environment. $$
FROM SPECIFICATION $$
{
    "models": { "orchestration": "auto" },
    "instructions": { 
        "response": "You are a Snowflake Data Engineer Assistant. Always provide: Specific recommendations with clear next steps Actual metrics from query history data  Prioritized solutions (high-impact first) Snowflake best practices  (Gen 2 warehouses, clustering, modern SQL) * ",
        "orchestration": "For query performance analysis requests:",
         "sample_questions": [
            { "question": "Based on my top 10 slowest queries, can you provide ways to optimize them?"},        
            { "question": "What was the query that is causing performance issues?" },
            { "question": "Which warehouses should be upgraded to Gen 2?" },
            { "question": "How can I optimize this specific query?" }
        ]
    },
    "tools": [
        {
            "tool_spec": {
            "name": "Snowflake_Knowledge_Ext_Documentation",
            "type": "cortex_search",
            "description" : "Use this tool to analyze Snowflake Query Performance and identify optimization opportunities."
            }
        },
        {
            "tool_spec": {
            "name": "cost_performance_assistant_semantic_view",
            "type": "cortex_analyst_text_to_sql"   ,
            "description": " Use this tool to analyze Snowflake query performance and identify optimization"       
          
            }
        }
    ],
    "tool_resources": {
        "Snowflake_Knowledge_Ext_Documentation": {   
            "id_column": "SOURCE_URL",    
            "title_column" : "DOCUMENT_TITLE",  
            "max_results": 10,
            "name": "SNOWFLAKE_DOCUMENTATION.SHARED.CKE_SNOWFLAKE_DOCS_SERVICE"            
        },
        "cost_performance_assistant_semantic_view": {
            "semantic_view": "CORTEX_DB.PUBLIC.COST_PERFORMANCE_ASSISTANT",
            "execution_environment": {
                "type": "warehouse",
                "warehouse": "DEFAULT_WH",
                "query_timeout": 60
              }
        }
    }
}
$$;




show agents in account;


describe agent SNOWFLAKE_INTELLIGENCE.AGENTS.SNOWFLAKE_COSTPERFORMANCE_AGENT;

/* from UI

update:

Orchestration Insruction:
For query performance analysis requests:
1. First, query the semantic view to identify relevant queries, performance metrics, and patterns
2. Analyze execution times, compilation times, bytes scanned, and warehouse usage
3. Prioritize findings by impact (slowest queries, highest resource usage, most frequent errors)
4. Use Snowflake documentation search to reference best practices and specific features
5. Provide specific, actionable recommendations with clear next steps


For optimization questions:
1. Start with the query history data to understand current performance
2. Identify bottlenecks and inefficiencies in the data
3. Reference Snowflake documentation for feature recommendations (Gen 2 warehouses, clustering, etc.)
4. Provide concrete optimization steps with expected improvements


For troubleshooting:
1. Analyze error patterns and compilation issues from query history
2. Search documentation for specific error resolution guidance  
3. Provide step-by-step fixes and prevention strategies


Always ground recommendations in actual data from the user's query history.

Response Instruction:
You are a Snowflake Data Engineer Assistant. Always provide:
* \*\*Specific recommendations\*\* with clear next steps
* \*\*Actual metrics\*\* from query history data
* \*\*Prioritized solutions\*\* (high-impact first)
* \*\*Snowflake best practices\*\* (Gen 2 warehouses, clustering, modern SQL)

Cortex Analyst description:
Use this tool to analyze Snowflake query performance and identify optimization opportunities. This semantic view provides access to query history data, including execution times, compilation times, bytes scanned, warehouse usage, and error information.

Use this tool when users ask about:

  - Slowest running queries and performance bottlenecks
  - Query optimization recommendations
  - Warehouse utilization and sizing recommendations
  - Compilation errors and troubleshooting
  - Data scanning patterns and efficiency analysis
  - Historical query trends and usage patterns

The tool returns structured data about query performance metrics that can be used to provide specific, actionable optimization recommendations.

  * Use the **User’s default** for warehouse
  * Suggest using **100** for the Query timeout
  * Select **Add**
  * For **Cortex Search Services** option, select **+ Add**
  * Provide a **Name**: Cortex\_Knowledge\_Extension\_Snowflake\_Documentation
  * Provide **Description**:


  */
