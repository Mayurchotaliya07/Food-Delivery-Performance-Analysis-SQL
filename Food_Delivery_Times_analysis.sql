-- Business Problem

-- A food delivery company wants to reduce delivery times and improve operational efficiency. 
-- Using delivery, traffic, weather, courier, and preparation data, analyze the factors affecting delivery performance and provide actionable business insights.

-- Seeing dataset

SELECT
		*
FROM food_delivery_info;

-- checking nulls

SELECT
    SUM(CASE WHEN Order_ID IS NULL OR Order_ID='' THEN 1 ELSE 0 END) AS Order_ID_Nulls,
    SUM(CASE WHEN Weather IS NULL OR Weather='' THEN 1 ELSE 0 END) AS Weather_Nulls,
    SUM(CASE WHEN Traffic_Level IS NULL OR Traffic_Level='' THEN 1 ELSE 0 END) AS Traffic_Level_Nulls,
    SUM(CASE WHEN Delivery_Time_min IS NULL OR Delivery_Time_min='' THEN 1 ELSE 0 END) AS Delivery_Time_Nulls,
    SUM(CASE WHEN Time_of_Day IS NULL OR Time_of_Day = '' THEN 1 ELSE 0 END) AS Time_of_Day_Nulls,
    SUM(CASE WHEN Vehicle_Type IS NULL OR Vehicle_Type = '' THEN 1 ELSE 0 END) AS Vehical_Type_Nulls,
    SUM(CASE WHEN Preparation_Time_min IS NULL OR Preparation_Time_min = '' THEN 1 ELSE 0 END) AS Preparation_Time_min_Nulls,
    SUM(CASE WHEN Courier_Experience_yrs IS NULL OR Courier_Experience_yrs = '' THEN 1 ELSE 0 END) AS Courier_Experience_yrs_Nulls,
    SUM(CASE WHEN Delivery_Time_min IS NULL OR Delivery_Time_min = '' THEN 1 ELSE 0 END) AS Delivery_Time_min_Nulls
FROM food_delivery_info;

-- Filling Nulls

UPDATE food_delivery_info
SET Weather = 'Unknown'
WHERE Weather IS NULL
   OR TRIM(Weather) = '';
   
UPDATE food_delivery_info
SET Traffic_Level = 'Unknown'
WHERE Traffic_Level IS NULL
   OR TRIM(Traffic_Level) = '';
   
UPDATE food_delivery_info
SET Time_of_Day = 'Unknown'
WHERE Time_of_Day IS NULL
   OR TRIM(Time_of_Day) = '';
   
UPDATE food_delivery_info
SET Weather = 'Unknown'
WHERE Weather IS NULL
   OR TRIM(Weather) = '';

-- Checking duplicate values

SELECT
		Order_ID,
        COUNT(*) 
FROM food_delivery_info
GROUP BY Order_ID;

-- Order Overview

-- 1) How many total deliveries were completed?

SELECT
		COUNT(delivery_time_min) AS total_orders
FROM food_delivery_info;

-- 2) What is the average delivery time?

SELECT
		ROUND(AVG(delivery_time_min), 2) AS average_delivery_time
FROM food_delivery_info;

-- 3) What is the average preparation time?

SELECT
		ROUND(AVG(preparation_time_min),2) AS average_preparation_time
FROM food_delivery_info;

-- 4) What is the average delivery distance?

SELECT
		ROUND(AVG(distance_km),2) AS average_distance
FROM food_delivery_info;

-- 5) What is the average courier experience?

SELECT
		ROUND(AVG(courier_experience_yrs),2) AS average_experience
FROM food_delivery_info;

-- Weather Analysis

-- 1) Which weather condition has the highest number of deliveries?

SELECT
		weather,
        COUNT(*) AS total_orders
FROM food_delivery_info
GROUP BY weather;

-- 2) Which weather condition results in the longest average delivery time?

WITH avg_time AS
(
SELECT
		weather,
        ROUND(AVG(delivery_time_min),2) AS average_time
FROM food_delivery_info
GROUP BY weather
)
SELECT
		weather,
        average_time
FROM (
SELECT
        *,
        DENSE_RANK() OVER(
        ORDER BY average_time DESC
        ) AS ranks
FROM avg_time)t
WHERE ranks = 1;

-- 3) How much does delivery time increase during rainy or stormy weather?

WITH avg_delivery AS
(
SELECT
		weather,
        ROUND(AVG(delivery_time_min),2) AS avg_delivery_time
FROM food_delivery_info
WHERE weather <> 'Clear'
GROUP BY weather
),
clear_avg AS
(
SELECT
		weather,
        ROUND(AVG(delivery_time_min),2) AS clear_avg_delivery_time
FROM food_delivery_info
WHERE weather = 'Clear'
GROUP BY weather
)
SELECT
		ad.weather AS weather,
        ad.avg_delivery_time AS average_delivery_time,
        ROUND((ad.avg_delivery_time - ca.clear_avg_delivery_time),2) AS Increase_in_time
FROM avg_delivery ad
CROSS JOIN clear_avg ca
WHERE ad.weather = 'Rainy';

-- 4) Which weather condition has the shortest preparation time?

WITH short_prep AS
(
SELECT
		weather,
        ROUND(AVG(preparation_time_min),2) AS average_time
FROM food_delivery_info
GROUP BY weather
)
SELECT
		weather,
        average_time
FROM (
SELECT
		*,
		DENSE_RANK() OVER(
        ORDER BY average_time ASC
        ) AS ranks
FROM short_prep
WHERE weather <> 'Unknown')t
WHERE ranks = 1;

-- Traffic Analysis

-- 1) Which traffic level occurs most frequently?

WITH traffic AS
(
SELECT
		traffic_level,
        COUNT(*) AS total_numbers
FROM food_delivery_info
GROUP BY traffic_level
)
SELECT
		traffic_level,
        total_numbers
FROM (
SELECT
		*,
        DENSE_RANK() OVER(
        ORDER BY total_numbers DESC
        ) AS ranks
FROM traffic)t
WHERE ranks = 1;

-- 2) Which traffic level has the highest average delivery time?

WITH traffic AS
(
SELECT
		traffic_level,
        ROUND(AVG(delivery_time_min),2) AS average_delivery
FROM food_delivery_info
GROUP BY traffic_level
)
SELECT
		traffic_level,
        average_delivery
FROM (
SELECT
		*,
        DENSE_RANK() OVER(
        ORDER BY average_delivery DESC
        ) AS ranks
FROM traffic)t
WHERE ranks = 1;

-- 3) How much additional time does high traffic add compared to low traffic?

WITH high AS
(
SELECT
		traffic_level,
        ROUND(AVG(delivery_time_min),2) AS avg_delivery_time
FROM food_delivery_info
WHERE traffic_level = 'High'
),
low AS
(
SELECT
		traffic_level,
        ROUND(AVG(delivery_time_min),2) AS avg_delivery_time
FROM food_delivery_info
WHERE traffic_level ='Low'
)
SELECT
		h.avg_delivery_time - l.avg_delivery_time AS total_difference
FROM high h
CROSS JOIN low l ;

-- 4) Which traffic condition causes the greatest operational delay?

WITH sample AS
(
SELECT
		traffic_level,
        (avg_preparation_time + avg_delivery_time) AS total_operational_time
FROM (
SELECT
		traffic_level,
        ROUND(AVG(preparation_time_min),2) AS avg_preparation_time,
        ROUND(AVG(delivery_time_min),2) AS avg_delivery_time
FROM food_delivery_info
GROUP BY traffic_level)t
)
SELECT
		traffic_level,
        total_operational_time
FROM (
SELECT
		*,
		DENSE_RANK() OVER(
        ORDER BY total_operational_time DESC
        ) AS ranks
FROM sample)t
WHERE ranks = 1;

-- Vehicle Performance

-- 1) Which vehicle type is used most often?

SELECT
		vehicle_type,
        total_used
FROM (
SELECT
		*,
        DENSE_RANK() OVER(
        ORDER BY total_used DESC
        ) AS ranks
FROM (
SELECT
		vehicle_type,
        COUNT(*) AS total_used
FROM food_delivery_info
GROUP BY vehicle_type)t)y
WHERE ranks = 1;

-- 2) Which vehicle type delivers the fastest on average?

SELECT
		vehicle_type,
        avg_delivery_time AS fastest_avg_time
FROM (
SELECT
		*,
        DENSE_RANK() OVER(
        ORDER BY avg_delivery_time DESC
        ) AS ranks
FROM (
SELECT
		vehicle_type,
        AVG(delivery_time_min) AS avg_delivery_time
FROM food_delivery_info
GROUP BY vehicle_type)t)y
WHERE ranks = 1;

-- 3) Which vehicle performs best for long-distance deliveries?

SELECT
		vehicle_type,
        avg_delivery_time
FROM (
SELECT
		*,
        DENSE_RANK() OVER(
        ORDER BY avg_delivery_time
        ) AS ranks
FROM (
SELECT
		vehicle_type,
        ROUND(AVG(delivery_time_min),2) AS avg_delivery_time
FROM food_delivery_info
WHERE distance_km > (SELECT
													AVG(distance_km)
										FROM food_delivery_info)
GROUP BY vehicle_type)t)y
WHERE ranks = 1;

-- 4) Which vehicle type is least affected by traffic?

WITH sample AS
(
SELECT
		vehicle_type,
        (High_avg - Low_avg) AS total_time_increase
FROM (
SELECT
		vehicle_type,
        AVG(
				CASE
							WHEN traffic_level = 'Low'
                            THEN delivery_time_min
				END
		) AS Low_avg,
         AVG(
				CASE
							WHEN traffic_level = 'High'
                            THEN delivery_time_min
				END
		) AS High_avg
FROM food_delivery_info
GROUP BY vehicle_type)t
)
SELECT
		vehicle_type,
        total_time_increase
FROM (
SELECT
		*,
        DENSE_RANK() OVER(
        ORDER BY total_time_increase ASC
        ) AS ranks
FROM sample)t
WHERE ranks = 1;

-- Time of Day Analysis

-- 1) During which time of day are the most orders delivered?
WITH sample_day AS
(
SELECT
		time_of_day,
        COUNT(*) AS total_orders
FROM food_delivery_info
GROUP BY time_of_day
)
SELECT
		time_of_day,
        total_orders
FROM (
SELECT
		*,
        DENSE_RANK() OVER(
        ORDER BY total_orders DESC
        ) AS ranks 
FROM sample_day)t
WHERE ranks = 1;

-- 2) Which time of day has the longest average delivery time?

WITH sample AS
(
SELECT
		time_of_day,
        ROUND(AVG(delivery_time_min),2) AS average_delivery_time
FROM food_delivery_info
GROUP BY time_of_day
)
SELECT
		time_of_day,
        average_delivery_time
FROM (
SELECT
		*,
        DENSE_RANK() OVER(
        ORDER BY average_delivery_time DESC
        ) AS ranks
FROM sample
WHERE time_of_day <> "Unknown")t
WHERE ranks = 1;

-- 3) Which time period experiences the highest preparation time?

WITH sample AS
(
SELECT
		time_of_day,
        ROUND(AVG(preparation_time_min),2) AS average_preparation_time
FROM food_delivery_info
GROUP BY time_of_day
)
SELECT
		time_of_day,
        average_preparation_time
FROM (
SELECT
		*,
        DENSE_RANK() OVER(
        ORDER BY average_preparation_time DESC
        ) AS ranks
FROM sample
WHERE time_of_day <> "Unknown")t
WHERE ranks = 1;

-- 4) During which time of day are deliveries completed the fastest?

WITH sample AS
(
SELECT
		time_of_day,
        ROUND(AVG(delivery_time_min),2) AS average_delivery_time
FROM food_delivery_info
GROUP BY time_of_day
)
SELECT
		time_of_day,
        average_delivery_time
FROM (
SELECT
		*,
        DENSE_RANK() OVER(
        ORDER BY average_delivery_time ASC
        ) AS ranks
FROM sample
WHERE time_of_day <> "Unknown")t
WHERE ranks = 1;

-- Advanced Business Insights

-- 1) Rank vehicle types by average delivery time.

WITH sample AS
(
SELECT
		vehicle_type,
        ROUND(AVG(delivery_time_min),2) AS average_delivery_time
FROM food_delivery_info
GROUP BY vehicle_type
)
SELECT
		*,
        DENSE_RANK() OVER(
        ORDER BY average_delivery_time ASC
        ) AS ranks
FROM sample;

-- 2) Compare delivery times across Weather × Traffic combinations.

SELECT
		weather,
        traffic_level,
        ROUND(AVG(delivery_time_min),2) AS average_delivery_time
FROM food_delivery_info
GROUP BY weather,traffic_level
ORDER BY weather, traffic_level;

-- 3) Find deliveries taking longer than the overall average.

WITH avg_time AS
(
SELECT
		AVG(delivery_time_min)
FROM food_delivery_info
)
SELECT
		*
FROM food_delivery_info
WHERE delivery_time_min > (SELECT * FROM avg_time);

-- 4) Identify the top 10 longest deliveries.

WITH sample AS
(
SELECT
		*,
        DENSE_RANK() OVER(
        ORDER BY delivery_time_min DESC
        ) AS ranks
FROM food_delivery_info
)
SELECT
		*
FROM sample
WHERE ranks <=10;

-- 5) Categorize deliveries into Fast, Moderate, and Slow

SELECT
		*,
        (CASE
					WHEN (delivery_time_min <=40) THEN 'Fast'
                    WHEN (delivery_time_min BETWEEN 41 AND 60) THEN 'Medium'
                    WHEN (delivery_time_min >= 61) THEN 'High'
		END) AS delivery_speed
FROM food_delivery_info;

-- 6) Determine whether courier experience reduces delivery time.

WITH experience_analysis AS
(
    SELECT
        courier_experience_yrs,
        ROUND(AVG(delivery_time_min), 2) AS avg_delivery_time
    FROM food_delivery_info
    WHERE courier_experience_yrs IS NOT NULL
    GROUP BY courier_experience_yrs
)
SELECT
    courier_experience_yrs,
    avg_delivery_time,
    LAG(avg_delivery_time) OVER (
        ORDER BY courier_experience_yrs
    ) AS previous_avg_delivery_time,
    ROUND(
        avg_delivery_time -
        LAG(avg_delivery_time) OVER (
            ORDER BY courier_experience_yrs
        ),
        2
    ) AS change_from_previous
FROM experience_analysis
ORDER BY courier_experience_yrs;