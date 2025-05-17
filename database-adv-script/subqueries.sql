-- subqueries.sql
-- SQL script with correlated and non-correlated subqueries for the AirBnB database
-- Target DBMS: PostgreSQL

-- Query 1: Non-correlated subquery to find properties with average rating > 4.0
-- Subquery calculates the average rating per property
-- Outer query selects properties matching the subquery's high-rated property_ids
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight
FROM Property p
WHERE p.property_id IN (
    SELECT r.property_id
    FROM Review r
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY p.name;

-- Query 2: Correlated subquery to find users with more than 3 bookings
-- Subquery counts bookings for each user from the outer query
-- Outer query selects users where the booking count > 3
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email
FROM "User" u
WHERE (
    SELECT COUNT(*)
    FROM Booking b
    WHERE b.user_id = u.user_id
) > 3
ORDER BY u.last_name;
