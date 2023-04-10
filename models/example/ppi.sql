WITH ca1_combined AS (
SELECT name, subject_c, COALESCE(ca_1_a_c, CAST(ca_1_a_num_c AS string), ca_1_a_pl_c, ca_1_a_program_c) AS ca_1 from ip-ipg-data.salesforce.walkthrough_c
),

dummy AS (
    SELECT name, subject_c,
    
    CASE CAST(ca_1 as STRING)
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
    SELECT name, school_c FROM ip-ipg-data.salesforce.walkthrough_c
),

walkthrough_lvl AS (
        SELECT name, school_c, subject_c,
        num_pi/num_walkthroughs AS ca1_ppi
        FROM grouped 
        JOIN school_codes using (name)
        
 ), 

  school_lvl AS (
     SELECT school_c, subject_c,
     round(AVG(ca1_ppi), 2) AS ca1_percentpi FROM walkthrough_lvl
     GROUP BY 1,2
 )




 SELECT * FROM school_lvl




  