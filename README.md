# Dashboard_project_olist_sales_customers_insights
tableau / PowerBI dashboard for the olist sales and customers insights

I use INNER JOINs to combine transactional, product, and customer data. First, I join orders with order_items to move from order-level to item-level granularity. Then I join products to enrich each item with category information, and customers to add geographic attributes. Since these are INNER JOINs, only records with complete relationships across all tables are retained.

### 📊 SQL Query Explanation: Delivered Orders – Customer & Product Insights

#### 🔷 Objective

This query is designed to analyze **delivered e-commerce orders** by combining order, customer, and product data. It provides a detailed view at the **order-item level**, enabling insights into revenue, product categories, and customer geographic distribution.

---

#### 🔷 Query Overview

The query retrieves key fields from multiple tables and calculates the total payment per item (including shipping costs). It filters the dataset to include only successfully delivered orders.

---

#### 🔷 Key Components

**1. Selecting Core Fields**

* `order_id`, `customer_id`, and `order_purchase_timestamp` are pulled from the `orders` table to identify each transaction and its timing.
* `product_category_name` is retrieved from the `products` table to categorize items.
* `customer_state` is sourced from the `customers` table to support geographic analysis.

---

**2. Calculating Payment Value**

* The query computes a new field:

  ```
  price + freight_value AS payment_value
  ```
* This represents the **total cost per item**, including both product price and shipping fee.
* This is a **derived metric**, calculated dynamically within the query.

---

**3. Joining Multiple Tables**
The query integrates data across four tables using inner joins:

* `orders` ↔ `order_items` (via `order_id`)
  → Expands each order into individual items

* `order_items` ↔ `products` (via `product_id`)
  → Adds product-level details

* `orders` ↔ `customers` (via `customer_id`)
  → Adds customer demographic information

---

**4. Filtering Delivered Orders**

* The `WHERE` clause ensures only completed transactions are included:

  ```
  order_status = 'delivered'
  ```

---

#### 🔷 Granularity

This query operates at the **order-item level**, meaning:

* Each row represents a **single item within an order**
* Orders with multiple items will appear in multiple rows

---

#### 🔷 Use Cases

This dataset can be used to:

* Analyze **revenue by product category**
* Evaluate **customer distribution by state**
* Track **purchase trends over time**
* Build dashboards for **business performance monitoring**

---

#### 🔷 Key Insight

Because the query is at the item level, the `payment_value` reflects **per-item revenue**, not total order revenue. Aggregation (e.g., `SUM`) would be required to calculate order-level or customer-level metrics.

---

#### 🔷 Example Business Question Answered

> “What are the top-performing product categories and how do they vary by customer location for delivered orders?”

---
