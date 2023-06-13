WITH surveysraw AS (
SELECT system_year_engagement_c, survey_collection_c, name, cfg_school_c, submitter_first_name_c, submitter_last_name_c, submitters_email_c, cfg_role_c, better_understanding_of_ipg_c, cfg_i_learned_something_c, cfg_valuable_use_of_my_time_c, clarity_direction_of_work_ahead_c, clear_about_change_we_seek_c, clear_about_roles_and_responsibilities_c, confidence_ability_support_instruction_c, confident_plan_will_achieve_goals_c, confident_plc_leads_to_learning_c, equipped_and_supported_c, feel_more_equipped_c, logistics_were_smooth_c, meeting_helped_make_decisions_c, objectives_were_met_c, plan_effectively_implemented_c, practice_will_improve_based_on_coaching_c, understand_state_of_instruction_c, cfg_1_2_impactful_moments_c, cfg_what_could_have_been_better_c
FROM ip-ipg-data.salesforce.survey_c), 

rawpivot AS (SELECT * FROM surveysraw UNPIVOT(response FOR question IN (better_understanding_of_ipg_c, cfg_i_learned_something_c, cfg_valuable_use_of_my_time_c, clarity_direction_of_work_ahead_c, clear_about_change_we_seek_c, clear_about_roles_and_responsibilities_c, confidence_ability_support_instruction_c, confident_plan_will_achieve_goals_c, confident_plc_leads_to_learning_c, equipped_and_supported_c, feel_more_equipped_c, logistics_were_smooth_c, meeting_helped_make_decisions_c, objectives_were_met_c, plan_effectively_implemented_c, practice_will_improve_based_on_coaching_c, understand_state_of_instruction_c))), 


joined AS (select col.name AS survey_collection, col.type_c, col.school_year_c, col.date_c, surv.system_year_engagement_c, surv.cfg_school_c,submitter_first_name_c, submitter_last_name_c, submitters_email_c, surv.question, surv.response, col.primary_facilitator_c, col.secondary_facilitator_c, col.tertiary_facilitator_c, col.quaternary_facilitator_c
FROM rawpivot AS surv JOIN ip-ipg-data.salesforce.survey_collection_c AS col on surv.survey_collection_c = col.id), 

cleantype AS (SELECT survey_collection, school_year_c, date_c, system_year_engagement_c, cfg_school_c, submitter_first_name_c, submitter_last_name_c, submitters_email_c, question, response, primary_facilitator_c, secondary_facilitator_c, tertiary_facilitator_c, quaternary_facilitator_c, 

CASE 
WHEN type_c = "Virtual Planning" THEN "Action Planning"
WHEN type_c = "IPG Norming" THEN "Walkthrough and Debrief" 
WHEN type_c = "Virtual Instructional Diagnosis" THEN "Walkthrough and Debrief"
WHEN type_c = "Virtual Training" THEN "Professional Development"
WHEN type_c = "Virtual Leader Coaching" THEN "Leader Coaching"
WHEN type_c = "Virtual PLC Support" THEN "PLC Support" 
WHEN type_c = "Virtual Progress Monitoring" THEN "Progress Monitoring"
WHEN type_c = "Virtual Teacher Coaching" THEN "Teacher Coaching"
WHEN type_c = "Walkthrough" THEN "Walkthrough and Debrief"
ELSE type_c END AS survey_type 
FROM joined), 

primary AS (select distinct survey_collection, u.name AS primary_facilitator FROM cleantype JOIN ip-ipg-data.salesforce.user AS u ON cleantype.primary_facilitator_c = u.id), 


secondary AS (select distinct survey_collection, u.name AS secondary_facilitator FROM cleantype JOIN ip-ipg-data.salesforce.user AS u ON cleantype.secondary_facilitator_c = u.id), 


tertiary AS (select distinct survey_collection, u.name AS tertiary_facilitator FROM cleantype JOIN ip-ipg-data.salesforce.user AS u ON cleantype.tertiary_facilitator_c = u.id), 


quaternary AS (select distinct survey_collection, u.name AS quaternary_facilitator FROM cleantype JOIN ip-ipg-data.salesforce.user AS u ON cleantype.quaternary_facilitator_c = u.id), 

facilitators AS (select primary.survey_collection, primary_facilitator, secondary_facilitator, tertiary_facilitator, quaternary_facilitator 

FROM primary LEFT OUTER JOIN secondary using (survey_collection) LEFT OUTER JOIN tertiary using (survey_collection) LEFT OUTER JOIN quaternary USING (survey_collection)),

survwfacilitators AS (SELECT cleantype.survey_collection, school_year_c, survey_type, date_c, system_year_engagement_c, cfg_school_c, submitter_first_name_c, submitter_last_name_c, submitters_email_c, question, response, primary_facilitator, secondary_facilitator, tertiary_facilitator, quaternary_facilitator
FROM cleantype JOIN facilitators using (survey_collection)),

finaltable AS (SELECT survey_collection, survey_type, date_c, f.school_year_c, left(school.name, length(school.name)-16) AS school, left(sys.name, length(sys.name)-16) AS system, submitter_first_name_c, submitter_last_name_c, submitters_email_c, question, response, primary_facilitator, secondary_facilitator, tertiary_facilitator, quaternary_facilitator 
FROM survwfacilitators AS f JOIN ip-ipg-data.salesforce.system_year_engagement_c AS sys ON f.system_year_engagement_c = sys.id JOIN ip-ipg-data.salesforce.school_year_engagement_c AS school on f.cfg_school_c = school.school_c AND f.school_year_c = school.school_year_c),

uniquesys AS (
SELECT DISTINCT School, New_System FROM ip-ipg-data.dimension_table.pmdim), 

newsys AS (SELECT surv.*, dim.New_System AS new_system FROM finaltable AS surv LEFT OUTER JOIN uniquesys AS dim on surv.school = dim.School),
cleansys AS (SELECT survey_collection, survey_type, date_c, school_year_c, school, system, 
CASE 
WHEN new_system IS NULL THEN system ELSE new_system END AS new_system, submitter_first_name_c, submitter_last_name_c, submitters_email_c,
question, response, primary_facilitator, secondary_facilitator, tertiary_facilitator, quaternary_facilitator 
FROM newsys)


SELECT * FROM cleansys
