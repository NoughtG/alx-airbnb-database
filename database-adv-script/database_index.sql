-- database_index.sql
-- SQL script to create indexes and analyze query performance in the AirBnB database
-- Target DBMS: PostgreSQL

-- Section 1: Create indexes for high-usage columns
-- Index on User.last_name for ORDER BY clauses
CREATE INDEX idx_user_last_name ON "User" (last_name);

-- Index on Booking.user_id for JOINs and WHERE clauses
CREATE INDEX idx_booking_user_id ON Booking (user_id);

-- Index on Booking.property_id for JOINs
CREATE INDEX idx_booking_property_id ON Booking (property_id);

-- Index on Booking.created_at for ORDER BY clauses
CREATE INDEX idx_booking_created_at ON Booking (created_at);

-- Index on Booking.start_date for ORDER BY clauses
CREATE INDEX idx_booking_start_date ON Booking (start_date);

-- Index on Property.name for ORDER BY and GROUP BY clauses
CREATE INDEX idx_property_name ON Property (name);

-- Section 2: Performance analysis with EXPLAIN ANALYZE
-- Query 1: INNER JOIN from joins_queries.sql
-- Tests Booking.user_id (JOIN), User.user_id (JOIN), Booking.created_at (ORDER BY)
EXPLAIN ANALYZE
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

-- Query 2: Window function from aggregations_and_window_functions.sql
-- Tests Property.property_id (JOIN, GROUP BY), Booking.property_id (JOIN), Property.name (ORDER BY, GROUP BY)
EXPLAIN ANALYZE
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
