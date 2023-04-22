
-- Section 3 - Products
-- Let's see which are our 10 best selling products and our 10 least sold products

SELECT 
    SUM(od.quantityordered) AS orders, p.productname
FROM
    orderdetails od
        LEFT JOIN
    products p ON p.productcode = od.productcode
GROUP BY 2 
UNION SELECT 
    SUM(od.quantityordered) AS orders, p.productname
FROM
    orderdetails od
        RIGHT JOIN
    products p ON p.productcode = od.productcode
GROUP BY 2
ORDER BY 1 DESC
LIMIT 5;

SELECT 
    CASE
        WHEN SUM(od.quantityordered) IS NULL THEN 0
        ELSE SUM(od.quantityordered)
    END AS orders,
    p.productname
FROM
    orderdetails od
        LEFT JOIN
    products p ON p.productcode = od.productcode
GROUP BY 2 
UNION SELECT 
    CASE
        WHEN SUM(od.quantityordered) IS NULL THEN 0
        ELSE SUM(od.quantityordered)
    END AS orders,
    p.productname
FROM
    orderdetails od
        RIGHT JOIN
    products p ON p.productcode = od.productcode
GROUP BY 2
ORDER BY 1
LIMIT 5;

--  Let's see how many Toyota Supras are in stock

SELECT 
    productname, quantityinstock
FROM
    products
WHERE
    productname = '1985 Toyota Supra';

-- Let's see which products have the highest and lowest margins per sale (we don't sell the products at a set price, so I calculated by the average price)

SELECT 
    p.productname,
    ROUND(AVG(od.priceeach), 2) AS 'avg revenue',
    ROUND(p.buyprice, 2) AS cost,
    ROUND(AVG(od.priceeach) - p.buyprice, 2) AS 'Margin per sale'
FROM
    orderdetails od
        LEFT JOIN
    products p ON p.productcode = od.productcode
GROUP BY 1 
UNION SELECT 
    p.productname,
    ROUND(AVG(od.priceeach), 2) AS 'avg revenue',
    ROUND(p.buyprice, 2) AS cost,
    ROUND(AVG(od.priceeach) - p.buyprice, 2) AS 'Margin per sale'
FROM
    orderdetails od
        LEFT JOIN
    products p ON p.productcode = od.productcode
GROUP BY 1
ORDER BY 4 DESC
LIMIT 5;

SELECT 
    p.productname,
    ROUND(AVG(od.priceeach), 2) AS 'avg revenue',
    ROUND(p.buyprice, 2) AS cost,
    ROUND(AVG(od.priceeach) - p.buyprice, 2) AS 'Margin per sale'
FROM
    orderdetails od
        LEFT JOIN
    products p ON p.productcode = od.productcode
GROUP BY 1
ORDER BY 4
LIMIT 5;

-- Let's see which products have the highest total margin and which have the lowest

SELECT 
    p.productname,
    SUM((od.quantityordered * od.priceeach) - (od.quantityordered * p.buyprice)) AS total_margin
FROM
    orderdetails od
        LEFT JOIN
    products p ON p.productcode = od.productcode
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

SELECT 
    p.productname,
    SUM((od.quantityordered * od.priceeach) - (od.quantityordered * p.buyprice)) AS total_margin
FROM
    orderdetails od
        LEFT JOIN
    products p ON p.productcode = od.productcode
GROUP BY 1
ORDER BY 2
LIMIT 5;

-- Let's see which productline sells the most and which has the highest total margin

SELECT 
    SUM(od.quantityordered) AS orders,
    p.productline,
    ROUND(SUM(od.quantityordered) * AVG(od.priceeach) - p.buyprice,
            2) AS ' total margin'
FROM
    orderdetails od
        LEFT JOIN
    products p ON p.productcode = od.productcode
GROUP BY 2
ORDER BY 1 DESC;

-- Showing the total quantity of units and number of product types in each order

SELECT 
    SUM(quantityordered) AS total_quantity_of_units,
    COUNT(DISTINCT productcode) AS number_of_product_types,
    ordernumber
FROM
    orderdetails
GROUP BY 3
ORDER BY 1 DESC;

-- Showing the minimum, maximum and average values of product types and total quantity of units

SELECT 
    ROUND(MIN(number_of_products), 1) AS minimum_product_types,
    ROUND(MAX(number_of_products), 1) AS maximum_product_types,
    ROUND(AVG(number_of_products), 1) AS avg_product_types,
    ROUND(MIN(total_quantity), 1) AS minimum_products_quantity,
    ROUND(MAX(total_quantity), 1) AS maximum_products_quantity,
    ROUND(AVG(total_quantity), 1) AS average_products_quantity
FROM
    (SELECT 
        SUM(quantityordered) AS total_quantity,
            COUNT(DISTINCT productcode) AS number_of_products,
            ordernumber
    FROM
        orderdetails
    GROUP BY 3
    ORDER BY 1 DESC) AS sub;

-- Let's see how many product types customers usually buy

SELECT 
    COUNT(product_types) AS 'number of orders',
    product_types AS 'number of product types'
FROM
    (SELECT 
        SUM(quantityordered) AS total_quantity,
            COUNT(DISTINCT productcode) AS product_types,
            ordernumber
    FROM
        orderdetails
    GROUP BY 3
    ORDER BY 2 DESC) AS sub
GROUP BY 2
ORDER BY 1 DESC;