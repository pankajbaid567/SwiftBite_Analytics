# 🍔 SwiftBite Analytics — SQL Portfolio Project

> **A production-grade SQL analytics case study simulating the data analytics function at a food delivery platform (Swiggy/Zomato style).**

[![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue?style=for-the-badge&logo=postgresql)](https://www.postgresql.org/)
[![Python](https://img.shields.io/badge/Data_Gen-Python-green?style=for-the-badge&logo=python)](https://python.org/)
[![Status](https://img.shields.io/badge/Status-Complete-success?style=for-the-badge)]()

---

## 📋 Table of Contents

- [Problem Statement](#-problem-statement)
- [Dataset](#-dataset)
- [Schema Design](#-schema-design)
- [SQL Queries](#-sql-queries)
- [Key Insights](#-key-insights)
- [Dashboard Ideas](#-dashboard-ideas)
- [Tech Stack](#-tech-stack)
- [How to Run](#-how-to-run)
- [Project Structure](#-project-structure)
- [Author](#-author)

---

## 🎯 Problem Statement

**SwiftBite** is a food delivery platform serving 50,000+ monthly active users across 10 Indian cities. After a Series B funding round, the leadership team needs data-driven answers to critical questions:

- 📉 **30.8% of new customers return within 30 days** — How do we push this to 50%?
- 💰 **Top 20% of customers generate 46% of revenue** — How do we reduce concentration risk?
- 🏪 **11% order cancellation rate, with worst restaurants at 31%** — Where's the operational waste?
- 🚴 **Late deliveries range from 53–57% across cities** — Where do we deploy more fleet?

This project uses **30 SQL queries** across beginner → advanced levels to answer these questions with data.

> 📄 [Full Business Problem Document →](docs/business_problem.md)

---

## 📊 Dataset

### Overview

| Table | Type | Rows | Description |
|-------|------|------|-------------|
| `users` | Dimension | 1,000 | Customer profiles |
| `restaurants` | Dimension | 200 | Restaurant partners |
| `menu_items` | Dimension | 915 | Menu catalog |
| `delivery_partners` | Dimension | 500 | Delivery fleet |
| `orders` | Fact | 5,000 | Core transactions |
| `order_items` | Bridge | 10,297 | Line-item details |
| `payments` | Fact | 5,000 | Payment records |
| `delivery` | Fact | 4,447 | Delivery tracking |
| **Total** | | **27,359** | |

### Data Generation

Data is synthetically generated using Python with:
- Realistic Indian names, cities, and cuisines
- Power-law distributions for user ordering behavior
- Proper foreign key relationships
- 12 months of data (Jan–Dec 2025)

> 📄 [Schema Design Document →](docs/schema_design.md)

---

## 🗄️ Schema Design

```
users ──────────────────┐
                        ├──▶ orders ──┬──▶ order_items ◀── menu_items ◀── restaurants
restaurants ────────────┘             ├──▶ payments
                                      └──▶ delivery ◀── delivery_partners
```

**8 tables** following dimensional modeling (star schema) — optimized for analytical queries with proper indexes, constraints, and referential integrity.

<!-- Screenshot placeholder -->
<!-- ![ERD](assets/erd.png) -->

---

## 🔍 SQL Queries

### 30 queries organized by difficulty level:

| Level | Count | Key Concepts | File |
|-------|-------|-------------|------|
| 🟢 **Beginner** | 5 | SELECT, GROUP BY, WHERE, COUNT, AVG | [`01_beginner.sql`](queries/01_beginner.sql) |
| 🟡 **Intermediate** | 10 | JOINs, Subqueries, CASE WHEN, HAVING | [`02_intermediate.sql`](queries/02_intermediate.sql) |
| 🔴 **Advanced** | 15 | Window Functions, CTEs, Cohort, RFM, Funnel | [`03_advanced.sql`](queries/03_advanced.sql) |

### Highlights

| # | Query | SQL Concepts |
|---|-------|-------------|
| Q18 | **RFM Customer Segmentation** | CTE, NTILE, CASE WHEN |
| Q21 | **Cohort Retention Analysis** | CTE, DATE_TRUNC, Self-Join |
| Q24 | **Pareto Analysis (80/20 Rule)** | PERCENT_RANK, CTE |
| Q30 | **Churn Prediction Scoring** | CTE, LAG/LEAD, Behavioral Scoring |

Each query includes: **Problem Statement → SQL Code → Explanation → Business Insight**

---

## 💡 Key Insights

| # | Insight | Impact |
|---|---------|--------|
| 1 | Top 20% customers generate 46% of total revenue | Revenue concentration risk |
| 2 | 30.8% of new users place a second order within 30 days | Retention optimization |
| 3 | Weekday & weekend revenue nearly equal (~₹5.9K vs ~₹6.1K/day) | Stable demand distribution |
| 4 | Healthy food restaurants generate ₹16K/partner — 4x Street Food | Supply acquisition priority |
| 5 | Late deliveries correlate with lower reorder probability | Ops efficiency critical |
| 6 | Premium members contribute 30.2% revenue (15% of users), order 2.2x more | Premium conversion ROI |
| 7 | 11% cancellation rate; worst restaurant hits 31% | Operational waste |
| 8 | Credit Card users avg 6.5 orders vs UPI at 5.7 | Re-engagement opportunity |
| 9 | Returning customer revenue reaches 95% by December | Healthy retention flywheel |
| 10 | Mumbai leads with 21% of orders; Tier-2 cities have growth headroom | Expansion opportunity |

> 📄 [Full Insights Document →](docs/insights.md)

---

## 📈 Dashboard Ideas

### Dashboard 1: Executive Revenue & Growth
- Revenue trends, city performance, cohort retention heatmap
- Designed for CEO and investors

### Dashboard 2: Operations Command Center
- Delivery time monitoring, cancellation alerts, fleet efficiency
- Designed for operations team

> 📄 [Dashboard Blueprints →](docs/dashboard_ideas.md)

<!-- Screenshot placeholders -->
<!-- ![Dashboard 1](assets/dashboard_revenue.png) -->
<!-- ![Dashboard 2](assets/dashboard_operations.png) -->

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| Database | PostgreSQL 14+ |
| SQL Queries | Advanced SQL (Window Functions, CTEs, Subqueries) |
| Data Generation | Python 3.x (no external dependencies) |
| Visualization | Tableau / Power BI (dashboard prototypes) |
| Version Control | Git + GitHub |

---

## 🚀 How to Run

### Prerequisites
- PostgreSQL 14+ installed
- Python 3.8+

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/swiftbite-analytics.git
cd swiftbite-analytics

# 2. Create the database
createdb swiftbite_analytics

# 3. Create tables
psql -d swiftbite_analytics -f schema/01_create_tables.sql

# 4. Generate and load data
python3 data/generate_data.py
psql -d swiftbite_analytics -f schema/02_seed_data.sql

# 5. Run queries
psql -d swiftbite_analytics -f queries/01_beginner.sql
psql -d swiftbite_analytics -f queries/02_intermediate.sql
psql -d swiftbite_analytics -f queries/03_advanced.sql
```

### Alternative: Use CSV files directly
CSV files are auto-generated in the `data/` directory for use with any database or tool.

---

## 📁 Project Structure

```
SwiftBite-Analytics/
├── README.md                          # You are here
├── docs/
│   ├── business_problem.md            # Business context & problem statement
│   ├── schema_design.md               # ERD & table documentation
│   ├── insights.md                    # 12 business insights
│   ├── dashboard_ideas.md             # Dashboard blueprints
│   └── resume_bullets.md              # Resume-ready bullet points
├── schema/
│   ├── 01_create_tables.sql           # DDL (CREATE TABLE statements)
│   └── 02_seed_data.sql               # INSERT statements (auto-generated)
├── data/
│   ├── generate_data.py               # Python data generator
│   ├── users.csv                      # Generated CSV files
│   ├── restaurants.csv
│   ├── menu_items.csv
│   ├── delivery_partners.csv
│   ├── orders.csv
│   ├── order_items.csv
│   ├── payments.csv
│   └── deliveries.csv
├── queries/
│   ├── 01_beginner.sql                # 5 beginner queries
│   ├── 02_intermediate.sql            # 10 intermediate queries
│   └── 03_advanced.sql                # 15 advanced queries
└── assets/
    └── (screenshots & ERD)
```

---

## 👤 Author

**Pankaj Baid**

- Portfolio: [Data Visualization & Analytics](https://github.com/pankajbaid567)
- LinkedIn: [Connect with me](https://linkedin.com/in/pankajbaid)

---

## ⭐ If you found this project helpful, please give it a star!

---

*Built with ❤️ and SQL*
