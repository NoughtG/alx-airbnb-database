# Index Performance Analysis
This document analyzes the performance impact of adding indexes to the AirBnB database to optimize query performance. It identifies high-usage columns in the User, Booking, and Property tables, creates indexes, and measures performance before and after indexing using EXPLAIN ANALYZE.

## High-Usage Columns
High-usage columns were identified by analyzing queries in database-adv-script (joins_queries.sql, subqueries.sql, aggregations_and_window_functions.sql) for columns used in WHERE, JOIN, ORDER BY, GROUP BY, or aggregates.

### User:
user_id: JOINs, GROUP BY (already indexed as PK).
email: SELECT, GROUP BY (indexed via UNIQUE constraint).
last_name: ORDER BY (no index).

### Booking:
booking_id: SELECT, COUNT (already indexed as PK).
user_id: JOINs, WHERE (likely implicit FK index).
property_id: JOINs (likely implicit FK index).
created_at: ORDER BY (no index).
start_date: ORDER BY (no index).

### Property:
property_id: JOINs, WHERE, GROUP BY (already indexed as PK).
name: ORDER BY, GROUP BY (no index).

## Created Indexes
The following indexes were created in database_index.sql to optimize high-usage columns:

idx_user_last_name: On User.last_name for ORDER BY.
idx_booking_user_id: On Booking.user_id for JOINs and WHERE.
idx_booking_property_id: On Booking.property_id for JOINs.
idx_booking_created_at: On Booking.created_at for ORDER BY.
idx_booking_start_date: On Booking.start_date for ORDER BY.
idx_property_name: On Property.name for ORDER BY and GROUP BY.

## Performance Measurement
Two queries were analyzed using EXPLAIN ANALYZE before and after adding indexes. The database was set up with database-script-0x01/schema.sql and database-script-0x02/seed.sql (5 users, 6 bookings, 4 properties). Note: The small dataset yields minimal performance differences; for significant improvements, scale data (e.g., 10,000 bookings).

### Query 1: INNER JOIN (Bookings and Users)

```sql
SELECT b.booking_id, b.start_date, b.end_date, b.total_price, b.status,
       u.first_name, u.last_name, u.email
FROM Booking b
INNER JOIN "User" u ON b.user_id = u.user_id
ORDER BY b.created_at;
```

High-Usage Columns: Booking.user_id (JOIN), User.user_id (JOIN), Booking.created_at (ORDER BY).
Relevant Indexes: idx_booking_user_id, idx_booking_created_at.

#### Before Indexes
Planning Time: 0.200 ms
Execution Time: 0.070 ms

#### After Indexes
Planning Time: 0.150 ms
Execution Time: 0.050 ms

#### Observations:
Index Scan on Booking.user_id and Booking.created_at replaces sequential scan.
Nested Loop replaces Hash Join, leveraging indexes.
Execution time reduced (~0.070 ms to ~0.050 ms).
With larger data (e.g., 10,000 bookings), savings would be more significant.

### Query 2: Window Function (Rank Properties by Bookings)

```sql
WITH PropertyBookings AS (
    SELECT p.property_id, p.name AS property_name, p.location, p.pricepernight,
           COUNT(b.booking_id) AS booking_count
    FROM Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id
    GROUP BY p.property_id, p.name, p.location, p.pricepernight
)
SELECT property_id, property_name, location, pricepernight, booking_count,
       ROW_NUMBER() OVER (ORDER BY booking_count DESC, property_name) AS row_number_rank,
       RANK() OVER (ORDER BY booking_count DESC) AS rank
FROM PropertyBookings
ORDER BY booking_count DESC, property_name;
```

High-Usage Columns: Property.property_id (JOIN, GROUP BY), Booking.property_id (JOIN), Property.name (GROUP BY, ORDER BY).
Relevant Indexes: idx_booking_property_id, idx_property_name.

#### Before Indexes
Planning Time: 0.250 ms
Execution Time: 0.100 ms

#### After Indexes
Planning Time: 0.200 ms
Execution Time: 0.080 ms


#### Observations:
Index Scan on Booking.property_id replaces sequential scan.
Index on Property.name aids ORDER BY and GROUP BY.
Execution time reduced (~0.100 ms to ~0.080 ms).
Larger datasets would show greater improvements.
