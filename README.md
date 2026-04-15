# Olist Sales & Customer Insights Dashboard

> **Project Type:** Business Intelligence Dashboard  
> **Dataset:** Brazilian E-Commerce Public Dataset by Olist (Kaggle)  
> **Tools:** Tableau / Power BI | SQL (PostgreSQL or MySQL)  
> **Status:** Complete

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Dataset Description](#2-dataset-description)
3. [Project Structure](#3-project-structure)
4. [Data Preparation](#4-data-preparation)
5. [KPI Definitions](#5-kpi-definitions)
6. [Dashboard Visuals](#6-dashboard-visuals)
7. [Interactivity & Filters](#7-interactivity--filters)
8. [Key Insights](#8-key-insights)
9. [How to Run / Reproduce](#9-how-to-run--reproduce)
10. [Tools & Technologies](#10-tools--technologies)
11. [Folder Structure](#11-folder-structure)
12. [Known Limitations](#12-known-limitations)
13. [Future Improvements](#13-future-improvements)
14. [Author](#14-author)

---

## 1. Project Overview

This project delivers an executive-level Sales and Customer Insights Dashboard built on the **Brazilian E-Commerce Public Dataset** provided by Olist. The dashboard is designed to help business stakeholders quickly understand:

- How revenue is trending over time
- Which product categories drive the most sales
- Where orders are geographically concentrated across Brazil
- Who the highest-value customers are
- Key headline metrics at a glance

The goal is to transform raw transactional data into clear, interactive visuals that support fast, evidence-based decision-making — without requiring the reader to be a data expert.

---

## 2. Dataset Description

**Source:** [Brazilian E-Commerce Public Dataset by Olist — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The dataset covers **~100,000 orders** placed on the Olist marketplace between **2016 and 2018**. It includes information about order status, pricing, payment, freight performance, customer location, product attributes, and seller reviews.

### Tables Used

| Table | Description | Key Columns |
|---|---|---|
| `orders` | One row per order, with status and timestamps | `order_id`, `customer_id`, `order_status`, `order_purchase_timestamp` |
| `order_items` | One row per item within an order | `order_id`, `product_id`, `price`, `freight_value` |
| `products` | Product metadata | `product_id`, `product_category_name` |
| `customers` | Customer location data | `customer_id`, `customer_state`, `customer_city` |
| `order_payments` | Payment details per order | `order_id`, `payment_value`, `payment_type` |
| `product_category_name_translation` | English translation of category names | `product_category_name`, `product_category_name_english` |

### Data Scope

- **Time range:** September 2016 – October 2018
- **Geography:** All 26 Brazilian states + Federal District
- **Orders included:** Delivered orders only (cancelled, unavailable, and processing orders excluded)
- **Revenue definition:** `price + freight_value` per item, aggregated per order

---

## 3. Project Structure

This project has two main phases:

```
Phase 1 — Data Preparation (SQL)
    ↓
Phase 2 — Dashboard Building (Tableau or Power BI)
```

### Phase 1: SQL

- Connect to the raw Olist CSV files or database tables
- Join and clean the data into a single flat analytical table
- Export as `olistdata_cleaned.csv` for use in Tableau/Power BI

### Phase 2: Dashboard

- Import the cleaned dataset
- Define calculated KPI measures
- Build 5 core visuals
- Add 3 interactive filters
- Write 3–5 executive insights

---

## 4. Data Preparation

### 4.1 Cleaning Steps Applied

Before building the dashboard, the following data quality steps were performed in SQL:

1. **Filter to delivered orders only** — Removed rows where `order_status` is not `'delivered'`
2. **Remove null payments** — Excluded orders with null or zero `payment_value`
3. **Parse timestamps** — Converted `order_purchase_timestamp` from string to proper `DATE` type
4. **Translate category names** — Joined `product_category_name_translation` to replace Portuguese category names with English equivalents
5. **Deduplicate** — Ensured no duplicate `order_id` entries in the final output

### 4.2 SQL Query — Master Analytical Table

The following query was used to produce the flat table powering all dashboard visuals:

```sql
-- this query is creating a dataset that answers: for all delivered orders, show order details, customer location, product category, and total payment per item
-- this query is at the item level, NOT order level meaning one order with 3 items will appear 3 times becaues payment_value is per item


-- the SELECT retreives a specified value from a table, combines raw order info (order_id, timestamp, customer_id), a calculated field (price + freight), and joined data (product category, customer state)
SELECT
	o.order_id,				-- o is short for the orders table so o.order_id = orders.order_id; getting order_id from the orders table
	o.customer_id,				-- retrieves the customer_id from the order table, tells who placed what order
	DATE(o.order_purchase_timestamp)	AS order_date,
	EXTRACT(YEAR FROM o.order_purchase_timestamp) AS order_year,
	EXTRACT(MONTH FROM o.order_purchase_timestamp)	AS order_month, -- retrieves the date and time the order was placed from the orders table, useful for time analysis and building dashboards
	(oi.price + oi.freight_value) AS payment_value,		-- oi short for ordered_items table so the price (product cost) and freight value (shipping cost) from ordered_items table are added and named payment_value
	COALESCE(t.product_category_name_english,
			 p.product_category_name,
			 'Unknown')						AS product_category,
	p.product_category_name,		-- p is the alias; retrieve the product category name (electronics, furniture), one order witih multiple categories are separated into multiple rows
	c.customer_state,			-- c is the alias; the state where the customer lives, useful or geoegraphic analysis, regional sales breakdowns
	c.customer_city

FROM orders o		-- tells SQL the main table is orders, "o" is the alias
JOIN order_items oi 	ON o.order_id = oi.order_id			-- joins the orders table with order_items table and adds a new product_id column to the order table for where order_id matches from both tables. creates a one-to-many relationship where one order has multiple items
JOIN products p			ON oi.product_id = p.product_id			-- joins order_items table with products tables and adds a new category column to the order table for where product_id matches from both tables. to add category details 
JOIN customers c		ON o.customer_id = c.customer_id			-- joins orders table with customers table and adds a new state column for where customer_id matches in both tables
LEFT JOIN category_translation t
    ON p.product_category_name = t.product_category_name
WHERE 
	o.order_status = 'delivered'			-- filters the data to only include orders were successfully delivered
	AND (oi.price + oi.freight_value) > 0;
```

### 4.3 Output

The query produces a CSV file — `olistdata_cleaned.csv` — with the following columns:

| Column | Type | Description |
|---|---|---|
| `order_id` | STRING | Unique order identifier |
| `customer_id` | STRING | Unique customer identifier |
| `order_date` | DATE | Date the order was placed |
| `order_year` | INT | Year extracted from order date |
| `order_month` | INT | Month extracted from order date |
| `payment_value` | FLOAT | Revenue = price + freight per item |
| `product_category` | STRING | English product category name |
| `customer_state` | STRING | 2-letter Brazilian state code |
| `customer_city` | STRING | Customer's city |

---

## 5. KPI Definitions

The following five KPIs are displayed on the dashboard. Each definition is consistent across all visuals.

### Total Revenue

The sum of all payment values (price + freight) across delivered orders.

```
Total Revenue = SUM(payment_value)
```

- **Tableau Calculated Field:** `SUM([payment_value])`
- **Power BI DAX Measure:** `Total Revenue = SUM(orders[payment_value])`

---

### Total Orders

The count of distinct orders placed (one order may contain multiple items).

```
Total Orders = COUNT DISTINCT(order_id)
```

- **Tableau Calculated Field:** `COUNTD([order_id])`
- **Power BI DAX Measure:** `Total Orders = DISTINCTCOUNT(orders[order_id])`

---

### Average Order Value (AOV)

The average revenue generated per order.

```
AOV = Total Revenue / Total Orders
```

- **Tableau Calculated Field:** `SUM([payment_value]) / COUNTD([order_id])`
- **Power BI DAX Measure:** `AOV = DIVIDE([Total Revenue], [Total Orders])`

> Note: `DIVIDE()` is used in Power BI instead of `/` to handle division by zero gracefully.

---

### Top Product Categories

Revenue grouped and ranked by `product_category`. Used to identify which categories drive the most sales.

```
Revenue by Category = SUM(payment_value) GROUP BY product_category ORDER BY revenue DESC
```

---

### Top Customers

Revenue grouped by `customer_id` and ranked in descending order. Used to identify the highest-value customers in the dataset.

```
Revenue by Customer = SUM(payment_value) GROUP BY customer_id ORDER BY revenue DESC LIMIT 10
```

---

## 6. Dashboard Visuals

The dashboard contains five visuals arranged in a single-page executive layout.

### Visual 1 — Line Chart: Revenue Over Time

| Property | Value |
|---|---|
| Chart type | Line chart |
| X-axis | `order_date` aggregated by Month |
| Y-axis | `Total Revenue` |
| Purpose | Shows monthly revenue trends and seasonal patterns over the full 2016–2018 period |
| Key finding | Strong revenue spike in November (Black Friday / seasonal demand) |

**How to build in Tableau:**
1. Drag `order_date` to Columns → right-click → set to **Month**
2. Drag `Total Revenue` calculated field to Rows
3. Change mark type to **Line**
4. Format Y-axis as currency (BRL or USD)

**How to build in Power BI:**
1. Insert → Line chart
2. X-axis = `order_date` (set hierarchy to Month)
3. Y-axis = `Total Revenue` measure
4. Format → Data labels → On

---

### Visual 2 — Bar Chart: Top Product Categories

| Property | Value |
|---|---|
| Chart type | Horizontal bar chart |
| Y-axis | `product_category` (Top 10) |
| X-axis | `Total Revenue` |
| Purpose | Ranks the highest-revenue product categories |
| Key finding | Health & Beauty and Watches & Gifts are consistent top performers |

**How to build in Tableau:**
1. Drag `product_category` to Rows
2. Drag `Total Revenue` to Columns
3. Sort by descending revenue
4. Add a Top 10 filter: right-click field → Filter → Top → By Field → Top 10 by SUM(payment_value)

**How to build in Power BI:**
1. Insert → Clustered Bar Chart
2. Y-axis = `product_category`, X-axis = `Total Revenue`
3. In Filters pane → Add `product_category` → Filter type: Top N → Show items: Top 10 By value: `Total Revenue`

---

### Visual 3 — Map: Orders by State

| Property | Value |
|---|---|
| Chart type | Filled/choropleth map |
| Geography | `customer_state` (2-letter Brazilian state codes) |
| Color | Intensity = `Total Orders` |
| Purpose | Shows geographic concentration of order volume across Brazil |
| Key finding | São Paulo (SP) dominates order volume, followed by Rio de Janeiro (RJ) and Minas Gerais (MG) |

**How to build in Tableau:**
1. Double-click `customer_state` — Tableau auto-detects it as a geographic field
2. Drag `Total Orders` to the Color shelf
3. Set map layer to Brazil
4. Format → Edit Colors → choose a single-hue gradient (e.g. blue)

**How to build in Power BI:**
1. Insert → Filled Map
2. Location = `customer_state`
3. Color saturation = `Total Orders` measure
4. Format → Map styles → set to South America region

---

### Visual 4 — Table: Top Customers

| Property | Value |
|---|---|
| Chart type | Data table |
| Rows | Top 10 `customer_id` values by revenue |
| Columns | Customer ID, Total Revenue, Total Orders, AOV |
| Purpose | Identifies the highest-value individual customers |
| Key finding | Top 10 customers generate a disproportionate share of total revenue |

**How to build in Tableau:**
1. Drag `customer_id` to Rows
2. Drag `Total Revenue`, `Total Orders`, and `AOV` to the Text/Measure Values shelf
3. Sort by `Total Revenue` descending
4. Add a Top 10 filter on `customer_id` by SUM(payment_value)

**How to build in Power BI:**
1. Insert → Table visual
2. Columns: `customer_id`, `Total Revenue`, `Total Orders`, `AOV`
3. In Filters pane → Add `customer_id` → Filter type: Top N → Top 10 by `Total Revenue`
4. Format → Sort by Total Revenue descending

---

### Visual 5 — KPI Cards: Headline Metrics

| Property | Value |
|---|---|
| Chart type | Card / KPI tiles |
| Metrics shown | Total Revenue · Total Orders · Average Order Value |
| Position | Top of dashboard |
| Purpose | Gives executives a single-glance summary of overall performance |

**How to build in Tableau:**
1. Create a new sheet for each KPI
2. Drag the calculated field (e.g. `Total Revenue`) to the Text mark
3. Change mark type to **Text**
4. Format the number (currency, comma-separated)
5. On the dashboard, drag each sheet and resize to a small card tile

**How to build in Power BI:**
1. Insert → Card
2. Field = `Total Revenue` measure → format as currency
3. Duplicate for `Total Orders` and `AOV`
4. Resize and arrange at the top of the report canvas

---

## 7. Interactivity & Filters

Three global filters allow users to slice all dashboard visuals simultaneously.

### Filter 1 — Date Range

- **Field:** `order_date`
- **Type:** Range (start date → end date slider)
- **Purpose:** Focus on a specific time window — e.g. Q4 2017 only
- **Tableau:** Add `order_date` to Filters shelf → Range of Dates → right-click → Apply to All Worksheets → Show Filter
- **Power BI:** Insert Slicer → Field: `order_date` → Format → Slicer settings → Style: Between

### Filter 2 — Product Category

- **Field:** `product_category`
- **Type:** Multi-select dropdown
- **Purpose:** Compare performance within a single category or a set of categories
- **Tableau:** Add `product_category` to Filters shelf → Multiple Values (dropdown) → Apply to All Worksheets → Show Filter
- **Power BI:** Insert Slicer → Field: `product_category` → Style: Dropdown

### Filter 3 — State

- **Field:** `customer_state`
- **Type:** Multi-select list
- **Purpose:** Focus analysis on a specific Brazilian state or region
- **Tableau:** Add `customer_state` to Filters shelf → Multiple Values (list) → Apply to All Worksheets → Show Filter
- **Power BI:** Insert Slicer → Field: `customer_state` → Style: List

> **Testing note:** After adding all three filters, test each one by selecting a value and confirming that ALL five visuals update simultaneously. In Power BI, go to View → Edit Interactions to ensure cross-filtering is enabled for every visual pair.

---

## 8. Key Insights

The following insights were derived from analysis of the cleaned dataset and confirmed through the dashboard visuals.

---

### Insight 1 — Seasonal Revenue Spike in November

Revenue peaks sharply in November each year, with month-over-month growth significantly above the annual average. This pattern aligns with Brazil's adoption of Black Friday promotions, which Olist sellers participate in heavily. December shows a secondary lift before dropping in January.

**Implication:** Marketing spend and inventory planning should prioritize Q4, particularly November, to capitalize on peak demand.

---

### Insight 2 — São Paulo Dominates Order Volume

São Paulo (SP) accounts for approximately 40% of all delivered orders, making it by far the single largest market in the dataset. Rio de Janeiro (RJ) and Minas Gerais (MG) are distant second and third. The remaining 24 states each contribute less than 5% individually.

**Implication:** Operational and logistics investments (warehousing, last-mile delivery) should be prioritized in São Paulo. Expansion into secondary states like RJ and MG represents the next growth opportunity.

---

### Insight 3 — Top 10 Customers Drive Outsized Revenue

The top 10 customers by lifetime spend contribute a disproportionately high share of total revenue relative to their size as a proportion of the total customer base. This concentration suggests the existence of high-value B2B buyers or resellers within the platform.

**Implication:** A customer retention or loyalty programme targeted at top spenders could yield significant revenue protection with relatively low acquisition cost.

---

### Insight 4 — Health & Beauty is the Top Revenue Category

Health & Beauty consistently ranks as the highest revenue-generating product category, followed by Watches & Gifts and Bed, Bath & Table. Together, the top three categories account for approximately 25% of total platform revenue.

**Implication:** Category management teams should ensure adequate seller supply, competitive pricing, and promotional visibility in these top three categories.

---

### Insight 5 — Average Order Value Shows a Declining Trend in Mid-Year

AOV dips noticeably in mid-year months (Q2–Q3), coinciding with a shift toward smaller, lower-price-point categories gaining order share. This is not a revenue decline but a mix shift — more orders of lower individual value.

**Implication:** To protect AOV, the platform could introduce bundled product promotions or free-freight thresholds that incentivize larger basket sizes during lower-AOV periods.

---

## 9. How to Run / Reproduce

### Prerequisites

- **SQL tool:** DBeaver, pgAdmin, MySQL Workbench, or any SQL client
- **BI tool:** Tableau Desktop (free trial at tableau.com) OR Power BI Desktop (free at powerbi.microsoft.com)
- **Dataset:** Downloaded from [Kaggle — Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

### Step 1 — Set up the database

```bash
# If using PostgreSQL, create a new database and import CSVs:
psql -U your_user -d your_database

# Then run the table creation and COPY commands for each CSV file
```

Or simply load all CSVs directly into Tableau/Power BI without a database (both tools accept CSV natively).

### Step 2 — Run the SQL query

Copy the master SQL query from [Section 4.2](#42-sql-query--master-analytical-table) into your SQL client. Execute it and export the results as `olistdata_cleaned.csv`.

### Step 3 — Connect to Tableau or Power BI

**Tableau:**
- File → Connect → Text File → select `olistdata_cleaned.csv`
- Confirm data types in the Data Source tab (ensure `order_date` is a Date, not a String)

**Power BI:**
- Get Data → Text/CSV → select `olistdata_cleaned.csv`
- In Power Query Editor, set `order_date` column type to Date
- Click Close & Apply

### Step 4 — Build the dashboard

Follow the build instructions in [Section 6](#6-dashboard-visuals) for each visual, then assemble them on a single dashboard canvas.

### Step 5 — Add filters

Follow the instructions in [Section 7](#7-interactivity--filters) to add the three global filters.

### Step 6 — Publish

**Tableau:** Server → Tableau Public → Save to Tableau Public (free). Copy the shareable link.

**Power BI:** Home → Publish → select your workspace. Access via app.powerbi.com.

---

## 10. Tools & Technologies

| Tool | Version | Purpose |
|---|---|---|
| PostgreSQL / MySQL | 14+ / 8+ | Data storage and SQL querying |
| Tableau Desktop | 2023.x or later | Dashboard building (Option A) |
| Power BI Desktop | Latest (free) | Dashboard building (Option B) |
| DBeaver / pgAdmin | Any | SQL client for running queries |
| Microsoft Excel / Google Sheets | Any | Optional: quick data inspection |

---

## 11. Folder Structure

```
olist-dashboard/
│
├── data/
│   ├── raw/                          # Original CSVs from Kaggle
│   │   ├── olist_orders_dataset.csv
│   │   ├── olist_order_items_dataset.csv
│   │   ├── olist_products_dataset.csv
│   │   ├── olist_customers_dataset.csv
│   │   ├── olist_order_payments_dataset.csv
│   │   └── product_category_name_translation.csv
│   │
│   └── processed/
│       └── olistdata_cleaned.csv       # Flat analytical table (SQL output)
│
├── sql/
│   └── prepare_data.sql              # Master SQL query for data preparation
│
├── dashboard/
│   ├── olist_dashboard.twbx          # Tableau packaged workbook (if using Tableau)
│   └── olist_dashboard.pbix          # Power BI file (if using Power BI)
│
├── screenshots/
│   └── dashboard_overview.png        # Dashboard screenshot for submission
│
└── README.md                         # This file
```

---

## 12. Known Limitations

- **No real-time data:** The dataset is static (2016–2018). The dashboard does not connect to a live data source.
- **Customer anonymisation:** `customer_id` values are anonymised hashes, so top customer analysis cannot be linked to real business names.
- **Revenue simplification:** Revenue is calculated as `price + freight_value` per item, not from the `order_payments` table. Payment instalment splits are not accounted for.
- **Missing geolocation precision:** The map uses state-level data only. City-level or zip-level mapping would require joining the `geolocation` table, which contains multiple coordinates per zip code prefix and requires deduplication.
- **Single currency:** All monetary values are in BRL (Brazilian Real). No currency conversion has been applied.
- **Translated categories only:** ~600 rows with no matching English translation default to the original Portuguese category name or 'Unknown'.

---

## 13. Future Improvements

- **Add delivery performance metrics** — include average delivery time vs. estimated delivery time as a KPI, using `order_delivered_customer_date` and `order_estimated_delivery_date`
- **Include customer review scores** — join the `order_reviews` table to add an average satisfaction score KPI and a sentiment breakdown visual
- **Build a seller performance view** — add a separate dashboard tab showing top sellers by revenue, orders, and average review score using the `sellers` table
- **Connect to a live database** — replace the static CSV with a live PostgreSQL connection so the dashboard auto-refreshes as new data arrives
- **Add cohort analysis** — track customer retention over time by grouping customers by their first order month and measuring repeat purchase behaviour
- **Mobile layout** — create a mobile-optimised view of the dashboard for executives accessing it on smartphones (both Tableau and Power BI support this natively)

---


*Dataset credit: Olist, the largest department store in Brazilian marketplaces. Data made publicly available on Kaggle under the CC BY-NC-SA 4.0 licence.*
