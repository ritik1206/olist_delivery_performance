# Decision Log

Each entry: what was chosen, why, and what was rejected.

## D1: Definition of "late"
- **Choice:** late = DATE(delivered) > DATE(estimated).
- **Why:** all estimated dates are at midnight (0 non-midnight rows), so the promise is a day, not a time.
- **Effect:** timestamp comparison gives 8.11% late vs 6.77% at date level (~1,300 orders arrived on the promised day).
- **Rejected:** timestamp comparison (penalises on-time-by-day orders); "transit days > N" (ignores each order's own promise).

## D2: Scope of orders
- **Choice:** order_status = 'delivered' with a delivery date: 96,470 orders.
- **Excluded:** 8 "delivered" orders with no delivery date.

## D3: Timeline anomalies
- At timestamp level: 166 orders with pickup before purchase, 23 with delivery before pickup.
- At date level: 23 orders still flagged by timeline_ok (2 pickup before purchase, 20 delivery before pickup; the 23rd is probably a missing pickup date, not confirmed).
- **Choice:** flag with timeline_ok; keep in the on-time KPI, exclude from stage-duration analysis.
- **Why:** the on-time KPI uses only the delivered and estimated dates; we cannot tell which timestamp is wrong.
- **Rejected:** deleting rows (loses valid information; effect is about 0.02% of orders).

## D4: Granularity of stage durations
- **Choice:** whole days, not hours.
- **Why:** pickup timestamps appear to be entered at minute precision and are unreliable; the promise is a day; an SLA a manager could set is in days.

## D5: Analysis window
- **Choice:** purchases from 2017-01 to 2018-08.
- **Why:** 2016 has 267 orders across three scattered months, so percentages are unstable.

## D6: Malformed review row and line endings
- The reviews file uses Windows line endings, so its load uses '\r\n'. With '\n' a hidden carriage return stayed in the last column and caused 1,000+ warnings.
- One record (1 of 99,223) loaded with 3 warnings: fields shifted and both dates became zero dates.
- **Choice:** keep the row, set review_creation_date and review_answer_timestamp to NULL.
- **Why:** order_id and review_score are intact and are all the analysis needs.
- **Rejected:** deleting the row (loses valid data); editing the source CSV (not reproducible).

## D7: One review per order
- **Choice:** keep the newest review per order (by creation date, then answer timestamp).
- **Why:** the latest review is the customer's final word; averaging reviews creates a score nobody gave.
- **Effect:** 95,823 of 96,470 delivered orders have a review; 647 have none and drop out of review analysis.
- [Fill in: reviews-per-order result from 05_review.sql, query 2.]

## D8: Order summary grain and joins
- vw_order_summary has one row per delivered order (96,470; verified rows = distinct orders).
- All joins are LEFT JOINs, so no order is dropped; missing pieces show as NULL.
- 1,275 orders (1.3%) have more than one seller; seller_state uses MIN(seller_id) for them, so seller-based analysis is restricted to n_sellers = 1.

## D9: Model dataset and data leakage
- **Included:** only features known at purchase: promised days, items, value, freight, route, distance, calendar.
- **Excluded on purpose:** review score, handling days, transit days, delay days. They are known only after the order is placed or delivered; including them would be data leakage.
- **Distance:** great-circle km between the average positions of the seller's and customer's ZIP prefixes. Geolocation filtered to a Brazil bounding box (42 stray points dropped).
- **Known limit:** ZIP-prefix centres are approximate delivery points.

## D10: Orders with no distance
- 480 orders (0.5%) have no distance: 265 with the customer ZIP prefix missing from geolocation, 216 with the seller's, 1 with both. Concentrated in DF (166).
- **Choice:** exclude them from model_data (95,990 rows remain). They stay in vw_model_data and in all earlier SQL analysis.
- **Effect:** the model under-represents DF.
- **Rejected:** imputing a state-pair median distance (invents values); revisit if DF matters.
