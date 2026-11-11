# Project documents

- [Project charter](charter.md): problem, questions, scope, timeline
- [Decision log](DECISIONS.md): choices made and alternatives rejected
- [Findings](FINDINGS.md): what the analysis shows
# Why Orders Arrive Late, and What It Costs: Olist Delivery Performance

An end-to-end analysis (MySQL, Python, Power BI) of delivery delays on a Brazilian e-commerce marketplace: where lateness comes from, what it does to customer reviews, and whether it can be predicted at purchase.

**Data:** [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle), about 99,000 orders, 2016-2018.

## The business question
Late deliveries hurt customer satisfaction. Where and when do they happen, why, and what should operations do about it?

## Key findings
1. **6.77% of delivered orders arrive late** (96,470 orders; late = delivered after the estimated date, compared by day).
2. **Late orders get far lower reviews.** Average score is 4.29 on time and 1.70 when 8+ days late; the 1-star share rises from 6.6% to 69.9%. Even 1-3 days late costs about a full point.
3. **Lateness comes in bursts.** Three months (Nov 2017, Feb 2018, Mar 2018) hold about half of all late orders. The slowdown was national, and Rio de Janeiro was hit hardest: about 34% late in Feb-Mar 2018 against about 4% in normal months.
4. **The cause points to carrier transit and tight promises, not sellers.** Seller handling time stayed flat (about 3 days) while transit in RJ roughly doubled (about 9 to 20 days). Promised dates did not keep pace, so the cushion between promise and actual delivery shrank to 1-7 days in the worst months.
5. **Distance matters:** late rate rises from 4.5% (under 100 km) to 12.0% (2,000+ km).
6. **A purchase-time risk score ranks orders well but cannot see bad months.** Orders sorted by predicted risk: the top decile is 18.2% late and the bottom 1.0%; the riskiest 30% of orders hold 57% of all late orders. But predicted risk barely moves between months (5-10%) while actual lateness ranges from 1% to 19%, because the spikes come from carrier conditions that an order's own details do not reveal. A recent-performance feature I tested did not fix this (it lags actual lateness by about two months).

## Recommendations
- **Track the delivery buffer** (promised days minus actual handling and transit days) weekly by state. It shrank before or with every spike, so it works as an early-warning metric.
- **Set promised dates from recent lane performance** (for example the latest 4-week 80th percentile, with a floor). Trade-off: a longer promise reduces lateness but does not speed delivery, and may cost conversions, which this data cannot measure.
- **Monitor RJ separately:** it breaks first and recovers last.
- **Use the risk score for low-cost actions** (proactive delivery message, early carrier check). Even the top decile is 82% on time, so it is not suited to costly interventions.

<!-- Add dashboard screenshots here when ready -->

## What is in this repo
| Folder | Contents |
|---|---|
| `sql/` | MySQL pipeline: schema, load, views, KPIs, analysis, model data. See `sql/README.md`. |
| `notebooks/` | Python notebook: exploration, time-based split, models, evaluation |
| `docs/` | Project charter, decision log (`DECISIONS.md`), findings (`FINDINGS.md`) |
| `dashboard/` | Power BI dashboard |
| `deck/` | Recommendation deck |

## Method in brief
- **Definition of late:** delivered date after estimated date, compared by day (a timestamp comparison would give 8.11% instead of 6.77%, because estimates are all at midnight).
- **Windows:** analysis covers purchases from Jan 2017 to Aug 2018 (96,203 delivered orders; 2016 has too few orders). The model uses the 95,723 of these with a known seller-customer distance.
- **Model:** gradient boosting, trained on orders before Mar 2018 and tested from Mar 2018 on (a time split, not random). Only features known at purchase were used, to avoid data leakage. ROC AUC 0.70.
- **Evaluation:** ROC AUC, PR AUC and top-decile capture, not accuracy (only 7% of orders are late).

## Limits
- Associations, not proven causes. There is no carrier or capacity data, so why transit slowed is not known.
- Review analysis covers customers who left a review (99% of delivered orders appear, but unhappy customers may be more likely to write one).
- One test period, and March 2018 contributes about half of its late orders.

## Reproduce
Run the `sql/` files in order (see `sql/README.md`), export `model_data` as CSV, then run the notebook. Raw data and exports are not stored in this repo.
