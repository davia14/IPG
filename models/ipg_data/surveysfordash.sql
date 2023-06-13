WITH addnames AS (SELECT surv.*, dim.name AS staff_name, dim.cluster FROM ip-ipg-data.ipg_transformations.surveysystemlvlpivoted AS surv LEFT OUTER JOIN ip-ipg-data.dimension_table.pmdim AS dim ON surv.new_system = dim.New_System),

emails AS (SELECT addnames.*, e.email_for_access, e.category FROM addnames LEFT OUTER JOIN ip-ipg-data.dimension_table.email_list AS e ON addnames.staff_name = e.staff_member_),

withraw AS (SELECT emails.*, submitter_first_name_c, submitter_last_name_c, submitters_email_c, response FROM emails JOIN ip-ipg-data.ipg_transformations.surveylvl AS surv ON emails.new_system = surv.new_system 
AND emails.school_year=surv.school_year_c AND emails.survey_type = surv.survey_type, emails.question = surv.question)

SELECT * FROM withraw 