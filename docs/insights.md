# 📊 SwiftBite Analytics — Business Insights

> Based on SQL analysis of 5,000 orders, 902 customers, 200 restaurants across 10 cities over 12 months (Jan–Dec 2025).

---

## Insight 1: Revenue Concentration Risk
**"Top 20% of customers generate 46% of total platform revenue."**

- Pareto analysis shows moderate concentration — not the extreme 80/20, but still significant
- The top 5% alone contribute ~18% of revenue
- Losing even a small portion of high-value customers creates measurable revenue impact
- **Action**: Launch a VIP loyalty tier for top 20% customers with exclusive perks and priority delivery

---

## Insight 2: Retention After First Order Is Promising but Has Room to Grow
**"30.8% of new customers place a second order within 30 days."**

- Out of 902 unique customers, 278 returned within 30 days — a solid foundation
- However, 69% of first-time customers still don't return within a month
- Customers who place 3+ orders have significantly higher lifetime value
- **Action**: Offer a time-limited incentive (₹100 off within 7 days) to convert first-timers into repeat buyers

---

## Insight 3: Consistent Revenue Across Weekdays and Weekends
**"Weekend and weekday daily revenues are nearly equal (~₹6,094 vs ~₹5,903), indicating stable demand."**

- Unlike many food delivery platforms, SwiftBite has relatively flat demand across the week
- This suggests a strong weekday office-lunch and dinner ordering habit
- Weekend AOV may be slightly higher due to family/group ordering
- **Action**: Since demand is already well-distributed, focus on peak-hour optimization (lunch 11–1 PM, dinner 7–9 PM) rather than day-of-week promotions

---

## Insight 4: Healthy & Italian Cuisines Lead in Per-Restaurant Revenue
**"Healthy food restaurants generate ₹16,131 revenue per partner — 4x more than Street Food restaurants (₹4,035)."**

| Cuisine | Revenue/Restaurant | Rank |
|---------|-------------------|------|
| Healthy | ₹16,131 | #1 |
| Italian | ₹14,834 | #2 |
| Biryani | ₹13,294 | #3 |
| Continental | ₹13,218 | #4 |
| Street Food | ₹4,035 | #10 |

- Healthy food's dominance reflects a growing urban health-conscious trend
- Biryani and Italian also command premium AOVs
- **Action**: Aggressively onboard healthy food and Italian restaurants in underserved cities; these verticals generate 3–4x the revenue per restaurant

---

## Insight 5: Delivery Time Directly Impacts Customer Satisfaction
**"Orders delivered in <25 minutes receive higher ratings; late deliveries correlate with lower reorder probability."**

- Cities with higher average delivery times show lower repeat order rates
- Each minute saved in delivery time improves the customer experience
- **Action**: Implement dynamic fleet allocation to reduce delivery times in slower cities like Lucknow and Ahmedabad

---

## Insight 6: Premium Members Are 2.2x More Frequent Orderers
**"Premium (Gold) members represent 15% of users but contribute 30.2% of total revenue, ordering 9.1 times on average vs 4.1 for non-premium users."**

- Premium users order at **2.2x the frequency** of standard users
- Their total revenue share (30.2%) is double their user share (15%)
- **Action**: Invest in premium conversion campaigns — each conversion roughly doubles a customer's ordering frequency

---

## Insight 7: 11% Cancellation Rate Creates Operational Waste
**"11.06% of all orders are cancelled, with some restaurants hitting 31% cancellation rates."**

- The worst offender (Grill Master - Bangalore) has a 31.25% cancellation rate
- 20 restaurants exceed a 19% cancellation rate
- Each cancelled order wastes delivery partner allocation time and damages customer trust
- **Action**: Implement "menu health checks" for restaurants with >15% cancellation rate; auto-delist repeat offenders

---

## Insight 8: Payment Method Mix — COD and Credit Card Users Order More Frequently
**"Credit Card users average 6.5 orders vs UPI users at 5.7 — suggesting payment friction doesn't deter high-intent users."**

| Payment Method | Avg Orders/User |
|---------------|-----------------|
| Credit Card | 6.5 |
| Debit Card | 6.4 |
| COD | 6.3 |
| Wallet | 6.3 |
| UPI | 5.7 |

- UPI dominates by transaction count (40% share) but those users order slightly less frequently
- COD users are surprisingly engaged — suggesting convenience drives loyalty
- **Action**: UPI's lower frequency may be a targeting opportunity — send re-engagement nudges to UPI-primary users who haven't ordered in 10+ days

---

## Insight 9: Returning Customers Drive 95% of Revenue by Year-End
**"By December 2025, returning customer revenue accounts for 95.3% of total monthly revenue — up from 24.4% in January."**

- This is a healthy sign: the platform is building a loyal base, not just renting customers
- New customer revenue drops from ₹87K (Jan) to ₹11K (Dec) as the user base saturates
- **Action**: Shift marketing budget from pure acquisition to retention and LTV expansion for existing customers

---

## Insight 10: Near-Zero Restaurant Dormancy — Supply Health Is Strong
**"Only 1.5% of restaurants (3 out of 200) received zero orders in the last 90 days."**

- This is an excellent restaurant health metric — nearly all partners are actively receiving orders
- The 3 dormant restaurants likely have listing quality or location issues
- **Action**: Conduct targeted audits of the 3 dormant restaurants (menu photos, pricing, delivery radius)

---

## Insight 11: Mumbai Dominates Order Volume
**"Mumbai alone accounts for 1,068 orders (21.4%) — more than Delhi (783) and Bangalore (746) individually."**

- Top 3 cities (Mumbai, Delhi, Bangalore) account for 52% of total orders
- Tier-2 cities (Jaipur: 316, Lucknow: 217, Ahmedabad: 236) have significant headroom for growth
- **Action**: Increase restaurant supply in Tier-2 cities where demand exists but selection is limited

---

## Insight 12: Platform-Wide AOV of ₹489 With Average Discount of ₹19
**"The average net order value is ₹489 with an average discount of only ₹19 (3.7% of gross) — indicating healthy unit economics."**

- Gross AOV: ₹508, Discount: ₹19, Net AOV: ₹489
- The low discount rate suggests the platform isn't over-subsidizing orders
- **Action**: Maintain current discount strategy; use targeted (not blanket) discounts to activate at-risk segments only

---

## Summary Matrix

| Insight | Impact | Effort | Priority |
|---------|--------|--------|----------|
| VIP loyalty for top 20% | High | Medium | P0 |
| First-order retention push | High | Low | P0 |
| Healthy/Italian restaurant supply | High | Medium | P1 |
| Peak-hour fleet optimization | High | High | P1 |
| Premium conversion campaigns | High | Medium | P1 |
| Cancellation rate intervention | Medium | Low | P1 |
| UPI user re-engagement | Medium | Low | P2 |
| Retention-focused marketing shift | Medium | Medium | P2 |
| Tier-2 city expansion | High | High | P1 |
