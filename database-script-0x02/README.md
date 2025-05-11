# Database Script 0x02
This directory contains the SQL script to populate the AirBnB database with sample data.

## Files
seed.sql: SQL script to insert sample data into the User, Property, Booking, Payment, Review, and Message tables.
Adds 5 users (2 guests, 2 hosts, 1 admin), 4 properties, 6 bookings, 5 payments, 4 reviews, and 4 messages.
Uses realistic data reflecting real-world AirBnB usage.
Target DBMS: PostgreSQL.

## Prerequisites
The database schema must be created first using database-script-0x01/schema.sql.
PostgreSQL must have the uuid-ossp extension enabled (CREATE EXTENSION IF NOT EXISTS "uuid-ossp";).



