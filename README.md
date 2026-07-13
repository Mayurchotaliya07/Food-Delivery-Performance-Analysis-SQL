# 🍔 Food Delivery Time Analysis | SQL Portfolio Project

![MySQL](https://img.shields.io/badge/MySQL-Database-4479A1?logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/Language-SQL-orange)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![Records](https://img.shields.io/badge/Records-1%2C000-blue)

> An operational deep-dive into what really drives food delivery times — weather, traffic, vehicle type, time of day, and courier experience — built entirely in MySQL using CTEs, window functions, subqueries, and CASE-based segmentation.

---

## 📖 Table of Contents
- [Project Overview](#-project-overview)
- [Business Problem](#-business-problem)
- [Dataset Information](#-dataset-information)
- [Tools & Technologies](#-tools--technologies)
- [Project Workflow](#-project-workflow)
- [Analysis Sections](#-analysis-sections)
- [Key Business Insights](#-key-business-insights)
- [Business Recommendations](#-business-recommendations)
- [SQL Concepts Used](#-sql-concepts-used)
- [Project Highlights](#-project-highlights)
- [Future Improvements](#-future-improvements)
- [Project Structure](#-project-structure)
- [How to Run](#-how-to-run)
- [Author](#-author)
- [License](#-license)

---

## 📌 Project Overview

Food delivery platforms compete on speed, and even small inefficiencies in courier assignment, route conditions, or kitchen turnaround can compound into missed delivery-time targets and frustrated customers. This project analyzes **1,000 real-world food delivery orders** to uncover the operational factors — weather, traffic congestion, vehicle type, time of day, and courier experience — that most influence delivery performance.

Using MySQL, the raw dataset was audited for missing values and duplicates, cleaned, and then explored through a structured series of queries covering order-level KPIs, weather and traffic segmentation, vehicle benchmarking, time-of-day patterns, and advanced diagnostics such as outlier detection and delivery-time categorization. The objective was to move beyond simple averages and pinpoint exactly *where* delays concentrate — which weather-traffic combinations create the worst outcomes, and which vehicle types hold up best under pressure.

The resulting insights are designed to support real operational decisions around courier and vehicle allocation, weather-contingency planning, and SLA design — while the project itself demonstrates practical SQL skills (CTEs, window functions, subqueries, CASE logic) applied to a realistic operations dataset.

---

## 🧩 Business Problem

Delivery time is one of the most visible metrics in the food delivery industry — it directly shapes customer satisfaction, repeat orders, and platform reputation, while long or unpredictable delivery windows drive up support costs and courier churn. Delivery time is influenced by a mix of controllable and uncontrollable factors: kitchen preparation speed, vehicle choice, and courier assignment can be managed operationally, while weather and traffic congestion largely cannot.

Without a clear, data-backed understanding of which factors matter most — and by how much — operations teams are left guessing: over-staffing on "safe" days, under-preparing for high-risk conditions, or applying a one-size-fits-all delivery SLA that doesn't reflect real-world variability. This analysis quantifies the impact of weather, traffic, vehicle type, time of day, and courier experience on delivery performance so the business can make targeted, evidence-based operational decisions rather than broad assumptions.

---

## 🗂 Dataset Information

| Detail | Description |
|---|---|
| **Dataset name** | `Food_Delivery_Times.csv` |
| **Total records** | 1,000 delivery orders |
| **Table name** | `food_delivery_info` |
| **Grain** | One row per delivery order |

**Features used:**

| Column | Description |
|---|---|
| `Order_ID` | Unique identifier for each delivery |
| `Distance_km` | Distance between restaurant and customer |
| `Weather` | Weather condition at time of delivery (Clear, Rainy, Snowy, Foggy, Windy) |
| `Traffic_Level` | Traffic congestion level (Low, Medium, High) |
| `Time_of_Day` | Order period (Morning, Afternoon, Evening, Night) |
| `Vehicle_Type` | Courier's vehicle (Bike, Scooter, Car) |
| `Preparation_Time_min` | Restaurant prep time in minutes |
| `Courier_Experience_yrs` | Courier's years of experience |
| `Delivery_Time_min` | Total delivery time in minutes (target metric) |

**Data cleaning performed:**
- Audited every column for missing values using conditional aggregation.
- Found **30 missing values (~3%)** each in `Weather`, `Traffic_Level`, and `Time_of_Day`, and a further 30 missing in `Courier_Experience_yrs`.
- Imputed missing `Weather`, `Traffic_Level`, and `Time_of_Day` values with `'Unknown'` so categorical breakdowns remain complete and auditable rather than silently dropping rows.
- Checked `Order_ID` for duplicates — **no duplicate order IDs found**; all 1,000 records are unique.

**Limitations:**
- `Courier_Experience_yrs` still contains missing values that were not imputed; queries involving this field explicitly filter them out with `IS NOT NULL`.
- The dataset has no date/timestamp field, so no day-of-week, seasonal, or trend-over-time analysis is possible.
- There is no revenue, order value, or customer satisfaction/rating field, so this analysis is limited strictly to **operational efficiency**, not financial or customer-experience impact.
- `Weather`, `Traffic_Level`, and `Time_of_Day` are point-in-time snapshots per order, not continuous tracking, so conditions mid-delivery aren't captured.

---

## 🛠 Tools & Technologies

- **MySQL** — database engine and query execution
- **SQL** — all data cleaning, transformation, and analysis
- **Window Functions** — `DENSE_RANK()`, `LAG()`
- **CTEs (Common Table Expressions)** — `WITH` clauses for layered, readable logic
- **CASE Statements** — categorization and conditional aggregation
- **Aggregate Functions** — `AVG()`, `COUNT()`, `SUM()`, `ROUND()`
- **Subqueries** — scalar and correlated subqueries for benchmarking against overall averages

---

## 🔄 Project Workflow

1. **Data Import** — Load the raw CSV into a MySQL table (`food_delivery_info`).
2. **Data Quality Audit** — Check for nulls across all key fields and scan for duplicate `Order_ID`s.
3. **Data Cleaning** — Impute missing categorical fields with `'Unknown'` to preserve row completeness.
4. **Order Overview** — Establish baseline KPIs (total orders, average delivery/prep time, average distance, average experience).
5. **Segmented Analysis** — Break down performance by weather, traffic, vehicle type, and time of day.
6. **Advanced Analytics** — Rank vehicles, cross-tabulate weather × traffic, isolate above-average and top-10 slowest deliveries, bucket deliveries into speed tiers, and test the courier-experience relationship.
7. **Insight Synthesis** — Translate query outputs into business-ready insights and recommendations.

---

## 📊 Analysis Sections

### 1. Order Overview
**What was analyzed:** Baseline KPIs — total order volume, average delivery time, average preparation time, average distance, and average courier experience.
**Why it matters:** Establishes the operational benchmark (a **56.73-minute** average delivery time across 1,000 orders) that every other segment is measured against.

### 2. Weather Analysis
**What was analyzed:** Order volume, average delivery time, and average preparation time broken down by weather condition, plus a direct rainy-vs-clear comparison.
**Why it matters:** Weather is uncontrollable but predictable in advance — quantifying its impact allows the business to plan staffing and set customer expectations ahead of poor-weather days.

### 3. Traffic Analysis
**What was analyzed:** Order frequency, average delivery time, the delivery-time gap between high and low traffic, and total operational time (prep + delivery combined) by traffic level.
**Why it matters:** Traffic congestion turned out to be the single largest controllable-adjacent lever — routing and dispatch decisions can meaningfully offset it.

### 4. Vehicle Performance
**What was analyzed:** Usage frequency, average delivery speed, performance on above-average-distance orders, and sensitivity to traffic, all broken down by vehicle type (Bike, Scooter, Car).
**Why it matters:** Vehicle assignment is one of the few levers the business fully controls — matching vehicle type to route conditions is a direct, actionable efficiency gain.

### 5. Time of Day Analysis
**What was analyzed:** Order volume, average delivery time, and average preparation time across Morning, Afternoon, Evening, and Night.
**Why it matters:** Identifies whether delays are driven by order volume (rush-hour crowding) or by other compounding factors like kitchen slowdown — critical for shift planning.

### 6. Advanced Business Insights
**What was analyzed:** Vehicle ranking by speed, weather × traffic cross-tabulation, deliveries exceeding the overall average, the 10 slowest deliveries, a Fast/Medium/High delivery-speed categorization, and the relationship between courier experience and delivery time.
**Why it matters:** Moves beyond single-variable averages to expose compounding conditions (e.g., a specific weather + traffic combination) and outliers that single-factor analysis would miss.

---

## 💡 Key Business Insights

- **Snowy weather produces the slowest deliveries**, averaging **67.11 minutes** — more than 14 minutes slower than clear-weather deliveries (53.08 minutes).
- **Rainy conditions add 6.71 minutes** to the average delivery, rising to **59.79 minutes** versus 53.08 minutes in clear weather.
- **High traffic is the strongest single driver of delay**: deliveries in high traffic average **64.81 minutes**, 11.92 minutes slower than low-traffic deliveries (52.89 minutes).
- **Traffic and prep time compound**: high-traffic orders carry the heaviest combined operational load (**81.54 minutes** of prep + delivery time combined), over 11 minutes above low-traffic orders (70.11 minutes).
- **The worst-performing combination is Rainy weather + High traffic**, averaging **77.05 minutes** — more than 27 minutes slower than the best combination, Clear weather + Low traffic (49.88 minutes).
- **Bikes are the most-used vehicle** (503 of 1,000 orders, 50.3%), but **scooters post the fastest average delivery time** (56.05 minutes), narrowly ahead of bikes (56.57) and cars (58.20).
- **Bikes are the least sensitive to traffic**, gaining only 9.59 minutes in delivery time between low and high traffic — versus scooters, which gain **16.53 minutes**, the largest swing of any vehicle type.
- **Scooters remain fastest even on long-distance orders** (above the 10.06 km average distance), averaging 70.0 minutes versus 71.45 (bike) and 72.73 (car).
- **Evening is the most delay-prone period**, with both the highest average delivery time (57.48 minutes) and the highest average preparation time (17.41 minutes) of any time-of-day segment.
- **Morning has the highest order volume** (308 orders, 30.8%) but is not the slowest period — indicating delays are driven more by weather and traffic conditions than by raw order volume.
- **Courier experience shows a general — though not perfectly linear — improvement pattern**: couriers with under 2 years' experience average roughly 60 minutes per delivery, while couriers with 5+ years average closer to 54–56 minutes.
- **Delay is common, not exceptional**: 482 of 1,000 orders (48.2%) exceed the overall average delivery time, and 415 orders (41.5%) fall into the "High" (61+ minute) delivery bucket versus only 247 (24.7%) in the "Fast" (≤40 minute) bucket.

---

## ✅ Business Recommendations

- **Pre-position additional couriers ahead of snowy and rainy forecasts**, when average delivery times rise by 6–14 minutes versus clear conditions.
- **Build weather-and-traffic-aware ETAs** rather than a flat SLA — the Rainy + High-traffic combination alone pushes average delivery time to 77 minutes, far above the network average of 56.73 minutes.
- **Prioritize bikes for known high-traffic zones and routes**, since they absorb traffic-driven delay better than any other vehicle type (+9.59 minutes vs. +16.53 for scooters).
- **Use scooters for standard-traffic and long-distance routes** where they consistently post the fastest times, but avoid defaulting to them on congested routes given their outsized traffic penalty.
- **Investigate evening kitchen and dispatch operations specifically** — both preparation time and delivery time peak in the evening window, suggesting a compounding bottleneck rather than a single root cause.
- **Continue assigning couriers by experience where possible**, and expand onboarding support for newer couriers (under 2 years), who currently run roughly 5–6 minutes slower on average.
- **Set up a delay-review workflow for outlier orders** — the single slowest delivery (153 minutes) occurred under clear weather, showing that some delays stem from factors outside weather and traffic, such as kitchen readiness or courier availability.
- **Re-segment delivery SLAs by condition rather than using one blanket target**, since nearly half of all deliveries already exceed the current network average.
- **Improve data capture at the point of order entry** for `Weather`, `Traffic_Level`, `Time_of_Day`, and `Courier_Experience_yrs` to eliminate the ~3% of records currently logged as "Unknown" and missing from experience-based analysis.
- **Use the traffic-level operational load findings (prep + delivery time) to guide dispatch pacing** during high-traffic windows, when total operational time runs over 11 minutes longer than during low-traffic windows.

---

## 🧠 SQL Concepts Used

| Concept | How It Was Applied |
|---|---|
| **Data Cleaning** | `UPDATE` statements with `TRIM()` and `IS NULL` checks to impute missing categorical values |
| **Conditional Aggregation** | `SUM(CASE WHEN ... THEN 1 ELSE 0 END)` to audit null counts column-by-column |
| **GROUP BY** | Aggregating delivery/prep time and order counts by weather, traffic, vehicle, and time of day |
| **ORDER BY** | Sorting ranked and comparative results for readability |
| **Aggregate Functions** | `AVG()`, `COUNT()`, `ROUND()` used throughout for KPI calculation |
| **CASE Statements** | Categorizing deliveries into Fast / Medium / High speed tiers; conditional averages for traffic-sensitivity comparisons |
| **CTEs (`WITH`)** | Layering intermediate aggregations (e.g., computing weather-level averages before ranking them) |
| **Window Functions — `DENSE_RANK()`** | Identifying top-performing/worst-performing categories (e.g., slowest weather condition, busiest traffic level, top 10 longest deliveries) without losing ties |
| **Window Functions — `LAG()`** | Comparing each courier-experience tier's average delivery time to the previous tier to test for a trend |
| **Subqueries (Scalar)** | Benchmarking individual orders against the overall average delivery time and average distance |
| **Subqueries (Correlated/Cross Join)** | Comparing rainy vs. clear weather and high vs. low traffic averages side-by-side using `CROSS JOIN` on pre-aggregated CTEs |
| **Common Functions** | `TRIM()` for whitespace-only null detection |

---

## 🌟 Project Highlights

- Analyzed **1,000 real-world delivery orders** across 5 weather conditions, 3 traffic levels, 3 vehicle types, and 4 time-of-day segments.
- Performed a full **data quality audit and cleaning pass** before any analysis, including null detection and duplicate-key verification.
- Quantified the **compounding effect of weather + traffic together**, not just each factor in isolation — surfacing a 27-minute swing between best- and worst-case conditions.
- Benchmarked **vehicle performance three different ways** (overall speed, long-distance speed, and traffic resilience) to support fleet-assignment decisions.
- Used **window functions and CTEs** to rank and isolate top/bottom performers without hardcoding thresholds.
- Built a **repeatable delivery-speed categorization** (Fast / Medium / High) using CASE logic, directly usable for downstream dashboards.
- Tested a **real operational hypothesis** (does courier experience reduce delivery time?) using `LAG()` for tier-over-tier comparison.
- Delivered **evidence-based, actionable recommendations** tied directly to query outputs — no assumed or invented metrics.

---

## 🚀 Future Improvements

- **Predictive delivery-time modeling** — use regression or ML models on distance, weather, traffic, and courier features to forecast delivery time per order.
- **Dashboard integration** — connect this analysis to Power BI or Tableau for live, interactive monitoring of delivery KPIs.
- **Geographic analysis** — if latitude/longitude or zone data becomes available, analyze delay hotspots by delivery region.
- **Customer satisfaction analysis** — join in ratings/feedback data to test whether longer delivery times correlate with lower satisfaction.
- **Route optimization** — incorporate real-time traffic and mapping APIs to recommend optimal courier routing.
- **Time-series analysis** — add order timestamps to study day-of-week and seasonal delivery patterns.
- **Full imputation strategy** — model or median-fill `Courier_Experience_yrs` instead of excluding nulls via filters.

---

## 📁 Project Structure

```
food-delivery-time-analysis/
│
├── Food_Delivery_Times.csv          # Raw dataset (1,000 delivery orders)
├── Food_Delivery_Times_analysis.sql # Full SQL script: cleaning + analysis
└── README.md                        # Project documentation (this file)
```

---

## ▶️ How to Run

1. **Install MySQL** (or use a compatible client such as MySQL Workbench, DBeaver, or the MySQL CLI).
2. **Create a database and import the dataset:**
   ```sql
   CREATE DATABASE food_delivery_db;
   USE food_delivery_db;
   -- Import Food_Delivery_Times.csv into a table named food_delivery_info
   -- (via Table Data Import Wizard in MySQL Workbench, or LOAD DATA INFILE)
   ```
3. **Run the analysis script:**
   ```bash
   mysql -u your_username -p food_delivery_db < Food_Delivery_Times_analysis.sql
   ```
4. Review each query's output section by section — the script is organized into Data Cleaning, Order Overview, Weather Analysis, Traffic Analysis, Vehicle Performance, Time of Day Analysis, and Advanced Business Insights.

---

## 👤 Author

**[Your Name]**
Data Analyst | SQL & Business Intelligence

---

## 🔗 GitHub Repository

[github.com/your-username/food-delivery-time-analysis](https://github.com/your-username/food-delivery-time-analysis)

## 💼 LinkedIn

[linkedin.com/in/your-profile](https://linkedin.com/in/your-profile)

---

## 📄 License

This project is licensed under the **MIT License** — free to use, modify, and share with attribution.

---

<p align="center">⭐ If you found this project useful, consider giving it a star on GitHub!</p>
