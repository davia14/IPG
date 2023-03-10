WITH ca1_combined AS (
SELECT name, COALESCE(ca_1_a_c, CAST(ca_1_a_num_c AS string), ca_1_a_pl_c, ca_1_a_program_c) AS ca_1 from ip-ipg-data.salesforce.walkthrough_c
),

dummy AS (
    SELECT name,
    
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
        SELECT name,
        COUNT(name) AS num_walkthroughs,
        SUM(ca1_pi_count) AS num_pi
        FROM dummy
        WHERE ca1_pi_count IS NOT NULL
        GROUP BY 1
 ),
walkthrough_lvl AS (
        SELECT name,
        num_pi/num_walkthroughs*100 AS ca1_ppi
        FROM grouped 
 ),

school_codes AS (
    SELECT name, school_c FROM ip-ipg-data.salesforce.walkthrough_c
),

 school_lvl AS (
     SELECT name, 
     round(AVG(ca1_ppi), 0) AS ca1_percentpi FROM walkthrough_lvl
     GROUP BY 1
 ),

 ca1_ppi_final AS (
     SELECT * from school_lvl 
     JOIN school_codes using (name)
 )

 SELECT * FROM school_lvl






  