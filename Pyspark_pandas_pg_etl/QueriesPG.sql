select trip_distance, total_amount, tip_amount, fare_amount, tolls_amount 
from public.transformed_table
order by 2 desc;
--as we can see the data seems to be wrong, because the trip distance doesnt match with total_amount at all, 
--there are some outliers in the data


select location_pickup, count(trip_distance) as num_rides
from public.transformed_table
group by 1
order by 2 desc;
-- most frequent pick up location has id 236 

select location_dropoff, count(trip_distance) as num_rides
from public.transformed_table
group by 1
order by 2 desc;
-- most frequent dropoff location is number 236.


select round(cast(avg(total_amount/trip_distance) as decimal),2) as avg_amount_per_mile
from public.transformed_table
where trip_distance != 0
and trip_distance < 300
and total_amount between 1 and 1000;
-- average amount you have to pay per mile is 10.66 dollars 

SELECT EXTRACT(HOUR FROM tpep_pickup_datetime) AS Hour, AVG(fare_amount) as Average_Fare
FROM public.transformed_table
GROUP BY Hour
ORDER BY Average_Fare DESC
LIMIT 4;
-- the highest fare is during the night hours, particularly 11 pm and midnight.




SELECT distinct tpep_pickup_datetime::date as Date, 
       MAX(trip_distance) OVER (PARTITION BY tpep_pickup_datetime::date) as Max_Distance,
       FIRST_VALUE(fare_amount) OVER (PARTITION BY tpep_pickup_datetime::date ORDER BY trip_distance DESC) as Corresponding_Fare
FROM public.transformed_table
GROUP BY Date, trip_distance, fare_amount
ORDER BY Date;
-- max distance and its fare_amount for every day of the month


SELECT DATE(tpep_pickup_datetime) as Date, 
       fare_amount,
       SUM(fare_amount) OVER (ORDER BY DATE(tpep_pickup_datetime) ROWS UNBOUNDED PRECEDING) as Cumulative_Fare
FROM public.transformed_table
ORDER BY Date;
-- cumulative sum  for each day of the month





