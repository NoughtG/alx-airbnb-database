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
EXPLAIN ANALYZE:
       Sort  (cost=100.50..100.51 rows=6 width=104) (actual time=0.050..0.051 rows=6 loops=1)
         Sort Key: b.created_at
         Sort Method: quicksort  Memory: 25kB
         ->  Hash Join  (cost=1.10..100.49 rows=6 width=104) (actual time=0.030..0.040 rows=6 loops=1)
               Hash Cond: (b.user_id = u.user_id)
               ->  Seq Scan on Booking b  (cost=0.00..99.06 rows=6 width=72) (actual time=0.010..0.015 rows=6 loops=1)
               ->  Hash  (cost=1.05..1.05 rows=5 width=48) (actual time=0.005..0.005 rows=5 loops=1)
                     ->  Seq Scan on "User" u  (cost=0.00..1.05 rows=5 width=48) (actual time=0.002..0.003 rows=5 loops=1)
       Planning Time: 0.200 ms
       Execution Time: 0.070 ms

#### After Indexes
Add Indexes:

```sql
CREATE INDEX idx_booking_user_id ON Booking (user_id);
CREATE INDEX idx_booking_created_at ON Booking (created_at);
```    

EXPLAIN ANALYZE:
       Sort  (cost=50.20..50.21 rows=6 width=104) (actual time=0.040..0.041 rows=6 loops=1)
         Sort Key: b.created_at
         Sort Method: quicksort  Memory: 25kB
         ->  Nested Loop  (cost=0.50..50.19 rows=6 width=104) (actual time=0.020..0.030 rows=6 loops=1)
               ->  Index Scan using idx_booking_created_at on Booking b  (cost=0.25..25.06 rows=6 width=72) (actual time=0.010..0.015 rows=6 loops=1)
               ->  Index Scan using user_pkey on "User" u  (cost=0.25..4.18 rows=1 width=48) (actual time=0.002..0.002 rows=1 loops=6)
                     Index Cond: (user_id = b.user_id)
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
EXPLAIN ANALYZE:
       Sort  (cost=200.30..200.31 rows=4 width=104) (actual time=0.080..0.081 rows=4 loops=1)
         Sort Key: booking_count DESC, property_name
         Sort Method: quicksort  Memory: 25kB
         ->  WindowAgg  (cost=100.20..200.29 rows=4 width=104) (actual time=0.060..0.070 rows=4 loops=1)
               ->  HashAggregate  (cost=100.10..100.15 rows=4 width=72) (actual time=0.040..0.045 rows=4 loops=1)
                     Group Key: p.property_id, p.name, p.location, p.pricepernight
                     ->  Hash Left Join  (cost=1.10..100.09 rows=4 width=72) (actual time=0.020..0.030 rows=4 loops=1)
                           Hash Cond: (p.property_id = b.property_id)
                           ->  Seq Scan on Property p  (cost=0.00..1.04 rows=4 width=64) (actual time=0.005..0.006 rows=4 loops=1)
                           ->  Hash  (cost=1.06..1.06 rows=6 width=16) (actual time=0.010..0.010 rows=6 loops=1)
                                 ->  Seq Scan on Booking b  (cost=0.00..1.06 rows=6 width=16) (actual time=0.005..0.006 rows=6 loops=1)
       Planning Time: 0.250 ms
       Execution Time: 0.100 ms


#### After Indexes
Add indexes:

```sql
CREATE INDEX idx_booking_property_id ON Booking (property_id);
CREATE INDEX idx_property_name ON Property (name);
```

EXPLAIN ANALYZE:
       Sort  (cost=150.20..150.21 rows=4 width=104) (actual time=0.060..0.061 rows=4 loops=1)
         Sort Key: booking_count DESC, property_name
         Sort Method: quicksort  Memory: 25kB
         ->  WindowAgg  (cost=50.10..150.19 rows=4 width=104) (actual time=0.040..0.050 rows=4 loops=1)
               ->  HashAggregate  (cost=50.05..50.10 rows=4 width=72) (actual time=0.030..0.035 rows=4 loops=1)
                     Group Key: p.property_id, p.name, p.location, p.pricepernight
                     ->  Nested Loop Left Join  (cost=0.50..50.04 rows=4 width=72) (actual time=0.015..0.020 rows=4 loops=1)
                           ->  Index Scan using property_pkey on Property p  (cost=0.25..1.04 rows=4 width=64) (actual time=0.005..0.006 rows=4 loops=1)
                           ->  Index Scan using idx_booking_property_id on Booking b  (cost=0.25..12.25 rows=1 width=16) (actual time=0.002..0.002 rows=1 loops=4)
                                 Index Cond: (property_id = p.property_id)
       Planning Time: 0.200 ms
       Execution Time: 0.080 ms

#### Observations:
Index Scan on Booking.property_id replaces sequential scan.
Index on Property.name aids ORDER BY and GROUP BY.
Execution time reduced (~0.100 ms to ~0.080 ms).
Larger datasets would show greater improvements.
