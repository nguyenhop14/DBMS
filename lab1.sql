select * from film;
# lab1
#1
select customer.customer_id, film.film_id, rental.return_date from rental
join customer on rental.customer_id = customer.customer_id
join inventory on rental.rental_id = inventory.inventory_id
join film on inventory.film_id = film.film_id and film.film_id = 2
where month(rental.rental_date) = 2 and year(rental.rental_date) =2006 and rental.return_date is null ;
#2
select film.film_id, film_text.description from film
join film_text on film.film_id = film_text.film_id and film_text.description like '%drama%teacher%' or film_text.description like '%teacher%drama%';

alter table film_text add fulltext (description);
select film.film_id, film_text.description from film
join film_text on film.film_id = film_text.film_id and match film_text.description against ('+drama +teacher' in boolean mode);

#3
select film.film_id, film.title, count(rental.inventory_id) sl from rental
join inventory on rental.inventory_id = inventory.inventory_id and month(rental.rental_date) = 2 and year(rental.rental_date)=2006
join film on film.film_id = inventory.film_id
group by inventory.film_id
order by sl
limit 10;

select film.film_id, film.title from film, rental
where film.film_id in 
(select inventory.film_id from inventory
join rental on inventory.inventory_id = rental.inventory_id 
and month(rental.rental_date) = 2 and year(rental.rental_date)=2006
group by inventory.film_id
order by count(rental.inventory_id))
limit 10;

#4
select store.store_id, count(inventory.inventory_id) sl from store
join inventory on inventory.store_id = store.store_id
join rental on rental.inventory_id = inventory.inventory_id and month(rental.rental_date) = 2 and year(rental.rental_date)=2006
group by store.store_id
order by sl desc;

#5
select distinct film.film_id from inventory
join film on film.film_id = inventory.film_id and film.title like '%dinosaur%'
join rental on rental.inventory_id = inventory.inventory_id and rental.return_date is not null
where inventory.store_id = 1;



