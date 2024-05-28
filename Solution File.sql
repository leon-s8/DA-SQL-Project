use film_rental;

# 1.What is the total revenue generated from all rentals in the database?
select sum(amount) as total_amount from payment ;
select * from payment;

#2. How many rentals were made in each month_name? 

select distinct year(rental_date) as year ,month(rental_date) as month, count(rental_id) as total_rental 
from rental group by year(rental_date), month(rental_date);

#3.What is the rental rate of the film with the longest title in the database?

select title,rental_rate,length(title) as lenght from film 
order by length(title) desc limit 1;

#4.What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")? 

select avg(rental_rate) as Average_rate from film  
where film_id in  (select film_id from rental r join inventory i 
using(inventory_id) where rental_date>=date_sub('2005-05-05 22:04:30',interval(30)day)); 

#5. What is the most popular category of films in terms of the number of rentals?

select c.name ,category_id,count(rental_id) from category c inner join film_category fc using(category_id) 
inner join inventory i using (film_id) inner join rental r using (inventory_id)
group by category_id order by count(rental_id) desc limit 1;


#6.Find the longest movie duration from the list of films that have not been rented by any customer

select film_id,title ,max(length) from film 
where film_id not in (select inventory_id from rental)
group by film_id,title order by max(length) desc;


#7.	What is the average rental rate for films, broken down by category?

select c.name as Category_name,avg(amount) as Average_rental_rate from category c inner join film_category fc using(category_id) 
inner join inventory i using (film_id) inner join rental r using (inventory_id) 
join payment p using (rental_id) group by c.name ;

# 8.	What is the total revenue generated from rentals for each actor in the database?

select actor_id ,concat(first_name," ",last_name) as actor_name,sum(amount) as total_revenue from film f join film_actor fa using(film_id) 
join actor using (actor_id) 
join inventory using( film_id) 
join rental using (inventory_id)
join payment using (rental_id) 
group by actor_id order by total_revenue desc;

#9.	Show all the actresses who worked in a film having a "Wrestler" in the description. 

select distinct concat(first_name," ",last_name),description as Actor_name from film f 
join film_actor fa using(film_id) 
join actor using (actor_id) where description in (select description from film where description like "%Wrestler%");

#10. Which customers have rented the same film more than once? 

select concat(c.first_name," ",c.last_name) as customer_name,f.title, count(title) as count
from customer c 
join rental r using (customer_id)
join inventory i using(inventory_id)
join film f using (film_id)
group by customer_name,f.title
having count>1
order by count(title) desc ;

#11. How many films in the comedy category have a rental rate higher than the average rental rate?

select count(c.name) as count_of_comedy_film from category c 
join film_category fc using (category_id)
join film f using (film_id) 
where c.name="comedy" and 
f.rental_rate > (select avg(rental_rate) from film f where c.name="comedy");

#12.Which films have been rented the most by customers living in each city? 

select ci.city ,f.title,count(f.title) as count
from customer cus 
join address ad using (address_id)
join city ci using (city_id)
join rental r using (customer_id)
join inventory i using(inventory_id)
join film f using (film_id)
group by f.title,ci.city
order by count desc;


#13. What is the total amount spent by customers whose rental payments exceed $200? (3 Marks)

select c.customer_id, concat(first_name," ",last_name) as Customer_name,sum(amount) as rental_payment from customer c join payment p using (customer_id) 
group by customer_id having rental_payment >200;

#14. Display the fields which are having foreign key constraints related to the "rental" table. [Hint: using Information_schema]

SELECT * 
FROM INFORMATION_SCHEMA. TABLES  
WHERE TABLE_SCHEMA = 'film_rental';

#15. Create a View for the total revenue generated by each staff member, broken down by store city with the country name.

create view Revenueby_staff as
select  distinct sf.staff_id, concat(sf.first_name," ",sf.last_name) as staff_name, ct.country, ci.city,
sum(amount) over (partition by ci.city) as total_revenue 
from payment p join staff sf using (staff_id)
join store st using (store_id)
join address ad on ad.address_id=st.address_id
join city ci using (city_id)
join country ct using (country_id);

select * from revenueby_staff;


# 16.Create a view based on rental information consisting of visiting_day, customer_name, the title of the film,  
-- no_of_rental_days, the amount paid by the customer along with the percentage of customer spending.

create  view rental_info as 
select rental_date as Visting_day, concat(c.first_name," ",c.last_name) as Customer_name,
f.title as Movie_title,
datediff(r.return_date,r.rental_date) as Duration_of_rental,
p.amount as Amount_paid,
(p.amount / (select sum(amount) from payment  ))*100 as spending_percent
from rental r 
join customer c using (customer_id)
join payment p using (rental_id)
join inventory i using (inventory_id)
join film f using(film_id);

select * from rental_info;


# 17.	Display the customers who paid 50% of their total rental costs within one day.

select concat(first_name," ",last_name) as customer_name  
from rental r 
join customer c using (customer_id)
join payment p using (rental_id)
join inventory i using (inventory_id);











