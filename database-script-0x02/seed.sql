-- seed.sql
-- SQL script to populate the AirBnB database with sample data
-- Target DBMS: PostgreSQL

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Insert Users (2 guests, 2 hosts, 1 admin)
INSERT INTO "User" (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at) VALUES
    (uuid_generate_v4(), 'Alice', 'Smith', 'alice.smith@email.com', 'hash123', '+1234567890', 'guest', '2025-01-01 10:00:00'),
    (uuid_generate_v4(), 'Bob', 'Johnson', 'bob.johnson@email.com', 'hash456', '+1987654321', 'guest', '2025-01-02 12:00:00'),
    (uuid_generate_v4(), 'Charlie', 'Brown', 'charlie.brown@email.com', 'hash789', '+1122334455', 'host', '2025-01-03 14:00:00'),
    (uuid_generate_v4(), 'Diana', 'Lee', 'diana.lee@email.com', 'hash012', '+1445566778', 'host', '2025-01-04 16:00:00'),
    (uuid_generate_v4(), 'Emma', 'Admin', 'emma.admin@email.com', 'hash345', NULL, 'admin', '2025-01-05 18:00:00');

-- Insert Properties (4 properties, 2 per host)
-- Assume host_id values from User table (replace with actual UUIDs after insertion)
INSERT INTO Property (property_id, host_id, name, description, location, pricepernight, created_at, updated_at) VALUES
    (uuid_generate_v4(), (SELECT user_id FROM "User" WHERE email = 'charlie.brown@email.com'), 'Cozy NYC Loft', 'A modern loft in downtown Manhattan', 'New York, NY, USA', 150.00, '2025-01-10 09:00:00', '2025-01-10 09:00:00'),
    (uuid_generate_v4(), (SELECT user_id FROM "User" WHERE email = 'charlie.brown@email.com'), 'Brooklyn Apartment', 'Spacious apartment with city views', 'Brooklyn, NY, USA', 120.00, '2025-01-11 11:00:00', '2025-01-11 11:00:00'),
    (uuid_generate_v4(), (SELECT user_id FROM "User" WHERE email = 'diana.lee@email.com'), 'Paris Studio', 'Charming studio near Eiffel Tower', 'Paris, France', 200.00, '2025-01-12 13:00:00', '2025-01-12 13:00:00'),
    (uuid_generate_v4(), (SELECT user_id FROM "User" WHERE email = 'diana.lee@email.com'), 'Countryside Cottage', 'Rustic cottage in Provence', 'Provence, France', 100.00, '2025-01-13 15:00:00', '2025-01-13 15:00:00');

-- Insert Bookings (6 bookings by guests for various properties)
INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at) VALUES
    (uuid_generate_v4(), (SELECT property_id FROM Property WHERE name = 'Cozy NYC Loft'), (SELECT user_id FROM "User" WHERE email = 'alice.smith@email.com'), '2025-06-01', '2025-06-04', 450.00, 'confirmed', '2025-05-01 10:00:00'),
    (uuid_generate_v4(), (SELECT property_id FROM Property WHERE name = 'Brooklyn Apartment'), (SELECT user_id FROM "User" WHERE email = 'alice.smith@email.com'), '2025-07-10', '2025-07-12', 240.00, 'pending', '2025-05-02 12:00:00'),
    (uuid_generate_v4(), (SELECT property_id FROM Property WHERE name = 'Paris Studio'), (SELECT user_id FROM "User" WHERE email = 'bob.johnson@email.com'), '2025-08-15', '2025-08-20', 1000.00, 'confirmed', '2025-05-03 14:00:00'),
    (uuid_generate_v4(), (SELECT property_id FROM Property WHERE name = 'Countryside Cottage'), (SELECT user_id FROM "User" WHERE email = 'bob.johnson@email.com'), '2025-09-01', '2025-09-05', 400.00, 'canceled', '2025-05-04 16:00:00'),
    (uuid_generate_v4(), (SELECT property_id FROM Property WHERE name = 'Cozy NYC Loft'), (SELECT user_id FROM "User" WHERE email = 'bob.johnson@email.com'), '2025-10-01', '2025-10-03', 300.00, 'confirmed', '2025-05-05 18:00:00'),
    (uuid_generate_v4(), (SELECT property_id FROM Property WHERE name = 'Paris Studio'), (SELECT user_id FROM "User" WHERE email = 'alice.smith@email.com'), '2025-11-10', '2025-11-12', 400.00, 'confirmed', '2025-05-06 20:00:00');

-- Insert Payments (5 payments for confirmed/pending bookings)
INSERT INTO Payment (payment_id, booking_id, amount, payment_date, payment_method) VALUES
    (uuid_generate_v4(), (SELECT booking_id FROM Booking WHERE total_price = 450.00 AND user_id = (SELECT user_id FROM "User" WHERE email = 'alice.smith@email.com')), 450.00, '2025-05-01 11:00:00', 'credit_card'),
    (uuid_generate_v4(), (SELECT booking_id FROM Booking WHERE total_price = 240.00 AND user_id = (SELECT user_id FROM "User" WHERE email = 'alice.smith@email.com')), 120.00, '2025-05-02 13:00:00', 'paypal'),
    (uuid_generate_v4(), (SELECT booking_id FROM Booking WHERE total_price = 1000.00 AND user_id = (SELECT user_id FROM "User" WHERE email = 'bob.johnson@email.com')), 1000.00, '2025-05-03 15:00:00', 'stripe'),
    (uuid_generate_v4(), (SELECT booking_id FROM Booking WHERE total_price = 300.00 AND user_id = (SELECT user_id FROM "User" WHERE email = 'bob.johnson@email.com')), 300.00, '2025-05-05 19:00:00', 'credit_card'),
    (uuid_generate_v4(), (SELECT booking_id FROM Booking WHERE total_price = 400.00 AND user_id = (SELECT user_id FROM "User" WHERE email = 'alice.smith@email.com')), 400.00, '2025-05-06 21:00:00', 'stripe');

-- Insert Reviews (4 reviews for properties by guests who booked them)
INSERT INTO Review (review_id, property_id, user_id, rating, comment, created_at) VALUES
    (uuid_generate_v4(), (SELECT property_id FROM Property WHERE name = 'Cozy NYC Loft'), (SELECT user_id FROM "User" WHERE email = 'alice.smith@email.com'), 5, 'Amazing stay, great location!', '2025-06-05 10:00:00'),
    (uuid_generate_v4(), (SELECT property_id FROM Property WHERE name = 'Paris Studio'), (SELECT user_id FROM "User" WHERE email = 'bob.johnson@email.com'), 4, 'Lovely studio, but a bit noisy.', '2025-08-21 12:00:00'),
    (uuid_generate_v4(), (SELECT property_id FROM Property WHERE name = 'Cozy NYC Loft'), (SELECT user_id FROM "User" WHERE email = 'bob.johnson@email.com'), 4, 'Comfortable and clean, highly recommend.', '2025-10-04 14:00:00'),
    (uuid_generate_v4(), (SELECT property_id FROM Property WHERE name = 'Paris Studio'), (SELECT user_id FROM "User" WHERE email = 'alice.smith@email.com'), 5, 'Perfect for a Paris getaway!', '2025-11-13 16:00:00');

-- Insert Messages (4 messages between guests and hosts)
INSERT INTO Message (message_id, sender_id, recipient_id, message_body, sent_at) VALUES
    (uuid_generate_v4(), (SELECT user_id FROM "User" WHERE email = 'alice.smith@email.com'), (SELECT user_id FROM "User" WHERE email = 'charlie.brown@email.com'), 'Is the NYC Loft available for June?', '2025-04-15 09:00:00'),
    (uuid_generate_v4(), (SELECT user_id FROM "User" WHERE email = 'charlie.brown@email.com'), (SELECT user_id FROM "User" WHERE email = 'alice.smith@email.com'), 'Yes, it’s available. Would you like to book?', '2025-04-15 10:00:00'),
    (uuid_generate_v4(), (SELECT user_id FROM "User" WHERE email = 'bob.johnson@email.com'), (SELECT user_id FROM "User" WHERE email = 'diana.lee@email.com'), 'Can I bring a pet to the Paris Studio?', '2025-04-20 11:00:00'),
    (uuid_generate_v4(), (SELECT user_id FROM "User" WHERE email = 'diana.lee@email.com'), (SELECT user_id FROM "User" WHERE email = 'bob.johnson@email.com'), 'Sorry, no pets allowed in the studio.', '2025-04-20 12:00:00');
