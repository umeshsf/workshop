
use role attendee_role;

--create cortex agent central repository, one time

CREATE DATABASE IF NOT EXISTS snowflake_intelligence;
CREATE SCHEMA IF NOT EXISTS snowflake_intelligence.agents;
-- Allow anyone to see the agents in this schema
GRANT USAGE ON DATABASE snowflake_intelligence TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA snowflake_intelligence.agents TO ROLE PUBLIC;
GRANT CREATE AGENT ON SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS TO role attendee_role;

-- we will have our data here
create or replace database cortex_db;
create or replace schema cortex_db.data;
use cortex_db.data;

-- create stage for semantic models
create or replace stage cortex_db.data.semantic_models 
    encryption = (type = 'snowflake_sse') 
    directory = ( enable = true );


-- create tables with data
create or replace table cortex_db.data.marketing_campaign_metrics as 
select * from ORGDATACLOUD$INTERNAL$MEDIA_DEMO_DATASET.MARKETING.marketing_campaign_metrics;

select * from cortex_db.data.marketing_campaign_metrics;

create or replace table cortex_db.data.products as
select * from ORGDATACLOUD$INTERNAL$MEDIA_DEMO_DATASET.MARKETING.products;

select * from products;

create or replace table cortex_db.data.sales as
select * from ORGDATACLOUD$INTERNAL$MEDIA_DEMO_DATASET.MARKETING.sales;

select * from sales;

create or replace table cortex_db.data.social_media as
select * from ORGDATACLOUD$INTERNAL$MEDIA_DEMO_DATASET.MARKETING.social_media;


-- email tool

create or replace notification integration email_integration
  type=email
  enabled=true
  default_subject = 'snowflake intelligence'
;

create or replace procedure send_email(
    recipient_email varchar,
    subject varchar,
    body varchar
)
returns varchar
language python
runtime_version = '3.12'
packages = ('snowflake-snowpark-python')
handler = 'send_email'
as
$$
def send_email(session, recipient_email, subject, body):
    try:
        # Escape single quotes in the body
        escaped_body = body.replace("'", "''")
        
        # Execute the system procedure call
        session.sql(f"""
            CALL SYSTEM$SEND_EMAIL(
                'email_integration',
                '{recipient_email}',
                '{subject}',
                '{escaped_body}',
                'text/html'
            )
        """).collect()
        
        return "Email sent successfully"
    except Exception as e:
        return f"Error sending email: {str(e)}"
$$;


call send_email('umesh.patel@snowflake.com','test','hello');

show tables;

-- create semantic view


-- using UI or command line
create or replace semantic view SALES_AND_MARKETING_SVW
	tables (
		MARKETING_CAMPAIGN_METRICS primary key (CATEGORY),
		PRODUCTS primary key (PRODUCT_ID),
		SALES,
		SOCIAL_MEDIA
	)
	relationships (
		SALES_TO_PRODUCT as SALES(PRODUCT_ID) references PRODUCTS(PRODUCT_ID),
		MARKETING_TO_SOCIAL as SOCIAL_MEDIA(CATEGORY) references MARKETING_CAMPAIGN_METRICS(CATEGORY)
	)
	facts (
		MARKETING_CAMPAIGN_METRICS.CLICKS as CLICKS with synonyms=('click_throughs','link_clicks','ad_clicks','button_clicks','selections','hits') comment='The total number of times users clicked on an advertisement or promotional link as part of a marketing campaign.',
		MARKETING_CAMPAIGN_METRICS.IMPRESSIONS as IMPRESSIONS with synonyms=('views','ad_views','ad_exposures','display_count','ad_impressions','exposures','ad_views_count','views_count') comment='The total number of times an ad was displayed to users during a marketing campaign.',
		SALES.SALES_AMOUNT as SALES_AMOUNT with synonyms=('total_sales','revenue','sales_total','sales_value','sales_revenue','total_revenue','sales_figure','sales_number') comment='The total amount of sales generated from a transaction or order.',
		SALES.UNITS_SOLD as UNITS_SOLD with synonyms=('quantity_sold','items_sold','sales_volume','units_purchased','volume_sold','sales_quantity') comment='The total quantity of products sold.',
		SOCIAL_MEDIA.MENTIONS as MENTIONS with synonyms=('citations','references','quotes','allusions','name_drops','tags','shoutouts','credits','acknowledgments') comment='The number of times a brand, product, or keyword is mentioned on social media platforms.'
	)
	dimensions (
		MARKETING_CAMPAIGN_METRICS.CAMPAIGN_NAME as CAMPAIGN_NAME with synonyms=('ad_campaign','marketing_campaign','promo_name','advertisement_name','campaign_title','promotion_name') comment='The name of the marketing campaign, which can be used to identify and analyze the performance of specific promotional initiatives.',
		MARKETING_CAMPAIGN_METRICS.CATEGORY as CATEGORY with synonyms=('type','classification','group','label','sector','class','kind','genre') comment='The category of the marketing campaign, which represents the product or service being promoted, such as a specific industry or product line.',
		MARKETING_CAMPAIGN_METRICS.DATE as DATE with synonyms=('day','calendar_date','timestamp','datestamp','calendar_day','date_value') comment='Date on which the marketing campaign metrics were recorded.',
		PRODUCTS.CATEGORY as CATEGORY with synonyms=('type','classification','group','genre','kind','class','product_type','product_group','product_category','product_classification') comment='The CATEGORY column represents the type of product being sold, which can be classified into three main categories: Fitness Wear, Casual Wear, and Accessories.',
		PRODUCTS.PRODUCT_ID as PRODUCT_ID with synonyms=('product_key','item_id','product_number','item_number','product_code','sku','product_identifier') comment='Unique identifier for each product in the catalog.',
		PRODUCTS.PRODUCT_NAME as PRODUCT_NAME with synonyms=('item_name','product_title','item_title','product_description','product_label','item_label') comment='The name of the product being sold, such as a specific type of fitness equipment or accessory.',
		SALES.DATE as DATE with synonyms=('day','calendar_date','date_field','calendar_day','timestamp','date_value','entry_date','record_date','log_date') comment='Date of sale, representing the calendar date when a transaction occurred.',
		SALES.PRODUCT_ID as PRODUCT_ID with synonyms=('product_code','item_id','product_number','item_number','sku','product_key') comment='Unique identifier for a product sold.',
		SALES.REGION as REGION with synonyms=('area','territory','zone','district','location','province','state','county','geographic_area','market_area') comment='Geographic region where the sale was made.',
		SOCIAL_MEDIA.CATEGORY as CATEGORY with synonyms=('type','classification','group','genre','kind','label','section','class') comment='The category of social media content, representing the type of product or service being promoted, such as fitness-related clothing and accessories.',
		SOCIAL_MEDIA.DATE as DATE with synonyms=('day','timestamp','calendar_date','posting_date','publication_date','entry_date') comment='Date on which social media data was collected or posted.',
		SOCIAL_MEDIA.INFLUENCER as INFLUENCER with synonyms=('social_media_personality','online_influencer','social_media_figure','content_creator','key_opinion_leader','thought_leader','industry_expert','brand_ambassador') comment='The name of the social media influencer promoting the product or service.',
		SOCIAL_MEDIA.PLATFORM as PLATFORM with synonyms=('channel','medium','site','social_media_channel','network','outlet') comment='The social media platform where the activity or engagement took place.'
	)
	comment='The Sales and Marketing Data model in cortex_db.data schema provides a complete view of retail business performance by connecting marketing campaigns, product information, sales data, and social media engagement. The model enables tracking of marketing campaign effectiveness through clicks and impressions, while linking to actual sales performance across different regions. Social media engagement is monitored through influencer activities and mentions, with all data connected through product categories and IDs. The temporal alignment across tables allows for comprehensive analysis of marketing impact on sales performance and social media engagement over time.'
	with extension (CA='{"tables":[{"name":"MARKETING_CAMPAIGN_METRICS","dimensions":[{"name":"CAMPAIGN_NAME","sample_values":["Summer Fitness Campaign"]},{"name":"CATEGORY","sample_values":["Fitness Wear"]}],"facts":[{"name":"CLICKS","sample_values":["429","552","446"]},{"name":"IMPRESSIONS","sample_values":["10238","9962","7278"]}],"time_dimensions":[{"name":"DATE","sample_values":["2025-06-17","2025-06-15","2025-07-01"]}]},{"name":"PRODUCTS","dimensions":[{"name":"CATEGORY","sample_values":["Fitness Wear","Casual Wear","Accessories"]},{"name":"PRODUCT_ID","sample_values":["1","2","3"]},{"name":"PRODUCT_NAME","sample_values":["Fitness Item 1","Fitness Item 2","Fitness Item 3"]}]},{"name":"SALES","dimensions":[{"name":"PRODUCT_ID","sample_values":["29","1","2"]},{"name":"REGION","sample_values":["North","East","South"]}],"facts":[{"name":"SALES_AMOUNT","sample_values":["1039.35","1494.08","3782.99"]},{"name":"UNITS_SOLD","sample_values":["25","33","28"]}],"time_dimensions":[{"name":"DATE","sample_values":["2025-05-16","2025-05-19","2025-05-17"]}]},{"name":"SOCIAL_MEDIA","dimensions":[{"name":"CATEGORY","sample_values":["Fitness Wear"]},{"name":"INFLUENCER","sample_values":["NovaFitStar"]},{"name":"PLATFORM","sample_values":["Facebook","Instagram","Twitter"]}],"facts":[{"name":"MENTIONS","sample_values":["6","9","16"]}],"time_dimensions":[{"name":"DATE","sample_values":["2025-05-16","2025-05-19","2025-07-06"]}]}],"relationships":[{"name":"SALES_TO_PRODUCT","relationship_type":"many_to_one","join_type":"inner"},{"name":"MARKETING_TO_SOCIAL","relationship_type":"many_to_one","join_type":"inner"}],"verified_queries":[{"name":"sales","question":"Show me the trend of sales by product category between June 2025 and August 2025\\n\\n","sql":"WITH monthly_sales AS (\\n  SELECT\\n    p.category,\\n    DATE_TRUNC(''MONTH'', s.date) AS month,\\n    SUM(s.sales_amount) AS monthly_sales\\n  FROM\\n    sales AS s\\n    INNER JOIN products AS p ON s.product_id = p.product_id\\n  WHERE\\n    s.date >= ''2025-06-01''\\n    AND s.date < ''2025-09-01''\\n  GROUP BY\\n    p.category,\\n    DATE_TRUNC(''MONTH'', s.date)\\n)\\nSELECT\\n  category,\\n  month,\\n  monthly_sales\\nFROM\\n  monthly_sales\\nORDER BY\\n  category,\\n  month","use_as_onboarding_question":false,"verified_by":"EVENT USER","verified_at":1758414365}]}');

show semantic views;




-- cortex search

create or replace table cortex_db.data.support_cases as
select * from ORGDATACLOUD$INTERNAL$MEDIA_DEMO_DATASET.MARKETING.SUPPORT_CASES;

select * from  cortex_db.data.support_cases;

create or replace cortex search service support_cases_search_svc 
on transcript 
attributes 
  id,title,product 
warehouse = default_wh 
embedding_model = 'snowflake-arctic-embed-m-v1.5' 
target_lag = '24 hour' 
initialize=on_schedule 
as 
(
	SELECT
		TRANSCRIPT,ID,TITLE,PRODUCT
	FROM cortex_db.data.support_cases
);


-- aggregated support case summary 

create or replace table AGGREGATED_SUPPORT_CASES_SUMMARY as
 select 
    ai_agg(transcript,'Read and analyze all support cases to provide a long-form text summary in no less than 5000 words.') as summary
    from support_cases;

select * from AGGREGATED_SUPPORT_CASES_SUMMARY;


show cortex searches;



