"""
SwiftBite Analytics — Synthetic Data Generator
================================================
Generates realistic food delivery data for all 8 tables.
Outputs: SQL INSERT statements (02_seed_data.sql) + CSV files.

Requirements: pip install faker
Usage: python generate_data.py
"""

import random
import csv
import os
from datetime import datetime, timedelta
from pathlib import Path

# ============================================================================
# CONFIGURATION
# ============================================================================

NUM_USERS = 1000
NUM_RESTAURANTS = 200
NUM_DELIVERY_PARTNERS = 500
NUM_ORDERS = 5000
AVG_ITEMS_PER_ORDER = 2.5  # Average items per order

CITIES = [
    'Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai',
    'Pune', 'Kolkata', 'Jaipur', 'Lucknow', 'Ahmedabad'
]

CITY_WEIGHTS = [0.18, 0.16, 0.15, 0.10, 0.09, 0.08, 0.07, 0.06, 0.06, 0.05]

CUISINE_TYPES = [
    'North Indian', 'South Indian', 'Chinese', 'Italian',
    'Fast Food', 'Biryani', 'Street Food', 'Desserts',
    'Healthy', 'Continental'
]

RESTAURANT_NAMES = [
    'Spice Garden', 'Royal Biryani House', 'Pizza Paradise', 'Dragon Wok',
    'Burger Barn', 'Dosa Corner', 'Tandoori Nights', 'Pasta Palace',
    'Green Bowl', 'Kebab King', 'Chai & Chaat', 'Sushi Spot',
    'Wrap Republic', 'Cake Walk', 'Grill Master', 'Momos Junction',
    'Idli Factory', 'Paneer Point', 'Noodle Bar', 'Ice Cream Dreams',
    'Thali Express', 'Rolls & More', 'Salad Stop', 'Coffee Culture',
    'Butter Chicken Co', 'Dal Tadka House', 'Paratha Plaza',
    'Seafood Shack', 'Veg Delight', 'BBQ Nation Lite'
]

MENU_ITEMS_BY_CUISINE = {
    'North Indian': [
        ('Butter Chicken', 'Main Course', 320, False),
        ('Dal Makhani', 'Main Course', 220, True),
        ('Paneer Tikka', 'Starters', 250, True),
        ('Naan', 'Breads', 45, True),
        ('Gulab Jamun', 'Desserts', 80, True),
        ('Lassi', 'Beverages', 90, True),
    ],
    'South Indian': [
        ('Masala Dosa', 'Main Course', 120, True),
        ('Idli Sambar', 'Main Course', 80, True),
        ('Vada', 'Starters', 60, True),
        ('Filter Coffee', 'Beverages', 50, True),
        ('Uttapam', 'Main Course', 110, True),
        ('Rasam', 'Soups', 70, True),
    ],
    'Chinese': [
        ('Hakka Noodles', 'Main Course', 180, True),
        ('Manchurian', 'Starters', 200, True),
        ('Fried Rice', 'Main Course', 170, True),
        ('Spring Rolls', 'Starters', 150, True),
        ('Sweet Corn Soup', 'Soups', 120, True),
        ('Chilli Chicken', 'Starters', 240, False),
    ],
    'Italian': [
        ('Margherita Pizza', 'Main Course', 299, True),
        ('Pasta Arrabiata', 'Main Course', 270, True),
        ('Garlic Bread', 'Starters', 149, True),
        ('Tiramisu', 'Desserts', 200, True),
        ('Bruschetta', 'Starters', 180, True),
        ('Lemonade', 'Beverages', 100, True),
    ],
    'Fast Food': [
        ('Classic Burger', 'Main Course', 150, False),
        ('French Fries', 'Sides', 99, True),
        ('Chicken Wings', 'Starters', 220, False),
        ('Milkshake', 'Beverages', 130, True),
        ('Veggie Wrap', 'Main Course', 140, True),
        ('Onion Rings', 'Sides', 110, True),
    ],
    'Biryani': [
        ('Hyderabadi Chicken Biryani', 'Main Course', 280, False),
        ('Veg Biryani', 'Main Course', 220, True),
        ('Raita', 'Sides', 50, True),
        ('Salan', 'Sides', 60, True),
        ('Double Ka Meetha', 'Desserts', 120, True),
        ('Kebab Platter', 'Starters', 300, False),
    ],
    'Street Food': [
        ('Pav Bhaji', 'Main Course', 100, True),
        ('Pani Puri', 'Starters', 60, True),
        ('Vada Pav', 'Main Course', 40, True),
        ('Samosa', 'Starters', 30, True),
        ('Chole Bhature', 'Main Course', 120, True),
        ('Jalebi', 'Desserts', 70, True),
    ],
    'Desserts': [
        ('Chocolate Brownie', 'Desserts', 180, True),
        ('Ice Cream Sundae', 'Desserts', 200, True),
        ('Cheesecake', 'Desserts', 250, True),
        ('Rasmalai', 'Desserts', 120, True),
        ('Cold Coffee', 'Beverages', 150, True),
        ('Waffle', 'Desserts', 220, True),
    ],
    'Healthy': [
        ('Grilled Chicken Salad', 'Main Course', 280, False),
        ('Quinoa Bowl', 'Main Course', 320, True),
        ('Smoothie Bowl', 'Beverages', 250, True),
        ('Hummus Wrap', 'Main Course', 200, True),
        ('Protein Shake', 'Beverages', 180, True),
        ('Oats Bowl', 'Main Course', 150, True),
    ],
    'Continental': [
        ('Grilled Sandwich', 'Main Course', 180, True),
        ('Caesar Salad', 'Starters', 220, True),
        ('Mushroom Soup', 'Soups', 160, True),
        ('Fish & Chips', 'Main Course', 350, False),
        ('Pancakes', 'Desserts', 200, True),
        ('Iced Tea', 'Beverages', 90, True),
    ],
}

PAYMENT_METHODS = ['UPI', 'Credit Card', 'Debit Card', 'Wallet', 'COD']
PAYMENT_WEIGHTS = [0.40, 0.15, 0.12, 0.18, 0.15]

ORDER_STATUSES = ['Delivered', 'Delivered', 'Delivered', 'Delivered',
                  'Delivered', 'Delivered', 'Delivered', 'Delivered',
                  'Cancelled']  # ~89% delivered, ~11% cancelled

VEHICLE_TYPES = ['Bike', 'Scooter', 'Bicycle']
VEHICLE_WEIGHTS = [0.50, 0.35, 0.15]

FIRST_NAMES = [
    'Aarav', 'Vivaan', 'Aditya', 'Vihaan', 'Arjun', 'Sai', 'Reyansh',
    'Ayaan', 'Krishna', 'Ishaan', 'Ananya', 'Diya', 'Myra', 'Sara',
    'Aanya', 'Aadhya', 'Ira', 'Kiara', 'Riya', 'Priya', 'Rahul',
    'Amit', 'Neha', 'Pooja', 'Rohit', 'Sneha', 'Vikram', 'Meera',
    'Karan', 'Simran', 'Deepak', 'Ankita', 'Manish', 'Swati', 'Rajesh',
    'Kavita', 'Suresh', 'Nisha', 'Harish', 'Pallavi', 'Gaurav', 'Divya',
    'Nikhil', 'Shruti', 'Pankaj', 'Ritika', 'Varun', 'Megha', 'Akash', 'Tanya'
]

LAST_NAMES = [
    'Sharma', 'Verma', 'Gupta', 'Singh', 'Kumar', 'Patel', 'Reddy',
    'Nair', 'Joshi', 'Rao', 'Mehta', 'Shah', 'Iyer', 'Menon', 'Bhat',
    'Chopra', 'Malhotra', 'Kapoor', 'Banerjee', 'Das', 'Mukherjee',
    'Agarwal', 'Tiwari', 'Mishra', 'Pandey', 'Dubey', 'Saxena',
    'Srivastava', 'Chauhan', 'Yadav'
]

# ============================================================================
# DATA GENERATION FUNCTIONS
# ============================================================================

random.seed(42)  # Reproducibility

START_DATE = datetime(2025, 1, 1)
END_DATE = datetime(2025, 12, 31)


def random_date(start, end):
    """Generate a random datetime between start and end."""
    delta = end - start
    random_days = random.randint(0, delta.days)
    random_seconds = random.randint(0, 86399)
    return start + timedelta(days=random_days, seconds=random_seconds)


def random_date_only(start, end):
    """Generate a random date (no time component)."""
    delta = end - start
    random_days = random.randint(0, delta.days)
    return (start + timedelta(days=random_days)).date()


def escape_sql(s):
    """Escape single quotes for SQL."""
    return str(s).replace("'", "''")


def generate_phone():
    """Generate Indian phone number."""
    return f"+91{random.randint(7000000000, 9999999999)}"


def generate_email(name, idx):
    """Generate email from name."""
    clean = name.lower().replace(' ', '.').replace("'", "")
    domains = ['gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com']
    return f"{clean}{idx}@{random.choice(domains)}"


# ============================================================================
# GENERATE DATA
# ============================================================================

print("🚀 Generating SwiftBite synthetic data...")

# --- 1. USERS ---
users = []
for i in range(1, NUM_USERS + 1):
    fname = random.choice(FIRST_NAMES)
    lname = random.choice(LAST_NAMES)
    name = f"{fname} {lname}"
    email = generate_email(name, i)
    phone = generate_phone()
    signup_date = random_date_only(
        datetime(2024, 1, 1), datetime(2025, 6, 30)
    )
    city = random.choices(CITIES, weights=CITY_WEIGHTS, k=1)[0]
    is_premium = random.random() < 0.15  # 15% premium users
    users.append((i, name, email, phone, signup_date, city, is_premium))

print(f"  ✅ Generated {len(users)} users")

# --- 2. RESTAURANTS ---
restaurants = []
for i in range(1, NUM_RESTAURANTS + 1):
    base_name = random.choice(RESTAURANT_NAMES)
    city = random.choices(CITIES, weights=CITY_WEIGHTS, k=1)[0]
    name = f"{base_name} - {city[:3]}"
    cuisine = random.choice(CUISINE_TYPES)
    rating = round(random.uniform(2.5, 4.9), 1)
    avg_del_time = random.randint(20, 55)
    is_active = random.random() < 0.92  # 92% active
    partner_since = random_date_only(
        datetime(2023, 1, 1), datetime(2025, 3, 31)
    )
    restaurants.append((
        i, name, city, cuisine, rating, avg_del_time, is_active, partner_since
    ))

print(f"  ✅ Generated {len(restaurants)} restaurants")

# --- 3. MENU ITEMS ---
menu_items = []
item_id = 1
for rest in restaurants:
    rest_id = rest[0]
    cuisine = rest[3]
    items = MENU_ITEMS_BY_CUISINE.get(cuisine, MENU_ITEMS_BY_CUISINE['North Indian'])
    # Add some variation
    num_items = random.randint(3, len(items))
    selected = random.sample(items, num_items)
    for item_name, category, base_price, is_veg in selected:
        # Add price variation
        price = round(base_price * random.uniform(0.85, 1.25), 2)
        menu_items.append((item_id, rest_id, item_name, category, price, is_veg))
        item_id += 1

print(f"  ✅ Generated {len(menu_items)} menu items")

# --- 4. DELIVERY PARTNERS ---
delivery_partners = []
for i in range(1, NUM_DELIVERY_PARTNERS + 1):
    fname = random.choice(FIRST_NAMES)
    lname = random.choice(LAST_NAMES)
    name = f"{fname} {lname}"
    phone = generate_phone()
    city = random.choices(CITIES, weights=CITY_WEIGHTS, k=1)[0]
    vehicle = random.choices(VEHICLE_TYPES, weights=VEHICLE_WEIGHTS, k=1)[0]
    rating = round(random.uniform(3.0, 5.0), 1)
    total_del = random.randint(50, 3000)
    join_date = random_date_only(
        datetime(2023, 6, 1), datetime(2025, 6, 30)
    )
    delivery_partners.append((
        i, name, phone, city, vehicle, rating, total_del, join_date
    ))

print(f"  ✅ Generated {len(delivery_partners)} delivery partners")

# --- 5. ORDERS ---
# Create weighted user ordering (power-law: some users order a lot)
user_order_weights = []
for u in users:
    # Premium users order more
    weight = random.uniform(1, 10) if u[6] else random.uniform(0.1, 5)
    user_order_weights.append(weight)

# Create restaurant-to-menu mapping
rest_menu_map = {}
for mi in menu_items:
    rest_id = mi[1]
    if rest_id not in rest_menu_map:
        rest_menu_map[rest_id] = []
    rest_menu_map[rest_id].append(mi)

orders = []
all_order_items = []
payments = []
deliveries = []
order_item_id = 1
payment_id = 1
delivery_id = 1

active_rest_ids = [r[0] for r in restaurants if r[7]]  # is_active

for order_id in range(1, NUM_ORDERS + 1):
    # Select user (weighted)
    user = random.choices(users, weights=user_order_weights, k=1)[0]
    user_id = user[0]

    # Select restaurant (from same city preferably)
    user_city = user[5]
    same_city_rests = [r for r in restaurants if r[2] == user_city and r[7] is not False]
    if same_city_rests:
        rest = random.choice(same_city_rests)
    else:
        rest = random.choice(restaurants)
    rest_id = rest[0]

    # Order date (after user signup)
    user_signup = datetime.combine(user[4], datetime.min.time())
    order_start = max(user_signup, START_DATE)
    if order_start >= END_DATE:
        order_start = START_DATE
    order_date = random_date(order_start, END_DATE)

    # Bias towards lunch (12-2) and dinner (7-10) hours
    hour_bias = random.choices(
        range(24),
        weights=[1,0,0,0,0,0,1,2,3,3,4,8,10,8,4,3,3,4,6,10,10,8,4,2],
        k=1
    )[0]
    order_date = order_date.replace(hour=hour_bias)

    # Select items from restaurant menu
    rest_items = rest_menu_map.get(rest_id, [])
    if not rest_items:
        continue

    num_items_ordered = max(1, int(random.gauss(AVG_ITEMS_PER_ORDER, 1)))
    num_items_ordered = min(num_items_ordered, len(rest_items))
    selected_items = random.sample(rest_items, num_items_ordered)

    order_amount = 0
    for item in selected_items:
        qty = random.choices([1, 2, 3], weights=[0.65, 0.25, 0.10], k=1)[0]
        item_price = item[4]
        subtotal = round(qty * item_price, 2)
        order_amount += subtotal
        all_order_items.append((
            order_item_id, order_id, item[0], qty, item_price, subtotal
        ))
        order_item_id += 1

    order_amount = round(order_amount, 2)

    # Discount (30% of orders get discounts)
    if random.random() < 0.30:
        discount_pct = random.choice([0.05, 0.10, 0.15, 0.20])
        discount = round(order_amount * discount_pct, 2)
    else:
        discount = 0

    final_amount = round(order_amount - discount, 2)

    # Status
    status = random.choice(ORDER_STATUSES)

    # Rating (only for delivered orders)
    rating = None
    if status == 'Delivered' and random.random() < 0.70:
        rating = random.choices([1, 2, 3, 4, 5], weights=[0.03, 0.07, 0.15, 0.35, 0.40], k=1)[0]

    orders.append((
        order_id, user_id, rest_id, order_date, order_amount,
        discount, final_amount, status, rating
    ))

    # --- PAYMENT ---
    pay_method = random.choices(PAYMENT_METHODS, weights=PAYMENT_WEIGHTS, k=1)[0]
    if status == 'Cancelled':
        pay_status = random.choice(['Failed', 'Refunded', 'Success'])
    else:
        pay_status = 'Success'

    pay_date = order_date + timedelta(seconds=random.randint(5, 120))
    payments.append((
        payment_id, order_id, pay_method, pay_status, pay_date, final_amount
    ))
    payment_id += 1

    # --- DELIVERY (only for non-cancelled orders) ---
    if status != 'Cancelled':
        # Select partner from same city
        city_partners = [dp for dp in delivery_partners if dp[3] == rest[2]]
        if city_partners:
            partner = random.choice(city_partners)
        else:
            partner = random.choice(delivery_partners)

        pickup_time = order_date + timedelta(minutes=random.randint(10, 25))
        duration = random.randint(15, 60)
        delivery_time = pickup_time + timedelta(minutes=duration)

        if duration <= 30:
            del_status = 'On Time'
        elif duration <= 40:
            del_status = random.choice(['On Time', 'Late'])
        else:
            del_status = 'Late'

        # ~20% early
        if duration <= 20:
            del_status = 'Early'

        distance = round(random.uniform(1.5, 15.0), 2)

        deliveries.append((
            delivery_id, order_id, partner[0], pickup_time,
            delivery_time, duration, del_status, distance
        ))
        delivery_id += 1

print(f"  ✅ Generated {len(orders)} orders")
print(f"  ✅ Generated {len(all_order_items)} order items")
print(f"  ✅ Generated {len(payments)} payments")
print(f"  ✅ Generated {len(deliveries)} deliveries")

# ============================================================================
# OUTPUT: SQL INSERT STATEMENTS
# ============================================================================

output_dir = Path(__file__).parent.parent / 'schema'
output_file = output_dir / '02_seed_data.sql'

print(f"\n📝 Writing SQL INSERT statements to {output_file}...")

with open(output_file, 'w') as f:
    f.write("-- ============================================================================\n")
    f.write("-- SwiftBite Analytics — Seed Data (Auto-Generated)\n")
    f.write(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    f.write("-- ============================================================================\n\n")

    # Users
    f.write("-- USERS\n")
    for u in users:
        f.write(
            f"INSERT INTO users (user_id, name, email, phone, signup_date, city, is_premium) "
            f"VALUES ({u[0]}, '{escape_sql(u[1])}', '{escape_sql(u[2])}', '{u[3]}', "
            f"'{u[4]}', '{u[5]}', {str(u[6]).upper()});\n"
        )

    f.write("\n-- RESTAURANTS\n")
    for r in restaurants:
        f.write(
            f"INSERT INTO restaurants (restaurant_id, name, city, cuisine_type, rating, "
            f"avg_delivery_time, is_active, partner_since) "
            f"VALUES ({r[0]}, '{escape_sql(r[1])}', '{r[2]}', '{r[3]}', {r[4]}, "
            f"{r[5]}, {str(r[6]).upper()}, '{r[7]}');\n"
        )

    f.write("\n-- MENU ITEMS\n")
    for mi in menu_items:
        f.write(
            f"INSERT INTO menu_items (item_id, restaurant_id, item_name, category, price, is_veg) "
            f"VALUES ({mi[0]}, {mi[1]}, '{escape_sql(mi[2])}', '{mi[3]}', {mi[4]}, "
            f"{str(mi[5]).upper()});\n"
        )

    f.write("\n-- DELIVERY PARTNERS\n")
    for dp in delivery_partners:
        f.write(
            f"INSERT INTO delivery_partners (partner_id, partner_name, phone, city, "
            f"vehicle_type, rating, total_deliveries, join_date) "
            f"VALUES ({dp[0]}, '{escape_sql(dp[1])}', '{dp[2]}', '{dp[3]}', "
            f"'{dp[4]}', {dp[5]}, {dp[6]}, '{dp[7]}');\n"
        )

    f.write("\n-- ORDERS\n")
    for o in orders:
        rating_val = 'NULL' if o[8] is None else str(o[8])
        f.write(
            f"INSERT INTO orders (order_id, user_id, restaurant_id, order_date, "
            f"order_amount, discount, final_amount, status, rating) "
            f"VALUES ({o[0]}, {o[1]}, {o[2]}, '{o[3]}', {o[4]}, {o[5]}, "
            f"{o[6]}, '{o[7]}', {rating_val});\n"
        )

    f.write("\n-- ORDER ITEMS\n")
    for oi in all_order_items:
        f.write(
            f"INSERT INTO order_items (order_item_id, order_id, item_id, quantity, "
            f"item_price, subtotal) "
            f"VALUES ({oi[0]}, {oi[1]}, {oi[2]}, {oi[3]}, {oi[4]}, {oi[5]});\n"
        )

    f.write("\n-- PAYMENTS\n")
    for p in payments:
        f.write(
            f"INSERT INTO payments (payment_id, order_id, payment_method, "
            f"payment_status, payment_date, amount) "
            f"VALUES ({p[0]}, {p[1]}, '{p[2]}', '{p[3]}', '{p[4]}', {p[5]});\n"
        )

    f.write("\n-- DELIVERIES\n")
    for d in deliveries:
        f.write(
            f"INSERT INTO delivery (delivery_id, order_id, partner_id, pickup_time, "
            f"delivery_time, delivery_duration_mins, delivery_status, distance_km) "
            f"VALUES ({d[0]}, {d[1]}, {d[2]}, '{d[3]}', '{d[4]}', {d[5]}, "
            f"'{d[6]}', {d[7]});\n"
        )

    # Reset sequences
    f.write("\n-- RESET SEQUENCES\n")
    f.write(f"SELECT setval('users_user_id_seq', {NUM_USERS});\n")
    f.write(f"SELECT setval('restaurants_restaurant_id_seq', {NUM_RESTAURANTS});\n")
    f.write(f"SELECT setval('menu_items_item_id_seq', {item_id - 1});\n")
    f.write(f"SELECT setval('delivery_partners_partner_id_seq', {NUM_DELIVERY_PARTNERS});\n")
    f.write(f"SELECT setval('orders_order_id_seq', {NUM_ORDERS});\n")
    f.write(f"SELECT setval('order_items_order_item_id_seq', {order_item_id - 1});\n")
    f.write(f"SELECT setval('payments_payment_id_seq', {payment_id - 1});\n")
    f.write(f"SELECT setval('delivery_delivery_id_seq', {delivery_id - 1});\n")

print(f"  ✅ SQL file written: {output_file}")

# ============================================================================
# OUTPUT: CSV FILES
# ============================================================================

csv_dir = Path(__file__).parent
csv_dir.mkdir(exist_ok=True)

csv_configs = [
    ('users.csv', users, ['user_id', 'name', 'email', 'phone', 'signup_date', 'city', 'is_premium']),
    ('restaurants.csv', restaurants, ['restaurant_id', 'name', 'city', 'cuisine_type', 'rating', 'avg_delivery_time', 'is_active', 'partner_since']),
    ('menu_items.csv', menu_items, ['item_id', 'restaurant_id', 'item_name', 'category', 'price', 'is_veg']),
    ('delivery_partners.csv', delivery_partners, ['partner_id', 'partner_name', 'phone', 'city', 'vehicle_type', 'rating', 'total_deliveries', 'join_date']),
    ('orders.csv', orders, ['order_id', 'user_id', 'restaurant_id', 'order_date', 'order_amount', 'discount', 'final_amount', 'status', 'rating']),
    ('order_items.csv', all_order_items, ['order_item_id', 'order_id', 'item_id', 'quantity', 'item_price', 'subtotal']),
    ('payments.csv', payments, ['payment_id', 'order_id', 'payment_method', 'payment_status', 'payment_date', 'amount']),
    ('deliveries.csv', deliveries, ['delivery_id', 'order_id', 'partner_id', 'pickup_time', 'delivery_time', 'delivery_duration_mins', 'delivery_status', 'distance_km']),
]

for filename, data, headers in csv_configs:
    filepath = csv_dir / filename
    with open(filepath, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(headers)
        writer.writerows(data)

print(f"  ✅ CSV files written to {csv_dir}/")

# ============================================================================
# SUMMARY
# ============================================================================

print("\n" + "=" * 60)
print("📊 DATA GENERATION SUMMARY")
print("=" * 60)
print(f"  Users:             {len(users):>6,}")
print(f"  Restaurants:       {len(restaurants):>6,}")
print(f"  Menu Items:        {len(menu_items):>6,}")
print(f"  Delivery Partners: {len(delivery_partners):>6,}")
print(f"  Orders:            {len(orders):>6,}")
print(f"  Order Items:       {len(all_order_items):>6,}")
print(f"  Payments:          {len(payments):>6,}")
print(f"  Deliveries:        {len(deliveries):>6,}")
print(f"  ────────────────────────────")
print(f"  Total Rows:        {sum(len(d) for _, d, _ in csv_configs):>6,}")
print("=" * 60)
print("✅ All data generated successfully!")
