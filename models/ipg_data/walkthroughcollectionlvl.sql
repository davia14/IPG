with av AS (SELECT system, school, school_year, subject, date, visit_c, AVG(standard_alignment_c) AS standard_alignment,AVG(mastery_c) AS mastery, AVG(ca_1a_binary) AS CA_1A, AVG(ca_1b_binary) AS CA_1B, AVG(ca_1c_binary) AS CA_1C, AVG(ca_1d) AS CA_1D, 
AVG(ca_2_a_c) AS CA_2A, AVG(ca_2_b_c) AS CA_2B, AVG(ca_2_c_c) AS CA_2C, AVG(ca_2_d_c) AS CA_2D, AVG(ca_2_e_c) AS CA_2E, AVG(ca_2_f_c) AS CA_2F, AVG(ca_3_a_c) AS CA_3A, AVG(ca_3_b_c) AS CA_3B, AVG(ca_3_c_c) AS CA_3C, AVG(ca_3_d_c) AS CA_3D, AVG(ca_3_e_c) AS CA_3E, 
AVG(ca_1_ppi) AS CA_1_PPI, AVG(ca2ppi) AS CA_2_PPI, AVG(ca3ppi) AS CA_3_PPI, AVG(totalppi) AS total_PPI FROM {{ref('walkthroughlvl')}} GROUP BY 1,2,3,4,5,6), 

dates AS (SELECT system, school, school_year, subject, MIN(date) AS min, MAX(date) AS max FROM av GROUP BY 1,2,3,4),

withdate AS (SELECT av.*, min, max FROM av join dates ON av.system = dates.system AND av.school = dates.school AND av.school_year = dates.school_year AND av.subject = dates.subject),

season AS (SELECT *, 
CASE 
WHEN max <= min + 42 THEN
    CASE 
    WHEN EXTRACT(month FROM date) >= 8 AND EXTRACT(month FROM date) <11
    THEN "Fall"
    WHEN EXTRACT(month FROM date) >= 11 OR EXTRACT(month FROM date) < 3
    THEN "Winter"
    ELSE "Spring"
    END
WHEN date <= min + 42
THEN "Fall"
WHEN date >= max - 42
THEN "Spring"
ELSE "Winter"
END 
AS season

FROM withdate)

SELECT system, school, school_year, subject, date, season.season, visit_c, standard_alignment, mastery, CA_1A, CA_1B, CA_1C, CA_1D, CA_2A, CA_2B, CA_2C, CA_2D, CA_2E, CA_2F, CA_3A, CA_3B, CA_3C, CA_3D, CA_3E, CA_1_PPI, CA_2_PPI, CA_3_PPI, total_PPI
FROM season ORDER BY 1,2,3,4,6