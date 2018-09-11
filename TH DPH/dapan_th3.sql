# 1
CREATE DEFINER=`root`@`localhost` PROCEDURE `displayFilmInfo`(IN category_id INT, IN language_id INT)
BEGIN
	if category_id != 0 && language_id != 0 THEN
		Select * from film_category inner join film on film_category.film_id = film.film_id
        where 
			film_category.category_id = category_id and
			film.language_id = language_id;
    elseif category_id != 0 THEN
		Select * from film_category inner join film on film_category.film_id = film.film_id
        where 
			film_category.category_id = category_id;
	elseif language_id != 0 THEN
		Select * from film_category inner join film on film_category.film_id = film.film_id
        where 
			film.language_id = language_id;
    end if;
END

# 2
CREATE DEFINER=`root`@`localhost` FUNCTION `film_total`(store_id int, in_month int, in_year int) RETURNS int(11)
BEGIN
    declare film_count int;
    
    select count(*) into film_count
    from rental inner join inventory on rental.inventory_id = inventory.inventory_id
    where
		inventory.store_id = store_id and
        month(rental.rental_date) = in_month and
        year(rental.rental_date) = in_year;
	
RETURN film_count;
END

# 3
CREATE DEFINER=`root`@`localhost` PROCEDURE `discount_film`(IN p_discount double, IN n_film int, IN in_date date)
BEGIN
	declare in_month int default month(str_to_date(in_date, "%Y-%m-%d"));
    declare in_year int default year(str_to_date(in_date, "%Y-%m-%d"));
    
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
END