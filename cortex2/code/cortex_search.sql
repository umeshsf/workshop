use role cortex_role;

create or replace schema workshop_db.unstructured_data;

    -- ========================================================================
    -- UNSTRUCTURED DATA
    -- ========================================================================
create or replace table workshop_db.unstructured_data.parsed_content as 
select 
    relative_path, 
    BUILD_STAGE_FILE_URL('@workshop_db.common.internal_data_stage', relative_path) as file_url,
    TO_File(BUILD_STAGE_FILE_URL('@workshop_db.common.internal_data_stage', relative_path) ) file_object,
        SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
                                    @workshop_db.common.internal_data_stage,
                                    relative_path,
                                    {'mode':'LAYOUT'}
                                    ):content::string as Content
    from directory(@workshop_db.common.internal_data_stage) 
where relative_path ilike 'unstructured_docs/%.pdf' ;

select * from workshop_db.unstructured_data.parsed_content;

use schema snowflake_intelligence.tools;

-- Create search service for finance documents
-- This enables semantic search over finance-related content
CREATE OR REPLACE CORTEX SEARCH SERVICE Search_finance_docs
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = cortex_wh
    TARGET_LAG = '30 day'
    initialize=on_create
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            relative_path,
            file_url,
            REGEXP_SUBSTR(relative_path, '[^/]+$') as title, -- Extract filename as title
            content
        FROM workshop_db.unstructured_data.parsed_content
        WHERE relative_path ilike '%/finance/%'
    );

-- Create search service for HR documents
-- This enables semantic search over HR-related content
CREATE OR REPLACE CORTEX SEARCH SERVICE Search_hr_docs
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = cortex_wh
    TARGET_LAG = '30 day'
    initialize=on_create
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            relative_path,
            file_url,
            REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
            content
        FROM workshop_db.unstructured_data.parsed_content
        WHERE relative_path ilike '%/hr/%'
    );

-- Create search service for marketing documents
-- This enables semantic search over marketing-related content
CREATE OR REPLACE CORTEX SEARCH SERVICE Search_marketing_docs
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = cortex_wh
    TARGET_LAG = '30 day'
    initialize=on_create    
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            relative_path,
            file_url,
            REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
            content
        FROM workshop_db.unstructured_data.parsed_content
        WHERE relative_path ilike '%/marketing/%'
    );

-- Create search service for sales documents
-- This enables semantic search over sales-related content
CREATE OR REPLACE CORTEX SEARCH SERVICE Search_sales_docs
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = cortex_wh
    TARGET_LAG = '30 day'
    initialize=on_create    
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            relative_path,
            file_url,
            REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
            content
        FROM workshop_db.unstructured_data.parsed_content
        WHERE relative_path ilike '%/sales/%'
    );

