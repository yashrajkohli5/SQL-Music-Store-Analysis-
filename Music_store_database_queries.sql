/* Q1: Who is the senior most employee based on job title? */
SELECT * 
FROM employee
ORDER BY levels DESC
LIMIT 1;

/* Q2: Which countries have the most Invoices? */
SELECT billing_country, count(*) as number_of_orders
FROM invoice
GROUP BY billing_country
ORDER BY number_of_orders DESC;

/* Q3: What are top 3 values of total invoice? */
SELECT total
FROM invoice
ORDER BY total desc
LIMIT 3;

/* Q4: Which city has the best customers */
SELECT billing_city, sum(total) as total_billing
FROM invoice
GROUP BY billing_city 
ORDER BY total_billing DESC
LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. */
SELECT first_name, last_name , sum(total) as amount_spent
FROM customer as c
JOIN invoice as i
ON c.customer_id = i.customer_id
GROUP BY first_name,last_name
ORDER BY amount_spent DESC
LIMIT 1;

/* Q6: Return the email, first name, last name and genre of all ROCK music listners. */
SELECT c.first_name AS FirstName, c.last_name AS LastName, c.email AS Email
FROM customer AS c
JOIN invoice as i
ON c.customer_id = i.customer_id
JOIN invoice_line as l
ON i.invoice_id = l.invoice_id
JOIN track 
ON track.track_id = l.track_id
JOIN genre
ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock';

/* Q7: Invite the artist who have written the most rock music in our dataset. Return the artist name and total track count of top 10 rock bands. */
SELECT artist.name, COUNT(artist.artist_id) as Number_of_Songs
FROM artist
JOIN album
ON artist.artist_id = album.artist_id
JOIN track
ON album.album_id = track.album_id
JOIN genre
ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY Number_of_Songs DESC;

/* Q8: Return the track names that have a song length longer than the average sing length. Return name and duration of song in miliseconds. Order by song length with the longest song listed first.*/
SELECT name, milliseconds
FROM track
WHERE milliseconds >
	(SELECT AVG(milliseconds)
	FROM track);

/* Q9: How much amount is spent by customer on each artists? */
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q10: Find the most popular genre for each country. Determine the most popular genre with highest amount of purchases. */
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1