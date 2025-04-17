-- ========================================
-- 📅 Yearly Entry Count
-- ========================================
SELECT 
    EXTRACT(YEAR FROM "InvoiceDate") AS year,
    COUNT(*) AS entry_count
FROM 
    online_retail
GROUP BY 
    year
ORDER BY 
    year;

-- ========================================
-- 🔁 Sales vs Returns Count
-- ========================================
SELECT
    COUNT(CASE WHEN "Invoice" LIKE 'C%' THEN 1 END) AS return_count,
    COUNT(CASE WHEN "Invoice" NOT LIKE 'C%' THEN 1 END) AS sale_count
FROM 
    online_retail;

-- ========================================
-- 🔝 Top 10 Products by Revenue
-- ========================================
SELECT 
    "Description",
    SUM("Quantity") AS units_sold, 
    SUM("revenue") AS total_revenue
FROM 
    online_retail
GROUP BY 
    "Description"
ORDER BY 
    total_revenue DESC
LIMIT 10;

-- ========================================
-- 🔝 Top 10 Products (Excluding Postage)
-- ========================================
SELECT 
    "Description",
    SUM("Quantity") AS units_sold, 
    SUM("revenue") AS total_revenue
FROM 
    online_retail
WHERE 
    "Description" NOT ILIKE '%postage%'
GROUP BY 
    "Description"
ORDER BY 
    total_revenue DESC
LIMIT 10;

-- ========================================
-- 🚫 Lowest-Selling Products (Potential Losses)
-- ========================================
-- (These may include discontinued or newly added items)
SELECT 
    "Description",
    SUM("Quantity") AS units_sold, 
    SUM("revenue") AS total_revenue
FROM 
    online_retail
GROUP BY 
    "Description"
HAVING 
    SUM("Quantity") > 0 AND SUM("revenue") > 0
ORDER BY 
    total_revenue ASC;

-- ========================================
-- 📉 Top 10 Most Returned Products (by Lost Revenue)
-- ========================================
SELECT 
    "Description",
    SUM("Quantity") AS units_sold, 
    SUM("revenue") AS total_revenue
FROM 
    online_retail
WHERE 
    revenue < 0
    AND NOT ("Description" ~* '\m(fee|postage|discount|debt|commission|samples|manual|bank charges)\M')
GROUP BY 
    "Description"
ORDER BY 
    total_revenue ASC
LIMIT 10;

-- ========================================
-- 📉 Top 10 Most Returned Products (by Units)
-- ========================================
SELECT 
    "Description",
    SUM("Quantity") AS units_sold, 
    SUM("revenue") AS total_revenue
FROM 
    online_retail
WHERE 
    revenue < 0
    AND NOT ("Description" ~* '\m(fee|postage|discount|debt|commission|samples|manual|bank charges)\M')
GROUP BY 
    "Description"
ORDER BY 
    units_sold ASC
LIMIT 10;

-- ========================================
-- 🧼 Create Cleaned Table for Power BI
-- ========================================
CREATE TABLE online_retail_cleaned AS
SELECT 
    "Invoice",
    "Description",
    "Quantity",
    DATE("InvoiceDate") AS sale_date,
    "Price",
    "Country",
    ("Quantity" * "Price") AS revenue
FROM 
    online_retail
WHERE 
    "Invoice" NOT LIKE 'C%'  -- remove returns
    AND NOT ("Description" ~* '\m(fee|postage|discount|commission|samples|manual|charges)\M')  -- remove other losses
    AND "Quantity" > 0  -- remove non-sale items
    AND "Price" > 0;  -- remove non-real items