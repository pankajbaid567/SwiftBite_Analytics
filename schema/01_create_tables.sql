-- ============================================================================
-- SwiftBite Analytics — Database Schema (DDL)
-- ============================================================================
-- Platform : PostgreSQL 14+
-- Author   : Pankaj Baid
-- Purpose  : Create all 8 tables for the SwiftBite food delivery analytics DB
-- ============================================================================

-- Drop tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS delivery CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS menu_items CASCADE;
DROP TABLE IF EXISTS delivery_partners CASCADE;
DROP TABLE IF EXISTS restaurants CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================================================
-- DIMENSION TABLES
-- ============================================================================

-- 1. Users — Customer profiles
CREATE TABLE users (
    user_id       SERIAL        PRIMARY KEY,
    name          VARCHAR(100)  NOT NULL,
    email         VARCHAR(150)  UNIQUE NOT NULL,
    phone         VARCHAR(15)   NOT NULL,
    signup_date   DATE          NOT NULL,
    city          VARCHAR(50)   NOT NULL,
    is_premium    BOOLEAN       DEFAULT FALSE
);

COMMENT ON TABLE users IS 'Customer profiles with demographic and membership data';
COMMENT ON COLUMN users.is_premium IS 'SwiftBite Gold membership status';

-- 2. Restaurants — Partner restaurant profiles
CREATE TABLE restaurants (
    restaurant_id     SERIAL        PRIMARY KEY,
    name              VARCHAR(150)  NOT NULL,
    city              VARCHAR(50)   NOT NULL,
    cuisine_type      VARCHAR(50)   NOT NULL,
    rating            DECIMAL(2,1)  CHECK (rating >= 1.0 AND rating <= 5.0),
    avg_delivery_time INT,
    is_active         BOOLEAN       DEFAULT TRUE,
    partner_since     DATE          NOT NULL
);

COMMENT ON TABLE restaurants IS 'Restaurant partner details and performance metrics';
COMMENT ON COLUMN restaurants.cuisine_type IS 'Primary cuisine: North Indian, South Indian, Chinese, Italian, Fast Food, etc.';

-- 3. Menu Items — Restaurant menu catalog
CREATE TABLE menu_items (
    item_id        SERIAL        PRIMARY KEY,
    restaurant_id  INT           NOT NULL REFERENCES restaurants(restaurant_id),
    item_name      VARCHAR(100)  NOT NULL,
    category       VARCHAR(50)   NOT NULL,
    price          DECIMAL(8,2)  NOT NULL CHECK (price > 0),
    is_veg         BOOLEAN       NOT NULL
);

COMMENT ON TABLE menu_items IS 'Menu catalog linked to restaurants';
COMMENT ON COLUMN menu_items.category IS 'Starters, Main Course, Desserts, Beverages, Combos';

-- 4. Delivery Partners — Fleet information
CREATE TABLE delivery_partners (
    partner_id       SERIAL        PRIMARY KEY,
    partner_name     VARCHAR(100)  NOT NULL,
    phone            VARCHAR(15)   NOT NULL,
    city             VARCHAR(50)   NOT NULL,
    vehicle_type     VARCHAR(20)   NOT NULL CHECK (vehicle_type IN ('Bike', 'Scooter', 'Bicycle')),
    rating           DECIMAL(2,1)  CHECK (rating >= 1.0 AND rating <= 5.0),
    total_deliveries INT           DEFAULT 0,
    join_date        DATE          NOT NULL
);

COMMENT ON TABLE delivery_partners IS 'Delivery fleet partner profiles';

-- ============================================================================
-- FACT TABLES
-- ============================================================================

-- 5. Orders — Core transaction table
CREATE TABLE orders (
    order_id       SERIAL         PRIMARY KEY,
    user_id        INT            NOT NULL REFERENCES users(user_id),
    restaurant_id  INT            NOT NULL REFERENCES restaurants(restaurant_id),
    order_date     TIMESTAMP      NOT NULL,
    order_amount   DECIMAL(10,2)  NOT NULL CHECK (order_amount >= 0),
    discount       DECIMAL(10,2)  DEFAULT 0 CHECK (discount >= 0),
    final_amount   DECIMAL(10,2)  NOT NULL CHECK (final_amount >= 0),
    status         VARCHAR(20)    NOT NULL CHECK (status IN (
                       'Placed', 'Confirmed', 'Preparing',
                       'Out for Delivery', 'Delivered', 'Cancelled'
                   )),
    rating         INT            CHECK (rating >= 1 AND rating <= 5)
);

COMMENT ON TABLE orders IS 'Core order transaction table — one row per order';
COMMENT ON COLUMN orders.final_amount IS 'order_amount - discount';

-- Indexes for common query patterns
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_restaurant_id ON orders(restaurant_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);

-- 6. Order Items — Line items (bridge between orders and menu_items)
CREATE TABLE order_items (
    order_item_id  SERIAL         PRIMARY KEY,
    order_id       INT            NOT NULL REFERENCES orders(order_id),
    item_id        INT            NOT NULL REFERENCES menu_items(item_id),
    quantity       INT            NOT NULL CHECK (quantity >= 1),
    item_price     DECIMAL(8,2)   NOT NULL CHECK (item_price > 0),
    subtotal       DECIMAL(10,2)  NOT NULL CHECK (subtotal > 0)
);

COMMENT ON TABLE order_items IS 'Line-item details for each order';
COMMENT ON COLUMN order_items.subtotal IS 'quantity × item_price';

CREATE INDEX idx_order_items_order_id ON order_items(order_id);

-- 7. Payments — Payment processing records
CREATE TABLE payments (
    payment_id      SERIAL         PRIMARY KEY,
    order_id        INT            NOT NULL REFERENCES orders(order_id),
    payment_method  VARCHAR(20)    NOT NULL CHECK (payment_method IN (
                        'UPI', 'Credit Card', 'Debit Card', 'Wallet', 'COD'
                    )),
    payment_status  VARCHAR(20)    NOT NULL CHECK (payment_status IN (
                        'Success', 'Failed', 'Refunded'
                    )),
    payment_date    TIMESTAMP      NOT NULL,
    amount          DECIMAL(10,2)  NOT NULL CHECK (amount >= 0)
);

COMMENT ON TABLE payments IS 'Payment gateway transaction records';

CREATE INDEX idx_payments_order_id ON payments(order_id);

-- 8. Delivery — Delivery tracking and logistics
CREATE TABLE delivery (
    delivery_id           SERIAL        PRIMARY KEY,
    order_id              INT           NOT NULL REFERENCES orders(order_id),
    partner_id            INT           NOT NULL REFERENCES delivery_partners(partner_id),
    pickup_time           TIMESTAMP,
    delivery_time         TIMESTAMP,
    delivery_duration_mins INT,
    delivery_status       VARCHAR(20)   NOT NULL CHECK (delivery_status IN (
                              'On Time', 'Late', 'Early'
                          )),
    distance_km           DECIMAL(5,2)  CHECK (distance_km > 0)
);

COMMENT ON TABLE delivery IS 'Delivery tracking data — one row per delivered order';

CREATE INDEX idx_delivery_order_id ON delivery(order_id);
CREATE INDEX idx_delivery_partner_id ON delivery(partner_id);

-- ============================================================================
-- SCHEMA VERIFICATION
-- ============================================================================
-- Run this to verify all tables were created:
-- SELECT table_name FROM information_schema.tables
-- WHERE table_schema = 'public' ORDER BY table_name;
