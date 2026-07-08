-- PostgreSQL Database Schema for Privelgo
-- Enable PostGIS Extension for geo-spatial operations
CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. Users Table (Passengers, Drivers, Operators, Admins)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('passenger', 'driver', 'operator', 'admin')),
    phone VARCHAR(20),
    photo_url VARCHAR(255),
    reward_points INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Operators Table (For Operator Portals)
CREATE TABLE operators (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Bus Stops Table (With PostGIS Geometry)
CREATE TABLE bus_stops (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location GEOMETRY(Point, 4326) NOT NULL, -- Geo location (Lon, Lat)
    shelter_available BOOLEAN DEFAULT FALSE,
    facilities JSONB DEFAULT '{}'::jsonb, -- e.g., {"seats": true, "digital_display": true, "lighting": true}
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_bus_stops_location ON bus_stops USING gist(location);

-- 4. Routes Table
CREATE TABLE routes (
    id SERIAL PRIMARY KEY,
    route_number VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL, -- e.g., "Colombo - Kandy"
    start_stop_id INTEGER REFERENCES bus_stops(id),
    end_stop_id INTEGER REFERENCES bus_stops(id),
    distance_km NUMERIC(5, 2) NOT NULL,
    duration_mins INTEGER NOT NULL,
    operating_hours VARCHAR(100) NOT NULL, -- e.g., "05:00 - 22:00"
    frequency_mins INTEGER NOT NULL,
    base_fare NUMERIC(6, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Route Stops Mapping Table (Establishes stop order along a route)
CREATE TABLE route_stops (
    route_id INTEGER REFERENCES routes(id) ON DELETE CASCADE,
    stop_id INTEGER REFERENCES bus_stops(id) ON DELETE CASCADE,
    sequence_order INTEGER NOT NULL,
    distance_from_start NUMERIC(5, 2) NOT NULL,
    fare_stage INTEGER NOT NULL,
    PRIMARY KEY (route_id, stop_id)
);

-- 6. Drivers Table (Link user with Operator)
CREATE TABLE drivers (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    operator_id INTEGER REFERENCES operators(id) ON DELETE CASCADE,
    license_number VARCHAR(50) UNIQUE NOT NULL,
    license_expiry DATE,
    is_active BOOLEAN DEFAULT TRUE
);

-- 7. Buses Table
CREATE TABLE buses (
    id SERIAL PRIMARY KEY,
    bus_number VARCHAR(20) UNIQUE NOT NULL, -- Plate number
    bus_name VARCHAR(100), -- Brand/Nickname of private bus
    operator_id INTEGER REFERENCES operators(id),
    driver_id INTEGER REFERENCES users(id), -- Current driver
    route_id INTEGER REFERENCES routes(id),
    capacity INTEGER NOT NULL DEFAULT 40,
    current_passengers INTEGER DEFAULT 0,
    crowdedness_level VARCHAR(20) DEFAULT 'seats_available' CHECK (crowdedness_level IN ('seats_available', 'moderately_crowded', 'full')),
    is_ac BOOLEAN DEFAULT FALSE,
    is_wifi BOOLEAN DEFAULT FALSE,
    is_accessible BOOLEAN DEFAULT FALSE,
    current_status VARCHAR(20) DEFAULT 'inactive' CHECK (current_status IN ('active', 'inactive', 'break', 'delayed')),
    latitude NUMERIC(9, 6),
    longitude NUMERIC(9, 6),
    speed NUMERIC(5, 2) DEFAULT 0.0,
    direction NUMERIC(5, 2) DEFAULT 0.0, -- Heading degree
    delay_minutes INTEGER DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. Reviews Table
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    bus_id INTEGER REFERENCES buses(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    cleanliness_score INTEGER CHECK (cleanliness_score BETWEEN 1 AND 5),
    comfort_score INTEGER CHECK (comfort_score BETWEEN 1 AND 5),
    driver_behavior_score INTEGER CHECK (driver_behavior_score BETWEEN 1 AND 5),
    punctuality_score INTEGER CHECK (punctuality_score BETWEEN 1 AND 5),
    photos JSONB DEFAULT '[]'::jsonb, -- Array of photo URLs
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. Digital Tickets Table
CREATE TABLE tickets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    route_id INTEGER REFERENCES routes(id),
    fare NUMERIC(6, 2) NOT NULL,
    qr_code VARCHAR(255) UNIQUE NOT NULL,
    ticket_type VARCHAR(20) DEFAULT 'single' CHECK (ticket_type IN ('single', 'daily_pass', 'monthly_pass', 'student_pass')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'used', 'expired')),
    purchase_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. Complaints Table
CREATE TABLE complaints (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    bus_id INTEGER REFERENCES buses(id) ON DELETE CASCADE,
    category VARCHAR(50) CHECK (category IN ('unsafe_driving', 'overcrowding', 'harassment', 'wrong_fare', 'vehicle_issue', 'late_bus')),
    description TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'resolved')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 11. Saved Places (Favorites)
CREATE TABLE saved_places (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    place_name VARCHAR(100) NOT NULL, -- "Home", "Work", "University"
    address VARCHAR(255),
    location GEOMETRY(Point, 4326) NOT NULL
);
CREATE INDEX idx_saved_places_location ON saved_places USING gist(location);

-- 12. Travel History
CREATE TABLE travel_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    bus_id INTEGER REFERENCES buses(id),
    route_id INTEGER REFERENCES routes(id),
    fare NUMERIC(6, 2) NOT NULL,
    distance_km NUMERIC(5, 2) NOT NULL,
    duration_mins INTEGER NOT NULL,
    traveled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
