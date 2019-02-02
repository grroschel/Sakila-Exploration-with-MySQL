-- Turn off safe updates
SET SQL_SAFE_UPDATES = 0;

USE sakila;

-- Display which DB I’m connected to
SELECT DATABASE();

-- 1a. Display the first and last names of all actors from the table actor
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column
-- in upper case letters. Name the column Actor Name
SELECT  
CONCAT(UPPER(first_name), ' ',UPPER(last_name)) AS 'Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor,
-- of whom you know only the first name, "Joe." What is one query would
-- you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI.
-- This time, order the rows by last name and first name, in that order:
SELECT * FROM actor WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following
-- countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a, You want to keep a description of each actor. You don't think you will
-- be performing queries on a description, so create a column in the table
-- actor named description and use the data type BLOB (Make sure to research
-- the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN description BLOB;
-- Let's look at the new column description in table actor
SELECT * FROM actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort.
-- Delete the description column.
ALTER TABLE actor DROP COLUMN description;

-- Let's verify the description column is gone from table actor
SELECT * FROM actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) FROM actor GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but
-- only for names that are shared by at least two actors.
SELECT last_name, COUNT(*) FROM actor GROUP BY last_name HAVING COUNT(*) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS.
-- Write a query to fix the record.
-- Let's look at the record first
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
-- Fix the record
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
-- Verify the record has been changed correctly
SELECT actor_id, first_name, last_name FROM actor WHERE last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was
-- the correct name after all! In a single query, if the first name of the actor is currently
-- HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';
-- Verify the record has been changed correctly
SELECT actor_id, first_name, last_name FROM actor WHERE last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- The following command 'describes' the column names of each column in the address table & their
-- concomitant definition/layout/specifics. This statement does the same thing as the
-- "SHOW CREATE TABLE tbl_name" statement.
DESC address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member.
-- Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address
ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005.
-- Use tables staff and payment.
SELECT staff.first_name, staff.last_name, SUM(payment.amount)
FROM staff
INNER JOIN payment
ON staff.staff_id = payment.staff_id
WHERE payment.payment_date LIKE '2005-08%'
GROUP BY staff.last_name, staff.first_name
ORDER BY staff.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor
-- and film. Use inner join.
SELECT film.title, COUNT(DISTINCT film_actor.actor_id)
FROM film
INNER JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY film.title
ORDER BY film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title, COUNT(inventory.film_id)
FROM inventory
INNER JOIN film
ON film.film_id = inventory.film_id
WHERE film.title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
-- List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(payment.amount)
FROM customer
INNER JOIN payment
ON customer.customer_id = payment.customer_id
GROUP BY customer.last_name
ORDER BY customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended
-- consequence, films starting with the letters K and Q have also soared in popularity. Use
-- subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- Pre-testing:
-- 1 SELECT title FROM film WHERE title LIKE 'K%' OR title LIKE 'Q%';
-- 2 SELECT language_id FROM language WHERE name = 'English';
-- 3 SELECT film_id FROM film WHERE language_id = '1';
-- 4 SELECT title FROM film WHERE film_id = whatever
SELECT title FROM film WHERE film_id IN
(SELECT film_id FROM film WHERE language_id IN
(SELECT language_id FROM language WHERE name = 'English'))
HAVING title LIKE 'K%' OR title LIKE 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
-- Pre-testing:
-- select film_id from film where title = "ALONE TRIP";
-- select actor_id from film_actor where film_id = 17;
-- select  first_name, last_name from actor where  actor_id = xxx;
SELECT first_name, last_name, actor_id FROM actor WHERE actor_id IN
(SELECT actor_id FROM film_actor WHERE film_id IN
(SELECT film_id FROM film WHERE title = "ALONE TRIP"));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names
-- and email addresses of all Canadian customers. Use joins to retrieve this information.
-- Pre-testing:
-- SELECT country_id FROM country WHERE country = "Canada";
-- SELECT city_id FROM city WHERE country_id = 20; /* there are 7 canadian city ids */
-- SELECT address_id FROM address WHERE city_id = whatever;
-- SELECT first_name, last_name, email FROM customer WHERE address_id = whatever;

-- This is the answer using a subquery:
SELECT first_name, last_name, email FROM customer WHERE address_id IN 
(SELECT address_id FROM address WHERE city_id IN 
(SELECT city_id FROM city WHERE country_id IN 
(SELECT country_id FROM country WHERE country = "Canada")));

-- This is the answer using joins:
SELECT c.first_name, c.last_name, c.email
FROM customer AS c
INNER JOIN address AS a ON c.address_id = a.address_id
INNER JOIN city AS ci ON a.city_id = ci.city_id
INNER JOIN country AS co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies
-- for a promotion. Identify all movies categorized as family films.
-- Pre-testing:
-- SELECT category_id FROM category WHERE name = "Family";
-- SELECT film_id FROM film_category WHERE category_id = 8;
-- SELECT title FROM film WHERE film_id = whetever;
SELECT title FROM film WHERE film_id IN
(SELECT film_id FROM film_category WHERE category_id IN
(SELECT category_id FROM category WHERE name = "Family"));

-- 7e. Display the most frequently rented movies in descending order.
SELECT title, rental_duration FROM film
ORDER BY rental_duration DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- Pre-testing:
-- select * from payment; /* get the amount & staff_id */
-- select * from staff; /* get the store_id */
-- select * from store; /* store_id */
SELECT st.store_id, SUM(amount) AS 'Total Store Sales'
FROM payment AS p
INNER JOIN staff AS sf ON p.staff_id = sf.staff_id
INNER JOIN store AS st ON st.store_id = sf.store_id
GROUP BY st.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT st.store_id AS 'Store ID', ci.city AS 'City', co.country AS 'Country'
FROM store AS st
INNER JOIN address AS a ON st.address_id = a.address_id
INNER JOIN city AS ci ON a.city_id = ci.city_id
INNER JOIN country AS co ON ci.country_id = co.country_id
GROUP BY st.store_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use
-- the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name AS 'Film Genre', SUM(p.amount) AS 'Total Revenue'
FROM category AS c
INNER JOIN film_category AS f ON c.category_id = f.category_id
INNER JOIN inventory AS i ON f.film_id = i.film_id
INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
INNER JOIN payment AS p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the
-- Top five genres by gross revenue. Use the solution from the problem above to create a view.
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_5_genres AS
SELECT c.name AS 'Film Genre', SUM(p.amount) AS 'Total Revenue'
FROM category AS c
INNER JOIN film_category AS f ON c.category_id = f.category_id
INNER JOIN inventory AS i ON f.film_id = i.film_id
INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
INNER JOIN payment AS p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC LIMIT 5;

-- Let's list all views:
SHOW FULL TABLES WHERE TABLE_TYPE LIKE 'VIEW';

-- Let's check the definition of my view:
SHOW CREATE VIEW top_5_genres;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_5_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_5_genres;
