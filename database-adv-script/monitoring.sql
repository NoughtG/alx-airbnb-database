-- monitoring.sql
-- SQL script to monitor and refine database performance
-- Target DBMS: PostgreSQL

-- Step 1: Create new composite indexes for Query 1
CREATE INDEX idx_booking_2023_status_created_at_user_id ON booking_2023 (status, created_at, user_id);
CREATE INDEX idx_booking_2024_status_created_at_user_id ON booking_2024 (status, created_at, user_id);
CREATE INDEX idx_booking_2025_status_created_at_user_id ON booking_2025 (status, created_at, user_id);

-- Step 2: Create partial indexes for Query 3
CREATE INDEX idx_booking_2024_confirmed_recent ON booking_2024 (created_at, user_id, property_id)
WHERE status = 'confirmed' AND created_at >= '2023-01-01';
CREATE INDEX idx_booking_2025_confirmed_recent ON booking_2025 (created_at, user_id, property_id)
WHERE status = 'confirmed' AND created_at >= '2023-01-01';

-- Step 3: Update statistics for Property (Query 2)
ANALYZE Property;

-- Step 4: Alter status column to ENUM
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'canceled');
ALTER TABLE booking_2023 ALTER COLUMN status TYPE booking_status USING (status::booking_status);
ALTER TABLE booking_2024 ALTER COLUMN status TYPE booking_status USING (status::booking_status);
ALTER TABLE booking_2025 ALTER COLUMN status TYPE booking_status USING (status::booking_status);

-- Step 5: EXPLAIN ANALYZE for Query 1 (INNER JOIN)
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
WHERE b.status = 'confirmed'
ORDER BY b.created_at;

-- Step 6: EXPLAIN ANALYZE for Query 2 (Window Function)
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

-- Step 7: EXPLAIN ANALYZE for Query 3 (Multi-Join)
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
WHERE b.status = 'confirmed' AND b.created_at >= '2023-01-01';
