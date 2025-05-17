# Database Advanced Script
This directory contains SQL scripts with advanced queries for the AirBnB database, focusing on complex joins.
Files

joins_queries.sql: SQL script with three queries demonstrating different types of joins.
Query 1: INNER JOIN to retrieve bookings and their corresponding users.
Query 2: LEFT JOIN to retrieve all properties and their reviews, including properties without reviews.
Query 3: FULL OUTER JOIN to retrieve all users and bookings, including those without matches.
Target DBMS: PostgreSQL.

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



