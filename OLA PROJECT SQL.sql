


SELECT * FROM olaa_data

--1.Retrieve all successful bookings:
CREATE VIEW suc_bookings AS
SELECT * 
FROM olaa_data
WHERE 
"Booking Status" = '{S}'

--2.Get the total number of cancelled rides by customers:
CREATE VIEW cancelled_rides_by_customer As
SELECT COUNT(*) 
FROM olaa_data
WHERE "Booking Status" = '{CC}';

--3.Get the total number of cancelled rides by Drivers:
CREATE VIEW cancelled_rides_by_Driver As
SELECT COUNT(*) 
FROM olaa_data
WHERE "Booking Status" = '{CD}';

--4.List the top 5 customers who booked the highest number of rides:
CREATE VIEW Top_5_Customer As
SELECT "Customer ID", COUNT( "Booking ID") as total_rides
FROM olaa_data
GROUP BY "Customer ID"
ORDER BY total_rides DESC
LIMIT 5;

--5.Find the maximum and minimum driver ratings for Prime Sedan bookings:
CREATE VIEW Max_Min_Avg_Drivers_ratings As
SELECT MAX("Driver Ratings") as max_rating,
MIN("Driver Ratings") as min_rating,
ROUND(AVG("Driver Ratings"),2) as avg_rating
FROM olaa_data
WHERE "Vehicle Type" = 'Prime Sedan'
AND "Driver Ratings"!= 0;

--6.Find the average customer rating per vehicle type:
CREATE VIEW AVG_Customer_Rating As
SELECT "Vehicle Type", ROUND(AVG("Customer Rating"),2) as avg_customer_rating
FROM olaa_data
GROUP BY "Vehicle Type";

--7.Calculate the total booking value of rides completed successfully:
CREATE VIEW total_suc_ride_value As
SELECT ROUND(SUM("Fare"),1) AS total_successful_ride_value
FROM olaa_data
WHERE cancel_reason IS  NULL
OR "Booking Status" = '{S}';

--8.List all incomplete rides along with the reason:
CREATE VIEW Incompl_Ride_Reason As
SELECT COUNT("Customer ID") AS total_cust_count ,cancel_reason
FROM olaa_data
WHERE cancel_reason IS NOT NULL
GROUP BY 2;


--Booking Trends & Demand Analysis

--9.Total number of bookings per week
CREATE VIEW Total_booking_week As
SELECT "Day of Week", COUNT("Booking Status") AS total_bookings
FROM olaa_data
GROUP BY "Day of Week"
ORDER BY "Day of Week";


--10.Demand change over weekdays vs. weekends
CREATE VIEW booking_weekday_vs_end As
SELECT CASE 
WHEN "Day of Week" IN ('Tuesday','Monday','Friday','Thursday','Wednesday') THEN 'Weekday'
ELSE 'Weekend' END AS day_type, 
COUNT(*) AS total_bookings
FROM olaa_data
GROUP BY day_type
ORDER BY total_bookings DESC;

--11.Most common pickup and drop locations
CREATE VIEW total_pickups_loc As
SELECT "Pickup Location", COUNT(*) AS total_pickups
FROM olaa_data
GROUP BY "Pickup Location"
ORDER BY total_pickups DESC
LIMIT 10;

CREATE VIEW total_drop_loc As
SELECT "Drop Location", COUNT(*) AS total_drops
FROM olaa_data
GROUP BY "Drop Location"
ORDER BY total_drops DESC
LIMIT 10;


--Customer & Driver Behavior Analysis

--12.Average customer rating per vehicle type
CREATE VIEW customer_rating_per_vehcile As
SELECT "Vehicle Type", ROUND(AVG("Customer Rating"), 2) AS avg_cust_rating,
MAX("Customer Rating") AS max_cust_rating,
MIN("Customer Rating") AS min_cust_rating
FROM olaa_data
WHERE "Customer Rating" != 0
GROUP BY "Vehicle Type";

--13.Average driver rating per vehicle type
CREATE VIEW driver_rating_per_vehcile As
SELECT "Vehicle Type", ROUND(AVG("Driver Ratings"), 2) AS avg_driver_rating,
MAX("Driver Ratings") AS max_driver_rating,
MIN("Driver Ratings") AS min_driver_rating
FROM olaa_data
WHERE "Driver Ratings" != 0
GROUP BY "Vehicle Type";

--14.Repeat customers vs new customers
CREATE VIEW repeat_vs_newcust As
WITH cte AS(SELECT "Customer ID",CASE 
WHEN COUNT("Customer ID") > 1 THEN 'Repeat Customer'
ELSE 'New Customer' END AS customer_type
FROM olaa_data
GROUP BY "Customer ID")

SELECT customer_type,
COUNT("Customer ID") AS total_customers
FROM cte
GROUP BY customer_type;

--15.Most preferred vehicle type by customers
CREATE VIEW prefered_Vehicle As
SELECT "Vehicle Type", COUNT(*) AS total_bookings
FROM olaa_data
GROUP BY "Vehicle Type"
ORDER BY total_bookings DESC
LIMIT 5;

--16.Top reasons for ride cancellations
CREATE VIEW ride_cancel_reasons As
SELECT cancel_reason, COUNT(*) AS total_cancellations
FROM olaa_data
WHERE  "Booking Status" = '{CC}'OR "Booking Status" = '{CD}' 
GROUP BY cancel_reason
ORDER BY total_cancellations DESC
LIMIT 5;

--17.Driver vs. customer-initiated cancellations
CREATE VIEW driver_cust_initiated_cancel As
SELECT 
CASE WHEN cancel_reason ='Driver asked to cancel' THEN 'Driver Initiated Cancellation'
ELSE 'Customer Initiated Cancellation' END AS Cancel_by, 
COUNT(*) AS total_cancellations
FROM olaa_data
GROUP BY cancel_by;


 --Operational Efficiency & Service Quality

--18.Average VTAT (Vehicle Time to Arrive) and CTAT (Customer Time to Arrive)
CREATE VIEW avg_vtat_ctat As
SELECT 
ROUND(AVG("Avg VTAT"), 2) AS avg_vtat,
ROUND(AVG("Avg CTAT"), 2) AS avg_ctat
FROM olaa_data
WHERE "Booking Status" = '{S}';

--19.Incomplete rides percentage
CREATE VIEW incomp_ride_percent As
SELECT 
(SUM(CASE WHEN "Booking Status" = '{I}' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS incomp_rides_percent
FROM olaa_data;

--20.Booking success rate
CREATE VIEW booking_success_rate As
SELECT 
SUM(CASE WHEN "Booking Status"= '{S}' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS success_rate
FROM olaa_data;

--21.VTAT & CTAT by location and vehicle type
CREATE VIEW avg_vtat_ctat_bylocation As
SELECT "Pickup Location", "Vehicle Type",
ROUND(AVG("Avg VTAT"), 2) AS avg_vtat,
 ROUND(AVG("Avg CTAT"), 2) AS avg_ctat
FROM olaa_data
WHERE "Booking Status" = '{S}'
GROUP BY "Pickup Location", "Vehicle Type"
ORDER BY avg_vtat;

--22.VTAT & CTAT by vehicle type
CREATE VIEW avg_vtat_ctat_byvehicle As
SELECT "Vehicle Type",
ROUND(AVG("Avg VTAT"), 2) AS avg_vtat,
ROUND(AVG("Avg CTAT"), 2) AS avg_ctat
FROM olaa_data
WHERE "Booking Status" = '{S}'
GROUP BY "Vehicle Type"
ORDER BY avg_vtat;


--Revenue & Fare Analysis

--23.Average fare per ride/vehicle type
CREATE VIEW avg_fare_per_vehicle As
SELECT "Vehicle Type",
ROUND(AVG("Fare"), 2) AS avg_fare
FROM olaa_data
WHERE "Booking Status" = '{S}'
GROUP BY "Vehicle Type";

--24.Fare revenue by vehicle type
CREATE VIEW fare_rev_per_vehicle As
SELECT "Vehicle Type", SUM("Fare") AS total_revenue
FROM olaa_data
WHERE "Booking Status" = '{S}'
GROUP BY "Vehicle Type"
ORDER BY total_revenue DESC;

--25.Fare distribution (Low, Mid, High fares)
CREATE VIEW total_rides_by_faredist As
SELECT 
CASE 
WHEN "Fare" < 500 THEN 'Low Fare'
WHEN "Fare"  BETWEEN 500 AND 1000 THEN 'Mid Fare'
ELSE 'High Fare'
END AS fare_category,
COUNT(*) AS total_rides
FROM olaa_data
WHERE "Booking Status" = '{S}'
GROUP BY fare_category
ORDER BY total_rides DESC;

--26.Total revenue per day/week/month/Quarter
CREATE VIEW total_rev_per_day As
SELECT "Booking date", COUNT("Booking ID") AS total_booking,
SUM("Fare") AS total_revenue
FROM olaa_data
WHERE "Booking Status" = '{S}'
GROUP BY "Booking date"
ORDER BY "Booking date";

CREATE VIEW total_rev_per_week As
SELECT "Day of Week", COUNT("Booking ID") AS total_booking,
SUM("Fare") AS total_revenue
FROM olaa_data
WHERE "Booking Status" = '{S}'
GROUP BY "Day of Week"
ORDER BY "Day of Week";

CREATE VIEW total_rev_per_month As
SELECT EXTRACT(MONTH FROM "Booking date") AS month, 
COUNT("Booking ID") AS total_booking, SUM("Fare") AS total_revenue
FROM olaa_data
WHERE "Booking Status" = '{S}'
GROUP BY month
ORDER BY month;

CREATE VIEW total_rev_per_quarter As
SELECT EXTRACT(QUARTER FROM "Booking date") AS quarter,
COUNT("Booking ID") AS total_bookings, SUM("Fare") AS total_revenue
FROM olaa_data
WHERE "Booking Status" = '{S}'
GROUP BY quarter
ORDER BY quarter;


--Cancellations & Service Issues

--27.Customer cancellation rate
CREATE VIEW  cust_cancel_rate As
WITH  cte AS(SELECT "Booking Status","Booking ID",
CASE WHEN "Booking Status"='{CC}' THEN 1 ELSE 0 END AS cancel_type
FROM olaa_data),
cte2 AS (SELECT  COUNT("Booking ID") AS total_booking,
SUM(cancel_type) AS sum_type
FROM cte
WHERE "Booking Status" IN ('{CC}','{CD}'))

SELECT ROUND(((sum_type*100.00)/total_booking),2) AS cancel_rate
FROM cte2


--28.Driver cancellation rate
CREATE VIEW driver_cancel_rate As
WITH  cte AS(SELECT "Booking Status","Booking ID",
CASE WHEN "Booking Status"='{CD}' THEN 1 ELSE 0 END AS cancel_type
FROM olaa_data),
cte2 AS (SELECT  COUNT("Booking ID") AS total_booking,
SUM(cancel_type) AS sum_type
FROM cte
WHERE "Booking Status" IN ('{CC}','{CD}'))

SELECT ROUND(((sum_type*100)/total_booking),2) AS cancel_rate
FROM cte2

--29.Vehicle type with highest cancellation rate
CREATE VIEW vehicle_type_highest_cancel_rate As
WITH cte AS (SELECT "Vehicle Type",
COUNT("Booking ID") AS total_cancelled_booking
FROM olaa_data
WHERE "Booking Status" IN ('{CC}','{CD}')
GROUP BY 1),
total AS(
SELECT "Vehicle Type",COUNT("Booking ID") AS total_count
FROM olaa_data
GROUP BY 1)

SELECT c."Vehicle Type",(total_cancelled_booking*100.0 /total_count) AS cancellation_rate
FROM cte AS c
INNER JOIN total AS t
ON c."Vehicle Type" =t."Vehicle Type"
ORDER BY cancellation_rate DESC
LIMIT 1;


--Booking & Demand Analysis

--30.What is the total number of bookings for each payment method?
CREATE VIEW total_booking_payment As
SELECT "Payment Method", COUNT(*) AS total_bookings
FROM olaa_data
GROUP BY "Payment Method"
ORDER BY total_bookings DESC;

--31.What is the average ride distance per booking (daily, weekly, monthly)?
CREATE VIEW avg_ride_dist_day As
SELECT "Booking date", ROUND(AVG("Ride Distance"), 2) AS avg_ride_distance
FROM olaa_data
GROUP BY "Booking date"
ORDER BY "Booking date";

CREATE VIEW avg_ride_dist_week As
SELECT "Day of Week" AS week, ROUND(AVG("Ride Distance"), 2) AS avg_ride_distance
FROM olaa_data
GROUP BY week
ORDER BY week;

CREATE VIEW avg_ride_dist_month As
SELECT EXTRACT(MONTH FROM "Booking date") AS month, ROUND(AVG("Ride Distance"), 2) AS avg_ride_distance
FROM olaa_data
GROUP BY month
ORDER BY month;

CREATE VIEW avg_ride_dist_quarter As
SELECT EXTRACT(QUARTER FROM "Booking date") AS quarter, ROUND(AVG("Ride Distance"), 2) AS avg_ride_distance
FROM olaa_data
GROUP BY quarter
ORDER BY quarter;

--32.What is the peak time for bookings (hour of the day)?
CREATE VIEW total_booking_hour_of_day As
SELECT EXTRACT(HOUR FROM "Booking time") AS hour_of_day, COUNT(*) AS total_bookings
FROM olaa_data
GROUP BY hour_of_day
ORDER BY hour_of_day ;

--Payment Method Analysis

--33.What is the distribution of bookings by payment method?
CREATE VIEW booking_dist_by_payment As
SELECT "Payment Method", COUNT(*) AS total_bookings
FROM olaa_data
GROUP BY "Payment Method"
ORDER BY total_bookings DESC;

--34.What is the average fare per booking for each payment method?
CREATE VIEW avg_fare_by_payment As
SELECT "Payment Method", ROUND(AVG("Fare"), 2) AS avg_fare
FROM olaa_data
GROUP BY "Payment Method"
ORDER BY avg_fare DESC;

--35.What percentage of bookings are paid by each payment method?
CREATE VIEW booking_percent_by_payment As
SELECT 
 "Payment Method", 
ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM olaa_data),2) AS payment_method_percentage
FROM olaa_data
GROUP BY  "Payment Method";

--36.Is there a correlation between payment method and booking success rate?
CREATE VIEW payment_correlate_booking_success As
SELECT 
"Payment Method",
(SUM(CASE WHEN "Booking Status" = '{S}' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS success_rate
FROM olaa_data
GROUP BY "Payment Method";


--Ride Distance & Operational Efficiency

--37.What is the distribution of bookings based on ride distance?
CREATE VIEW dist_cat_total_bookings As
SELECT 
CASE 
WHEN "Ride Distance" <= 5 THEN 'Short Distance'
WHEN "Ride Distance" BETWEEN 5 AND 15 THEN 'Medium Distance'
ELSE 'Long Distance'
END AS distance_category,
COUNT(*) AS total_bookings
FROM olaa_data
GROUP BY distance_category
ORDER BY total_bookings DESC;

--38.What is the average booking fare for different ride distances?
CREATE VIEW ride_dist_correlate_booking_fare As
SELECT 
   CASE 
WHEN "Ride Distance" <= 5 THEN 'Short Distance'
 WHEN "Ride Distance" BETWEEN 5 AND 15 THEN 'Medium Distance'
ELSE 'Long Distance'
END AS distance_category,
ROUND(AVG("Fare"), 2) AS avg_fare
FROM olaa_data
GROUP BY distance_category
ORDER BY avg_fare DESC;

--39.How does ride distance correlate with booking success or cancellations?
CREATE VIEW ride_dist_correlate_booking_cancel As
SELECT 
CASE 
 WHEN "Ride Distance"<= 5 THEN 'Short Distance'
WHEN "Ride Distance" BETWEEN 5 AND 15 THEN 'Medium Distance'
ELSE 'Long Distance'
END AS distance_category,
ROUND((SUM(CASE WHEN "Booking Status" IN ('{CC}','{CD}') THEN 1 ELSE 0 END) * 100.0) / COUNT(*),2)AS cancellation_rate
FROM olaa_data
GROUP BY distance_category
ORDER BY cancellation_rate DESC;


--Cancellations & Service Issues

--40.What is the cancellation rate by payment method?
CREATE VIEW cancel_rate_payment_method As
SELECT 
"Payment Method", 
ROUND((SUM(CASE WHEN "Booking Status" IN ('{CD}','{CC}') THEN 1 ELSE 0 END) * 100.0) / COUNT(*),2) AS cancellation_rate
FROM olaa_data
GROUP BY "Payment Method";

-- 41.How does the cancellation rate differ by ride distance?
CREATE VIEW cancel_rate_ride_dist As
SELECT 
    CASE 
 WHEN "Ride Distance"<= 5 THEN 'Short Distance'
WHEN "Ride Distance" BETWEEN 5 AND 15 THEN 'Medium Distance'
ELSE 'Long Distance'
END AS distance_category,
    ROUND((SUM(CASE WHEN "Booking Status" IN ('{CD}','{CC}') THEN 1 ELSE 0 END) * 100.0) / COUNT(*),2) AS cancellation_rate
FROM olaa_data
GROUP BY distance_category
ORDER BY cancellation_rate DESC;

--Revenue & Fare Analysis

--42.What is the fare distribution across different ride distances?
CREATE VIEW total_rev_fare_dist As
SELECT
 CASE 
 WHEN "Ride Distance"<= 5 THEN 'Short Distance'
WHEN "Ride Distance" BETWEEN 5 AND 15 THEN 'Medium Distance'
ELSE 'Long Distance'
END AS distance_category,
    SUM("Fare") AS total_revenue
FROM olaa_data
WHERE "Booking Status" = '{S}'
GROUP BY distance_category
ORDER BY total_revenue DESC;

--What is the average fare per booking based on payment method?
CREATE VIEW payment_method_avg_fare As
SELECT 
"Payment Method",
 ROUND(AVG("Fare"), 2) AS avg_fare
FROM olaa_data
WHERE "Booking Status" = '{S}'
GROUP BY "Payment Method"
ORDER BY avg_fare DESC;

--Customer & Driver Ratings

--43.How does the customer rating vary by payment method?
CREATE VIEW payment_method_cust_rating As
SELECT 
"Payment Method", 
ROUND(AVG("Customer Rating"), 2) AS avg_customer_rating
FROM olaa_data
WHERE "Customer Rating" IS NOT NULL
GROUP BY "Payment Method";

--44.How does the driver rating vary by payment method?
CREATE VIEW payment_method_driver_rating As
SELECT 
"Payment Method", 
ROUND(AVG("Driver Ratings"), 2) AS avg_driver_rating
FROM olaa_data
WHERE "Driver Ratings" IS NOT NULL
GROUP BY "Payment Method";

--45.How does the driver rating correlate with booking distance?
CREATE VIEW distance_category_avg_driver_rating As
SELECT 
    CASE 
 WHEN "Ride Distance"<= 5 THEN 'Short Distance'
WHEN "Ride Distance" BETWEEN 5 AND 15 THEN 'Medium Distance'
ELSE 'Long Distance'
END AS distance_category,
    ROUND(AVG("Driver Ratings"), 2) AS avg_driver_rating
FROM olaa_data
WHERE "Driver Ratings" IS NOT NULL
GROUP BY distance_category;

--46.What is the total booking count based on time of the day (e.g., morning, evening)?
CREATE VIEW time_wise_total_bookings As
SELECT 
 CASE 
WHEN EXTRACT(HOUR FROM "Booking time") BETWEEN 6 AND 12 THEN 'Morning'
WHEN EXTRACT(HOUR FROM "Booking time") BETWEEN 13 AND 18 THEN 'Afternoon'
ELSE 'Evening'
END AS time_of_day,COUNT(*) AS total_bookings
FROM olaa_data
GROUP BY time_of_day;

