SELECT * 
FROM ushouseholdincome;

SELECT * 
FROM us_household_income_statistics;

SELECT COUNT(id)
FROM ushouseholdincome;

SELECT COUNT(id)
FROM us_household_income_statistics;	

-- Identifying if there are any duplicates

SELECT id, COUNT(id)
FROM US_housing_income.ushouseholdincome
GROUP BY id
HAVING COUNT(id) > 1
;

SELECT *
FROM (
SELECT row_id, id, ROW_NUMBER() OVER(PARTITION BY id ORDER BY ID) row_num
FROM US_housing_income.ushouseholdincome
) duplicates
WHERE row_num > 1
;

DELETE FROM US_housing_income.ushouseholdincome
WHERE row_id IN (
SELECT row_id
FROM (
SELECT row_id, id, ROW_NUMBER() OVER(PARTITION BY id ORDER BY ID) row_num
FROM US_housing_income.ushouseholdincome
) duplicates
WHERE row_num > 1);

-- Cleaning Data 

SELECT id, COUNT(id)
FROM us_household_income_statistics
GROUP BY id
HAVING COUNT(id) > 1
;

SELECT State_Name, COUNT(State_Name)
FROM ushouseholdincome
GROUP By State_Name
;


UPDATE ushouseholdincome
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';

UPDATE ushouseholdincome
SET State_Name = 'Alabama' 
WHERE State_Name = 'alabama'; 


SELECT * 
FROM ushouseholdincome
WHERE Place = ''
ORDER BY 1 ;


UPDATE ushouseholdincome
SET Place = 'Autaugaville' 
WHERE County = 'Autauga County'
AND City = 'Vinemont';

SELECT Type, COUNT(Type)
FROM ushouseholdincome
GROUP BY Type;

UPDATE ushouseholdincome
SET Type = 'Borough'
WHERE Type = 'Boroughs';

UPDATE ushouseholdincome
SET Type = 'CDP'
WHERE Type = 'CPD';


-- Exploring the data 


SELECT State_Name, SUM(ALand), SUM(AWater)
FROM ushouseholdincome
GROUP BY State_Name
ORDER BY 2 DESC;

SELECT u.State_Name, County, Type, `Primary`, Mean Median
FROM ushouseholdincome u
JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0;

SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM ushouseholdincome u
JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0 
GROUP BY u.State_Name
ORDER BY 2
;

SELECT Type, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM ushouseholdincome u
JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0 
GROUP BY Type
ORDER BY 2
;

SELECT Type, COUNT(Type), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM ushouseholdincome u
JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0 
GROUP BY 1
ORDER BY 4 DESC
Limit 20
;

SELECT *
FROM ushouseholdincome
WHERE Type = 'Community';


SELECT u.State_Name, ROUND(AVG(Mean),1)
FROM ushouseholdincome u
JOIN us_household_income_statistics us
	ON u.id = us.id		
GROUP BY u.State_Name, City DESC;