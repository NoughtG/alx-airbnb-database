-- database_index.sql
-- SQL script to create indexes for improving query performance in the AirBnB database
-- Target DBMS: PostgreSQL

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
