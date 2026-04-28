# 🗄️ SwiftBite Analytics — Database Schema Design

## Overview

The SwiftBite database follows a **star schema** design optimized for analytical queries. It consists of **4 dimension tables** and **4 fact/bridge tables**, modeling the complete food delivery lifecycle from customer signup to order delivery.

---

## Entity Relationship Diagram

```
┌─────────────┐       ┌──────────────┐       ┌───────────────┐
│   users      │       │  restaurants  │       │  menu_items    │
│─────────────│       │──────────────│       │───────────────│
│ user_id (PK) │       │ rest_id (PK)  │──────▶│ item_id (PK)   │
│ name         │       │ name          │       │ rest_id (FK)   │
│ email        │       │ city          │       │ item_name      │
│ phone        │       │ cuisine_type  │       │ category       │
│ signup_date  │       │ rating        │       │ price          │
│ city         │       │ avg_delivery  │       │ is_veg         │
│ is_premium   │       │ is_active     │       └───────┬───────┘
└──────┬──────┘       │ partner_since │               │
       │              └──────┬───────┘               │
       │                     │                        │
       ▼                     ▼                        ▼
┌──────────────────────────────────┐    ┌──────────────────────┐
│            orders                 │    │     order_items       │
│──────────────────────────────────│    │──────────────────────│
│ order_id (PK)                    │───▶│ order_item_id (PK)   │
│ user_id (FK → users)             │    │ order_id (FK)        │
│ rest_id (FK → restaurants)       │    │ item_id (FK)         │
│ order_date                       │    │ quantity             │
│ order_amount                     │    │ item_price           │
│ discount                         │    │ subtotal             │
│ final_amount                     │    └──────────────────────┘
│ status                           │
│ rating                           │
└──────┬───────────────┬──────────┘
       │               │
       ▼               ▼
┌────────────────┐ ┌──────────────────────────┐
│   payments      │ │       delivery            │
│────────────────│ │──────────────────────────│
│ payment_id (PK)│ │ delivery_id (PK)          │
│ order_id (FK)  │ │ order_id (FK)             │
│ payment_method │ │ partner_id (FK)           │
│ payment_status │ │ pickup_time               │
│ payment_date   │ │ delivery_time             │
│ amount         │ │ delivery_duration_mins    │
└────────────────┘ │ delivery_status           │
                   │ distance_km               │
                   └───────────┬──────────────┘
                               │
                               ▼
                   ┌──────────────────────┐
                   │  delivery_partners    │
                   │──────────────────────│
                   │ partner_id (PK)       │
                   │ partner_name          │
                   │ phone                 │
                   │ city                  │
                   │ vehicle_type          │
                   │ rating                │
                   │ total_deliveries      │
                   │ join_date             │
                   └──────────────────────┘
```

---

## Table Definitions

### 1. `users` (Dimension Table)

Customer profiles with demographic and behavioral attributes.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| `user_id` | SERIAL | PRIMARY KEY | Unique customer identifier |
| `name` | VARCHAR(100) | NOT NULL | Customer full name |
| `email` | VARCHAR(150) | UNIQUE, NOT NULL | Customer email |
| `phone` | VARCHAR(15) | NOT NULL | Phone number |
| `signup_date` | DATE | NOT NULL | Account creation date |
| `city` | VARCHAR(50) | NOT NULL | Customer's city |
| `is_premium` | BOOLEAN | DEFAULT FALSE | SwiftBite Gold membership |

**Mimics**: Swiggy/Zomato user registration data  
**Row Count**: ~1,000 users

---

### 2. `restaurants` (Dimension Table)

Restaurant partner profiles.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| `restaurant_id` | SERIAL | PRIMARY KEY | Unique restaurant identifier |
| `name` | VARCHAR(150) | NOT NULL | Restaurant name |
| `city` | VARCHAR(50) | NOT NULL | Operating city |
| `cuisine_type` | VARCHAR(50) | NOT NULL | Primary cuisine category |
| `rating` | DECIMAL(2,1) | CHECK(1.0–5.0) | Average customer rating |
| `avg_delivery_time` | INT | | Typical delivery time (minutes) |
| `is_active` | BOOLEAN | DEFAULT TRUE | Currently accepting orders |
| `partner_since` | DATE | NOT NULL | Onboarding date |

**Mimics**: Swiggy restaurant listing data  
**Row Count**: ~200 restaurants

---

### 3. `menu_items` (Dimension Table)

Menu catalog for each restaurant.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| `item_id` | SERIAL | PRIMARY KEY | Unique menu item ID |
| `restaurant_id` | INT | FK → restaurants | Parent restaurant |
| `item_name` | VARCHAR(100) | NOT NULL | Dish name |
| `category` | VARCHAR(50) | NOT NULL | Starters, Main Course, Desserts, Beverages |
| `price` | DECIMAL(8,2) | NOT NULL | Item price in ₹ |
| `is_veg` | BOOLEAN | NOT NULL | Vegetarian flag |

**Mimics**: Swiggy menu scrape data  
**Row Count**: ~800 items (avg 4 items per restaurant)

---

### 4. `delivery_partners` (Dimension Table)

Delivery fleet information.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| `partner_id` | SERIAL | PRIMARY KEY | Unique partner ID |
| `partner_name` | VARCHAR(100) | NOT NULL | Partner full name |
| `phone` | VARCHAR(15) | NOT NULL | Contact number |
| `city` | VARCHAR(50) | NOT NULL | Operating city |
| `vehicle_type` | VARCHAR(20) | NOT NULL | Bike, Scooter, Bicycle |
| `rating` | DECIMAL(2,1) | | Partner rating |
| `total_deliveries` | INT | DEFAULT 0 | Lifetime deliveries |
| `join_date` | DATE | NOT NULL | Fleet join date |

**Mimics**: Delivery partner HR/operations data  
**Row Count**: ~500 partners

---

### 5. `orders` (Fact Table — Core)

Central transaction table recording every order placed.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| `order_id` | SERIAL | PRIMARY KEY | Unique order identifier |
| `user_id` | INT | FK → users | Customer who placed the order |
| `restaurant_id` | INT | FK → restaurants | Fulfilling restaurant |
| `order_date` | TIMESTAMP | NOT NULL | Order placed timestamp |
| `order_amount` | DECIMAL(10,2) | NOT NULL | Gross order value |
| `discount` | DECIMAL(10,2) | DEFAULT 0 | Discount applied |
| `final_amount` | DECIMAL(10,2) | NOT NULL | Net amount after discount |
| `status` | VARCHAR(20) | NOT NULL | Placed, Confirmed, Preparing, Out for Delivery, Delivered, Cancelled |
| `rating` | INT | CHECK(1–5) | Post-delivery customer rating |

**Mimics**: Swiggy/Zomato order transaction logs  
**Row Count**: ~5,000 orders

---

### 6. `order_items` (Bridge Table)

Line-item detail for each order (supports multi-item orders).

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| `order_item_id` | SERIAL | PRIMARY KEY | Unique line item ID |
| `order_id` | INT | FK → orders | Parent order |
| `item_id` | INT | FK → menu_items | Menu item ordered |
| `quantity` | INT | NOT NULL, CHECK(≥1) | Quantity ordered |
| `item_price` | DECIMAL(8,2) | NOT NULL | Price at time of order |
| `subtotal` | DECIMAL(10,2) | NOT NULL | quantity × item_price |

**Mimics**: E-commerce cart/line-item data  
**Row Count**: ~12,000 line items

---

### 7. `payments` (Fact Table)

Payment processing records.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| `payment_id` | SERIAL | PRIMARY KEY | Unique payment ID |
| `order_id` | INT | FK → orders | Associated order |
| `payment_method` | VARCHAR(20) | NOT NULL | UPI, Credit Card, Debit Card, Wallet, COD |
| `payment_status` | VARCHAR(20) | NOT NULL | Success, Failed, Refunded |
| `payment_date` | TIMESTAMP | NOT NULL | Payment timestamp |
| `amount` | DECIMAL(10,2) | NOT NULL | Amount charged |

**Mimics**: Payment gateway (Razorpay/Paytm) logs  
**Row Count**: ~5,000 payments

---

### 8. `delivery` (Fact Table)

Delivery tracking and logistics data.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| `delivery_id` | SERIAL | PRIMARY KEY | Unique delivery ID |
| `order_id` | INT | FK → orders | Associated order |
| `partner_id` | INT | FK → delivery_partners | Assigned delivery partner |
| `pickup_time` | TIMESTAMP | | Restaurant pickup timestamp |
| `delivery_time` | TIMESTAMP | | Customer doorstep timestamp |
| `delivery_duration_mins` | INT | | Total delivery time in minutes |
| `delivery_status` | VARCHAR(20) | NOT NULL | On Time, Late, Early |
| `distance_km` | DECIMAL(5,2) | | Delivery distance |

**Mimics**: Logistics/fleet management data  
**Row Count**: ~4,500 deliveries (excludes cancelled orders)

---

## Referential Integrity Map

```
users ──────────────────┐
                        ├──▶ orders ──┬──▶ order_items ◀── menu_items ◀── restaurants
restaurants ────────────┘             ├──▶ payments
                                      └──▶ delivery ◀── delivery_partners
```

---

## Real-World Dataset Mapping

This schema mimics data commonly found in:
- **Kaggle**: "Zomato Restaurants Dataset", "Swiggy Food Delivery Dataset"
- **Industry**: Swiggy's internal analytics warehouse, DoorDash public datasets
- **Structure**: Follows the dimensional modeling pattern used by analytics teams at food-tech companies
