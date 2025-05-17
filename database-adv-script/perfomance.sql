-- perfomance.sql
-- SQL script with initial and refactored queries for performance optimization
-- Target DBMS: PostgreSQL

-- Initial Query: Retrieve all bookings with user, property, and payment details
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status AS booking_status,
    u.first_name,
    u.last_name,
    u.email,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    pay.amount AS payment_amount,
    pay.payment_method,
    pay.payment_status
FROM Booking b
INNER JOIN "User" u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at;

-- Create Indexes: Optimize refactored query
CREATE INDEX idx_payment_booking_id ON Payment (booking_id);
CREATE INDEX idx_booking_status_created_at ON Booking (status, created_at);

-- Refactored Query: Optimized for performance
-- Reduced columns, added WHERE filter, removed ORDER BY
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
WHERE b.status = 'confirmed';
