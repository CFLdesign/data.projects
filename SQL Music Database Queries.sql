--(1)TRACKS PURCHASED PER GENRE
SELECT g.name AS genre,
COUNT(t.name) AS tracks_sold,
SUM(il.unitprice) AS genre_purchases,
COUNT(DISTINCT i.customerid) AS customer_amount,
CASE WHEN SUM(il.unitprice) > 100 THEN 'Highest Purchases'
WHEN SUM(il.unitprice) > 30 THEN 'Mid-level Purchases'
WHEN SUM(il.unitprice) < 30 THEN 'Low Purchases'
ELSE 'N/A' END AS sale_category
FROM genre AS g
JOIN track AS t
ON g.genreid = t.genreid
JOIN invoiceline AS il
ON t.trackid = il.trackid
JOIN invoice AS i
ON il.invoiceid = i.invoiceid
GROUP BY 1;
--These query results are taking a look at how different genres perform in sales.
--I used some aggregations to count the number of units sold and total sales for each genre. 
--Using CASE to create catergories I used for a pie chart in Excel. 

--(2)Total sales and units sold per country 
SELECT i.billingcountry,
SUM(i.total) AS total_purchases,
COUNT(il.quantity) AS total_units_sold
FROM invoice AS i
JOIN invoiceline AS il
ON i.invoiceid = il.invoiceid
GROUP BY 1
order by 2 desc;
--This query is supposed to show the total sales and units sold for each country. 
--I have done simple joins and aggregations to build this one. 

--(3)Countries with higher than average units sold
WITH country_inline_count AS (
SELECT i.billingcountry,
COUNT(il.quantity) AS total_units_sold
FROM invoice AS i
JOIN invoiceline AS il
ON i.invoiceid = il.invoiceid
GROUP BY 1
order by 1 desc;
)
SELECT i.billingcountry,
COUNT(i.invoiceid) AS total_units_sold
FROM invoice AS i
JOIN invoiceline AS il
ON i.invoiceid = il.invoiceid
GROUP BY 1
HAVING COUNT(il.quantity) > (
SELECT AVG(total_units_sold)
FROM country_inline_count);
--Here I am looking for countries where the unit count sold is higher than average. 
--I used a CTE for readability on this query. 

--(4)Ranking country sales with customerids 
SELECT i.billingcountry AS country,
c.customerid,
DATE_TRUNC('year',i.invoicedate) AS date,         
i.total,
DENSE_RANK() OVER total_window AS dense_rank
FROM invoice AS i
JOIN customer AS c
ON i.customerid = c.customerid
WINDOW total_window AS 
(PARTITION BY i.billingcountry ORDER BY i.total DESC);
--Here I ranked the individual transactions partitioned by the billing country to see trends in the countries. 
--I used a window function and dense_rank to manipulate the data. 
