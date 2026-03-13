CREATE DATABASE RetailNova_DB;

USE RetailNova_DB;

SET DATEFORMAT dmy; 

-- 1. Customers
CREATE TABLE Customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    gender VARCHAR(20),
    age INT,
    signup_date DATE,
    region VARCHAR(50),
    age_group VARCHAR(20)
);

-- 2. Products
CREATE TABLE Products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    brand VARCHAR(100),
    cost_price DECIMAL(10,2),
    unit_price DECIMAL(10,2),
    margin_pct FLOAT
);

-- 3. Stores
CREATE TABLE Stores (
    store_id VARCHAR(50) PRIMARY KEY,
    store_name VARCHAR(100),
    store_type VARCHAR(50),
    region VARCHAR(50),
    city VARCHAR(50),
    operating_cost DECIMAL(10,2)
);

-- 4. Sales
CREATE TABLE Sales (
    order_id VARCHAR(50) PRIMARY KEY,
    order_date DATE,
    customer_id VARCHAR(50),
    product_id VARCHAR(50),
    store_id VARCHAR(50),
    sales_channel VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(10,2),
    discount_pct DECIMAL(10,2),
    total_amount DECIMAL(12,2),
    cost_price DECIMAL(10,2),
    profit DECIMAL(12,2)
);

-- 5. Returns
CREATE TABLE Returns (
    return_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    return_date DATE,
    return_reason VARCHAR(255)
);


-- Loading Data into Customers Table

BULK INSERT Customers
FROM 'D:\Data_analytics_ExcellenC\Project 2\End-to-End Retail Performance and Behavioral Analytics\Data\Raw\Cleaned\customers_cleaned.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW= 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Loading the Data into Products Table

BULK INSERT Products
FROM 'D:\Data_analytics_ExcellenC\Project 2\End-to-End Retail Performance and Behavioral Analytics\Data\Raw\Cleaned\products_cleaned.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW= 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);


-- Loading Data into Sales Table


BULK INSERT Sales
FROM 'D:\Data_analytics_ExcellenC\Project 2\End-to-End Retail Performance and Behavioral Analytics\Data\Raw\Cleaned\salesdata_cleaned.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Loading Data into Stores Table

BULK INSERT Stores
FROM 'D:\Data_analytics_ExcellenC\Project 2\End-to-End Retail Performance and Behavioral Analytics\Data\Raw\Cleaned\stores_cleaned.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW= 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Loading Data into Returns Table

BULK INSERT Returns
FROM 'D:\Data_analytics_ExcellenC\Project 2\End-to-End Retail Performance and Behavioral Analytics\Data\Raw\Cleaned\returns_cleaned.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW= 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);


-- Link Sales to Customers

ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Customers
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id);

-- Link Sales to Products

ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Products
FOREIGN KEY (product_id) REFERENCES Products(product_id);

-- Link Sales to Returns

ALTER TABLE Returns
ADD CONSTRAINT FK_Returns_Sales 
FOREIGN KEY (order_id) REFERENCES Sales(order_id);


-- Link Sales to Stores

-- 1. Insert the 'Online' record into the Stores table
-- This ensures the 'Sales' table has a valid 'Parent' to point to.

INSERT INTO Stores (store_id, store_name, store_type, region, city, operating_cost)
VALUES ('Online', 'Online E-Commerce', 'Digital', 'Global', 'All Cities', 0.00);

-- 2. Establish the Relationship (Foreign Key)
-- 'WITH CHECK' tells SQL to verify that all existing data follows this rule.

ALTER TABLE Sales
WITH CHECK ADD CONSTRAINT FK_Sales_Stores
FOREIGN KEY (store_id) REFERENCES Stores(store_id);

-- 3. Final Verification Join
-- If this query returns data, your Star Schema is officially working!

SELECT TOP 5 
    sl.order_id, 
    sl.total_amount, 
    st.store_name, 
    st.store_type
FROM Sales sl
JOIN Stores st ON sl.store_id = st.store_id
WHERE st.store_id = 'Online';



-- Creating the Index:

-- Index for date-based reporting
CREATE INDEX idx_order_date ON Sales(order_date);

-- Index for product performance
CREATE INDEX idx_product_id ON Sales(product_id);

-- Index for customer analysis
CREATE INDEX idx_customer_id ON Sales(customer_id);

-- Index for store analysis 
CREATE INDEX idx_store_id ON Sales(store_id);

-- Index for Returns analysis
CREATE INDEX idx_returns_orderid ON Returns(order_id);


-- Calculate Derived Metrics (Validation View)

CREATE VIEW v_SalesPerformance AS
SELECT *,
    (unit_price * quantity) AS Gross_Amount,
    (unit_price * quantity * discount_pct) AS Discount_Value,
    -- Verify Profit: Total Amount - (Unit Cost * Quantity)
    (total_amount - (cost_price * quantity)) AS Calculated_Profit
FROM Sales;


-- SQL for Business Questions:

-- 1. Total revenue generated in the last 12 months.

DECLARE @MaxDate DATE = (SELECT MAX(order_date) FROM Sales);

SELECT SUM(total_amount) AS Total_Revenue
FROM Sales
WHERE order_date >= DATEADD(MONTH, -12, @MaxDate);

-- 2. Top 5 best-selling products by quantity?

SELECT TOP 5 
    p.product_name, 
    SUM(s.quantity) AS Total_Quantity
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY Total_Quantity DESC;

-- 3. How many customers are from each region?

SELECT region, COUNT(customer_id) AS Customer_Count
FROM Customers
GROUP BY region;

-- 4. Which store has the highest profit in the past year?

DECLARE @LastYear DATE = (SELECT DATEADD(YEAR, -1, MAX(order_date)) FROM Sales);

SELECT TOP 1 
    st.store_name, 
    SUM(s.profit) AS Total_Profit
FROM Sales s
JOIN Stores st ON s.store_id = st.store_id
WHERE s.order_date >= @LastYear
GROUP BY st.store_name
ORDER BY Total_Profit DESC;

-- 5. What is the return rate by product category?

SELECT 
    p.category,
    -- Total Returns divided by Total Sales
    CAST(COUNT(r.order_id) AS FLOAT) / NULLIF(COUNT(s.order_id), 0) AS Return_Rate
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
LEFT JOIN Returns r ON s.order_id = r.order_id
GROUP BY p.category
ORDER BY Return_Rate DESC;

-- 6. Average revenue per customer by age group?

SELECT 
    c.age_group,
    SUM(s.total_amount) / COUNT(DISTINCT s.customer_id) AS Avg_Revenue_Per_Customer
FROM Sales s
JOIN Customers c ON s.customer_id = c.customer_id
GROUP BY c.age_group;


-- 7. Which sales channel (Online vs In-Store) is more profitable on average?

SELECT 
    sales_channel, 
    AVG(profit) AS Avg_Profit
FROM Sales
GROUP BY sales_channel;

-- 8. Monthly profit change over the last 2 years by region?

SELECT 
    st.region,
    FORMAT(s.order_date, 'yyyy-MM') AS Sale_Month,
    SUM(s.profit) AS Monthly_Profit
FROM Sales s
JOIN Stores st ON s.store_id = st.store_id
WHERE s.order_date >= DATEADD(YEAR, -2, (SELECT MAX(order_date) FROM Sales))
GROUP BY st.region, FORMAT(s.order_date, 'yyyy-MM')
ORDER BY Sale_Month, st.region;

-- 9. Top 3 products with the highest return rate in each category?

WITH CategoryReturnRates AS (
    SELECT 
        p.category,
        p.product_name,
        COUNT(r.order_id) * 1.0 / NULLIF(COUNT(s.order_id), 0) AS Return_Rate,
        DENSE_RANK() OVER(PARTITION BY p.category ORDER BY (COUNT(r.order_id) * 1.0 / NULLIF(COUNT(s.order_id), 0)) DESC) AS Rank
    FROM Sales s
    JOIN Products p ON s.product_id = p.product_id
    LEFT JOIN Returns r ON s.order_id = r.order_id
    GROUP BY p.category, p.product_name
)
SELECT * FROM CategoryReturnRates WHERE Rank <= 3;


-- 10. Which 5 customers have contributed the most to total profit, and what is their tenure with the company?

SELECT TOP 5 
    c.first_name + ' ' + c.last_name AS Customer_Full_Name,
    SUM(s.profit) AS Total_Profit_Contribution,
    DATEDIFF(YEAR, c.signup_date, GETDATE()) AS Tenure_Years
FROM Sales s
JOIN Customers c ON s.customer_id = c.customer_id
GROUP BY 
    c.first_name, 
    c.last_name, 
    c.signup_date
ORDER BY Total_Profit_Contribution DESC;

