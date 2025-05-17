# Database Advanced Script
This directory contains SQL scripts with advanced queries for the AirBnB database, focusing on complex joins.

## Files
**joins_queries.sql**: SQL script with three queries demonstrating different types of joins.
Query 1: INNER JOIN to retrieve bookings and their corresponding users.
Query 2: LEFT JOIN to retrieve all properties and their reviews, including properties without reviews.
Query 3: FULL OUTER JOIN to retrieve all users and bookings, including those without matches.
Target DBMS: PostgreSQL.

**subqueries.sql**: SQL script with two queries demonstrating correlated and non-correlated subqueries.
Query 1: Non-correlated subquery to find properties with an average rating greater than 4.0.
Query 2: Correlated subquery to find users who have made more than 3 bookings.
Target DBMS: PostgreSQL.

**aggregations_and_window_functions.sql**: SQL script with two queries demonstrating aggregation and window functions.
Query 1: Aggregation using COUNT and GROUP BY to find the total number of bookings per user.
Query 2: Window functions (ROW_NUMBER, RANK) to rank properties by total number of bookings.
Target DBMS: PostgreSQL.

**database_index.sql**: SQL script to create indexes for optimizing query performance.
Creates indexes on high-usage columns in User, Booking, and Property tables.
Target DBMS: PostgreSQL.

**index_performance.md**: Documentation analyzing query performance before and after adding indexes.
Includes EXPLAIN ANALYZE results for two queries.
Provides recommendations for scaling and maintenance.

## Prerequisites
The database schema must be created using database-script-0x01/schema.sql.
Sample data should be populated using database-script-0x02/seed.sql.
PostgreSQL must have the uuid-ossp extension enabled (CREATE EXTENSION IF NOT EXISTS "uuid-ossp";).

## Usage

### Set up PostgreSQL:
Ensure PostgreSQL is installed and the airbnb database exists.
Create the schema and populate data:psql -U <username> -d airbnb -f database-script-0x01/schema.sql
psql -U <username> -d airbnb -f database-script-0x02/seed.sql

### Run the queries:
Open a PostgreSQL client: psql -U <username> -d airbnb
Execute the queries:\i database-adv-script/joins_queries.sql

Or copy-paste individual queries from joins_queries.sql into the client.
Replace <username> with your PostgreSQL username.

### View results:
Each query returns results based on the sample data.
Use SELECT * FROM <table> to inspect related data if needed.
