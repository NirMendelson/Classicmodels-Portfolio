
-- Section 2 - Orders
-- Showing orders by quarter and month

SELECT 
    YEAR(orderdate) AS 'year',
    QUARTER(orderdate) AS 'quarter',
    COUNT(DISTINCT ordernumber) AS 'orders made'
FROM
    orders
GROUP BY 1 , 2;

SELECT 
    YEAR(orderdate) AS 'year',
    MONTH(orderdate) AS 'month',
    COUNT(DISTINCT ordernumber) AS 'orders made'
FROM
    orders
GROUP BY 1 , 2;

-- Let's check the exact growth pct between January-May because the database runs until May 2005

SELECT 
    COUNT(DISTINCT CASE
            WHEN orderdate < '2003-06-01' THEN ordernumber
            ELSE NULL
        END) AS 'January-May 2003',
    COUNT(DISTINCT CASE
            WHEN
                orderdate >= '2004-01-01'
                    AND orderdate < '2004-06-01'
            THEN
                ordernumber
            ELSE NULL
        END) AS 'January-May 2004',
    ROUND(COUNT(DISTINCT CASE
                    WHEN
                        orderdate >= '2004-01-01'
                            AND orderdate < '2004-06-01'
                    THEN
                        ordernumber
                    ELSE NULL
                END) / COUNT(DISTINCT CASE
                    WHEN orderdate < '2003-06-01' THEN ordernumber
                    ELSE NULL
                END) * 100,
            0) AS '03-04 growth pct',
    COUNT(DISTINCT CASE
            WHEN
                orderdate >= '2005-01-01'
                    AND orderdate < '2005-06-01'
            THEN
                ordernumber
            ELSE NULL
        END) AS 'January-May 2005',
    ROUND(COUNT(DISTINCT CASE
                    WHEN
                        orderdate >= '2005-01-01'
                            AND orderdate < '2005-06-01'
                    THEN
                        ordernumber
                    ELSE NULL
                END) / COUNT(DISTINCT CASE
                    WHEN
                        orderdate >= '2004-01-01'
                            AND orderdate < '2004-06-01'
                    THEN
                        ordernumber
                    ELSE NULL
                END) * 100,
            0) AS '04-05 growth pct'
FROM
    orders;

-- Let's see order amounts by country

SELECT 
    COUNT(DISTINCT o.ordernumber) AS 'orders made',
    c.country AS 'shipped to'
FROM
    orders o
        LEFT JOIN
    customers c ON c.customernumber = o.customernumber
GROUP BY 2
ORDER BY 1 DESC;

-- Let's see order amounts and revenue per state

SELECT 
    COUNT(DISTINCT od.ordernumber) AS orders,
    ROUND(SUM(od.quantityordered * priceeach), 0) AS revenue,
    c.state
FROM
    orderdetails od
        LEFT JOIN
    orders o ON o.ordernumber = od.ordernumber
        LEFT JOIN
    customers c ON c.customernumber = o.customernumber
WHERE
    c.country = 'USA'
GROUP BY 3
ORDER BY 2 DESC;

-- I want to see how many orders total each sales rep made

SELECT 
    COUNT(DISTINCT od.ordernumber) AS orders,
    CASE
        WHEN ROUND(SUM(od.quantityordered * priceeach), 0) IS NULL THEN 0
        ELSE ROUND(SUM(od.quantityordered * priceeach), 0)
    END AS revenue,
    CONCAT(e.firstname, ' ', e.lastname) AS sales_rep
FROM
    orderdetails od
        LEFT JOIN
    orders o ON o.ordernumber = od.ordernumber
        LEFT JOIN
    customers c ON c.customernumber = o.customernumber
        LEFT JOIN
    employees e ON e.employeenumber = c.salesrepemployeenumber
WHERE
    e.jobtitle = 'sales rep'
GROUP BY 3 
UNION SELECT 
    COUNT(DISTINCT od.ordernumber) AS orders,
    CASE
        WHEN ROUND(SUM(od.quantityordered * priceeach), 0) IS NULL THEN 0
        ELSE ROUND(SUM(od.quantityordered * priceeach), 0)
    END AS revenue,
    CONCAT(e.firstname, ' ', e.lastname) AS sales_rep
FROM
    orderdetails od
        RIGHT JOIN
    orders o ON o.ordernumber = od.ordernumber
        RIGHT JOIN
    customers c ON c.customernumber = o.customernumber
        RIGHT JOIN
    employees e ON e.employeenumber = c.salesrepemployeenumber
WHERE
    e.jobtitle = 'sales rep'
GROUP BY 3
ORDER BY 1 DESC;

-- Let's see if Gerard Hernandez made the most successful sales (shipped status) and if he makes the most money for the company

SELECT 
    COUNT(DISTINCT od.ordernumber) AS successful_sales,
    ROUND(SUM(od.quantityordered * priceeach), 0) AS revenue,
    CONCAT(e.firstname, ' ', e.lastname) AS sales_rep
FROM
    orderdetails od
        LEFT JOIN
    orders o ON o.ordernumber = od.ordernumber
        LEFT JOIN
    customers c ON c.customernumber = o.customernumber
        LEFT JOIN
    employees e ON e.employeenumber = c.salesrepemployeenumber
WHERE
    o.status = 'shipped'
GROUP BY 3
ORDER BY 2 DESC;

-- Let's check how much time shipping takes to each country

SELECT 
    ROUND(AVG(DATEDIFF(o.requireddate, o.shippeddate)),
            1) AS 'Average Shipping time (days)',
    c.country AS destination
FROM
    orders o
        LEFT JOIN
    customers c ON c.customernumber = o.customernumber
WHERE
    o.requireddate > o.shippeddate
GROUP BY 2
ORDER BY 1 DESC;

-- Let's see how many orders had issues (on hold, disputed, resolved, cancelled)

SELECT 
    COUNT(DISTINCT CASE
            WHEN status = 'shipped' THEN ordernumber
            ELSE NULL
        END) AS 'No issues',
    COUNT(DISTINCT CASE
            WHEN status IN ('resolved' , 'cancelled', 'on hold', 'disputed') THEN ordernumber
            ELSE NULL
        END) AS 'had issues',
    ROUND(COUNT(DISTINCT CASE
                    WHEN status IN ('resolved' , 'cancelled', 'on hold', 'disputed') THEN ordernumber
                    ELSE NULL
                END) / COUNT(DISTINCT CASE
                    WHEN status = 'shipped' THEN ordernumber
                    ELSE NULL
                END),
            2) * 100 AS pct
FROM
    orders;

-- Let's go through the comments section to see which customer has the most issues

SELECT 
    COUNT(DISTINCT comments) as amount_of_comments, customernumber
FROM
    orders
GROUP BY 2
having COUNT(DISTINCT comments) > 1
ORDER BY 1 DESC;

-- Let's see what those comments are

SELECT 
    comments
FROM
    orders
WHERE
    customernumber = 141
        AND comments IS NOT NULL;

-- Who sells to customer 141

SELECT 
    c.customernumber,
    CONCAT(e.firstname, ' ', e.lastname) AS sales_rep
FROM
    customers c
        LEFT JOIN
    employees e ON e.employeenumber = c.salesrepemployeenumber
WHERE
    c.customernumber = 141;