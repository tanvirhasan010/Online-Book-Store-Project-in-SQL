-- Create Database
CREATE DATABASE OnlineBookstore;

-- Create Tables
DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);

DROP TABLE IF EXISTS customers;
CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);

DROP TABLE IF EXISTS orders;
CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);

SELECT * FROM Books;
SELECT * FROM Customers;
SELECT * FROM Orders;

-- Import Data into Books Table
/* I am using mac so I drag data from Tables section then import csv */

-- 1) Retrieve all books in the "Fiction" genre:

SELECT * FROM Books 
WHERE Genre='Fiction';

-- 2) Find books published after the year 1950:
SELECT * FROM Books 
WHERE Published_year>1950;

-- 3) List all customers from the Canada:
SELECT * FROM Customers 
WHERE country='Canada';

-- 4) Show orders placed in November 2023:

SELECT * FROM Orders 
WHERE order_date BETWEEN '2023-11-01' AND '2023-11-30';

-- 5) Retrieve the total stock of books available:

SELECT SUM(stock) AS Total_Stock
From Books;

-- 6) Find the details of the most expensive book:
SELECT * FROM Books 
ORDER BY Price DESC 
LIMIT 1;

-- 7) Show all customers who ordered more than 1 quantity of a book:
SELECT * FROM Orders 
WHERE quantity>1;


-- 8) Retrieve all orders where the total amount exceeds $20:
SELECT * FROM Orders 
WHERE total_amount>20;

-- 9) List all genres available in the Books table:
SELECT DISTINCT genre FROM Books;

-- 10) Find the book with the lowest stock:
SELECT * FROM Books 
ORDER BY stock 
LIMIT 1;

-- 11) Calculate the total revenue generated from all orders:
SELECT SUM(total_amount) As Revenue 
FROM Orders;

-- Advance Questions : 

-- 1) Retrieve the total number of books sold for each genre:

SELECT * FROM ORDERS;

SELECT b.Genre, SUM(o.Quantity) AS Total_Books_sold
FROM Orders o
JOIN Books b ON o.book_id = b.book_id
GROUP BY b.Genre;

-- 2) Find the average price of books in the "Fantasy" genre:
SELECT AVG(price) AS Average_Price
FROM Books
WHERE Genre = 'Fantasy';

-- 3) List customers who have placed at least 2 orders:
SELECT o.customer_id, c.name, COUNT(o.Order_id) AS ORDER_COUNT
FROM orders o
JOIN customers c ON o.customer_id=c.customer_id
GROUP BY o.customer_id, c.name
HAVING COUNT(Order_id) >=2;

-- 4) Find the most frequently ordered book:
SELECT o.Book_id, b.title, COUNT(o.order_id) AS ORDER_COUNT
FROM orders o
JOIN books b ON o.book_id=b.book_id
GROUP BY o.book_id, b.title
ORDER BY ORDER_COUNT DESC LIMIT 1;

-- 5) Show the top 3 most expensive books of 'Fantasy' Genre :
SELECT * FROM books
WHERE genre ='Fantasy'
ORDER BY price DESC LIMIT 3;

-- 6) Retrieve the total quantity of books sold by each author:

SELECT b.author, SUM(o.quantity) AS Total_Books_Sold
FROM orders o
JOIN books b ON o.book_id=b.book_id
GROUP BY b.Author;


-- 7) List the cities where customers who spent over $30 are located:

SELECT DISTINCT c.city, total_amount
FROM orders o
JOIN customers c ON o.customer_id=c.customer_id
WHERE o.total_amount > 30;

-- 8) Find the customer who spent the most on orders:
SELECT c.customer_id, c.name, SUM(o.total_amount) AS Total_Spent
FROM orders o
JOIN customers c ON o.customer_id=c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY Total_spent Desc LIMIT 1;

--9) Calculate the stock remaining after fulfilling all orders:

SELECT b.book_id, b.title, b.stock, COALESCE(SUM(o.quantity),0) AS Order_quantity,  
	b.stock- COALESCE(SUM(o.quantity),0) AS Remaining_Quantity
FROM books b
LEFT JOIN orders o ON b.book_id=o.book_id
GROUP BY b.book_id ORDER BY b.book_id;

--10)Customer Order Frequency & Recency (RFM Analysis)
WITH customer_rfm AS (
    SELECT
        c.Customer_ID,
        c.Name,
        MAX(o.Order_Date) AS Last_Order_Date,
        COUNT(o.Order_ID) AS Frequency,
        SUM(o.Total_Amount) AS Monetary_Value,
        NTILE(5) OVER (ORDER BY MAX(o.Order_Date) DESC) AS Recency_Score,
        NTILE(5) OVER (ORDER BY COUNT(o.Order_ID)) AS Frequency_Score,
        NTILE(5) OVER (ORDER BY SUM(o.Total_Amount)) AS Monetary_Score
    FROM Customers c
    JOIN Orders o ON c.Customer_ID = o.Customer_ID
    GROUP BY c.Customer_ID, c.Name
)
SELECT *,
       (Recency_Score + Frequency_Score + Monetary_Score) AS RFM_Total
FROM customer_rfm
ORDER BY RFM_Total DESC;

--11)Running Total of Revenue by Genre
SELECT
    b.Genre,
    o.Order_Date,
    SUM(o.Total_Amount) OVER (PARTITION BY b.Genre ORDER BY o.Order_Date) AS Running_Total_Revenue
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
WHERE o.Order_Date >= '2023-01-01'
ORDER BY b.Genre, o.Order_Date;

--12) Finding the "Next Purchase" for Each Customer
SELECT
    Customer_ID,
    Order_Date,
    LEAD(Order_Date) OVER (PARTITION BY Customer_ID ORDER BY Order_Date) AS Next_Order_Date,
    LEAD(Order_Date) OVER (PARTITION BY Customer_ID ORDER BY Order_Date) - Order_Date AS Days_Until_Next_Order
FROM Orders
ORDER BY Customer_ID, Order_Date;

--13)Books That Are Above Average Price in Their Genre
-- Method 1: Using a Correlated Subquery (Intuitive)
SELECT
    Book_ID,
    Title,
    Author,
    Genre,
    Price
FROM Books b1
WHERE Price > (
    SELECT AVG(Price)
    FROM Books b2
    WHERE b2.Genre = b1.Genre
)
ORDER BY Genre, Price DESC;

-- Method 2: Using a Window Function (Often more efficient)
WITH GenreAverages AS (
    SELECT
        *,
        AVG(Price) OVER (PARTITION BY Genre) AS Avg_Genre_Price
    FROM Books
)
SELECT
    Book_ID,
    Title,
    Author,
    Genre,
    Price,
    Avg_Genre_Price
FROM GenreAverages
WHERE Price > Avg_Genre_Price
ORDER BY Genre, Price DESC;

--14)Month-over-Month Sales Growth Percentage
WITH MonthlyRevenue AS (
    SELECT
        DATE_TRUNC('month', Order_Date) AS Order_Month,
        SUM(Total_Amount) AS Total_Revenue
    FROM Orders
    GROUP BY Order_Month
)
SELECT
    Order_Month,
    Total_Revenue,
    LAG(Total_Revenue) OVER (ORDER BY Order_Month) AS Previous_Month_Revenue,
    ROUND(
        ((Total_Revenue - LAG(Total_Revenue) OVER (ORDER BY Order_Month)) /
        LAG(Total_Revenue) OVER (ORDER BY Order_Month)) * 100,
        2
    ) AS Growth_Percentage
FROM MonthlyRevenue
ORDER BY Order_Month;

--15) Finding the First Order for Each Customer
WITH FirstOrders AS (
    SELECT
        o.Order_ID,
        o.Customer_ID,
        c.Name,
        o.Order_Date,
        o.Total_Amount,
        ROW_NUMBER() OVER (PARTITION BY o.Customer_ID ORDER BY o.Order_Date) AS order_rank
    FROM Orders o
    JOIN Customers c ON o.Customer_ID = c.Customer_ID
)
SELECT
    Order_ID,
    Customer_ID,
    Name,
    Order_Date,
    Total_Amount
FROM FirstOrders
WHERE order_rank = 1;

--16)Percentage of Total Revenue by Author
WITH AuthorRevenue AS (
    SELECT
        b.Author,
        SUM(o.Total_Amount) AS Revenue
    FROM Orders o
    JOIN Books b ON o.Book_ID = b.Book_ID
    GROUP BY b.Author
)
SELECT
    Author,
    Revenue,
    ROUND(
        (Revenue / SUM(Revenue) OVER ()) * 100,
        2
    ) AS Revenue_Percentage
FROM AuthorRevenue
ORDER BY Revenue_Percentage DESC;

--17)Identifying "High-Value" Recent Customers
SELECT
    c.Customer_ID,
    c.Name,
    MAX(o.Order_Date) AS Last_Order_Date,
    COUNT(o.Order_ID) AS Number_of_Orders,
    SUM(o.Total_Amount) AS Total_Spent
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Name
HAVING MAX(o.Order_Date) >= CURRENT_DATE - INTERVAL '3 months'
   AND SUM(o.Total_Amount) > (
       SELECT AVG(customer_total)
       FROM (
           SELECT SUM(Total_Amount) AS customer_total
           FROM Orders
           GROUP BY Customer_ID
       ) AS avg_customer_value
   );

--18)Top-Selling Book in Each Genre
WITH RankedBooks AS (
    SELECT
        b.Genre,
        b.Title,
        b.Author,
        SUM(o.Quantity) AS Total_Sold,
        RANK() OVER (PARTITION BY b.Genre ORDER BY SUM(o.Quantity) DESC) AS rank_in_genre
    FROM Books b
    JOIN Orders o ON b.Book_ID = o.Book_ID
    GROUP BY b.Genre, b.Title, b.Author
)
SELECT
    Genre,
    Title,
    Author,
    Total_Sold
FROM RankedBooks
WHERE rank_in_genre = 1;

--19)Customer Churn Prediction (Simplified)
SELECT
    c.Customer_ID,
    c.Name,
    c.Email,
    MAX(o.Order_Date) AS Last_Order_Date,
    (CURRENT_DATE - MAX(o.Order_Date)) AS Days_Since_Last_Order,
    (CURRENT_DATE - MAX(o.Order_Date)) > 90 AS Is_Churn_Risk -- Returns TRUE/FALSE
FROM Customers c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Name, c.Email
HAVING MAX(o.Order_Date) IS NULL OR (CURRENT_DATE - MAX(o.Order_Date)) > 90
ORDER BY Days_Since_Last_Order DESC NULLS FIRST;

/* 20)Price Elasticity Analysis by Genre
Business Question: How does price affect quantity sold for different genres?*/
WITH genre_price_analysis AS (
    SELECT
        b.Genre,
        CASE 
            WHEN b.Price < 10 THEN 'Budget (<$10)'
            WHEN b.Price BETWEEN 10 AND 20 THEN 'Mid-range ($10-$20)'
            ELSE 'Premium (>$20)'
        END AS price_bucket,
        COUNT(o.Order_ID) AS order_count,
        SUM(o.Quantity) AS total_quantity,
        AVG(o.Quantity) AS avg_quantity_per_order,
        AVG(b.Price) AS avg_price
    FROM Books b
    JOIN Orders o ON b.Book_ID = o.Book_ID
    GROUP BY b.Genre, price_bucket
)
SELECT
    Genre,
    price_bucket,
    order_count,
    total_quantity,
    avg_quantity_per_order,
    avg_price,
    ROUND(total_quantity / order_count, 2) AS quantity_per_order
FROM genre_price_analysis
ORDER BY Genre, 
    CASE 
        WHEN price_bucket = 'Budget (<$10)' THEN 1
        WHEN price_bucket = 'Mid-range ($10-$20)' THEN 2
        ELSE 3
    END;

/*21)Customer Geographic Heatmap Analysis
Business Question: Which geographic regions generate the most revenue and orders?*/

SELECT
    c.Country,
    c.City,
    COUNT(DISTINCT o.Customer_ID) AS unique_customers,
    COUNT(o.Order_ID) AS total_orders,
    SUM(o.Quantity) AS total_books_sold,
    SUM(o.Total_Amount) AS total_revenue,
    ROUND(SUM(o.Total_Amount) / COUNT(DISTINCT o.Customer_ID), 2) AS avg_revenue_per_customer
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY ROLLUP(c.Country, c.City)
HAVING c.Country IS NOT NULL
ORDER BY total_revenue DESC;

/*22)Seasonal Sales Pattern Analysis
Business Question: Are there seasonal patterns in book sales by genre?*/
SELECT
    b.Genre,
    EXTRACT(MONTH FROM o.Order_Date) AS order_month,
    EXTRACT(QUARTER FROM o.Order_Date) AS order_quarter,
    COUNT(o.Order_ID) AS order_count,
    SUM(o.Quantity) AS total_quantity,
    SUM(o.Total_Amount) AS total_revenue,
    ROUND(SUM(o.Total_Amount) / SUM(SUM(o.Total_Amount)) OVER (PARTITION BY b.Genre) * 100, 2) AS genre_percentage
FROM Books b
JOIN Orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Genre, order_month, order_quarter
ORDER BY b.Genre, order_month;

/* 23)Customer Segmentation by Purchasing Behavior 
Business Question: Can we segment customers based on their purchasing behavior and preferences?*/

WITH customer_stats AS (
    SELECT
        c.Customer_ID,
        c.Name,
        c.Country,
        COUNT(DISTINCT o.Order_ID) AS order_count,
        SUM(o.Quantity) AS total_books,
        SUM(o.Total_Amount) AS total_spent,
        COUNT(DISTINCT b.Genre) AS genres_purchased,
        MAX(o.Order_Date) AS last_order_date,
        AVG(o.Total_Amount) AS avg_order_value
    FROM Customers c
    JOIN Orders o ON c.Customer_ID = o.Customer_ID
    JOIN Books b ON o.Book_ID = b.Book_ID
    GROUP BY c.Customer_ID, c.Name, c.Country
),
customer_segments AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY total_spent DESC) AS spending_segment,
        NTILE(5) OVER (ORDER BY order_count DESC) AS frequency_segment,
        CASE 
            WHEN genres_purchased >= 3 THEN 'Varied'
            WHEN genres_purchased = 2 THEN 'Focused'
            ELSE 'Specialized'
        END AS preference_segment,
        CASE 
            WHEN CURRENT_DATE - last_order_date <= 30 THEN 'Active'
            WHEN CURRENT_DATE - last_order_date <= 90 THEN 'Lapsing'
            ELSE 'Dormant'
        END AS recency_segment
    FROM customer_stats
)
SELECT
    spending_segment,
    frequency_segment,
    preference_segment,
    recency_segment,
    COUNT(Customer_ID) AS customer_count,
    ROUND(AVG(total_spent), 2) AS avg_total_spent,
    ROUND(AVG(order_count), 2) AS avg_orders
FROM customer_segments
GROUP BY CUBE(spending_segment, frequency_segment, preference_segment, recency_segment)
ORDER BY spending_segment, frequency_segment, preference_segment, recency_segment;

/*24)Author Popularity Trend Analysis
Business Question: Which authors are gaining or losing popularity over time?*/
WITH author_monthly_sales AS (
    SELECT
        b.Author,
        DATE_TRUNC('month', o.Order_Date) AS sales_month,
        SUM(o.Quantity) AS books_sold,
        LAG(SUM(o.Quantity)) OVER (PARTITION BY b.Author ORDER BY DATE_TRUNC('month', o.Order_Date)) AS prev_month_sales
    FROM Books b
    JOIN Orders o ON b.Book_ID = o.Book_ID
    GROUP BY b.Author, sales_month
),
author_trends AS (
    SELECT
        Author,
        sales_month,
        books_sold,
        prev_month_sales,
        CASE 
            WHEN prev_month_sales IS NULL THEN 'New'
            WHEN books_sold > prev_month_sales * 1.1 THEN 'Growing'
            WHEN books_sold < prev_month_sales * 0.9 THEN 'Declining'
            ELSE 'Stable'
        END AS trend
    FROM author_monthly_sales
)
SELECT
    Author,
    sales_month,
    books_sold,
    trend,
    COUNT(*) OVER (PARTITION BY Author ORDER BY sales_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS trend_streak
FROM author_trends
ORDER BY Author, sales_month;

/*25)Basket Analysis (Market Basket)
Business Question: Which books are frequently purchased together?*/
WITH order_books AS (
    SELECT
        o.Order_ID,
        b.Book_ID,
        b.Title,
        b.Genre
    FROM Orders o
    JOIN Books b ON o.Book_ID = b.Book_ID
),
book_combinations AS (
    SELECT
        ob1.Order_ID,
        ob1.Book_ID AS book1_id,
        ob1.Title AS book1_title,
        ob1.Genre AS book1_genre,
        ob2.Book_ID AS book2_id,
        ob2.Title AS book2_title,
        ob2.Genre AS book2_genre
    FROM order_books ob1
    JOIN order_books ob2 ON ob1.Order_ID = ob2.Order_ID AND ob1.Book_ID < ob2.Book_ID
)
SELECT
    book1_title,
    book2_title,
    book1_genre,
    book2_genre,
    COUNT(DISTINCT Order_ID) AS times_purchased_together,
    ROUND(COUNT(DISTINCT Order_ID) * 100.0 / (SELECT COUNT(DISTINCT Order_ID) FROM Orders), 3) AS percentage_of_orders
FROM book_combinations
GROUP BY book1_title, book2_title, book1_genre, book2_genre
HAVING COUNT(DISTINCT Order_ID) > 1
ORDER BY times_purchased_together DESC
LIMIT 20;

/*26)Inventory Optimization Analysis
Business Question: How can we optimize inventory levels based on sales velocity and seasonality? */

WITH monthly_sales AS (
    SELECT
        b.Book_ID,
        b.Title,
        b.Genre,
        EXTRACT(MONTH FROM o.Order_Date) AS month,
        EXTRACT(QUARTER FROM o.Order_Date) AS quarter,
        SUM(o.Quantity) AS quantity_sold,
        AVG(SUM(o.Quantity)) OVER (PARTITION BY b.Book_ID) AS avg_monthly_sales,
        STDDEV(SUM(o.Quantity)) OVER (PARTITION BY b.Book_ID) AS sales_volatility
    FROM Books b
    JOIN Orders o ON b.Book_ID = o.Book_ID
    GROUP BY b.Book_ID, b.Title, b.Genre, month, quarter
),
inventory_recommendations AS (
    SELECT
        Book_ID,
        Title,
        Genre,
        ROUND(AVG(quantity_sold), 2) AS avg_monthly_demand,
        ROUND(MAX(quantity_sold), 2) AS peak_monthly_demand,
        ROUND(sales_volatility, 2) AS demand_volatility,
        CASE
            WHEN sales_volatility / AVG(quantity_sold) > 0.5 THEN 'High variability'
            WHEN sales_volatility / AVG(quantity_sold) > 0.2 THEN 'Medium variability'
            ELSE 'Low variability'
        END AS variability_category,
        CASE
            WHEN sales_volatility / AVG(quantity_sold) > 0.5 THEN ROUND(AVG(quantity_sold) * 2 + sales_volatility * 1.5, 0)
            WHEN sales_volatility / AVG(quantity_sold) > 0.2 THEN ROUND(AVG(quantity_sold) * 1.5 + sales_volatility, 0)
            ELSE ROUND(AVG(quantity_sold) * 1.2, 0)
        END AS recommended_stock_level
    FROM monthly_sales
    GROUP BY Book_ID, Title, Genre, sales_volatility
)
SELECT
    ir.*,
    b.Stock AS current_stock,
    CASE
        WHEN b.Stock < ir.recommended_stock_level * 0.7 THEN 'Needs restocking'
        WHEN b.Stock > ir.recommended_stock_level * 1.3 THEN 'Overstocked'
        ELSE 'Adequate'
    END AS inventory_status
FROM inventory_recommendations ir
JOIN Books b ON ir.Book_ID = b.Book_ID
ORDER BY (ir.recommended_stock_level - b.Stock) DESC;

--27)Top-Selling Books by Country
SELECT 
    c.Country,
    b.Title,
    b.Author,
    COUNT(o.Order_ID) AS total_orders,
    SUM(o.Quantity) AS total_copies_sold
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
JOIN Customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Country, b.Title, b.Author
HAVING COUNT(o.Order_ID) > 1
ORDER BY c.Country, total_copies_sold DESC;

--28)Monthly Revenue Comparison (Current vs Previous Month)
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', Order_Date) AS month,
        SUM(Total_Amount) AS revenue
    FROM Orders
    GROUP BY DATE_TRUNC('month', Order_Date)
)
SELECT 
    TO_CHAR(month, 'YYYY-MM') AS current_month,
    revenue AS current_revenue,
    LAG(revenue) OVER (ORDER BY month) AS previous_revenue,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) * 100, 2) AS growth_percentage
FROM monthly_revenue
ORDER BY month;

--29) Customers Who Purchased Across Multiple Genres
SELECT 
    c.Customer_ID,
    c.Name,
    COUNT(DISTINCT b.Genre) AS genres_purchased,
    STRING_AGG(DISTINCT b.Genre, ', ') AS genre_list
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY c.Customer_ID, c.Name
HAVING COUNT(DISTINCT b.Genre) > 1
ORDER BY genres_purchased DESC;

--30)Books Never Ordered
SELECT 
    b.Book_ID,
    b.Title,
    b.Author,
    b.Genre,
    b.Price
FROM Books b
LEFT JOIN Orders o ON b.Book_ID = o.Book_ID
WHERE o.Order_ID IS NULL
ORDER BY b.Genre, b.Title;

--31)Average Order Value by Customer City
SELECT 
    c.City,
    c.Country,
    COUNT(o.Order_ID) AS total_orders,
    ROUND(AVG(o.Total_Amount), 2) AS avg_order_value,
    SUM(o.Total_Amount) AS total_revenue
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.City, c.Country
HAVING COUNT(o.Order_ID) >= 3
ORDER BY avg_order_value DESC;

--32)Authors With Books in Multiple Genres
SELECT 
    Author,
    COUNT(DISTINCT Genre) AS genre_count,
    STRING_AGG(DISTINCT Genre, ', ') AS genres,
    COUNT(Book_ID) AS book_count
FROM Books
GROUP BY Author
HAVING COUNT(DISTINCT Genre) > 1
ORDER BY genre_count DESC, book_count DESC;

--33)Quarterly Sales Performance by Genre
SELECT 
    b.Genre,
    EXTRACT(QUARTER FROM o.Order_Date) AS quarter,
    EXTRACT(YEAR FROM o.Order_Date) AS year,
    COUNT(o.Order_ID) AS orders,
    SUM(o.Quantity) AS books_sold,
    SUM(o.Total_Amount) AS revenue
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Genre, quarter, year
ORDER BY year, quarter, revenue DESC;

--34)Customers With Above-Average Order Frequency
WITH customer_order_stats AS (
    SELECT 
        c.Customer_ID,
        c.Name,
        COUNT(o.Order_ID) AS order_count,
        ROUND(AVG(o.Total_Amount), 2) AS avg_order_value
    FROM Customers c
    JOIN Orders o ON c.Customer_ID = o.Customer_ID
    GROUP BY c.Customer_ID, c.Name
)
SELECT 
    Customer_ID,
    Name,
    order_count,
    avg_order_value,
    (SELECT ROUND(AVG(order_count), 2) FROM customer_order_stats) AS avg_order_count
FROM customer_order_stats
WHERE order_count > (SELECT AVG(order_count) FROM customer_order_stats)
ORDER BY order_count DESC;

--35)Price Range Analysis by Genre
SELECT 
    Genre,
    COUNT(Book_ID) AS book_count,
    ROUND(MIN(Price), 2) AS min_price,
    ROUND(MAX(Price), 2) AS max_price,
    ROUND(AVG(Price), 2) AS avg_price,
    ROUND(SUM(Stock), 2) AS total_stock
FROM Books
GROUP BY Genre
ORDER BY avg_price DESC;

--36)Price Range Analysis by Genre
SELECT 
    Genre,
    COUNT(Book_ID) AS book_count,
    ROUND(MIN(Price), 2) AS min_price,
    ROUND(MAX(Price), 2) AS max_price,
    ROUND(AVG(Price), 2) AS avg_price,
    ROUND(SUM(Stock), 2) AS total_stock
FROM Books
GROUP BY Genre
ORDER BY avg_price DESC;

--37)Customer Retention Rate by Acquisition Month
WITH first_orders AS (
    SELECT 
        Customer_ID,
        MIN(Order_Date) AS first_order_date
    FROM Orders
    GROUP BY Customer_ID
),
order_activity AS (
    SELECT 
        fo.Customer_ID,
        DATE_TRUNC('month', fo.first_order_date) AS acquisition_month,
        DATE_TRUNC('month', o.Order_Date) AS order_month,
        COUNT(DISTINCT o.Order_ID) AS orders_this_month
    FROM first_orders fo
    JOIN Orders o ON fo.Customer_ID = o.Customer_ID
    GROUP BY fo.Customer_ID, acquisition_month, order_month
)
SELECT 
    TO_CHAR(acquisition_month, 'YYYY-MM') AS acquisition_month,
    COUNT(DISTINCT Customer_ID) AS new_customers,
    COUNT(DISTINCT CASE WHEN order_month = acquisition_month + INTERVAL '1 month' THEN Customer_ID END) AS retained_month_1,
    COUNT(DISTINCT CASE WHEN order_month = acquisition_month + INTERVAL '2 month' THEN Customer_ID END) AS retained_month_2,
    ROUND(COUNT(DISTINCT CASE WHEN order_month = acquisition_month + INTERVAL '1 month' THEN Customer_ID END) * 100.0 / COUNT(DISTINCT Customer_ID), 2) AS retention_rate_month_1,
    ROUND(COUNT(DISTINCT CASE WHEN order_month = acquisition_month + INTERVAL '2 month' THEN Customer_ID END) * 100.0 / COUNT(DISTINCT Customer_ID), 2) AS retention_rate_month_2
FROM order_activity
GROUP BY acquisition_month
ORDER BY acquisition_month;

--38)Customer Purchase Frequency Analysis
SELECT 
    c.Customer_ID,
    c.Name,
    c.Country,
    COUNT(o.Order_ID) AS total_orders,
    MIN(o.Order_Date) AS first_order_date,
    MAX(o.Order_Date) AS last_order_date,
    ROUND((MAX(o.Order_Date) - MIN(o.Order_Date)) / NULLIF(COUNT(o.Order_ID) - 1, 0), 2) AS avg_days_between_orders
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Name, c.Country
HAVING COUNT(o.Order_ID) > 1
ORDER BY avg_days_between_orders DESC;

--39) Genre Popularity by Season
SELECT 
    b.Genre,
    CASE 
        WHEN EXTRACT(MONTH FROM o.Order_Date) IN (12, 1, 2) THEN 'Winter'
        WHEN EXTRACT(MONTH FROM o.Order_Date) IN (3, 4, 5) THEN 'Spring'
        WHEN EXTRACT(MONTH FROM o.Order_Date) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END AS season,
    COUNT(o.Order_ID) AS order_count,
    SUM(o.Quantity) AS books_sold,
    SUM(o.Total_Amount) AS revenue
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Genre, season
ORDER BY b.Genre, season;

--40)Price Sensitivity Analysis
SELECT 
    CASE 
        WHEN b.Price < 10 THEN 'Under $10'
        WHEN b.Price BETWEEN 10 AND 20 THEN '$10-$20'
        WHEN b.Price BETWEEN 20 AND 30 THEN '$20-$30'
        ELSE 'Over $30'
    END AS price_range,
    COUNT(o.Order_ID) AS order_count,
    SUM(o.Quantity) AS total_quantity,
    ROUND(AVG(o.Quantity), 2) AS avg_quantity_per_order,
    ROUND(SUM(o.Total_Amount) / SUM(o.Quantity), 2) AS avg_price_paid
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY price_range
ORDER BY MIN(b.Price);

--41)Customer Loyalty by Repeat Purchases
WITH customer_orders AS (
    SELECT 
        c.Customer_ID,
        c.Name,
        COUNT(DISTINCT o.Order_ID) AS order_count,
        COUNT(DISTINCT b.Book_ID) AS unique_books,
        COUNT(DISTINCT b.Genre) AS unique_genres
    FROM Customers c
    JOIN Orders o ON c.Customer_ID = o.Customer_ID
    JOIN Books b ON o.Book_ID = b.Book_ID
    GROUP BY c.Customer_ID, c.Name
)
SELECT 
    order_count AS loyalty_tier,
    COUNT(Customer_ID) AS customer_count,
    ROUND(AVG(unique_books), 2) AS avg_books_purchased,
    ROUND(AVG(unique_genres), 2) AS avg_genres_explored
FROM customer_orders
GROUP BY order_count
HAVING order_count > 1
ORDER BY order_count DESC;

--42)Author Performance Comparison
SELECT 
    b.Author,
    COUNT(DISTINCT b.Book_ID) AS books_in_catalog,
    COUNT(o.Order_ID) AS times_ordered,
    SUM(o.Quantity) AS copies_sold,
    ROUND(SUM(o.Total_Amount), 2) AS revenue_generated,
    ROUND(SUM(o.Total_Amount) / COUNT(DISTINCT b.Book_ID), 2) AS revenue_per_book
FROM Books b
LEFT JOIN Orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Author
HAVING COUNT(DISTINCT b.Book_ID) > 1
ORDER BY revenue_generated DESC;

--43) Stock Level vs Sales Velocity
SELECT 
    b.Book_ID,
    b.Title,
    b.Author,
    b.Genre,
    b.Stock AS current_stock,
    COUNT(o.Order_ID) AS times_ordered,
    SUM(o.Quantity) AS total_sold,
    ROUND(SUM(o.Quantity) / NULLIF(COUNT(DISTINCT DATE_TRUNC('month', o.Order_Date)), 0), 2) AS avg_monthly_sales,
    CASE 
        WHEN b.Stock = 0 THEN 'Out of Stock'
        WHEN b.Stock < SUM(o.Quantity) / NULLIF(COUNT(DISTINCT DATE_TRUNC('month', o.Order_Date)), 0) THEN 'Low Stock'
        ELSE 'Adequate Stock'
    END AS stock_status
FROM Books b
LEFT JOIN Orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID, b.Title, b.Author, b.Genre, b.Stock
ORDER BY stock_status, avg_monthly_sales DESC;

--44) Geographic Sales Concentration
SELECT 
    c.Country,
    c.City,
    COUNT(DISTINCT o.Customer_ID) AS unique_customers,
    COUNT(o.Order_ID) AS total_orders,
    SUM(o.Quantity) AS books_sold,
    SUM(o.Total_Amount) AS revenue,
    ROUND(SUM(o.Total_Amount) / COUNT(o.Order_ID), 2) AS avg_order_value
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY ROLLUP(c.Country, c.City)
HAVING c.Country IS NOT NULL
ORDER BY revenue DESC;

--45)Book Popularity Over Time
WITH monthly_sales AS (
    SELECT 
        b.Book_ID,
        b.Title,
        DATE_TRUNC('month', o.Order_Date) AS sale_month,
        SUM(o.Quantity) AS monthly_sales,
        RANK() OVER (PARTITION BY DATE_TRUNC('month', o.Order_Date) ORDER BY SUM(o.Quantity) DESC) AS sales_rank
    FROM Books b
    JOIN Orders o ON b.Book_ID = o.Book_ID
    GROUP BY b.Book_ID, b.Title, sale_month
)
SELECT 
    Title,
    TO_CHAR(sale_month, 'YYYY-MM') AS month,
    monthly_sales,
    sales_rank
FROM monthly_sales
WHERE sales_rank <= 5
ORDER BY sale_month DESC, sales_rank;

--46)Customer Preference Clustering
WITH customer_preferences AS (
    SELECT 
        c.Customer_ID,
        c.Name,
        b.Genre,
        COUNT(o.Order_ID) AS genre_orders,
        ROUND(COUNT(o.Order_ID) * 100.0 / SUM(COUNT(o.Order_ID)) OVER (PARTITION BY c.Customer_ID), 2) AS genre_percentage
    FROM Customers c
    JOIN Orders o ON c.Customer_ID = o.Customer_ID
    JOIN Books b ON o.Book_ID = b.Book_ID
    GROUP BY c.Customer_ID, c.Name, b.Genre
),
primary_preference AS (
    SELECT 
        Customer_ID,
        Name,
        Genre AS primary_genre,
        genre_percentage
    FROM customer_preferences cp1
    WHERE genre_percentage = (SELECT MAX(genre_percentage) 
                             FROM customer_preferences cp2 
                             WHERE cp1.Customer_ID = cp2.Customer_ID)
)
SELECT 
    primary_genre,
    COUNT(Customer_ID) AS customer_count,
    ROUND(AVG(genre_percentage), 2) AS avg_preference_strength
FROM primary_preference
GROUP BY primary_genre
ORDER BY customer_count DESC;

--47)Order Size Analysis
SELECT 
    CASE 
        WHEN o.Quantity = 1 THEN 'Single Book'
        WHEN o.Quantity = 2 THEN 'Two Books'
        ELSE 'Three or More'
    END AS order_size,
    COUNT(o.Order_ID) AS order_count,
    SUM(o.Quantity) AS total_books,
    ROUND(AVG(o.Total_Amount), 2) AS avg_order_value,
    ROUND(SUM(o.Total_Amount), 2) AS total_revenue,
    ROUND(COUNT(o.Order_ID) * 100.0 / (SELECT COUNT(*) FROM Orders), 2) AS percentage_of_orders
FROM Orders o
GROUP BY order_size
ORDER BY total_revenue DESC;

--48)Genre Cross-Purchase Analysis
WITH genre_combinations AS (
    SELECT 
        o.Order_ID,
        STRING_AGG(DISTINCT b.Genre, ' + ' ORDER BY b.Genre) AS genre_combo,
        COUNT(DISTINCT b.Genre) AS genre_count
    FROM Orders o
    JOIN Books b ON o.Book_ID = b.Book_ID
    GROUP BY o.Order_ID
    HAVING COUNT(DISTINCT b.Genre) > 1
)
SELECT 
    genre_combo,
    COUNT(Order_ID) AS order_count,
    ROUND(COUNT(Order_ID) * 100.0 / (SELECT COUNT(*) FROM genre_combinations), 2) AS percentage
FROM genre_combinations
GROUP BY genre_combo
ORDER BY order_count DESC
LIMIT 10;

--49) Price Point Optimization Analysis
SELECT 
    ROUND(b.Price, 0) AS price_point,
    COUNT(DISTINCT b.Book_ID) AS books_available,
    COUNT(o.Order_ID) AS times_ordered,
    SUM(o.Quantity) AS copies_sold,
    ROUND(SUM(o.Total_Amount), 2) AS revenue_generated,
    ROUND(SUM(o.Quantity) / COUNT(o.Order_ID), 2) AS avg_quantity_per_order,
    ROUND(SUM(o.Total_Amount) / SUM(o.Quantity), 2) AS effective_price
FROM Books b
LEFT JOIN Orders o ON b.Book_ID = o.Book_ID
GROUP BY price_point
HAVING COUNT(DISTINCT b.Book_ID) > 0
ORDER BY price_point;

--50)Author Popularity vs. Availability Analysis
WITH author_stats AS (
    SELECT 
        b.Author,
        COUNT(DISTINCT b.Book_ID) AS books_available,
        SUM(b.Stock) AS total_stock,
        COUNT(o.Order_ID) AS times_ordered,
        SUM(o.Quantity) AS copies_sold,
        ROUND(SUM(o.Total_Amount), 2) AS revenue_generated
    FROM Books b
    LEFT JOIN Orders o ON b.Book_ID = o.Book_ID
    GROUP BY b.Author
    HAVING COUNT(DISTINCT b.Book_ID) > 1
)
SELECT 
    Author,
    books_available,
    total_stock,
    times_ordered,
    copies_sold,
    revenue_generated,
    ROUND(times_ordered * 100.0 / books_available, 2) AS order_to_availability_ratio,
    ROUND(copies_sold * 100.0 / total_stock, 2) AS sales_to_stock_ratio,
    CASE 
        WHEN times_ordered > books_available * 2 THEN 'High Demand'
        WHEN times_ordered > books_available THEN 'Moderate Demand'
        ELSE 'Low Demand'
    END AS demand_status
FROM author_stats
ORDER BY order_to_availability_ratio DESC;

--Queries done by (Md Tanvir Hasan, Business Analyst, Honda Bangladesh)