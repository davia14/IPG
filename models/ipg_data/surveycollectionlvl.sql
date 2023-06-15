WITH dummy AS (SELECT system, new_system, school_year_c, survey_collection, survey_type, date_c, submitters_email_c, question, response, primary_facilitator, secondary_facilitator, tertiary_facilitator, quaternary_facilitator,

CASE
WHEN response = "Strongly Agree" or response = "Agree" THEN 1 ELSE 0 END AS saacount,

CASE
WHEN response = "Strongly Agree"  THEN 1 ELSE 0 END AS saonlycount, 

CASE
WHEN response = "Agree"  THEN 1 ELSE 0 END AS agreeonlycount


FROM {{ref("surveylvl")}}),

countpct AS (SELECT  system, new_system, school_year_c, survey_collection, survey_type, date_c,primary_facilitator, secondary_facilitator, tertiary_facilitator, quaternary_facilitator, question,  SUM(saacount) AS stronglyagree_andagree, SUM(saonlycount) AS strongly_agree, SUM(agreeonlycount) AS agree, COUNT(response) AS num_of_responses
FROM dummy GROUP BY 1,2,3,4,5,6,7,8,9,10,11


),

pct AS (SELECT system, new_system, school_year_c, survey_collection, survey_type, date_c,  primary_facilitator, secondary_facilitator, tertiary_facilitator, quaternary_facilitator, question, num_of_responses, stronglyagree_andagree/num_of_responses AS pct_sa_a, strongly_agree/num_of_responses AS pct_sa_only, agree/num_of_responses AS pct_agree_only FROM countpct)


SELECT * FROM pct