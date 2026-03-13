End-to-End Retail Performance & Behavioral Analytics
1. Overview
This project, RetailNova, is a comprehensive data analytics solution designed to bridge the gap between raw transactional data and strategic decision-making. By integrating sales, product, and customer demographics, the project provides a 360-degree view of business health, focusing on customer retention, product profitability, and regional growth.

2. Dataset
The analysis is based on five primary datasets representing a multi-channel retail environment:

Customers: Demographic details (Age, Gender, Location, Signup Date).

Products: Product catalog, categories, brands, and profit margins.

Sales: Transactional records including order dates, channels (Online/Store), and discounts.

Stores: Operational costs and geographic locations.

Returns: Return reasons (Defective, Late Delivery, etc.) and dates.

3. Tools Used
Data Cleaning & EDA: Python (Pandas, NumPy, Matplotlib, Seaborn)

Database Management: SQL Server (T-SQL)

Data Visualization: Power BI (DAX, Power Query)

Documentation: Microsoft Word & PowerPoint

4. Project Steps
Phase 1: Python (Cleaning & Preprocessing)
Handled missing values using median imputation for demographic consistency.

Performed feature engineering (e.g., creating age_group and total_amount columns).

Standardized categorical data and validated date formats for leap-year accuracy.

Exported cleaned .csv files for SQL ingestion.

Phase 2: SQL Server (Advanced Analysis)
Designed a relational schema and imported cleaned data.

Developed complex queries to track Customer Churn (90-day inactivity window).

Used Window Functions (DENSE_RANK) to identify products with the highest return rates.

Analyzed monthly profit trends and regional performance.

Phase 3: Power BI (Dashboarding)
Built a dynamic, multi-page dashboard featuring automated KPI tracking.

Developed advanced DAX measures for Churn Rate % and Loyalty Tiers.

Created interactive maps for regional store performance and channel comparisons.

5. Dashboard Preview
The Power BI dashboard consists of five core views:

Sales Performance: Revenue, Profit, and Order trends.

Customer Insights: Gender distribution and Loyalty segmentation.

Product Performance: Analysis of categories and brands.

Return Analysis: Financial impact of defective goods.

Store Performance: Regional profitability and Online vs. Physical store metrics.

6. Key Results & Insights
Churn Reality: Identified that a significant portion of churned customers are those who signed up but never made a first purchase.

Financial Leakage: Identified a $30K loss due to returns, specifically within the Electronics category.

Growth Opportunity: The South region was identified as the most profitable, suggesting it as the ideal location for a new flagship store.

Recommendation: Proposed a "First Purchase" coupon strategy to convert new signups and reduce early-stage churn.

7. How to Run
Python: Open data_cleaning_eda.ipynb in Jupyter Notebook or VS Code to see the preprocessing logic.

SQL: Run the scripts in SQLQuery.sql on SQL Server to generate the analytical views.

Power BI: Open Retail Analytics.pbix to interact with the live dashboard (requires Power BI Desktop).

Presentation: Review RETAILNOVA Project Presentation.pptx for a high-level executive summary.


Author: Sara Mahesh

Role: Data Analyst

Contact: saramahesh02@gmail.com
