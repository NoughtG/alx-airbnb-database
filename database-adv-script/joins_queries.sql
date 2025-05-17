-- joins_queries.sql
-- SQL script with complex join queries for the AirBnB database
-- Target DBMS: PostgreSQL

-- Query 1: INNER JOIN to retrieve all bookings and the users who made them
-- Joins Booking and User tables on user_id
-- Returns booking details and user details for bookings with matching users
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name,
    u.last_name,
    u.email
FROM Booking b
INNER JOIN "User" u ON b.user_id = u.user_id
ORDER BY b.created_at;

-- Query 2: LEFT JOIN to retrieve all properties and their reviews, including properties without reviews
-- Joins Property and Review tables on property_id
-- Returns all properties, with review details or NULL if no reviews exist
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at AS review_created_at
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id
ORDER BY p.name, r.created_at;

-- Query 3: FULL OUTER JOIN to retrieve all users and all bookings
-- Joins User and Booking tables on user_id
-- Returns all users (even without bookings) and all bookings (even without users, unlikely due to FK)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    b.booking_id,
    b.start_date,
    b.total_price,
    b.status
FROM "User" u
FULL OUTER JOIN Booking b ON u.user_id = b.user_id
ORDER BY u.last_name, b.start_date;
