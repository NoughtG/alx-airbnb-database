-- aggregations_and_window_functions.sql
-- SQL script with aggregation and window function queries for the AirBnB database
-- Target DBMS: PostgreSQL

-- Query 1: Aggregation to find the total number of bookings per user
-- Uses COUNT and GROUP BY to summarize bookings, including users with zero bookings
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(b.booking_id) AS booking_count
FROM "User" u
LEFT JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.email
ORDER BY booking_count DESC, u.last_name;

-- Query 2: Window function to rank properties by total number of bookings
-- Uses ROW_NUMBER and RANK to assign rankings based on booking count
WITH PropertyBookings AS (
    SELECT 
        p.property_id,
        p.name AS property_name,
        p.location,
        p.pricepernight,
        COUNT(b.booking_id) AS booking_count
    FROM Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id
    GROUP BY p.property_id, p.name, p.location, p.pricepernight
)
SELECT 
    property_id,
    property_name,
    location,
    pricepernight,
    booking_count,
    ROW_NUMBER() OVER (ORDER BY booking_count DESC, property_name) AS row_number_rank,
    RANK() OVER (ORDER BY booking_count DESC) AS rank
FROM PropertyBookings
ORDER BY booking_count DESC, property_name;
