SELECT 
    RECORD_ATTRIBUTES:"snow.ai.observability.agent.planning.model"::STRING AS planning_model,
    sum(RECORD_ATTRIBUTES:"snow.ai.observability.agent.planning.token_count.total"::NUMBER) AS total_token_count,
    (total_token_count*2.55/1000000) as credits
FROM SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS
where planning_model is not null
group by all
;

SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_SEARCH_DAILY_USAGE_HISTORY;


select distinct a.date,
a.session_id,
a.user,
b.planning_model,
b.total_token_count,
(total_token_count*2.55/1000000) as credits
from (
select     
date(TIMESTAMP) as date,
 RESOURCE_ATTRIBUTES:"snow.session.id"::STRING AS session_id,
RECORD_ATTRIBUTES:"snow.ai.observability.user.name"::STRING as user,
FROM SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS
where user is not null) a
join
(SELECT 
    date(TIMESTAMP) as date,
    RESOURCE_ATTRIBUTES:"snow.session.id"::STRING AS session_id,
    RECORD_ATTRIBUTES:"snow.ai.observability.agent.planning.model"::STRING AS planning_model,
    sum(RECORD_ATTRIBUTES:"snow.ai.observability.agent.planning.token_count.total"::NUMBER) AS total_token_count
FROM SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS
where planning_model is not null
group by all) b
on a.session_id = b.session_id
and a.date = b.date;
