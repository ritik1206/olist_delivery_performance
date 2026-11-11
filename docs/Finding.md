# Findings

Window: purchases 2017-01 to 2018-08 unless stated. All findings are associations, not proven causes.

## Headline
- 96,470 delivered orders; 6,534 late (6.77%, date-level definition).
- Three months (Nov 2017, Feb 2018, Mar 2018) hold roughly half of all late orders.

## F1: Late orders get much lower reviews
| Delay | Orders | Avg score | 1-star share |
|---|---|---|---|
| On time or early | 89,442 | 4.29 | 6.6% |
| 1-3 days late | 1,852 | 3.29 | 25.1% |
| 4-7 days late | 1,748 | 2.10 | 58.6% |
| 8+ days late | 2,781 | 1.70 | 69.9% |

A one-day delay costs about a full point on average. Based on 95,823 orders that have a review.

## F2: Lateness is a long-tail problem
71% of late reviewed orders (4,529 of 6,381) are 4 or more days late.

## F3: Where lateness is concentrated
- Highest late rates: AL 21.5%, MA 17.5%, SE 15.4%, PI 13.9%, CE 13.8%, BA 12.2%, RJ 12.1%. Lowest: SP 4.5%, PR 4.1%, MG 4.6%.
- SP and RJ together hold about half of all late orders (SP ~28%, RJ ~23%). RJ has 12.8% of orders but ~23% of late ones.
- Late rate tracks carrier transit time state by state.

## F4: Distance matters, but not alone
| Distance | Orders | Late % | Avg promised days |
|---|---|---|---|
| under 100 km | 17,879 | 4.45 | 16.0 |
| 100-500 km | 37,011 | 6.11 | 23.5 |
| 500-1,000 km | 25,754 | 7.12 | 26.9 |
| 1,000-2,000 km | 9,735 | 9.49 | 30.8 |
| 2,000+ km | 5,611 | 12.03 | 33.8 |

The platform's promise already grows with distance, but lateness still rises. Different-state orders are late 8.16% vs 4.57% for same-state, but the gap is a mix effect: within SP there is no penalty (4.06% vs 4.71%); in MG it is 4.96% vs 2.53%; in RJ 12.88% vs 4.83%.

## F5: RJ's problem is an event, not a standing problem
- RJ late rate is about 4% in normal months and 13-35% from Nov 2017 to Mar 2018 (26.0, 24.0, 13.1, 34.0, 34.5).
- The five spike months are 35% of RJ's orders but 77% of its late orders (1,150 of 1,495).
- Seller handling stays flat (2.5-4.2 days): sellers are not the cause.
- Carrier transit more than doubled (about 9 days normally, 20-21 in Feb-Mar 2018).
- Promised dates did not keep pace: the average buffer (promise minus handling minus transit) fell to 1.4-7.1 days in the four worst months, which had 24-34% late.
- Volume alone does not explain it: Apr-Jun 2018 volume is similar and transit is normal.

## F6: The slowdown was national; RJ was hit hardest
- Rest of Brazil late rate: 10.2% (Nov), 11.1% (Feb), 16.8% (Mar) vs about 4% baseline; transit up 2-4 days; buffer fell from about 12 to 6.7-9.4 days.
- RJ: transit up 5-11 days, buffer 1.4-4.4 days; recovered later (Dec: RJ 24.0% vs rest 4.9%).
- About 2,300 of roughly 3,160 peak-month late orders were outside RJ.

## Caveats
- Review analysis covers only customers who left a review (99% of delivered orders appear, but unhappy customers may be more likely to write one).
- No carrier or capacity data, so we cannot say why transit slowed.
- Averages hide the tail; percentiles come in the Python analysis.
- A longer promise reduces lateness without making delivery faster, and may cost conversions, which this data cannot measure.

## Superseded readings
- An early reading that the SP-seller to RJ-customer lane is permanently slow was based on averages that blended calm months with the spike; replaced by F5-F6.


## F10: The risk ranking separates good and bad orders
- Test orders sorted into 10 equal risk groups: late rate falls steadily from 18.2% (highest risk) to 1.0% (lowest).
- The top 30% of orders hold 57% of all late orders; the bottom 30% hold 10%.
- Even the top decile is 82% on time, so the score suits low-cost actions (proactive message, early carrier check), not drastic ones.
