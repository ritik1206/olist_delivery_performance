# SQL pipeline

MySQL 8.0 scripts that build the Olist delivery-performance database, from raw CSVs to a model-ready dataset. Run the files in numeric order.

**Data:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle). Raw CSVs are not stored in this repo.

## Run order

| File | What it does |
|---|---|
| `01_create_tables.sql` | Creates the `olist` database and 8 tables with types and keys |
| `02_load_data.sql` | Loads the 8 CSVs, converts blanks to NULL, fixes one malformed row |
| `03_views.sql` | Views: delivered orders with delay measures, one review per order, items per order, order summary |
| `04_kpi.sql` | Headline late-delivery KPI, timeline checks, monthly trend |
| `05_review.sql` | Review checks and review score vs delay |
| `06_order_summary.sql` | Late rate by state, lane, month; RJ vs rest of Brazil |
| `07_model_data.sql` | Distance feature (ZIP-prefix coordinates) and the model dataset |
| `08_model_checks.sql` | Read-only checks on the model dataset |

## How to run

1. Install MySQL 8.0 and download the Olist CSV files.
2. Enable local file loading on the server (`SET GLOBAL local_infile = 1;`) and in your client connection (`OPT_LOCAL_INFILE=1`).
3. In `02_load_data.sql`, replace the folder path `C:/path/to/olist/Data/` with the folder containing your CSVs. Use forward slashes.
4. Run `01` to `03`, then any analysis file, then `07`.

## Expected results (use these to check your run)

| Table | Rows |
|---|---|
| orders | 99,441 |
| customers | 99,441 |
| sellers | 3,095 |
| order_items | 112,650 |
| order_reviews | 99,223 (3 load warnings, see below) |
| products | 32,951 |
| product_category_translation | 71 |
| geolocation | 1,000,163 |

- `vw_order_summary`: 96,470 rows (delivered orders, one row each)
- Late-delivery rate: 6.77% (delivered after the estimated date, compared at date level)
- `model_data`: 95,990 rows

## Design notes

- **Late = delivered date later than estimated date, compared by day.** Estimates are all at midnight, so a timestamp comparison would mark on-time-by-day orders as late (8.11% vs 6.77%).
- **Only delivered orders are analysed** (96,470). 8 "delivered" orders without a delivery date are excluded.
- **Timeline anomalies are flagged, not deleted** (`timeline_ok`). They are excluded only from stage-duration analysis.
- **One review per order:** the newest review is kept.
- **Joins use LEFT JOIN** so no order is dropped; missing pieces appear as NULL.
- **The model dataset contains only features known at purchase** (no data leakage). 480 orders with no distance are excluded.

## Data-loading notes

- The reviews file uses Windows line endings, so its load uses `'\r\n'`. With `'\n'` a hidden `\r` stays in the last column and causes over 1,000 warnings.
- One review record is malformed (3 load warnings). Its score and order link are intact, so only its two date columns are set to NULL.

Decisions and findings: see `docs/DECISIONS.md` and `docs/FINDINGS.md`.
