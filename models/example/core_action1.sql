
WITH ca1_combined AS (
SELECT name, subject_c, created_date, visit_c, ca_1_d_c AS ca_1d, COALESCE(CAST(ca_1_c_num_c AS string), ca_1_c_pl_c) AS ca_1c, COALESCE(CAST(ca_1_b_c AS string), ca_1_b_pl_c) AS ca_1b, COALESCE(ca_1_a_c, CAST(ca_1_a_num_c AS string), ca_1_a_pl_c) AS ca_1a from ip-ipg-data.salesforce.walkthrough_c
),

dummy AS (
    SELECT name, subject_c, created_date, visit_c,
    
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
    AS ca_1a_pi_count,

CASE CAST(ca_1b as STRING)
    WHEN NULL THEN NULL
    WHEN "Yes" THEN 1
    WHEN "No" THEN 0
    WHEN "No, but appropriate" THEN 1
    WHEN "3" THEN 1
    WHEN "4" THEN 1
    WHEN "1" THEN 0
    WHEN "2" THEN 0
    ELSE NULL END 
    AS ca_1b_pi_count,


CASE CAST(ca_1c as STRING)
    WHEN NULL THEN NULL
    WHEN "Yes" THEN 1
    WHEN "No" THEN 0
    WHEN "No, but appropriate" THEN 1
    WHEN "3" THEN 1
    WHEN "4" THEN 1
    WHEN "1" THEN 0
    WHEN "2" THEN 0
    ELSE NULL END 
    AS ca_1c_pi_count,
    
    ca_1d

    FROM ca1_combined),

    dummy_ELA AS (

    SELECT name, subject_c, created_date, visit_c, ca_1d,

    CASE

    WHEN subject_c = "ELA" AND created_date < '2022-08-01' THEN ca_1b_pi_count 
    ELSE ca_1a_pi_count END
    AS ca_1a_pi_count,

     CASE 

    WHEN subject_c = "ELA" AND created_date < '2022-08-01' THEN ca_1a_pi_count 
    ELSE ca_1b_pi_count END
    AS ca_1b_pi_count,

    CASE 
    WHEN subject_c = "ELA" AND created_date < '2018-08-01' THEN NULL
    ELSE ca_1c_pi_count END 
    AS ca_1c_pi_count,

    CASE 
    WHEN ca_1a_pi_count IS NOT NULL THEN 1 ELSE 0 END +

    CASE 
    WHEN ca_1b_pi_count IS NOT NULL THEN 1 ELSE 0 END + 

    CASE 
    WHEN ca_1c_pi_count IS NOT NULL AND subject_c = "Math" THEN 1 ELSE 0 END

    AS ca1_scored_ind,

    CASE
    WHEN subject_c = "ELA" THEN ca_1a_pi_count + ca_1b_pi_count ELSE 
    ca_1a_pi_count + ca_1b_pi_count + ca_1c_pi_count END 

    AS ca1_pos_ind
    
    FROM dummy),

    ca1_ppi_table AS (

        select name, subject_c, created_date, visit_c, ca_1a_pi_count, ca_1b_pi_count, ca_1c_pi_count, ca_1d, ca1_pos_ind, ca1_scored_ind, ca1_pos_ind/ca1_scored_ind AS ca_1_ppi

        FROM dummy_ELA
    )

 

    select visit_c, subject_c, AVG(ca_1a_pi_count) AS AVG_CA_1A, AVG(ca_1b_pi_count) AS AVG_CA_1B, AVG(ca_1c_pi_count) AS AVG_CA_1C, AVG(ca_1d) AS AVG_CA_1D, AVG(ca_1_ppi) AS AVG_CA1_PPI from ca1_ppi_table WHERE created_date < '2022-08-01' AND (subject_c = "ELA" OR subject_c="Math") GROUP BY visit_c, subject_c 
 




  
