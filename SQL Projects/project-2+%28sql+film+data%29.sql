use film_rental;

-- 1.	What is the total revenue generated from all rentals in the database? (2.25 Marks)- 67406.56

SELECT SUM(amount) AS total_revenue
FROM Payment;

--  2.	How many rentals were made in each month_name?

SELECT DATE_FORMAT(rental_date, '%M') AS month_name, COUNT(*) AS rental_count
FROM Rental
GROUP BY month_name;

select*from rental;

-- 3.	What is the rental rate of the film with the longest title in the database?-2.99


SELECT rental_rate,title
FROM film
WHERE LENGTH(title) = (SELECT MAX(LENGTH(title)) FROM film);


-- 4.	What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")?

select avg(amount) as Avg_rental_rate
from payment
where rental_id in (select rental_id from rental where rental_date between "2005-05-05 22:04:30" and date_add("2005-05-05 22:04:30", interval 30 day));

-- or
SELECT AVG(Film.rental_rate) AS avg_rental_rate
FROM Film, Rental
WHERE Film.film_id = Rental.rental_id 
and Rental.rental_date BETWEEN DATE_SUB('2005-05-05 22:04:30', INTERVAL 30 DAY) AND '2005-05-05 22:04:30';



select*from film;
select *from rental;




-- 5.	What is the most popular category of films in terms of the number of rentals? 

select name,count(name) as Rentals
from category 
join film_category
using(category_id)
where film_id in 
(select film_id from inventory
where inventory_id in (select inventory_id from rental))
group by 1 order by 2 desc limit 1;

-- or

SELECT Category.name AS category_name, COUNT(*) AS rental_count
FROM Film_Category 
JOIN Film ON Film_Category.film_id = Film.film_id
JOIN Rental ON Film.film_id = Rental.inventory_id
JOIN Category ON Film_Category.category_id = Category.category_id
GROUP BY Category.name
ORDER BY rental_count DESC
LIMIT 1;





-- 6.	Find the longest movie duration from the list of films that have not been rented by any customer?

SELECT MAX(length) AS longest_duration
FROM film
WHERE film_id NOT IN (
    SELECT DISTINCT inventory.film_id
    FROM inventory
    INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
);




--   7.	What is the average rental rate for films, broken down by category? 

SELECT c.name AS category, round(avg(f.rental_rate),2) AS avg_rental_rate
FROM film_category fc
INNER JOIN film f ON fc.film_id = f.film_id
INNER JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY c.name asc;

-- 8.	What is the total revenue generated from rentals for each actor in the database? 


SELECT 
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name, 
    (
        SELECT SUM(p.amount) 
        FROM payment p 
        INNER JOIN rental r ON p.rental_id = r.rental_id 
        INNER JOIN inventory i ON r.inventory_id = i.inventory_id 
        INNER JOIN film_actor fa ON i.film_id = fa.film_id 
        WHERE fa.actor_id = a.actor_id
    ) AS total_revenue
FROM actor a
ORDER BY actor_name asc;




-- 9.	Show all the actresses who worked in a film having a "Wrestler" in description

SELECT DISTINCT concat(actor.first_name, actor.last_name) as actor_name
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
JOIN film ON film_actor.film_id = film.film_id
WHERE film.description LIKE '%Wrestler%';

    

-- 10.	Which customers have rented the same film more than once? 

SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    COUNT(*) AS rental_count,
    f.title AS film_title
FROM 
    customer c 
    JOIN rental r ON c.customer_id = r.customer_id 
    JOIN inventory i ON r.inventory_id = i.inventory_id 
    JOIN film f ON i.film_id = f.film_id 
GROUP BY 
    c.customer_id, 
    f.film_id 
HAVING 
    COUNT(*) > 1;

-- 11.	How many films in the comedy category have a rental rate higher than the average rental rate? 

select count(film_id)as No_of_Films
from film_category
join category using (category_id)
where name="comedy" and film_id in (select film_id from film where rental_rate > (select avg(rental_rate) from film));

-- or  

SELECT 
    COUNT(*) AS comedy_films_above_avg
FROM 
    film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
WHERE 
    c.name = 'Comedy' AND f.rental_rate > (
        SELECT 
            AVG(rental_rate)
        FROM 
            film f
            JOIN film_category fc ON f.film_id = fc.film_id
            JOIN category c ON fc.category_id = c.category_id
        WHERE 
            c.name = 'Comedy'
    );
    
-- 12.	Which films have been rented the most by customers living in each city? 



WITH city_rentals AS (
  SELECT c.city, f.title, COUNT(*) AS rental_count,
    ROW_NUMBER() OVER (PARTITION BY c.city ORDER BY COUNT(*) DESC) AS rank1
  FROM rental r
  JOIN customer cu ON r.customer_id = cu.customer_id
  JOIN address a ON cu.address_id = a.address_id
  JOIN city c ON a.city_id = c.city_id
  JOIN inventory i ON r.inventory_id = i.inventory_id
  JOIN film f ON i.film_id = f.film_id
  GROUP BY c.city, f.title
),
city_top_rentals AS (
  SELECT city, title, rental_count
  FROM city_rentals
  WHERE rank1 = 1
)
SELECT city, title, rental_count
FROM city_top_rentals
ORDER BY city ;

-- or

select city,title
from city join address using(city_id) 
join customer using(address_id)
join rental using(customer_id)
join inventory using(inventory_id)
join film using(film_id);

-- 13.	What is the total amount spent by customers whose rental payments exceed $200?

select customer_id, concat_ws(" ",first_name,Last_name) as Name,sum(amount) as Total 
from payment join customer using(customer_id)
group by 1
having Total>200;

-- or

SELECT SUM(amount) AS total_amount
FROM payment
WHERE customer_id IN (
  SELECT customer_id
  FROM payment
  GROUP BY customer_id
  HAVING SUM(amount) >= 200
);


--  14.	Create a View for the total revenue generated by each staff member, broken down by store city with country name? 

CREATE VIEW revenue_by_staff_and_store AS
SELECT s.staff_id, s.first_name, s.last_name,
       c.city, cy.country, 
       SUM(p.amount) OVER (PARTITION BY s.staff_id, c.city, cy.country) AS total_revenue
FROM staff s
JOIN store st ON s.store_id = st.store_id
JOIN address a ON st.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN country cy ON c.country_id = cy.country_id
JOIN rental r ON s.staff_id = r.staff_id
JOIN payment p ON r.rental_id = p.rental_id;

SELECT distinct* FROM revenue_by_staff_and_store;


-- 15.	Create a view based on rental information consisting of visiting_day, customer_name, title of film, no_of_rental_days, amount paid by the customer along with percentage of customer spending. 


CREATE VIEW rental_info_view AS
SELECT 
    DATE_FORMAT(Rental.rental_date, '%Y-%m-%d') AS visiting_day,
    CONCAT(Customer.first_name, ' ', Customer.last_name) AS customer_name,
    Film.title,
    DATEDIFF(Rental.return_date, Rental.rental_date) AS no_of_rental_days,
    Payment.amount,
    (Payment.amount / (SELECT SUM(amount) FROM Payment)) * 100 AS percentage_spending
FROM Rental
JOIN Customer ON Rental.customer_id = Customer.customer_id
JOIN Inventory ON Rental.inventory_id = Inventory.inventory_id
JOIN Film ON Inventory.film_id = Film.film_id
JOIN Payment ON Rental.rental_id = Payment.rental_id;

select*from rental_info_view
order by customer_name;

-- 16.	Display the customers who paid 50% of their total rental costs within one day. 

SELECT 
    customer.first_name,
    customer.last_name,
    SUM(payment.amount) AS total_rental_cost,
    DATEDIFF(MAX(payment.payment_date), MIN(payment.payment_date)) AS rental_days,
    SUM(payment.amount) * 0.5 AS half_rental_cost
FROM 
    customer
    INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY 
    customer.customer_id
HAVING 
    rental_days = 0 AND SUM(payment.amount) >= half_rental_cost;
    
    select*from payment;
    
    




















