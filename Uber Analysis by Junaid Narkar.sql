Create Database UberAnalysis;
 
 use UberAnalysis;

 /******************************************************************************
* Project: Uber Ride Operations Analysis
* Author:   Junaid Abrar Narkar
* Date:     09-09-26
* Purpose:  To analyze operational data for Uber to identify revenue leaks,
*           cancellation patterns, driver performance, and city-level insights.
******************************************************************************/

-- Creating Table 

CREATE TABLE ncr_ride_bookings (
    [Date] nvarchar(50) NULL,
    [Time] nvarchar(50) NULL,
    [Booking_ID] nvarchar(50) NULL,
    [Booking_Status] nvarchar(50) NULL,
    [Customer_ID] nvarchar(50) NULL,
    [Vehicle_Type] nvarchar(50) NULL,
    [Pickup_Location] nvarchar(50) NULL,
    [Drop_Location] nvarchar(50) NULL,
    [Avg_VTAT] nvarchar(50) NULL,
    [Avg_CTAT] nvarchar(50) NULL,
    [Cancelled_Rides_by_Customer] nvarchar(50) NULL,
    [Reason_for_cancelling_by_Customer] nvarchar(200) NULL,
    [Cancelled_Rides_by_Driver] nvarchar(50) NULL,
    [Driver_Cancellation_Reason] nvarchar(200) NULL,
    [Incomplete_Rides] nvarchar(50) NULL,
    [Incomplete_Rides_Reason] nvarchar(200) NULL,
    [Booking_Value] nvarchar(50) NULL,
    [Ride_Distance] nvarchar(50) NULL,
    [Driver_Ratings] nvarchar(50) NULL,
    [Customer_Rating] nvarchar(50) NULL,
    [Payment_Method] nvarchar(50) NULL
);

-- Importing Data into the Table

BULK INSERT ncr_ride_bookings
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.JUNAIDNARKAR11\MSSQL\DATA\ncr_ride_bookings.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    FORMAT = 'CSV',
    FIELDQUOTE = '"'
);

-- Checking the Data

SELECT COUNT(*) AS Total_Rows FROM ncr_ride_bookings;
GO

SELECT TOP 3 * FROM ncr_ride_bookings;
GO

-- Data cleaning

UPDATE ncr_ride_bookings SET Avg_VTAT = NULL WHERE LTRIM(RTRIM(Avg_VTAT)) IN ('null','NULL','Null','');
UPDATE ncr_ride_bookings SET Avg_CTAT = NULL WHERE LTRIM(RTRIM(Avg_CTAT)) IN ('null','NULL','Null','');
UPDATE ncr_ride_bookings SET Cancelled_Rides_by_Customer = NULL WHERE LTRIM(RTRIM(Cancelled_Rides_by_Customer)) IN ('null','NULL','Null','');
UPDATE ncr_ride_bookings SET Cancelled_Rides_by_Driver = NULL WHERE LTRIM(RTRIM(Cancelled_Rides_by_Driver)) IN ('null','NULL','Null','');
UPDATE ncr_ride_bookings SET Incomplete_Rides = NULL WHERE LTRIM(RTRIM(Incomplete_Rides)) IN ('null','NULL','Null','');
UPDATE ncr_ride_bookings SET Booking_Value = NULL WHERE LTRIM(RTRIM(Booking_Value)) IN ('null','NULL','Null','');
UPDATE ncr_ride_bookings SET Ride_Distance = NULL WHERE LTRIM(RTRIM(Ride_Distance)) IN ('null','NULL','Null','');
UPDATE ncr_ride_bookings SET Driver_Ratings = NULL WHERE LTRIM(RTRIM(Driver_Ratings)) IN ('null','NULL','Null','');
UPDATE ncr_ride_bookings SET Customer_Rating = NULL WHERE LTRIM(RTRIM(Customer_Rating)) IN ('null','NULL','Null','');
UPDATE ncr_ride_bookings SET Reason_for_cancelling_by_Customer = NULL WHERE LTRIM(RTRIM(Reason_for_cancelling_by_Customer)) IN ('null','NULL','Null','');
UPDATE ncr_ride_bookings SET Driver_Cancellation_Reason = NULL WHERE LTRIM(RTRIM(Driver_Cancellation_Reason)) IN ('null','NULL','Null','');
UPDATE ncr_ride_bookings SET Incomplete_Rides_Reason = NULL WHERE LTRIM(RTRIM(Incomplete_Rides_Reason)) IN ('null','NULL','Null','');
UPDATE ncr_ride_bookings SET Payment_Method = NULL WHERE LTRIM(RTRIM(Payment_Method)) IN ('null','NULL','Null','');
UPDATE ncr_ride_bookings SET Pickup_Location = NULL WHERE LTRIM(RTRIM(Pickup_Location)) IN ('null','NULL','Null','');
UPDATE ncr_ride_bookings SET Drop_Location = NULL WHERE LTRIM(RTRIM(Drop_Location)) IN ('null','NULL','Null','');

-- Altering the table

ALTER TABLE ncr_ride_bookings ALTER COLUMN Avg_VTAT FLOAT;
ALTER TABLE ncr_ride_bookings ALTER COLUMN Avg_CTAT FLOAT;
ALTER TABLE ncr_ride_bookings ALTER COLUMN Cancelled_Rides_by_Customer INT;
ALTER TABLE ncr_ride_bookings ALTER COLUMN Cancelled_Rides_by_Driver INT;
ALTER TABLE ncr_ride_bookings ALTER COLUMN Incomplete_Rides INT;
ALTER TABLE ncr_ride_bookings ALTER COLUMN Booking_Value DECIMAL(18,2);
ALTER TABLE ncr_ride_bookings ALTER COLUMN Ride_Distance FLOAT;
ALTER TABLE ncr_ride_bookings ALTER COLUMN Driver_Ratings FLOAT;
ALTER TABLE ncr_ride_bookings ALTER COLUMN Customer_Rating FLOAT;
ALTER TABLE ncr_ride_bookings ALTER COLUMN [Date] DATE;
ALTER TABLE ncr_ride_bookings ALTER COLUMN [Time] TIME;

-- Adding Primary Key

ALTER TABLE ncr_ride_bookings ADD id INT IDENTITY(1,1) PRIMARY KEY;
GO

-- Checking the table

SELECT 
    COUNT(*) AS Total_Rows,
    COUNT(Driver_Ratings) AS Rows_With_Rating,
    MIN(Driver_Ratings) AS Min_Rating,
    MAX(Driver_Ratings) AS Max_Rating,
    AVG(Driver_Ratings) AS Avg_Rating
FROM ncr_ride_bookings;

-- Creating View for Easy Analsis

CREATE VIEW vw_Ride_Analysis AS
SELECT 
    id,
    [Date] AS RideDate,
    [Time] AS RideTime,
    Booking_ID,
    Booking_Status,
    Customer_ID,
    Vehicle_Type,
    Pickup_Location,
    Drop_Location,
    Avg_VTAT,
    Avg_CTAT,
    Cancelled_Rides_by_Customer,
    Reason_for_cancelling_by_Customer,
    Cancelled_Rides_by_Driver,
    Driver_Cancellation_Reason,
    Incomplete_Rides,
    Incomplete_Rides_Reason,
    Booking_Value,
    Ride_Distance,
    Driver_Ratings,
    Customer_Rating,
    Payment_Method
FROM ncr_ride_bookings;

-- Top 3 Cities for Driver Recuritment

SELECT TOP 3
    Pickup_Location AS City,
    COUNT(*) AS Total_Rides,
    SUM(CASE WHEN Booking_Status LIKE '%Cancelled%' THEN 1 ELSE 0 END) AS Cancelled_Rides,
    ROUND(SUM(CASE WHEN Booking_Status LIKE '%Cancelled%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Cancellation_Rate_Pct,
    ROUND(AVG(Driver_Ratings), 2) AS Avg_Driver_Rating,
    ROUND(AVG(Customer_Rating), 2) AS Avg_Customer_Rating,
    ROUND(
        COUNT(*) * (1 + (SUM(CASE WHEN Booking_Status LIKE '%Cancelled%' THEN 1 ELSE 0 END) * 1.0 / COUNT(*))) 
        * (1 + (5.0 - AVG(Driver_Ratings)) / 5.0), 
    2) AS Recruitment_Score
FROM vw_Ride_Analysis
WHERE Pickup_Location IS NOT NULL 
    AND Driver_Ratings IS NOT NULL
GROUP BY Pickup_Location
ORDER BY Recruitment_Score DESC;

-- Query 2 : Where are we losing money? Which rides should have been paid but weren't? 
-- Revenue Leakage Detection

Select id,RideDate,Pickup_Location,Booking_value,Ride_Distance,Booking_Status,Payment_Method,
Case
    When Booking_Status = 'Completed' And Payment_Method Is Null
	    Then 'Critical: Completed but No Payment'
	When Booking_Status = 'Completed' And Booking_Value < 50 And Ride_Distance > 10
	    Then 'Suspicious High Distance , Low Fare'
	When Booking_Status = 'Incomplete' And Booking_Value>500
	    Then 'High value Incomplete'
	When Booking_Status = 'Cancelled by Drivers' And Booking_Value>100
	     Then 'High Value Driver Cancellation'
	Else 'OK'
   End As Leakage_Type
From vw_Ride_Analysis
Where 
     (Booking_Status = 'Completed' And Payment_Method is Null)
	 or (Booking_Status = 'Completed' And Booking_value < 5 And Ride_Distance >100)
	 or (Booking_Status = 'InComplete' And Booking_value > 500)
	 or (Booking_Status = 'Cancelled by Driver' And Booking_value > 100)
Order by Booking_value Desc;
Go

-- Query 3 : Which cities have the worst cancellation problem? How much revenue are we losing?
-- Cancellation Rate by City

SELECT 
    Pickup_Location AS City,
    COUNT(*) AS Total_Rides,
    SUM(CASE WHEN Booking_Status LIKE '%Cancelled%' THEN 1 ELSE 0 END) AS Cancelled_Rides,
    ROUND(SUM(CASE WHEN Booking_Status LIKE '%Cancelled%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Cancellation_Rate_Pct
FROM vw_Ride_Analysis
WHERE Pickup_Location IS NOT NULL
GROUP BY Pickup_Location
HAVING COUNT(*) > 20
ORDER BY Cancellation_Rate_Pct DESC;
GO

SELECT 
    Booking_Status,
    COUNT(*) AS How_Many,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM vw_Ride_Analysis), 2) AS Pct
FROM vw_Ride_Analysis
GROUP BY Booking_Status
ORDER BY How_Many DESC;
GO

SELECT 
    Booking_ID,
    COUNT(*) AS Times_Appeared
FROM vw_Ride_Analysis
WHERE Booking_ID IS NOT NULL
GROUP BY Booking_ID
HAVING COUNT(*) > 1
ORDER BY Times_Appeared DESC;
GO

SELECT 
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Booking_ID) AS Unique_Bookings,
    COUNT(*) - COUNT(DISTINCT Booking_ID) AS Duplicate_Rows
FROM vw_Ride_Analysis;
GO

-- Add a row number to find duplicates
WITH Duplicates AS (
    SELECT 
        id,
        Booking_ID,
        ROW_NUMBER() OVER (PARTITION BY Booking_ID ORDER BY id) AS rn
    FROM ncr_ride_bookings
    WHERE Booking_ID IS NOT NULL
)
-- Delete duplicates (keep the first occurrence)
DELETE FROM ncr_ride_bookings
WHERE id IN (
    SELECT id FROM Duplicates WHERE rn > 1
);
GO

-- Verify
SELECT 
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Booking_ID) AS Unique_Bookings
FROM ncr_ride_bookings;
GO

SELECT 
    Pickup_Location AS City,
    COUNT(*) AS Total_Rides,
    SUM(CASE WHEN Booking_Status LIKE '%Cancelled%' THEN 1 ELSE 0 END) AS Cancelled_Rides,
    ROUND(SUM(CASE WHEN Booking_Status LIKE '%Cancelled%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Cancellation_Rate_Pct
FROM vw_Ride_Analysis
WHERE Pickup_Location IS NOT NULL
GROUP BY Pickup_Location
HAVING COUNT(*) > 20
ORDER BY Cancellation_Rate_Pct DESC;
GO

SELECT 
    COUNT(DISTINCT Pickup_Location) AS Unique_Cities,
    COUNT(*) AS Total_Rows
FROM vw_Ride_Analysis;
GO

-- Query 4: Cancellation Patterns by Time of Day
-- Business Question
-- "When do cancellations happen most? Morning, afternoon, evening, or night?"

SELECT 
    CASE 
        WHEN DATEPART(HOUR, RideTime) BETWEEN 6 AND 11 THEN 'Morning (6-11 AM)'
        WHEN DATEPART(HOUR, RideTime) BETWEEN 12 AND 16 THEN 'Afternoon (12-4 PM)'
        WHEN DATEPART(HOUR, RideTime) BETWEEN 17 AND 21 THEN 'Evening (5-9 PM)'
        ELSE 'Night (10 PM-5 AM)'
    END AS Time_Period,
    COUNT(*) AS Total_Rides,
    SUM(CASE WHEN Booking_Status LIKE '%Cancelled%' THEN 1 ELSE 0 END) AS Cancelled_Rides,
    ROUND(SUM(CASE WHEN Booking_Status LIKE '%Cancelled%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Cancellation_Rate_Pct,
    ROUND(SUM(CASE WHEN Booking_Status = 'Completed' THEN Booking_Value ELSE 0 END), 2) AS Revenue_Completed
FROM vw_Ride_Analysis
WHERE RideTime IS NOT NULL
GROUP BY 
    CASE 
        WHEN DATEPART(HOUR, RideTime) BETWEEN 6 AND 11 THEN 'Morning (6-11 AM)'
        WHEN DATEPART(HOUR, RideTime) BETWEEN 12 AND 16 THEN 'Afternoon (12-4 PM)'
        WHEN DATEPART(HOUR, RideTime) BETWEEN 17 AND 21 THEN 'Evening (5-9 PM)'
        ELSE 'Night (10 PM-5 AM)'
    END
ORDER BY Cancellation_Rate_Pct DESC;
GO

-- Query 5: Cancellation by Vehicle Type
-- Business Question
-- "Which vehicle type has the worst cancellation rate? Should we promote or phase out certain vehicles?"

SELECT 
    Vehicle_Type,
    COUNT(*) AS Total_Rides,
    SUM(CASE WHEN Booking_Status LIKE '%Cancelled%' THEN 1 ELSE 0 END) AS Cancelled_Rides,
    ROUND(SUM(CASE WHEN Booking_Status LIKE '%Cancelled%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Cancellation_Rate_Pct,
    ROUND(AVG(Booking_Value), 2) AS Avg_Fare,
    ROUND(AVG(Driver_Ratings), 2) AS Avg_Driver_Rating,
    ROUND(SUM(Booking_Value), 2) AS Total_Revenue
FROM vw_Ride_Analysis
WHERE Vehicle_Type IS NOT NULL
GROUP BY Vehicle_Type
ORDER BY Cancellation_Rate_Pct DESC;
GO

-- Query 6: Seasonal Fare Variations
-- Business Question
-- "Do fares change by month? Which months are most profitable? Are there seasonal patterns?"

SELECT 
    DATENAME(MONTH, RideDate) AS Month_Name,
    DATEPART(MONTH, RideDate) AS Month_Num,
    COUNT(*) AS Total_Rides,
    ROUND(AVG(Booking_Value), 2) AS Avg_Fare,
    ROUND(SUM(Booking_Value), 2) AS Total_Revenue,
    ROUND(AVG(Ride_Distance), 2) AS Avg_Distance,
    ROUND(SUM(CASE WHEN Booking_Status LIKE '%Cancelled%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Cancellation_Rate_Pct
FROM vw_Ride_Analysis
WHERE RideDate IS NOT NULL
GROUP BY DATENAME(MONTH, RideDate), DATEPART(MONTH, RideDate)
ORDER BY Month_Num;
GO

-- Query 7: Average Ride Distance by City
-- Business Question
-- "Which cities have the longest average rides? Where should we focus for long-distance pricing?"

SELECT 
    Pickup_Location AS City,
    COUNT(*) AS Total_Rides,
    ROUND(AVG(Ride_Distance), 2) AS Avg_Distance_km,
    ROUND(AVG(Booking_Value), 2) AS Avg_Fare,
    ROUND(AVG(Booking_Value) / NULLIF(AVG(Ride_Distance), 0), 2) AS Fare_Per_Km
FROM vw_Ride_Analysis
WHERE Pickup_Location IS NOT NULL 
    AND Ride_Distance > 0
GROUP BY Pickup_Location
HAVING COUNT(*) > 20
ORDER BY Avg_Distance_km DESC;
GO

-- Query 8: Driver Performance View
-- Business Question
-- "Who are our top drivers? Who needs training? Which rating buckets have the best/worst cancellation rates?"

DROP VIEW IF EXISTS vw_Driver_Performance;
GO

CREATE VIEW vw_Driver_Performance AS
SELECT 
    Driver_Ratings,
    COUNT(*) AS Total_Rated_Rides,
    ROUND(AVG(Customer_Rating), 2) AS Avg_Customer_Rating,
    ROUND(AVG(Booking_Value), 2) AS Avg_Fare,
    ROUND(AVG(Ride_Distance), 2) AS Avg_Distance_km
FROM vw_Ride_Analysis
WHERE Driver_Ratings IS NOT NULL
GROUP BY Driver_Ratings;
GO

SELECT * FROM vw_Driver_Performance
ORDER BY Driver_Ratings DESC;
GO

-- Query 9: Payment Method Analysis
-- Business Question
-- "Which payment methods are most popular? Are there payment issues? Where should we focus?"

SELECT 
    Payment_Method,
    COUNT(*) AS Total_Rides,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM vw_Ride_Analysis WHERE Payment_Method IS NOT NULL), 2) AS Usage_Pct,
    ROUND(SUM(Booking_Value), 2) AS Total_Revenue,
    ROUND(AVG(Booking_Value), 2) AS Avg_Fare,
    SUM(CASE WHEN Booking_Status = 'Completed' THEN 1 ELSE 0 END) AS Completed_Rides
FROM vw_Ride_Analysis
WHERE Payment_Method IS NOT NULL
GROUP BY Payment_Method
ORDER BY Total_Rides DESC;
GO

-- Query 10: Executive Summary + Recommendations
-- Business Question
-- "Give me the big picture — total rides, revenue, cancellations, and what to do."

-- Step 1: Create Executive Summary View
CREATE VIEW vw_Executive_Dashboard AS
SELECT 
    COUNT(*) AS Total_Rides,
    SUM(CASE WHEN Booking_Status = 'Completed' THEN 1 ELSE 0 END) AS Completed_Rides,
    SUM(CASE WHEN Booking_Status LIKE '%Cancelled%' THEN 1 ELSE 0 END) AS Cancelled_Rides,
    SUM(CASE WHEN Booking_Status = 'No Driver Found' THEN 1 ELSE 0 END) AS No_Driver_Found,
    SUM(CASE WHEN Booking_Status = 'Incomplete' THEN 1 ELSE 0 END) AS Incomplete_Rides,
    ROUND(SUM(Booking_Value), 2) AS Total_Revenue,
    ROUND(AVG(Booking_Value), 2) AS Avg_Fare,
    ROUND(SUM(CASE WHEN Booking_Status LIKE '%Cancelled%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Cancellation_Rate_Pct,
    MIN(RideDate) AS Data_Start_Date,
    MAX(RideDate) AS Data_End_Date
FROM vw_Ride_Analysis;
GO

-- Step 2: Read the executive summary
SELECT * FROM vw_Executive_Dashboard;
GO