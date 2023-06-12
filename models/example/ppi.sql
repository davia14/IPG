WITH ca1_combined AS (
SELECT name, subject_c, COALESCE(ca_1_a_c, CAST(ca_1_a_num_c AS string), ca_1_a_pl_c, ca_1_a_program_c) AS ca_1a, COALESCE(CAST(ca_1_b_c AS string), ca_1_b_pl_c) AS ca_1b, COALESCE(CAST(ca_1_c_num_c AS string), ca_1_c_pl_c) AS ca_1c, ca_1_d_c AS ca_id from ip-ipg-data.salesforce.walkthrough_c
),

dummy AS (
    SELECT name, subject_c,
    
    CASE CAST(ca_1a as STRING)
    WHEN NULL THEN NULL
    WHEN "Yes" THEN 1
    WHEN "No" THEN 0
    WHEN "No, but appropriate" THEN 1
    WHEN "3" THEN 1
    WHEN "4" THEN 1
    WHEN "1" THEN 0
    WHEN "2" THEN 0
    ELSE NULL END 
    AS ca1_pi_count
     FROM ca1_combined),

 grouped AS (
        SELECT name, subject_c,
        COUNT(name) AS num_walkthroughs,
        SUM(ca1_pi_count) AS num_pi
        FROM dummy
        WHERE ca1_pi_count IS NOT NULL
        GROUP BY 1,2
 ),


school_codes AS (
    SELECT walk.name, walk.school_c, school_year_engagement_c, system_c, visit_type_c FROM ip-ipg-data.salesforce.walkthrough_c AS walk
JOIN ip-ipg-data.salesforce.visit_c AS visit on walk.visit_c = visit.id ),

walkthrough_lvl AS (
        SELECT name, school_c, subject_c, school_year_engagement_c, system_c, 
        num_pi/num_walkthroughs AS ca1_ppi
        FROM grouped 
        JOIN school_codes using (name)
        
 ), 

  school_lvl AS (
     SELECT school_year_engagement_c, system_c, school_c, subject_c,
     round(AVG(ca1_ppi), 2) AS ca1_percentpi FROM walkthrough_lvl
     GROUP BY 1,2,3,4
 )




 SELECT * FROM school_codes




  