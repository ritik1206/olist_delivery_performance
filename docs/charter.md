# Project Charter: Olist Delivery Performance Analysis

## 1. Problem Statement
Late deliveries on a Brazilian e-commerce marketplace hurt customer
satisfaction and put revenue at risk. Operations leadership lacks a clear
view of where and why delays happen.

## 2. Objective
Identify the drivers of late delivery, quantify their impact on customer
reviews, and recommend policy changes that reduce late orders.

## 3. Key Business Questions
1. How often are orders delivered late, and is the trend changing over time?
2. Where is lateness concentrated (region, seller, product category)?
3. Which stage causes the delay: seller handling or carrier transit?
4. How does late delivery affect review scores?
5. What would a seller SLA or revised promise date change?

## 4. Scope
In scope: delivered orders, delivery timeline analysis, seller and region
analysis, late-delivery prediction, scenario analysis, dashboard, deck.
Out of scope: payments analysis, real-time systems, web application.

## 5. Deliverables
SQL scripts, analysis notebook, Power BI dashboard, recommendation deck,
decision log.

## 6. Stakeholder (simulated)
Head of Operations, who needs actionable recommendations with quantified
impact.

## 7. Success Criteria
- Clear on-time delivery KPI baseline
- Top delay drivers identified with evidence
- Predictive model with documented evaluation
- At least one quantified recommendation

## 8. Timeline (30 days)
Week 1: Setup, charter, SQL foundation
Week 2: Diagnostics and root-cause analysis
Week 3: Prediction model and scenarios
Week 4: Dashboard, deck, repo polish

## 9. Risks and Mitigation
| Risk | Mitigation |
|---|---|
| Joins double count revenue | Fix grain per query and validate row counts |
| Incomplete early and late periods | Define a clean analysis window |
| Undelivered orders lack dates | Filter to delivered orders and document it |
| Scope creep | Check every addition against this charter |
