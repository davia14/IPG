WITH av AS (SELECT system, new_system, survey_type, school_year_c AS school_year, question, SUM(num_of_responses) AS num_of_responses, AVG(pct_sa_only) AS pct_sa_only, AVG(pct_agree_only) AS pct_agree_only, AVG(pct_sa_a) AS pct_sa_a
FROM {{ref("surveycollectionlvl")}} GROUP BY 1,2,3,4,5)

select * FROM av