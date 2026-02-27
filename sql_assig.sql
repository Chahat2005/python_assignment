

/* =========================
   SECTION 1: SQL BASICS
   ========================= */

-- Q1
CREATE TABLE employees (
    emp_id INT NOT NULL PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    age INT CHECK (age >= 18),
    email VARCHAR(255) UNIQUE,
    salary DECIMAL(10,2) DEFAULT 30000.00
);

-- Q2
-- Constraints maintain data integrity by restricting invalid data.
-- Common constraints:
-- 1) NOT NULL: disallows NULL values.
-- 2) UNIQUE: all values in column must be distinct.
-- 3) PRIMARY KEY: uniquely identifies each row (UNIQUE + NOT NULL).
-- 4) FOREIGN KEY: enforces referential integrity with parent table.
-- 5) CHECK: enforces condition (e.g., age >= 18).
-- 6) DEFAULT: assigns default value when none provided.

-- Q3
-- NOT NULL is used for mandatory fields so missing values are not allowed.
-- Primary key can NEVER contain NULL because it must uniquely identify every row.

-- Q4
-- Add constraint example:
ALTER TABLE employees
ADD CONSTRAINT chk_salary CHECK (salary >= 0);

-- Remove constraint examples:
ALTER TABLE employees DROP CHECK chk_salary;
ALTER TABLE employees DROP INDEX email;

-- Q5
-- If DML violates constraints, DB throws error and operation fails.
-- Example:
-- INSERT INTO employees(emp_id, emp_name, age, email) VALUES (1,'A',16,'a@x.com');
-- Error example: CHECK constraint 'employees_chk_1' is violated.

-- Q6 (modify products table constraints)
ALTER TABLE products
ADD PRIMARY KEY (product_id);

ALTER TABLE products
MODIFY price DECIMAL(10,2) DEFAULT 50.00;

-- Q7 (student_name + class_name via INNER JOIN)
SELECT s.student_name, c.class_name
FROM students s
INNER JOIN classes c ON s.class_id = c.class_id;

-- Q8 (all products listed even without order)
SELECT o.order_id, c.customer_name, p.product_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN customers c ON o.customer_id = c.customer_id;

-- Q9 (total sales amount for each product)
SELECT p.product_name,
       SUM(oi.quantity * oi.unit_price) AS total_sales
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name;

-- Q10 (order_id, customer_name, quantity)
SELECT o.order_id, c.customer_name, oi.quantity
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id;


/* =========================
   SECTION 2: SQL COMMANDS (SAKILA)
   ========================= */

-- 1) PK/FK identification queries
SELECT tc.table_name, tc.constraint_name, tc.constraint_type, kcu.column_name,
       kcu.referenced_table_name, kcu.referenced_column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
 AND tc.table_schema = kcu.table_schema
 AND tc.table_name = kcu.table_name
WHERE tc.table_schema = 'sakila'
  AND tc.constraint_type IN ('PRIMARY KEY','FOREIGN KEY')
ORDER BY tc.table_name, tc.constraint_type;

-- Difference:
-- Primary Key: uniquely identifies row in same table, only one PK per table (can be composite), NOT NULL.
-- Foreign Key: references PK/UNIQUE in another table, multiple FKs allowed, enforces referential integrity.

-- 2
SELECT * FROM actor;

-- 3
SELECT * FROM customer;

-- 4
SELECT DISTINCT country FROM country;

-- 5
SELECT * FROM customer WHERE active = 1;

-- 6
SELECT rental_id FROM rental WHERE customer_id = 1;

-- 7
SELECT * FROM film WHERE rental_duration > 5;

-- 8
SELECT COUNT(*) AS total_films
FROM film
WHERE replacement_cost > 15 AND replacement_cost < 20;

-- 9
SELECT COUNT(DISTINCT first_name) AS unique_actor_first_names
FROM actor;

-- 10
SELECT * FROM customer LIMIT 10;

-- 11
SELECT * FROM customer
WHERE first_name LIKE 'B%'
LIMIT 3;

-- 12
SELECT title FROM film
WHERE rating = 'G'
LIMIT 5;

-- 13
SELECT * FROM customer WHERE first_name LIKE 'A%';

-- 14
SELECT * FROM customer WHERE first_name LIKE '%a';

-- 15
SELECT city
FROM city
WHERE city LIKE 'a%a'
LIMIT 4;

-- 16
SELECT * FROM customer WHERE first_name LIKE '%NI%';

-- 17
SELECT * FROM customer WHERE first_name LIKE '_r%';

-- 18
SELECT * FROM customer
WHERE first_name LIKE 'A%'
  AND CHAR_LENGTH(first_name) >= 5;

-- 19
SELECT * FROM customer WHERE first_name LIKE 'A%o';

-- 20
SELECT * FROM film WHERE rating IN ('PG','PG-13');

-- 21
SELECT * FROM film WHERE length BETWEEN 50 AND 100;

-- 22
SELECT * FROM actor LIMIT 50;

-- 23
SELECT DISTINCT film_id FROM inventory;


/* =========================
   SECTION 3: FUNCTIONS + GROUP BY + JOINS
   ========================= */

-- Q1
SELECT COUNT(*) AS total_rentals FROM rental;

-- Q2
SELECT AVG(DATEDIFF(return_date, rental_date)) AS avg_rental_days
FROM rental
WHERE return_date IS NOT NULL;

-- Q3
SELECT UPPER(first_name) AS first_name_upper,
       UPPER(last_name) AS last_name_upper
FROM customer;

-- Q4
SELECT rental_id,
       MONTH(rental_date) AS rental_month
FROM rental;

-- Q5
SELECT customer_id,
       COUNT(*) AS rental_count
FROM rental
GROUP BY customer_id;

-- Q6
SELECT s.store_id,
       SUM(p.amount) AS total_revenue
FROM payment p
JOIN staff s ON p.staff_id = s.staff_id
GROUP BY s.store_id;

-- Q7
SELECT c.name AS category_name,
       COUNT(*) AS rental_count
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.category_id, c.name;

-- Q8
SELECT l.name AS language_name,
       AVG(f.rental_rate) AS avg_rental_rate
FROM film f
JOIN language l ON f.language_id = l.language_id
GROUP BY l.language_id, l.name;

-- Q9
SELECT f.title,
       c.first_name,
       c.last_name
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN customer c ON r.customer_id = c.customer_id;

-- Q10
SELECT a.first_name, a.last_name
FROM film_actor fa
JOIN film f ON fa.film_id = f.film_id
JOIN actor a ON fa.actor_id = a.actor_id
WHERE f.title = 'GONE WITH THE WIND';

-- Q11
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       SUM(p.amount) AS total_spent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- Q12 (example city: London)
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       GROUP_CONCAT(DISTINCT f.title ORDER BY f.title SEPARATOR ', ') AS rented_movies
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE ci.city = 'London'
GROUP BY c.customer_id, c.first_name, c.last_name;

-- Q13
SELECT f.film_id,
       f.title,
       COUNT(*) AS times_rented
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY f.film_id, f.title
ORDER BY times_rented DESC
LIMIT 5;

-- Q14
SELECT c.customer_id,
       c.first_name,
       c.last_name
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT i.store_id) = 2;


/* =========================
   SECTION 4: WINDOW FUNCTIONS
   ========================= */

-- 1) Rank customers by total spending
SELECT customer_id,
       total_spent,
       DENSE_RANK() OVER (ORDER BY total_spent DESC) AS spend_rank
FROM (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM payment
    GROUP BY customer_id
) t;

-- 2) Cumulative revenue by film over time
SELECT film_id,
       title,
       payment_date,
       amount,
       SUM(amount) OVER (PARTITION BY film_id ORDER BY payment_date) AS cumulative_revenue
FROM (
    SELECT f.film_id, f.title, p.payment_date, p.amount
    FROM payment p
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
) x;

-- 3) Average rental duration for films with similar lengths
SELECT film_id,
       title,
       length,
       rental_duration,
       AVG(rental_duration) OVER (PARTITION BY length) AS avg_rental_duration_same_length
FROM film;

-- 4) Top 3 films in each category by rental counts
SELECT category_name, title, rental_count
FROM (
    SELECT c.name AS category_name,
           f.title,
           COUNT(*) AS rental_count,
           DENSE_RANK() OVER (PARTITION BY c.category_id ORDER BY COUNT(*) DESC) AS rn
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    GROUP BY c.category_id, c.name, f.film_id, f.title
) z
WHERE rn <= 3;

-- 5) Difference between each customer's rentals and avg rentals across customers
SELECT customer_id,
       rental_count,
       rental_count - AVG(rental_count) OVER () AS diff_from_avg
FROM (
    SELECT customer_id, COUNT(*) AS rental_count
    FROM rental
    GROUP BY customer_id
) t;

-- 6) Monthly revenue trend
SELECT DATE_FORMAT(payment_date, '%Y-%m') AS revenue_month,
       SUM(amount) AS monthly_revenue,
       SUM(SUM(amount)) OVER (ORDER BY DATE_FORMAT(payment_date, '%Y-%m')) AS running_revenue
FROM payment
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY revenue_month;

-- 7) Customers in top 20% by spending
SELECT customer_id, total_spent
FROM (
    SELECT customer_id,
           SUM(amount) AS total_spent,
           CUME_DIST() OVER (ORDER BY SUM(amount) DESC) AS cume_dist_desc
    FROM payment
    GROUP BY customer_id
) t
WHERE cume_dist_desc <= 0.20;

-- 8) Running total of rentals per category ordered by rental_count
SELECT category_name,
       rental_count,
       SUM(rental_count) OVER (ORDER BY rental_count DESC) AS running_total
FROM (
    SELECT c.name AS category_name,
           COUNT(*) AS rental_count
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film_category fc ON i.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    GROUP BY c.category_id, c.name
) t;

-- 9) Films rented less than category average rental count
SELECT category_name, title, rental_count, avg_category_rental_count
FROM (
    SELECT c.name AS category_name,
           f.title,
           COUNT(*) AS rental_count,
           AVG(COUNT(*)) OVER (PARTITION BY c.category_id) AS avg_category_rental_count
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    GROUP BY c.category_id, c.name, f.film_id, f.title
) t
WHERE rental_count < avg_category_rental_count;

-- 10) Top 5 months with highest revenue
SELECT revenue_month, monthly_revenue
FROM (
    SELECT DATE_FORMAT(payment_date, '%Y-%m') AS revenue_month,
           SUM(amount) AS monthly_revenue,
           DENSE_RANK() OVER (ORDER BY SUM(amount) DESC) AS rn
    FROM payment
    GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
) t
WHERE rn <= 5
ORDER BY monthly_revenue DESC;


/* =========================
   SECTION 5: NORMALIZATION + CTE
   ========================= */

-- 1NF (example discussion)
-- Example table violating 1NF (conceptual): customer_phone(customer_id, customer_name, phones)
-- where phones stores comma-separated values. To normalize:
-- Split into customer(customer_id, customer_name) and customer_phone(customer_id, phone).

-- 2NF (example)
-- Check composite key tables (e.g., film_actor(actor_id, film_id, ...)).
-- If non-key attribute depends only on part of composite key, move it to separate table.
-- In Sakila, film_actor already mostly in 2NF because it has only key attributes + last_update.

-- 3NF (example)
-- A transitive dependency example (conceptual): customer(customer_id, city_id, city_name, country_name)
-- city_name/country_name depend on city_id, not directly on customer_id.
-- Normalize into customer(address_id), address(city_id), city(country_id), country.

-- 4) Normalization process (UNF -> 2NF concept)
-- UNF: order(order_id, customer_name, product_list)
-- 1NF: one row per product line -> order_line(order_id, product_id, qty)
-- 2NF: split customer/product details to separate tables:
-- customer(customer_id,...), product(product_id,...), orders(order_id, customer_id,...), order_line(order_id, product_id, qty)

-- 5) CTE basics: actor names + number of films
WITH actor_film_count AS (
    SELECT a.actor_id,
           CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
           COUNT(fa.film_id) AS film_count
    FROM actor a
    LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
    GROUP BY a.actor_id, a.first_name, a.last_name
)
SELECT actor_name, film_count
FROM actor_film_count
ORDER BY film_count DESC, actor_name;

-- 6) CTE with joins: film + language + rental rate
WITH film_lang AS (
    SELECT f.title, l.name AS language_name, f.rental_rate
    FROM film f
    JOIN language l ON f.language_id = l.language_id
)
SELECT *
FROM film_lang
ORDER BY title;

-- 7) CTE for aggregation: total revenue per customer
WITH customer_revenue AS (
    SELECT customer_id, SUM(amount) AS total_revenue
    FROM payment
    GROUP BY customer_id
)
SELECT c.customer_id, c.first_name, c.last_name, cr.total_revenue
FROM customer c
JOIN customer_revenue cr ON c.customer_id = cr.customer_id
ORDER BY cr.total_revenue DESC;

-- 8) CTE with window: rank films by rental duration
WITH film_rank AS (
    SELECT film_id,
           title,
           rental_duration,
           DENSE_RANK() OVER (ORDER BY rental_duration DESC) AS duration_rank
    FROM film
)
SELECT *
FROM film_rank
ORDER BY duration_rank, title;

-- 9) CTE + filtering: customers with >2 rentals + details
WITH frequent_customers AS (
    SELECT customer_id, COUNT(*) AS rental_count
    FROM rental
    GROUP BY customer_id
    HAVING COUNT(*) > 2
)
SELECT c.customer_id, c.first_name, c.last_name, fc.rental_count
FROM frequent_customers fc
JOIN customer c ON fc.customer_id = c.customer_id
ORDER BY fc.rental_count DESC;

-- 10) CTE date calculation: rentals each month
WITH monthly_rentals AS (
    SELECT DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
           COUNT(*) AS total_rentals
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT *
FROM monthly_rentals
ORDER BY rental_month;

-- 11) CTE + self join: actor pairs in same film
WITH actor_pairs AS (
    SELECT fa1.film_id,
           fa1.actor_id AS actor1_id,
           fa2.actor_id AS actor2_id
    FROM film_actor fa1
    JOIN film_actor fa2
      ON fa1.film_id = fa2.film_id
     AND fa1.actor_id < fa2.actor_id
)
SELECT ap.film_id,
       CONCAT(a1.first_name, ' ', a1.last_name) AS actor_1,
       CONCAT(a2.first_name, ' ', a2.last_name) AS actor_2
FROM actor_pairs ap
JOIN actor a1 ON ap.actor1_id = a1.actor_id
JOIN actor a2 ON ap.actor2_id = a2.actor_id
ORDER BY ap.film_id, actor_1, actor_2;

-- 12) Recursive CTE: staff hierarchy by manager (reports_to)
WITH RECURSIVE staff_hierarchy AS (
    SELECT staff_id, first_name, last_name, reports_to, 0 AS level
    FROM staff
    WHERE staff_id = 1

    UNION ALL

    SELECT s.staff_id, s.first_name, s.last_name, s.reports_to, sh.level + 1
    FROM staff s
    JOIN staff_hierarchy sh ON s.reports_to = sh.staff_id
)
SELECT *
FROM staff_hierarchy
ORDER BY level, staff_id;
