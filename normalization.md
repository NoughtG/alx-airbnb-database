# AirBnB Database Normalization
This document outlines the process of reviewing the AirBnB database schema to ensure it is in the Third Normal Form (3NF). The schema was analyzed for compliance with 1NF, 2NF, and 3NF, and potential issues were evaluated. No changes were made, as the identified issues were deemed acceptable design choices.

## Normalization Principles
First Normal Form (1NF): Attributes are atomic, and each table has a primary key.
Second Normal Form (2NF): Must be in 1NF, with no partial dependencies (non-key attributes depend on the entire primary key).
Third Normal Form (3NF): Must be in 2NF, with no transitive dependencies (non-key attributes do not depend on other non-key attributes).

## Schema Review
### 1NF Check
All attributes are atomic (e.g., first_name, location, total_price are single-valued).
Each table has a primary key (user_id, property_id, etc.).
Conclusion: The schema is in 1NF.

### 2NF Check
All tables have single-column primary keys (no composite keys), so partial dependencies are not possible.
Non-key attributes (e.g., name, start_date) depend on the entire primary key.
Conclusion: The schema is in 2NF.

### 3NF Check
#### User:
Attributes: user_id (PK), first_name, last_name, email (UNIQUE), password_hash, phone_number, role, created_at
Dependencies: user_id → first_name, last_name, email, password_hash, phone_number, role, created_at.
No transitive dependencies (e.g., first_name doesn’t determine last_name).
Result: In 3NF.

#### Property:
Attributes: property_id (PK), host_id (FK), name, description, location, pricepernight, created_at, updated_at
Dependencies: property_id → host_id, name, description, location, pricepernight, created_at, updated_at.
location (VARCHAR) may store structured data (e.g., “New York, NY, USA”), potentially leading to redundancy if city or country is repeated. This could be normalized into a separate table (e.g., Location with city, state, country).
Design Choice: Storing location as a single string is intentional for simplicity, accepting minor redundancy.
Result: In 3NF

#### Booking:
Attributes: booking_id (PK), property_id (FK), user_id (FK), start_date, end_date, total_price, status, created_at
Dependencies: booking_id → property_id, user_id, start_date, end_date, total_price, status, created_at.
total_price is derived from Property.pricepernight and the duration (end_date - start_date), introducing a transitive dependency.
Design Choice: Retaining total_price is intentional for auditing and performance (to lock in the price at booking time), accepting the denormalization.
Result: In 3NF

#### Payment:
Attributes: payment_id (PK), booking_id (FK), amount, payment_date, payment_method
Dependencies: payment_id → booking_id, amount, payment_date, payment_method.
No transitive dependencies (e.g., amount relates to booking_id, a foreign key).
Result: In 3NF.

#### Review:
Attributes: review_id (PK), property_id (FK), user_id (FK), rating, comment, created_at
Dependencies: review_id → property_id, user_id, rating, comment, created_at.
No transitive dependencies (e.g., rating and comment are independent).
Result: In 3NF.

#### Message:
Attributes: message_id (PK), sender_id (FK), recipient_id (FK), message_body, sent_at
Dependencies: message_id → sender_id, recipient_id, message_body, sent_at.
No transitive dependencies.
Result: In 3NF.



### Identified Issues and Design Choices
Two potential 3NF violations were identified but accepted as intentional design choices:

#### Property.location:
Issue: location (VARCHAR) may cause redundancy if it includes structured data (e.g., repeated city names).
Decision: Kept as a single string for simplicity, accepting minor redundancy over creating a separate Location table.

#### Booking.total_price:
Issue: total_price is derived from Property.pricepernight and the booking duration, creating a transitive dependency.
Decision: Retained for auditing and performance (to ensure price consistency), accepting the denormalization.



## Final Schema
The schema is in 3NF, with Property.location and Booking.total_price noted as intentional deviations for practical reasons.

