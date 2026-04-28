# 🍔 SwiftBite Analytics — Business Problem

## Company Overview

**SwiftBite** is a rapidly growing food delivery platform operating across 10+ cities in India. The platform connects customers with local restaurants, enabling them to browse menus, place orders, and receive deliveries within 30–45 minutes. SwiftBite currently serves **50,000+ monthly active users**, partners with **2,000+ restaurants**, and manages a fleet of **5,000+ delivery partners**.

After a Series B funding round of ₹500 Cr, the leadership team is under pressure to demonstrate a clear path to profitability. The CEO has tasked the analytics team with a deep-dive into platform performance to identify growth levers, reduce operational inefficiencies, and improve customer retention.

---

## Key Stakeholders

| Stakeholder | Role | Key Questions |
|-------------|------|---------------|
| **CEO / Founder** | Strategic direction | Are we growing sustainably? Where should we double down? |
| **VP of Product** | Feature prioritization | Which features drive retention? Where do users drop off? |
| **Head of Marketing** | Campaign ROI | Which customer segments respond best? What's our CAC vs LTV? |
| **Head of Operations** | Delivery efficiency | Are delivery times improving? Which cities need more partners? |
| **Head of Finance** | Revenue & margins | What's our revenue mix? Where are we losing money? |
| **Restaurant Success Team** | Partner health | Which restaurants are churning? Who are the top performers? |

---

## Problem Statement

> **"SwiftBite's customer retention rate has dropped from 42% to 31% over the last two quarters, while customer acquisition cost (CAC) has increased by 28%. The leadership needs data-driven insights to understand WHY customers are leaving, WHICH segments are most at risk, and WHAT operational or product changes can reverse this trend — all while maintaining the path to profitability."**

---

## Why This Problem Matters

### Business Impact

1. **Revenue at Risk**: A 10% drop in retention translates to approximately ₹12 Cr in lost annual revenue. Retaining existing customers is 5–7x cheaper than acquiring new ones.

2. **Unit Economics Under Pressure**: With rising CAC (₹180 → ₹230) and stagnant average order values, the contribution margin per order has shrunk from ₹28 to ₹19.

3. **Investor Confidence**: Post Series-B investors expect a clear path to profitability within 18 months. Unchecked churn threatens this timeline.

4. **Competitive Pressure**: Competitors like Swiggy and Zomato are aggressively expanding into Tier-2 cities — SwiftBite risks losing market share if retention isn't addressed.

5. **Operational Waste**: Low-retention cities still receive the same delivery partner allocation, leading to underutilized fleet capacity and inflated costs.

---

## Analytical Objectives

The analytics team must answer the following questions through SQL-based analysis:

### Customer Analytics
- Who are our most valuable customers? (Pareto / RFM analysis)
- What does the customer lifecycle look like? (Cohort analysis)
- When do customers typically churn? (Retention curves)
- What behaviors differentiate retained vs churned users?

### Revenue Analytics
- What's driving revenue growth or decline? (MoM trends)
- Which cities, cuisines, and restaurants contribute most to revenue?
- Is our average order value trending up or down?
- What's the revenue concentration risk?

### Operational Analytics
- How do delivery times vary across cities and time slots?
- Which delivery partners are most/least efficient?
- What's the cancellation rate, and what causes it?
- Are we over/under-serving any city?

### Restaurant Analytics
- Which restaurants are at risk of churning?
- How does restaurant rating correlate with order volume?
- What's the revenue distribution across restaurants?

---

## Scope & Constraints

- **Data Period**: 12 months (Jan 2025 – Dec 2025)
- **Geography**: 10 Indian cities (Mumbai, Delhi, Bangalore, Hyderabad, Chennai, Pune, Kolkata, Jaipur, Lucknow, Ahmedabad)
- **Analysis Tool**: PostgreSQL (SQL-first approach)
- **Visualization**: Tableau / Power BI (for dashboard prototypes)
- **No ML/Python in core analysis** — this is a SQL-centric project

---

## Expected Deliverables

| # | Deliverable | Description |
|---|-------------|-------------|
| 1 | Database Schema | 8-table relational schema with proper normalization |
| 2 | Synthetic Dataset | 5,000+ rows of realistic, analytically rich data |
| 3 | SQL Query Bank | 30 queries (beginner → advanced) with business context |
| 4 | Business Insights | 10+ actionable insights backed by data |
| 5 | Dashboard Blueprint | 2 dashboard designs with metric definitions |
| 6 | Executive Summary | Key findings & recommendations |
