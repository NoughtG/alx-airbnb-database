-- monitoring_adjustments.sql
-- SQL script to implement schema adjustments for performance optimization
-- Target DBMS: PostgreSQL

-- Query 1 Adjustments: Optimize INNER JOIN query
-- Create composite index per partition for status, created_at, user_id
CREATE INDEX idx_booking_2023_status_created_at_user_id ON booking_2023 (status, created_at, user_id);
CREATE INDEX idx_booking_2024_status_created_at_user_id ON booking_2024 (status, created_at, user_id);
CREATE INDEX idx_booking_2025_status_created_at_user_id ON booking_2025 (status, created_at, user_id);

-- Revised Query 1: Add start_date filter
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.total_price,
    u.email,
    p.name AS property_name,
    pay.amount AS payment_amount,
    pay.payment_status
FROM Booking b
INNER JOIN "User" u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status = 'confirmed' AND b.created_at >= '2023-01-01' AND b.start_date >= '2023-01-01';

-- Query 2 Adjustments: Create materialized view for booking counts
CREATE MATERIALIZED VIEW property_booking_counts AS
SELECT 
    p.property_id,
    p.name AS property_name,
    COUNT(b.booking_id) AS booking_count
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name
WITH DATA;

-- Revised Query 2: Use materialized view
EXPLAIN ANALYZE
SELECT 
    property_id,
    property_name,
    booking_count,
    RANK() OVER (ORDER BY booking_count DESC) AS rank
FROM property_booking_counts
ORDER BY booking_count DESC, property_name;

-- Query 3 Adjustments: Optimize date range query
-- Create partial index for confirmed bookings in 2024
CREATE INDEX idx_booking_2024_status_confirmed ON booking_2024 (status) WHERE status = 'confirmed';

-- Revised Query 3: Select specific columns, add status filter
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.total_price,
    b.status
FROM Booking b
WHERE b.start_date BETWEEN '2024-01-01' AND '2024-12-31' AND b.status = 'confirmed';
