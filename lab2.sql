#1
DELIMITER $$
#DROP PROCEDURE [IF EXISTS] displayFilmInfo;
CREATE PROCEDURE displayFilmInfo(IN category_id INT,IN language_id INT)
BEGIN
IF category_id != 0 && language_id != 0 THEN
select * from film join film_category on film.film_id = film_category.film_id
where film.language_id = language_id and film_category.category_id = category_id;
ELSEIF category_id = 0 THEN
select *from film_category join film on film.film_id = film_category.film_id
where film.language_id = language_id;
ELSEIF language_id = 0 THEN
select *from film_category join film on film.film_id = film_category.film_id
where film_category.category_id = category_id;
END IF;
END$$
DELIMITER ;
CALL displayFilmInfo(1,2);

#3
DELIMITER $$
drop procedure badCustomer;
CREATE PROCEDURE badCustomer()
BEGIN
DECLARE @DateDiff AS Int;

SELECT * FROM customer join rental ON customer.customer_id = rental.customer_id
WHERE rental.return_date is null and datediff(now(), rental_date);
END$$
DELIMITER ;
CALL badCustomer();

select * from rental where datediff(now(), rental_date)>4500;
select now();


#2
DELIMITER $$
CREATE PROCEDURE rental_total (IN store_id INT, IN rental_month INT, IN rental_year INT)
BEGIN
select * from inventory 
join rental on inventory.inventory_id = rental.inventory_id
group by inventory.store_id
having inventory.store_id = store_id and month(rental.rental_date)= rental_month and year(rental.rental_date) = rental_year;
END$$;
DELIMITER ;

CALL rental_total(1,2,2006);


#4
DELIMITER $$
CREATE  PROCEDURE discount_film(IN p_discount double, IN n_film int)
BEGIN
	declare in_month int default month(now())-1;
    declare in_year int default year(now());
    
    DECLARE v_finished INTEGER DEFAULT 0;
    DECLARE v_film int DEFAULT 0;
    
	declare film_cursor cursor for
	select inventory.film_id
    from rental inner join inventory on rental.inventory_id = inventory.inventory_id
    where
		month(rental.rental_date) = in_month and
		year(rental.rental_date) = in_year
	group by inventory.film_id
    order by count(inventory.film_id) asc, film_id asc
    limit n_film;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
	
    OPEN film_cursor;
    
    get_film: LOOP
    FETCH film_cursor INTO v_film;
    IF v_finished = 1 THEN 
		LEAVE get_film;
    END IF;
    
	update film_view set rental_rate = rental_rate / 100 * (100-p_discount) where film_id = v_film;
    
	END LOOP get_film;
	CLOSE film_cursor;
END$$
DELIMITER ;
call discount_film(10,3);





