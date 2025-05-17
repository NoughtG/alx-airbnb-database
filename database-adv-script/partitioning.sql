-- partitioning.sql
-- SQL script to implement range partitioning on Booking table by start_date
-- Target DBMS: PostgreSQL

-- Step 1: Drop foreign key constraints (not supported on partitioned tables)
ALTER TABLE Booking DROP CONSTRAINT IF EXISTS booking_property_id_fkey;
ALTER TABLE Booking DROP CONSTRAINT IF EXISTS booking_user_id_fkey;

-- Step 2: Create new parent Booking table (partitioned, no data)
CREATE TABLE booking_new (
    booking_id UUID NOT NULL,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'confirmed', 'canceled')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (start_date);

-- Step 3: Create child tables for 2023, 2024, 2025
CREATE TABLE booking_2023 PARTITION OF booking_new
    FOR VALUES FROM ('2023-01-01') TO ('2023-12-31');
CREATE TABLE booking_2024 PARTITION OF booking_new
    FOR VALUES FROM ('2024-01-01') TO ('2024-12-31');
CREATE TABLE booking_2025 PARTITION OF booking_new
    FOR VALUES FROM ('2025-01-01') TO ('2025-12-31');

-- Step 4: Add indexes to child tables
-- Primary key on booking_id
ALTER TABLE booking_2023 ADD CONSTRAINT booking_2023_pkey PRIMARY KEY (booking_id);
ALTER TABLE booking_2024 ADD CONSTRAINT booking_2024_pkey PRIMARY KEY (booking_id);
ALTER TABLE booking_2025 ADD CONSTRAINT booking_2025_pkey PRIMARY KEY (booking_id);

-- Index on start_date
CREATE INDEX idx_booking_2023_start_date ON booking_2023 (start_date);
CREATE INDEX idx_booking_2024_start_date ON booking_2024 (start_date);
CREATE INDEX idx_booking_2025_start_date ON booking_2025 (start_date);

-- Indexes on user_id, property_id (from database_index.sql)
CREATE INDEX idx_booking_2023_user_id ON booking_2023 (user_id);
CREATE INDEX idx_booking_2024_user_id ON booking_2024 (user_id);
CREATE INDEX idx_booking_2025_user_id ON booking_2025 (user_id);
CREATE INDEX idx_booking_2023_property_id ON booking_2023 (property_id);
CREATE INDEX idx_booking_2024_property_id ON booking_2024 (property_id);
CREATE INDEX idx_booking_2025_property_id ON booking_2025 (property_id);

-- Step 5: Migrate data from old Booking table to new partitioned table
INSERT INTO booking_new
SELECT * FROM Booking
WHERE start_date >= '2023-01-01' AND start_date <= '2025-12-31';

-- Step 6: Drop old Booking table and rename new one
DROP TABLE Booking;
ALTER TABLE booking_new RENAME TO Booking;

-- Step 7: Test query performance on partitioned table
EXPLAIN ANALYZE
SELECT *
FROM Booking
WHERE start_date BETWEEN '2024-01-01' AND '2024-12-31';
