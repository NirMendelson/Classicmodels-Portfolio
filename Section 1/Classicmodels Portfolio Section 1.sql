
-- Section 1: employees and customers

-- Showing how many employees are in each office and where the office is located

SELECT 
    e.officecode,
    e.jobtitle,
    COUNT(DISTINCT e.employeenumber) AS employees,
    CASE
        WHEN o.country = 'usa' THEN o.state
        ELSE o.country
    END AS country
FROM
    employees e
        LEFT JOIN
    offices o ON o.officecode = e.officecode
GROUP BY 1 , 2;

-- Showing how many customers every office has

SELECT 
    COUNT(DISTINCT c.customernumber) AS customers,
    e.officecode,
    o.country
FROM
    customers c
        LEFT JOIN
    employees e ON e.employeenumber = c.salesrepemployeenumber
        LEFT JOIN
    offices o ON o.officecode = e.officecode
GROUP BY 2
ORDER BY 1 DESC;

-- Let's see if there are sales reps that don't have any customers

SELECT 
    COUNT(DISTINCT c.customernumber) AS customers,
    CASE
        WHEN e.firstname IS NOT NULL THEN CONCAT(e.firstname, ' ', e.lastname)
        ELSE 'no sales rep'
    END AS sales_rep,
    CASE
        WHEN e.officecode IS NOT NULL THEN e.officecode
        ELSE 'no office'
    END AS 'officecode',
    CASE
        WHEN o.country = 'usa' THEN o.state
        WHEN o.country IS NULL THEN 'no office'
        ELSE o.country
    END AS country
FROM
    customers c
        LEFT JOIN
    employees e ON e.employeenumber = c.salesrepemployeenumber
        LEFT JOIN
    offices o ON o.officecode = e.officecode
GROUP BY 2 
UNION SELECT 
    COUNT(DISTINCT c.customernumber) AS customers,
    CASE
        WHEN e.firstname IS NOT NULL THEN CONCAT(e.firstname, ' ', e.lastname)
        ELSE 'no sales rep'
    END AS sales_rep,
    CASE
        WHEN e.officecode IS NOT NULL THEN e.officecode
        ELSE 'no office'
    END AS 'officecode',
    CASE
        WHEN o.country = 'usa' THEN o.state
        ELSE o.country
    END AS country
FROM
    customers c
        RIGHT JOIN
    employees e ON e.employeenumber = c.salesrepemployeenumber
        LEFT JOIN
    offices o ON o.officecode = e.officecode
WHERE
    e.jobtitle IS NULL
        OR e.jobtitle = 'sales rep'
GROUP BY 2
ORDER BY 1 DESC;

-- Let's see where those 22 customers are located 

SELECT 
    COUNT(DISTINCT c.customernumber) AS customer_amount,
    c.country
FROM
    customers c
        LEFT JOIN
    employees e ON e.employeenumber = c.salesrepemployeenumber
WHERE
    CONCAT(e.firstname, ' ', e.lastname) IS NULL
GROUP BY 2
ORDER BY 1 DESC;

-- Let's see active customers vs potential customers

SELECT 
    COUNT(DISTINCT CASE
            WHEN salesrepemployeenumber IS NOT NULL THEN customernumber
            ELSE NULL
        END) AS 'active customers',
    COUNT(DISTINCT customernumber) - COUNT(DISTINCT CASE
            WHEN salesrepemployeenumber IS NOT NULL THEN customernumber
            ELSE NULL
        END) AS 'potential customers',
    country
FROM
    customers
GROUP BY 3
ORDER BY 2 DESC;


SELECT 
    COUNT(DISTINCT customernumber),
    COUNT(DISTINCT CASE
            WHEN salesrepemployeenumber IS NULL THEN customernumber
            ELSE NULL
        END) AS 'potential customer',
    COUNT(DISTINCT CASE
            WHEN salesrepemployeenumber IS NOT NULL THEN customernumber
            ELSE NULL
        END) AS 'active customer',
    country
FROM
    customers
GROUP BY 4
;

-- Let's estimate how much money the company would make if every customer had a sales rep

SELECT 
    ROUND(AVG(revenue), 0) AS Average_Monthly_Revenue
FROM
    (SELECT 
        YEAR(paymentdate) AS 'year',
            MONTH(paymentdate) AS 'month',
            SUM(amount) AS revenue
    FROM
        payments
    GROUP BY 1 , 2
    ORDER BY 1 , 2) AS pay;

SELECT 
    COUNT(DISTINCT CASE
            WHEN salesrepemployeenumber IS NOT NULL THEN customernumber
            ELSE NULL
        END) AS active_customers,
    COUNT(DISTINCT customernumber) AS active_and_potential_customers,
    ROUND(COUNT(DISTINCT customernumber) / COUNT(DISTINCT CASE
                    WHEN salesrepemployeenumber IS NOT NULL THEN customernumber
                    ELSE NULL
                END) * 100,
            0) AS growth_pct,
    295128 AS average_monthly_revenue,
    ROUND(295128 * COUNT(DISTINCT customernumber) / COUNT(DISTINCT CASE
                    WHEN salesrepemployeenumber IS NOT NULL THEN customernumber
                    ELSE NULL
                END),
            0) AS potential_monthly_revenue
FROM
    customers;

-- Let's check if we have a sales rep that can reach out to them

SELECT 
    c.customernumber,
    c.country AS customer_country,
    CONCAT(e.firstname, ' ', e.lastname) AS employeename
FROM
    customers c
        LEFT JOIN
    employees e ON e.employeenumber = c.salesrepemployeenumber
ORDER BY 2 , 3;



