SELECT system, school, school_year, subject, season, AVG(standard_alignment) AS standard_alignment,AVG(mastery) AS mastery, AVG(CA_1A) AS CA_1A, AVG(CA_1B) AS CA_1B, AVG(CA_1C) AS CA_1C, AVG(CA_1D) AS CA_1D, 
AVG(CA_2A) AS CA_2A, AVG(CA_2B) AS CA_2B, AVG(CA_2C) AS CA_2C, AVG(CA_2D) AS CA_2D, AVG(CA_2E) AS CA_2E, AVG(CA_2F) AS CA_2F, AVG(CA_3A) AS CA_3A, AVG(CA_3B) AS CA_3B, AVG(CA_3C) AS CA_3C, AVG(CA_3D) AS CA_3D, AVG(CA_3E) AS CA_3E, 
AVG(CA_1_PPI) AS CA_1_PPI, AVG(CA_2_PPI) AS CA_2_PPI, AVG(CA_3_PPI) AS CA_3_PPI, AVG(total_PPI) AS total_PPI FROM ip-ipg-data.ipg_transformations.walkthroughcollectionlvl GROUP BY 1,2,3,4,5