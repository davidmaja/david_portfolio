SELECT * 
FROM World_Life_Expectancy.worldlifeexpectancy;

-- Initial data cleaning

-- Looking to identify if there are any duplicates in the data

-- Combining country and year together to create a unique identifier 

SELECT Country, YEAR, CONCAT(Country, YEAR), COUNT(CONCAT(Country, Year))
FROM World_Life_Expectancy.worldlifeexpectancy
GROUP BY Country, Year, CONCAT(Country, Year)
Having COUNT(CONCAT(Country, Year)) > 1;


	SELECT *
FROM (
	SELECT Row_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT (Country, Year)) AS Row_Num
	FROM  World_Life_Expectancy.worldlifeexpectancy
	) AS Row_table
    WHERE Row_Num > 1
    ;
    
-- Inner query aim is to give each row a number based on the unique identifier (country, year), causing the duplicate rows to no longer be unqiue 
-- Outer query is to filter to only the duplicates



DELETE FROM World_Life_Expectancy.worldlifeexpectancy
WHERE
	Row_ID IN (
    SELECT Row_ID
FROM (
	SELECT Row_ID,
	CONCAT(Country, Year),	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT (Country, Year)) AS Row_Num
	FROM  World_Life_Expectancy.worldlifeexpectancy
	) AS Row_table
    WHERE Row_Num > 1
    )
    ;
    
-- Noticed missing values in the status column 
    
SELECT * 
FROM World_Life_Expectancy.worldlifeexpectancy
WHERE Status = ''
;



SELECT DISTINCT (status) 
FROM World_Life_Expectancy.worldlifeexpectancy
WHERE Status <> ''
;
-- Checking the possible outputs that the status can be populated with
    
    
SELECT DISTINCT (Country) 
FROM World_Life_Expectancy.worldlifeexpectancy
WHERE Status = 'Developing';
    
    
    
UPDATE World_Life_Expectancy.worldlifeexpectancy w1
JOIN World_Life_Expectancy.worldlifeexpectancy w2
    ON w1.Country = w2.Country
SET w1.Status = 'Developing' 
WHERE w1.Status = ''
AND w2.Status <> ''
AND w2.Status = 'Developing'
;
    
-- Updating the table and setting the status = developing to relevant countries present in the output (line 60)



SELECT * 
FROM World_Life_Expectancy.worldlifeexpectancy
WHERE Status = ''
;


UPDATE World_Life_Expectancy.worldlifeexpectancy w1
JOIN World_Life_Expectancy.worldlifeexpectancy w2
    ON w1.Country = w2.Country
SET w1.Status = 'Developed' 
WHERE w1.Status = ''
AND w2.Status <> ''
AND w2.Status = 'Developed'
;

-- Updating the table and setting the status = developed to relevant countries present in the output 



SELECT * 
FROM  World_Life_Expectancy.worldlifeexpectancy;

-- Noticed missing values in life expentency 


SELECT *
FROM World_Life_Expectancy.worldlifeexpectancy
WHERE `Life expectancy` = ''
;



SELECT w1.Country, w1.Year, w1.`Life expectancy`, 
w2.Country, w2.Year, w2.`Life expectancy`, 
w3.Country, w3.Year, w3.`Life expectancy`,  
ROUND((w2.`Life expectancy` + w3.`Life expectancy`)/2,1)	
FROM World_Life_Expectancy.worldlifeexpectancy w1
JOIN World_Life_Expectancy.worldlifeexpectancy w2
	ON w1.Country = w2.Country
    AND w1.Year = w2.Year - 1
JOIN World_Life_Expectancy.worldlifeexpectancy w3
	ON w1.Country = w3.Country
    AND w1.Year = w3 .Year + 1
    WHERE w1.`Life expectancy` = ''
    ;
    
-- Based on the data made the decision to fill in the missing life expectancy data with the average based on the year before and the year after 9 (Line 114)

UPDATE World_Life_Expectancy.worldlifeexpectancy w1
JOIN World_Life_Expectancy.worldlifeexpectancy w2
	ON w1.Country = w2.Country
    AND w1.Year = w2.Year - 1
JOIN World_Life_Expectancy.worldlifeexpectancy w3
	ON w1.Country = w3.Country
    AND w1.Year = w3 .Year + 1
SET w1.`Life expectancy` = ROUND((w2.`Life expectancy` + w3.`Life expectancy`)/2,1)
WHERE w1.`Life expectancy` = ''
;


-- Starting to explore the data 

SELECT Country, 
MIN(`Life expectancy`) AS Min, 
MAX(`Life expectancy`) AS Max, 
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),2) AS Life_increase_15_years
FROM World_Life_Expectancy.worldlifeexpectancy
GROUP BY Country
ORDER BY Country DESC
;

SELECT Country, 
MIN(`Life expectancy`) AS Min, 
MAX(`Life expectancy`) AS Max, 
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),2) AS Life_increase_15_years
FROM World_Life_Expectancy.worldlifeexpectancy
GROUP BY Country
ORDER BY Country ASC
;


SELECT Country, 
MIN(`Life expectancy`) AS Min, 
MAX(`Life expectancy`) AS Max, 
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),2) AS Life_increase_15_years
FROM World_Life_Expectancy.worldlifeexpectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Country DESC
;

-- Noticed 0's in the data filtering hem out 


SELECT YEAR, ROUND(AVG(`Life expectancy`),2)
FROM World_Life_Expectancy.worldlifeexpectancy
WHERE `Life expectancy` <> 0
GROUP BY YEAR 
ORDER BY YEAR
; 

SELECT Country,ROUND(AVG(`Life expectancy`),2) As Life_Exp, ROUND(AVG(GDP),2) AS GDP
FROM World_Life_Expectancy.worldlifeexpectancy
GROUP BY Country
;

SELECT Country,ROUND(AVG(`Life expectancy`),2) As Life_Exp, ROUND(AVG(GDP),2) AS GDP
FROM World_Life_Expectancy.worldlifeexpectancy
GROUP BY Country
ORDER BY Life_Exp
;

-- Noticing 0's in the data ordering lowest to highest to take a closer look at the 0's
-- Noticed mainly small counties with zero (thought they may have just not provided the data)

SELECT Country,ROUND(AVG(`Life expectancy`),2) As Life_Exp, ROUND(AVG(GDP),2) AS GDP
FROM World_Life_Expectancy.worldlifeexpectancy
GROUP BY Country
Having Life_Exp > 0
AND GDP > 0
ORDER BY GDP
;


SELECT Country,ROUND(AVG(`Life expectancy`),2) As Life_Exp, ROUND(AVG(GDP),2) AS GDP
FROM World_Life_Expectancy.worldlifeexpectancy
GROUP BY Country
Having Life_Exp > 0
AND GDP > 0
ORDER BY GDP DESC
;

-- Thoughts based on data: Lower GDP is corrolated with a lower life expentancy. Higher GDP is corrolated with higher life expectancy

SELECT
SUM(CASE
	WHEN GDP >= 1500 THEN 1
	ELSE 0 
END) HIGH_GDP_Count,
AVG(CASE
	WHEN GDP >= 1500 THEN `Life expectancy`
	ELSE NULL
END) HIGH_GDP_life_expectancy,
SUM(CASE
	WHEN GDP <= 1500 THEN 1
	ELSE 0 
END) Low_GDP_Count,
AVG(CASE
	WHEN GDP <= 1500 THEN `Life expectancy`
	ELSE NULL
END) Low_GDP_life_expectancy
FROM World_Life_Expectancy.worldlifeexpectancy
;

-- Low GDP countries have a 10 year lower life expectancy than high GDP countries 

SELECT Status, ROUND(AVG(`Life expectancy`),1)
FROM World_Life_Expectancy.worldlifeexpectancy
GROUP BY Status
;

SELECT Status, COUNT(DISTINCT Country)
FROM World_Life_Expectancy.worldlifeexpectancy
GROUP BY Status
;


SELECT Country,ROUND(AVG(`Life expectancy`),2) As Life_Exp, ROUND(AVG(BMI),2) AS BMI
FROM World_Life_Expectancy.worldlifeexpectancy
GROUP BY Country
Having Life_Exp > 0
AND BMI > 0
ORDER BY BMI DESC
;

SELECT Country,ROUND(AVG(`Life expectancy`),2) As Life_Exp, ROUND(AVG(BMI),2) AS BMI
FROM World_Life_Expectancy.worldlifeexpectancy
GROUP BY Country
Having Life_Exp > 0
AND BMI > 0
ORDER BY BMI 
;

SELECT Country,ROUND(AVG(GDP),2) As GDP, ROUND(AVG(BMI),2) AS BMI
FROM World_Life_Expectancy.worldlifeexpectancy
GROUP BY Country
Having GDP > 0
AND BMI > 0
ORDER BY GDP 
;

SELECT Country,ROUND(AVG(GDP),2) As GDP, ROUND(AVG(BMI),2) AS BMI
FROM World_Life_Expectancy.worldlifeexpectancy
GROUP BY Country
Having GDP > 0
AND BMI > 0
ORDER BY GDP DESC 
;

-- Thoughts based on data: Lower BMI, lower life expectancy, lower gdp are all corrolated to one another
-- Interpretation: Countries with a lower GDP are unable to provide enough resources, directly resulting in both a low BMI and a lower Life expectancy


SELECT Country,
Year, 
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) 	OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM World_Life_Expectancy.worldlifeexpectancy
;