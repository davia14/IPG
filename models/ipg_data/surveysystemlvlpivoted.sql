WITH uniquesys AS (
SELECT DISTINCT School, New_System FROM ip-ipg-data.dimension_table.pmdim), 

newsys AS (SELECT surv.*, dim.New_System AS new_system FROM ip-ipg-data.ipg_transformations.surveycollectionlvl AS surv LEFT OUTER JOIN uniquesys AS dim on surv.school = dim.School),
cleansys AS (SELECT survey_collection, survey_type, date_c, school_year_c, school, system, 
CASE 
WHEN new_system IS NULL THEN system ELSE new_system END AS new_system, 
question, num_of_responses, pct_sa_only, pct_agree_only, pct_sa_a, primary_facilitator, secondary_facilitator, tertiary_facilitator, quaternary_facilitator 
FROM newsys), 

av AS (SELECT system, new_system, survey_type, school_year_c AS school_year, question, SUM(num_of_responses), AVG(pct_sa_only), AVG(pct_agree_only), AVG(pct_sa_a)
FROM cleansys GROUP BY 1,2,3,4,5)

select * FROM av