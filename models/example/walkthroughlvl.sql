WITH ca1_combined AS (
SELECT name, subject_c, visit_c, ca_1_d_c AS ca_1d, COALESCE(CAST(ca_1_c_num_c AS string), ca_1_c_pl_c) AS ca_1c, COALESCE(CAST(ca_1_b_c AS string), ca_1_b_pl_c) AS ca_1b, COALESCE(ca_1_a_c, CAST(ca_1_a_num_c AS string), ca_1_a_pl_c) AS ca_1a from ip-ipg-data.salesforce.walkthrough_c
),

dummy AS (
    SELECT walk.name, subject_c, visit_c, visit_type_c, date_c, system_c, school_c,
    
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
    AS ca_1a_binary,

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
    AS ca_1b_binary,


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
    AS ca_1c_binary,
    
    ca_1d

    FROM ca1_combined AS walk join ip-ipg-data.salesforce.visit_c as visit on walk.visit_c = visit.id),

    dummy_ELA AS (

    SELECT name, subject_c, date_c, visit_c, visit_type_c, system_c, school_c, ca_1d,

    CASE

    WHEN subject_c = "ELA" AND date_c < '2022-08-01' THEN ca_1b_binary 
    ELSE ca_1a_binary END
    AS ca_1a_binary,

     CASE 

    WHEN subject_c = "ELA" AND date_c < '2022-08-01' THEN ca_1a_binary 
    ELSE ca_1b_binary END
    AS ca_1b_binary,

    CASE 
    WHEN subject_c = "ELA" AND date_c < '2018-08-01' THEN NULL
    ELSE ca_1c_binary END 
    AS ca_1c_binary,

    CASE 
    WHEN ca_1a_binary IS NOT NULL THEN 1 ELSE 0 END +

    CASE 
    WHEN ca_1b_binary IS NOT NULL THEN 1 ELSE 0 END + 

    CASE 
    WHEN ca_1c_binary IS NOT NULL AND subject_c = "Math" THEN 1 ELSE 0 END

    AS ca1ppi_scored_ind,

    
    CASE 
    WHEN ca_1a_binary IS NOT NULL THEN 1 ELSE 0 END +

    CASE 
    WHEN ca_1b_binary IS NOT NULL THEN 1 ELSE 0 END + 

    CASE 
    WHEN ca_1c_binary IS NOT NULL THEN 1 ELSE 0 END +

    CASE 
    WHEN ca_1d IS NOT NULL THEN 1 ELSE 0 END

    AS ca1ALL_scored_ind,

    CASE
    WHEN subject_c = "ELA" THEN 
        CASE  WHEN ca_1a_binary =1 THEN 1 ELSE 0 END + 
        CASE WHEN ca_1b_binary = 1 THEN 1 ELSE 0 END
     ELSE 
        CASE WHEN ca_1a_binary = 1 THEN 1 ELSE 0 END +
        CASE WHEN  ca_1b_binary = 1 THEN 1 ELSE 0 END  +
        CASE WHEN  ca_1c_binary = 1 THEN 1 ELSE 0 END
    END
    AS ca1ppi_pos_ind,

 CASE
    WHEN ca_1d = 3 OR ca_1d = 4 THEN 1 ELSE 0 END + 
    
    CASE
    WHEN ca_1a_binary =1 THEN 1 ELSE 0 END + 
    
    CASE WHEN ca_1b_binary=1 THEN 1 ELSE 0 END + 
    
    CASE WHEN ca_1c_binary =1 THEN 1 ELSE 0 END AS ca1ALL_pos_ind,
    
    FROM dummy),

ca1_ppi_table AS (

        select name, subject_c, date_c, visit_c, visit_type_c, system_c, school_c, ca_1a_binary, ca_1b_binary, ca_1c_binary, CAST(ca_1d AS float64) AS ca_1d, ca1ppi_pos_ind, ca1ppi_scored_ind, 
        
        CASE WHEN ca1ppi_scored_ind = 0 OR ca1ppi_scored_ind IS NULL THEN NULL ELSE ca1ppi_pos_ind/ca1ppi_scored_ind END AS ca_1_ppi, 
        
        ca1ALL_pos_ind, ca1ALL_scored_ind

        FROM dummy_ELA
    ),

 ca2and3 AS (
select walk.name, subject_c, visit_c, date_c, system_c, walk.school_c, mastery_c, standard_alignment_c, ca_2_a_c, ca_2_b_c, ca_2_c_c, ca_2_d_c, ca_2_e_c, ca_2_f_c, ca_3_a_c, ca_3_b_c, ca_3_c_c, ca_3_d_c, ca_3_e_c from ip-ipg-data.salesforce.walkthrough_c AS walk
JOIN ip-ipg-data.salesforce.visit_c as visit on walk.visit_c = visit.id), 

ca23swap AS (

select name, subject_c, visit_c, date_c, system_c, school_c, mastery_c, standard_alignment_c, ca_2_a_c, ca_2_b_c, ca_2_c_c, ca_2_d_c, ca_2_f_c, ca_3_a_c, ca_3_b_c, ca_3_c_c, ca_3_d_c,

CASE 

WHEN subject_c = "ELA" AND date_c < '2021-08-01'
THEN ca_3_e_c ELSE ca_2_e_c END AS ca_2_e_c, 

CASE 

WHEN subject_c = "ELA" AND date_c < '2021-08-01'
THEN NULL ELSE ca_3_e_c END AS ca_3_e_c

from ca2and3), 

ca23ppi AS (
select name, subject_c, visit_c, date_c, system_c, school_c, standard_alignment_c, mastery_c, ca_2_a_c, ca_2_b_c, ca_2_c_c, ca_2_d_c, ca_2_e_c, ca_2_f_c, ca_3_a_c, ca_3_b_c, ca_3_c_c, ca_3_d_c, ca_3_e_c,
CASE 
WHEN ca_2_a_c IS NOT NULL THEN 1 ELSE 0 END +

CASE 
WHEN ca_2_b_c IS NOT NULL THEN 1 ELSE 0 END +

CASE 
WHEN ca_2_c_c IS NOT NULL THEN 1 ELSE 0 END +

CASE 
WHEN ca_2_d_c IS NOT NULL THEN 1 ELSE 0 END +

CASE 
WHEN ca_2_e_c IS NOT NULL THEN 1 ELSE 0 END AS ca2scored, 

CASE 
WHEN ca_3_a_c IS NOT NULL THEN 1 ELSE 0 END +

CASE 
WHEN ca_3_b_c IS NOT NULL THEN 1  ELSE 0 END +

CASE 
WHEN ca_3_c_c IS NOT NULL THEN 1 ELSE 0 END +

CASE 
WHEN ca_3_d_c IS NOT NULL THEN 1 ELSE 0 END +

CASE 
WHEN ca_3_e_c IS NOT NULL THEN 1 ELSE 0 END AS ca3scored, 

CASE 
WHEN ca_2_a_c = 3 OR ca_2_a_c = 4 THEN 1 ELSE 0 END +

CASE 
WHEN ca_2_b_c = 3 OR ca_2_b_c = 4 THEN 1 ELSE 0 END +

CASE 
WHEN ca_2_c_c = 3 OR ca_2_c_c = 4 THEN 1 ELSE 0 END +

CASE 
WHEN ca_2_d_c = 3 or ca_2_d_c = 4 THEN 1 ELSE 0 END +

CASE 
WHEN ca_2_e_c=3 OR ca_2_e_c = 4 THEN 1 ELSE 0 END AS ca2pos, 

CASE 
WHEN ca_3_a_c = 3 OR ca_3_a_c = 4 THEN 1 ELSE 0 END +

CASE 
WHEN ca_3_b_c = 3 OR ca_3_b_c = 4 THEN 1 ELSE 0 END +

CASE 
WHEN ca_3_c_c = 3 OR ca_3_c_c = 4 THEN 1 ELSE 0 END +

CASE 
WHEN ca_3_d_c = 3 or ca_3_d_c = 4 THEN 1 ELSE 0 END +

CASE 
WHEN ca_3_e_c=3 OR ca_3_e_c = 4 THEN 1 ELSE 0 END AS ca3pos

FROM ca2and3
), 

ca23ppitable AS (select name, subject_c, visit_c, date_c, system_c, school_c, standard_alignment_c, mastery_c, ca_2_a_c, ca_2_b_c, ca_2_c_c, ca_2_d_c, ca_2_e_c, ca_2_f_c, ca_3_a_c, ca_3_b_c, ca_3_c_c, ca_3_d_c, ca_3_e_c, ca2scored, ca2pos, ca3scored, ca3pos,
CASE
WHEN ca2scored = 0 OR ca2scored IS NULL then NULL ELSE ca2pos/ca2scored END AS ca2ppi,
CASE
WHEN ca3scored = 0 OR ca3scored IS NULL then NULL ELSE ca3pos/ca3scored END AS ca3ppi
FROM ca23ppi
), 

allind AS (select ca1.name, ca1.subject_c, ca1.visit_c, visit_type_c, ca1.date_c, ca1.system_c, ca1.school_c, standard_alignment_c, mastery_c, ca_1a_binary, ca_1b_binary, ca_1c_binary, ca_1d, ca1ppi_scored_ind, ca1ppi_pos_ind, ca_2_a_c, ca_2_b_c, ca_2_c_c, ca_2_d_c, ca_2_e_c, ca_2_f_c, ca_3_a_c, ca_3_b_c, ca_3_c_c, ca_3_d_c, ca_3_e_c, ca2scored, ca2pos, ca3scored, ca3pos, ca2ppi, ca3ppi, 
CASE 
WHEN standard_alignment_c IS NOT NULL THEN 1 ELSE 0 END + 

CASE
WHEN mastery_c IS NOT NULL THEN 1 ELSE 0 END + 
ca1ALL_scored_ind+ca2scored+ca3scored AS totalscoredind,

CASE 
WHEN standard_alignment_c = 3 OR standard_alignment_c = 4 THEN 1 ELSE 0 END +

CASE WHEN mastery_c = 3 OR mastery_c = 4 THEN 1 ELSE 0 END +
 ca1ALL_pos_ind+ca2pos+ca3pos AS totalposind

FROM ca1_ppi_table AS ca1 JOIN ca23ppitable AS ca23 on ca1.name = ca23.name),


finaltable AS (select name, subject_c, visit_type_c, visit_c, date_c, system_c, school_c, ca_1a_binary, ca_1b_binary, ca_1c_binary, ca_1d, ca1ppi_scored_ind, ca1ppi_pos_ind, ca_2_a_c, ca_2_b_c, ca_2_c_c, ca_2_d_c, ca_2_e_c, ca_2_f_c, ca_3_a_c, ca_3_b_c, ca_3_c_c, ca_3_d_c, ca_3_e_c, ca2scored, ca2pos, ca3scored, ca3pos, ca2ppi, ca3ppi, totalscoredind, totalposind,
CASE
WHEN totalscoredind=0 OR totalscoredind IS NULL THEN NULL ELSE totalposind/totalscoredind END AS totalppi
FROM allind),

finalwithsye AS (select f.*, school.name AS school, sys.name AS system, sys.school_year_c AS schoolyear
FROM finaltable AS f JOIN ip-ipg-data.salesforce.school_year_engagement_c AS school ON f.school_c = school.school_c 
JOIN ip-ipg-data.salesforce.system_year_engagement_c AS sys ON f.system_c = sys.system_c)



SELECT system, school, schoolyear, name AS walkthroughname, subject_c AS subject, date_c AS date, visit_type_c, visit_c, ca_1a_binary, ca_1b_binary, ca_1c_binary, ca_1d, ca1ppi_scored_ind, ca1ppi_pos_ind, ca_2_a_c, ca_2_b_c, ca_2_c_c, ca_2_d_c, ca_2_e_c, ca_2_f_c, ca_3_a_c, ca_3_b_c, ca_3_c_c, ca_3_d_c, ca_3_e_c, ca2scored, ca2pos, ca3scored, ca3pos, ca2ppi, ca3ppi, totalscoredind, totalposind, totalppi  FROM finalwithsye WHERE (subject_c = "ELA" OR subject_c="Math" OR subject_c = "Science") AND (visit_type_c = "Formal" OR (visit_type_c IS NULL AND totalscoredind>=7))