create database Green_Technology;

select * from industries_1;
select * from industries_2;
select * from somabay_1;
select * from somabay_2;
select * from gasstation_2;
select * from gasstation_1;

set sql_safe_updates=0;
Update gasstation_2 set `ROI %`= '14%' where proj_Id = 'AT_1';
Update gasstation_2 set `ROI %`= '13%' where proj_Id = 'ELK_1';
Update gasstation_2 set `ROI %`= '14%' where proj_Id = 'ELB_1';
Update gasstation_2 set `ROI %`= '15%' where proj_Id = 'ELS_1';
Update gasstation_2 set `ROI %`= '14%' where proj_Id = 'KOMB_1';
Update gasstation_2 set `ROI %`= '13%' where proj_Id = 'SN_1';
-- Cleaning Gasstation2 Data (Payback Period)
Update gasstation_2 set `Payback Period`= '6.8' where proj_Id = 'AT_1';
Update gasstation_2 set `Payback Period`= '7.6' where proj_Id = 'ELK_1';
Update gasstation_2 set `Payback Period`= '6.75' where proj_Id = 'ELB_1';
Update gasstation_2 set `Payback Period`= '6.5' where proj_Id = 'ELS_1';
Update gasstation_2 set `Payback Period`= '7.35' where proj_Id = 'KOMB_1';
Update gasstation_2 set `Payback Period`= '7.7' where proj_Id = 'SN_1';
-- Cleaning Industries2 Data (Paybach Period)
Update industries_2 set `Payback Period`= '5.2' where proj_Id = 'DF11';
Update industries_2 set `Payback Period`= '5' where proj_Id = 'DF12';
Update industries_2 set `Payback Period`= '4.9' where proj_Id = 'DF18';
Update industries_2 set `Payback Period`= '5.2' where proj_Id = 'DF20';
Update industries_2 set `Payback Period`= '5.25' where proj_Id = 'ASF1';
Update industries_2 set `Payback Period`= '5.5' where proj_Id = 'ASF2';
-- Cleaning Somabay2 Data (Payback Period)
Update somabay_2  set `paybac period` = '4.9'  where `project id` = 'SMP 1';
set sql_safe_updates=1;


ALTER TABLE `indsutries data_python.1` RENAME TO industries_1;
ALTER TABLE  `indsutries data_python.2` RENAME TO industries_2;
ALTER TABLE `somabay_python.1` RENAME TO somabay_1;
ALTER TABLE `somabay_python.2` RENAME TO somabay_2;
ALTER TABLE `gas station_python.2` RENAME TO gasstation_2;
ALTER TABLE `gas station_python.1` RENAME TO gasstation_1;

#q1.A which industrial project have the short payback period
select `Project name`,`Payback Period`
from industries_2
order by `Payback Period`
limit 1; 
#q1.B which gasstation project have the short payback period
select `Project name`,`Payback Period`
from gasstation_2
order by `Payback Period`
limit 1; 


#q2 How does the Return on Investment (ROI) for solar projects vary across industries, somabay and gas station
SELECT 
    Industry,
    COUNT(*) AS Project_Count,  -- Number of projects per industry
    round(AVG(ROI),2) AS Avg_ROI      -- Average ROI
   
FROM (
    SELECT 'Industries' AS Industry,`ROI %` AS ROI FROM industries_2
    UNION ALL
    SELECT 'Somabay' AS Industry, `ROI %` AS ROI FROM somabay_2
    Union All
    select 'Gas Station' as Industry, `ROI(%)`  as ROI from gasstation_2
    #select 'Gas Station' as Industry, ROI_Percent as ROI from gasstation_1
) AS CombinedData
GROUP BY Industry
ORDER BY Avg_ROI DESC;



#Q3: What is the correlation between performance ratio (%) and self-sufficiency levels across projects?
SELECT 
    i1.proj_Id, 
    MAX(i2.`performance ratio%`) AS Performance_Ratio,  -- Use MAX() to avoid error
    round(AVG(i1.Produced_from_Solar_MWh), 3) as Avg_Energy,
    round(AVG(i1.Self_Suff_Percent), 3) AS Avg_Self_Sufficiency
FROM industries_1 i1
JOIN industries_2 i2 ON i1.proj_Id = i2.proj_Id
GROUP BY i1.proj_Id;

#Q4: How much CO₂ emissions have been reduced due to renewable energy adoption in different sectors? 
#INDUSTRY: 
SELECT 
    'Dina Farms' AS sector,
    ROUND(SUM(d.CO2_Reduction_tons),2) AS total_co2_reduced,
    ROUND(SUM(d.CO2_Reduction_tons) / COUNT(DISTINCT p.proj_Id), 1) AS avg_avoided_tons_per_project
FROM 
    industries_1 d
JOIN 
    industries_2 p ON d.proj_Id = p.proj_Id
WHERE 
    p.`Project name` LIKE '%Feeder%'

UNION ALL

SELECT 
    'ASCOM Facilities' AS sector,
    ROUND(SUM(d.CO2_Reduction_tons),2),
    ROUND(SUM(d.CO2_Reduction_tons) / COUNT(DISTINCT p.proj_Id), 1)
FROM 
    industries_1 d
JOIN 
    industries_2 p ON d.proj_Id = p.proj_Id
WHERE 
    p.`Project name` LIKE '%Ascom%'

UNION ALL

-- GAS STATION (using the exact column name you provided)
SELECT 
    'Gas Stations' AS sector,
    ROUND(SUM(`CO? Reduction (Ton)`),2),
    ROUND(SUM(`CO? Reduction (Ton)`) / COUNT(DISTINCT proj_Id), 1)
FROM 
    gasstation_1

UNION ALL

-- SOMABAY
SELECT 
    'Resort' AS sector,
    ROUND(SUM(CO2_Reduction_tons),2),
    SUM(CO2_Reduction_tons) AS avg_avoided_tons_per_project
FROM 
    somabay_1
ORDER BY 
    total_co2_reduced DESC;

#Q5: Which gas station project had the highest average 'Energy to Grid' (MWh) per year over the 25-year period?    
    SELECT 
    g2.`Project Name`,
   round(AVG(g1.`Energy To Grid (MWh)`),2) as Avg_Energy_to_grid_MWH
FROM gasstation_1 g1
JOIN gasstation_2 g2 ON g2.proj_Id = g1.proj_Id
GROUP BY g2.`Project Name`, g2.proj_Id
ORDER BY Avg_Energy_to_grid_MWH DESC;

#Q6 A: Which project (between industries& Somabay ) had the highest cumulative cost savings by the end of the 25-year period?
SELECT 
'industries' AS sector,
    proj_Id,
    round(MAX(Cumulative_NSs_EGP),2) AS Net_saving
FROM 
  industries_1
WHERE 
    Year = 25
    GROUP BY 
    proj_Id
    
    UNION ALL

SELECT 
    'Somabay' AS sector,
    proj_Id,
   round( Max(Cumulative_NSs_EGP),2) AS Net_saving
FROM 
    somabay_1
GROUP BY 
    proj_Id

ORDER BY 
    Net_saving DESC;


#Q6 B: the highest cumulative cost savings by the end of the 25-year period? (Gasstaion)
SELECT 
    proj_Id,
    MAX(Cumulative_NSs_EGP) AS Net_saving
FROM 
 gasstation_1
WHERE 
    `Assessment Year` = 25
GROUP BY 
    proj_Id
ORDER BY 
    Net_saving DESC;
