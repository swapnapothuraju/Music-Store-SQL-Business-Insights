-------------------------------------------------Question Set 1 - Easy

-- 1) Senior most employee based on job title
SELECT *
FROM employee
ORDER BY levels DESC
LIMIT 1;

-- 2) Which countries have the most Invoices?

SELECT billing_country, COUNT(*) AS total_invoices
FROM invoice
GROUP BY billing_country
ORDER BY total_invoices DESC;


-- 3)What are top 3 values of total invoice? 
SELECT billing_country, COUNT(*) AS total_invoices
FROM invoice
GROUP BY billing_country
ORDER BY total_invoices DESC LIMIT 3;

-- 4)Which city has the best customers? We would like to throw a promotional Music 
--Festival in the city we made the most money. Write a query that returns one city that 
--has the highest sum of invoice totals. Return both the city name & sum of all invoice 
--totals
SELECT billing_city, SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_city
ORDER BY total_revenue DESC
LIMIT 1;

-- 5) Who is the best customer? The customer who has spent the most money will be 
--declared the best customer. Write a query that returns the person who has spent the 
--most money
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;

---------------------------------------Question Set 2 – Moderate--------

-- 1)  Write query to return the email, first name, last name, & Genre of all Rock Music 
--listeners. Return your list ordered alphabetically by email starting with A 

SELECT DISTINCT c.email, c.first_name, c.last_name, g.name AS genre
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email;

-- 2) Let's invite the artists who have written the most rock music in our dataset. Write a 
--query that returns the Artist name and total track count of the top 10 rock bands
SELECT ar.name AS artist_name, COUNT(t.track_id) AS total_tracks
FROM artist ar
JOIN album al ON ar.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY ar.name
ORDER BY total_tracks DESC
LIMIT 10;

-- 3) Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the 
--longest songs listed first
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds)
    FROM track
)
ORDER BY milliseconds DESC;

--------------------------------------Question Set 3 – Advance----------------

-- 1)  Find how much amount spent by each customer on artists? Write a query to return 
-- customer name, artist name and total spent

SELECT 
    c.first_name || ' ' || c.last_name AS customer_name,
    ar.name AS artist_name,
    SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY customer_name, artist_name
ORDER BY total_spent DESC;

--2)  We want to find out the most popular music Genre for each country. We determine the 
--most popular genre as the genre with the highest amount of purchases. Write a query 
--that returns each country along with the top Genre. For countries where the maximum 
--number of purchases is shared return all Genres.
WITH genre_sales AS (
    SELECT 
        i.billing_country,
        g.name AS genre,
        COUNT(il.invoice_line_id) AS purchases
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY i.billing_country, g.name
),
max_genre AS (
    SELECT billing_country, MAX(purchases) AS max_purchases
    FROM genre_sales
    GROUP BY billing_country
)
SELECT gs.billing_country, gs.genre, gs.purchases
FROM genre_sales gs
JOIN max_genre mg
ON gs.billing_country = mg.billing_country
AND gs.purchases = mg.max_purchases
ORDER BY gs.billing_country;

-- 3) Write a query that determines the customer that has spent the most on music for each 
--country. Write a query that returns the country along with the top customer and how 
--much they spent. For countries where the top amount spent is shared, provide all 
--customers who spent this amount
WITH customer_spending AS (
    SELECT 
        i.billing_country,
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        SUM(i.total) AS total_spent
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY i.billing_country, c.customer_id
),
max_spending AS (
    SELECT billing_country, MAX(total_spent) AS max_total
    FROM customer_spending
    GROUP BY billing_country
)
SELECT cs.billing_country, cs.customer_name, cs.total_spent
FROM customer_spending cs
JOIN max_spending ms
ON cs.billing_country = ms.billing_country
AND cs.total_spent = ms.max_total
ORDER BY cs.billing_country;

