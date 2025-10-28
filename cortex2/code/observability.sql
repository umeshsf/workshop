SELECT * FROM TABLE(
  SNOWFLAKE.LOCAL.CORTEX_ANALYST_REQUESTS(
    'SEMANTIC_VIEW',
    'SNOWFLAKE_INTELLIGENCE.TOOLS.FINANCE_SEMANTIC_VIEW'
  )
);



    
SELECT
    timestamp,
    record_attributes,
    *,
    record_attributes:"ai.observability.eval.target_record_id" AS record_id,
    record_attributes:"ai.observability.eval.metric_type" AS METRIC,
    record_attributes:"ai.observability.eval.score" AS SCORE,
    record_attributes:"ai.observability.eval.args"."ai.observability.record_root.input" AS USER_QUERY,
    record_attributes:"ai.observability.eval.args"."ai.observability.record_root.output" AS LLM_RESPONSE,
    record_attributes:"ai.observability.eval.args"."ai.observability.retrieval.retrieved_context" AS RETRIEVED_CONTEXT_CHUNK,
    record_attributes:"ai.observability.eval.args"."ai.observability.retrieval.retrieved_contexts" AS RETRIEVED_CONTEXTS_FULL_LIST
FROM
    SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS

ORDER BY
    RECORD_ID,
    METRIC;



--

SELECT
    MIN(timestamp) AS first_eval_timestamp,
    record_attributes:"ai.observability.eval.target_record_id" AS record_id,
    -- Get the input/output from any eval record (they should be the same)
    MAX(record_attributes:"ai.observability.eval.args"."ai.observability.record_root.input") AS user_query,
    MAX(record_attributes:"ai.observability.eval.args"."ai.observability.record_root.output") AS llm_response,
    MAX(record_attributes:"ai.observability.eval.args"."ai.observability.retrieval.retrieved_context") AS retrieved_context_chunk,
    MAX(record_attributes:"ai.observability.eval.args"."ai.observability.retrieval.retrieved_contexts") AS retrieved_contexts_full_list,
    -- Aggregate all metrics and scores
    OBJECT_CONSTRUCT(
        LISTAGG(DISTINCT record_attributes:"ai.observability.eval.metric_type", ',') WITHIN GROUP (ORDER BY record_attributes:"ai.observability.eval.metric_type"),
        LISTAGG(record_attributes:"ai.observability.eval.score", ',') WITHIN GROUP (ORDER BY record_attributes:"ai.observability.eval.metric_type")
    ) AS all_metrics_scores,
    -- Individual metric scores using AVG
    AVG(CASE WHEN record_attributes:"ai.observability.eval.metric_type" = 'groundedness' 
             THEN record_attributes:"ai.observability.eval.score" END) AS groundedness_score,
    AVG(CASE WHEN record_attributes:"ai.observability.eval.metric_type" = 'relevance' 
             THEN record_attributes:"ai.observability.eval.score" END) AS relevance_score,
    AVG(CASE WHEN record_attributes:"ai.observability.eval.metric_type" = 'coherence' 
             THEN record_attributes:"ai.observability.eval.score" END) AS coherence_score,
    AVG(CASE WHEN record_attributes:"ai.observability.eval.metric_type" = 'correctness' 
             THEN record_attributes:"ai.observability.eval.score" END) AS correctness_score,
    AVG(CASE WHEN record_attributes:"ai.observability.eval.metric_type" = 'answer_relevance' 
             THEN record_attributes:"ai.observability.eval.score" END) AS answer_relevance_score,
    -- Overall average score across all metrics for this record
    AVG(record_attributes:"ai.observability.eval.score") AS overall_avg_score,
    COUNT(*) AS metric_count
FROM
    SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS
WHERE true
   -- and record_attributes:"ai.observability.span_type" = 'eval'
--    AND record_attributes:"ai.observability.eval.metric_type" IS NOT NULL
 --   AND record_attributes:"ai.observability.eval.score" IS NOT NULL
GROUP BY
    record_attributes:"ai.observability.eval.target_record_id"
ORDER BY
    record_id;
