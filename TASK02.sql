---------------------------------Data Cleaning----------------------------------------------------
SELECT * FROM train;
---------------------------------Changing the 'Survived' column to make it readable-----------------------------------
UPDATE train
SET Survived = CASE
                    WHEN Survived = 0 THEN 'No'
                    WHEN Survived = 1 THEN 'Yes'
                    ELSE Survived
                END;
-------------------------------Handling missing values by replacing them with the mean age--------------------------
UPDATE train
SET Age = (
    SELECT AVG(Age)
    FROM train
    WHERE Age IS NOT NULL
)
WHERE Age IS NULL;

---------Removing the decimal values from Age----------------
UPDATE train
SET Age = LEFT(Age, CHARINDEX('.', Age) - 1)
WHERE CHARINDEX('.', Age) > 0;

----------Removing duplicates-----------------------
SELECT Ticket, COUNT(*) AS Count
FROM train
GROUP BY Ticket
HAVING COUNT(*) > 1;

;WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Ticket ORDER BY (SELECT NULL)) AS rn
    FROM train
)
DELETE FROM CTE WHERE rn > 1;

------------------------------------------MAKING 'Embarked' column readable------------------------------------------
UPDATE train
SET Embarked = CASE
                    WHEN Embarked  = 'S' THEN 'Southampton'
                    WHEN Embarked  = 'C' THEN 'Cherbourg'
					WHEN Embarked  = 'Q' THEN 'Queenstow'
                END;

-----------------------Renaming columns-------------------------------------------------
ALTER TABLE train
ADD TicketClass int;

SELECT * FROM train;

UPDATE train
SET TicketClass = Pclass;

ALTER TABLE train
DROP COLUMN Pclass;

--------------------------------Sibsp-------------------
ALTER TABLE train
ADD SiblingSpouse int;

SELECT * FROM train;

UPDATE train
SET SiblingSpouse = SibSp;

ALTER TABLE train
DROP COLUMN SibSp;

---------------------------------------------Parch-----------------------------------
ALTER TABLE train
ADD ParentsChildren int;

SELECT * FROM train;

UPDATE train
SET ParentsChildren  = Parch;

ALTER TABLE train
DROP COLUMN Parch;

-----------------------------------------Rounding off the Fare column---------------------------
UPDATE train
SET Fare = ROUND(Fare, 2);

----------------------------------------------------------EXPLORATORY DATA ANALYSIS--------------------------------------
-----Survival Count
SELECT Survived, COUNT(*) AS SurvivalCount FROM train GROUP BY Survived;

SELECT * FROM train;

-----Male/Female distribution
SELECT Sex, Count(*) As SexDistribution
FROM train
GROUP BY Sex;

-----Survival count among male and female
SELECT Sex,Survived, Count(*) As SurvivedCount
FROM train
GROUP BY Sex, Survived;

-----Average age by class
SELECT TicketClass, ROUND(AVG(Age),0) AS avg_age
FROM train
GROUP BY TicketClass
ORDER BY TicketClass;

-----Fare distribution
SELECT 
    fare_range,
    COUNT(*) AS FareCount
FROM (
    SELECT 
        CASE 
            WHEN Fare < 50 THEN '<50' 
            WHEN Fare BETWEEN 50 AND 99 THEN '50-99' 
            WHEN Fare BETWEEN 100 AND 149 THEN '100-149' 
            WHEN Fare BETWEEN 150 AND 199 THEN '150-199' 
            ELSE '200+' 
        END AS fare_range
    FROM train
) AS fare_ranges
GROUP BY fare_range
ORDER BY fare_range;

-------Survival count of each class
SELECT Survived, TicketClass, Count(*) as SurvivalCountByClass
FROM train
Group by Survived, TicketClass;


-----Number of passengers with siblings/spouses aboard
SELECT SiblingSpouse, COUNT(*) AS count
FROM train
GROUP BY SiblingSpouse
ORDER BY SiblingSpouse;


-----Number of passengers with parents/children aboard
SELECT ParentsChildren, COUNT(*) AS count
FROM train
GROUP BY ParentsChildren
ORDER BY ParentsChildren;



















