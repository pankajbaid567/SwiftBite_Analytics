# 📈 SwiftBite Analytics — Dashboard Ideas

> All metrics below are verified against actual PostgreSQL query results.

---

## Dashboard 1: Executive Revenue & Growth Dashboard

### Purpose
A single-pane view for the CEO and investors showing platform health, growth trajectory, and key financial metrics.

### Key Metrics

| Metric | Value (Actual) | Visualization | Position |
|--------|---------------|---------------|----------|
| Total Revenue (FY 2025) | ₹21.74 Lakhs | KPI Card | Top row |
| Total Delivered Orders | 4,447 | KPI Card | Top row |
| Average Order Value | ₹489 | KPI Card | Top row |
| Latest MoM Growth (Dec) | +29.7% | KPI Card (green arrow) | Top row |
| Daily Revenue Trend | ₹115K (Jan) → ₹230K (Dec) | Line chart (12 months) | Center left |
| Revenue by City | Mumbai #1 (1,068 orders) | Horizontal bar chart | Center right |
| Revenue by Cuisine Type | Healthy ₹16K/partner tops | Donut/pie chart | Bottom left |
| New vs Returning Revenue | Returning hits 95% by Dec | Stacked area chart | Bottom center |
| Cohort Retention Heatmap | Month-1: ~33%, Month-3: ~36% | Heatmap (months × cohorts) | Bottom right |

### Filters
- Date range selector (Jan 2025 – Dec 2025)
- City dropdown (10 cities)
- Customer segment (All / Premium / Standard)

### Story It Tells
> "SwiftBite grew from ₹1.16L to ₹2.30L monthly revenue over 2025, a near 2x increase. By December, 95% of monthly revenue comes from returning customers — proving strong organic retention. The Jan 2025 cohort shows 33% Month-1 retention and 36% Month-3 retention. However, top 20% of customers drive 46% of revenue, indicating moderate concentration risk that a VIP loyalty program could mitigate."

### Design Notes
- Dark theme with accent colors (teal `#14B8A6`, coral `#F97316`)
- KPI cards with sparkline trend indicators
- Cohort heatmap using green-to-red gradient (high retention → low)
- Mobile-responsive for CEO's phone check

---

## Dashboard 2: Operations & Delivery Performance Dashboard

### Purpose
Operations command center for monitoring delivery quality, fleet efficiency, and restaurant health across 10 cities.

### Key Metrics

| Metric | Value (Actual) | Visualization | Position |
|--------|---------------|---------------|----------|
| Avg Delivery Time | 37.5 mins (platform-wide) | KPI Gauge (target: <35) | Top row |
| Late Delivery % | 53–57% across cities | KPI Card (red flag) | Top row |
| Cancellation Rate | 11.06% platform-wide | KPI Card | Top row |
| Active Delivery Partners | 500 | KPI Card | Top row |
| Delivery Time by City | Jaipur worst (38.0 min, 57.2% late) | Bar chart (sorted) | Center left |
| Hourly Order Heatmap | Peaks: 12 PM lunch, 7–8 PM dinner | Heatmap (hour × day) | Center right |
| Top 3 Fastest Partners | Priya Shah (27.5 min avg) | Ranked table | Bottom left |
| Worst Cancellation Restaurants | Grill Master - Ban (31.3%) | Bar chart (worst first) | Bottom center |
| Late Delivery Trend | Consistent ~55% across all cities | Line chart (weekly) | Bottom right |

### Filters
- City selector (10 cities)
- Date range (Jan–Dec 2025)
- Vehicle type (Bike / Scooter / Bicycle)

### Story It Tells
> "Delivery performance is uniformly concerning — late delivery rates range from 53.4% (Pune) to 57.2% (Jaipur), well above the 30% target. Avg delivery time of 37.5 minutes exceeds the 35-minute SLA. Grill Master in Bangalore has a 31.3% cancellation rate — 3x the platform average of 11%. The fastest partner (Priya Shah, Kolkata) averages 27.5 minutes, proving sub-30 min delivery is achievable with the right routing and assignment."

### Design Notes
- Traffic-light color coding: green (< 30 min), yellow (30–40 min), red (> 40 min)
- Alert badges for SLA breaches (cities with >55% late rate)
- Drill-down capability: City → Restaurant → Individual orders
- Auto-refresh every 5 minutes for real-time monitoring
