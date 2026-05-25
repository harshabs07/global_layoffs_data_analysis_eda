# World Layoffs: Data Cleaning & Exploratory Data Analysis (EDA) in MySQL

## 📌 Project Overview
This project is an end-to-end relational database exercise focused on processing raw, unstructured employment data. Using **MySQL**, I took a messy dataset of global corporate layoffs (2020–2023), architected a staging environment, systematically cleaned the data, and performed in-depth exploratory data analysis (EDA) to identify industry trends and rolling operational metrics.

## 🛠️ Technical Stack
* **Database Management System:** MySQL
* **Core Analytics Skills:** Data Cleaning, ETL staging, Exploratory Data Analysis (EDA), Time-Series Tracking
* **Advanced SQL Concepts Utilized:** * Common Table Expressions (CTEs)
  * Window Functions (`ROW_NUMBER()`, `DENSE_RANK()`, `SUM() OVER()`)
  * String Manipulation (`TRIM()`, `SUBSTRING()`)
  * Data Type Formatting (`STR_TO_DATE()`)
  * Self-Joins

---

## 🧹 Phase 1: Data Cleaning
In the real world, data is rarely ready for immediate analysis. To preserve the integrity of the raw data, I created a staging table and executed a multi-step cleaning pipeline:

1. **Removing Duplicates:** Utilized `ROW_NUMBER()` partitioned across all relevant columns to flag and delete duplicate records without a unique identifier.
2. **Standardization:** Cleaned string inconsistencies (e.g., standardizing multiple variations of "Crypto" into a single category, stripping trailing periods from country names) using `TRIM()` and `TRAILING`.
3. **Data Type Conversion:** Transformed raw text strings into standard SQL `DATE` formats to enable accurate time-series analysis.
4. **Handling NULLs & Blank Values:** Used **Self-Joins** to populate missing industry data by cross-referencing companies with multiple layoff events.
5. **Removing Unnecessary Data:** Dropped isolated rows lacking both layoff totals and percentage metrics, ensuring the final dataset was strictly analytical. 

*Code reference:* [`data_cleaning.sql`](data_cleaning.sql)

---

## 📊 Phase 2: Exploratory Data Analysis (EDA)
With a clean, structured database, I executed complex queries to extract actionable insights regarding the severity and timeline of global layoffs.

**Key Analytical Queries:**
* **Macro Trends:** Identified total layoffs per company, industry, and country (e.g., tracking the massive spike in US tech layoffs in late 2022/early 2023).
* **Time-Series Rolling Totals:** Built a CTE-driven rolling sum to track the cumulative progression of layoffs month-by-month over the 3-year period.
* **Company Rankings per Year:** Engineered a multi-layered CTE using `DENSE_RANK()` to partition the data by year and rank the top 5 companies with the highest workforce reductions annually.

*Code reference:* [`exploratory_data_analysis.sql`](exploratory_data_analysis.sql)

---

## 💡 Key Business Insights
* **The 2022-2023 Spike:** While 2021 showed a relative stabilization in tech, the late 2022 to early 2023 window saw devastating cuts, heavily driven by post-IPO tech giants (Google, Meta, Amazon).
* **Industry Impact:** The Consumer and Retail sectors took the heaviest initial hits during the 2020 lockdowns, while the Crypto and Tech sectors suffered the most significant volumetric losses in 2022.
* **Funding vs. Layoffs:** Explored the correlation between highly-funded companies (measured in funds raised in millions) and high-volume workforce reductions.
