#1
show create table payment;
CREATE TABLE payment_log (
   payment_id smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   customer_id smallint(5) unsigned NOT NULL,
   staff_id tinyint(3) unsigned NOT NULL,
   rental_id int(11) DEFAULT NULL,
   amount decimal(5,2) NOT NULL,
   payment_date datetime NOT NULL,
   changedate DATETIME DEFAULT NULL,
    action VARCHAR(50) DEFAULT NULL,
   PRIMARY KEY (payment_id)
   );
   

DELIMITER $$
CREATE TRIGGER update_payment BEFORE UPDATE ON payvment
FOR EACH ROW
BEGIN
INSERT INTO payment_log 
SET action = 'update',
payment_id = OLD.payment_id,
customer_id = OLD.customer_id,
staff_id = OLD.staff_id,
rental_id = OLD.rental_id,
amount = OLD.amount,
payment_date = OLD.payment_date,
changedate = NOW();
END$$
DELIMITER ;
select * from rental;
#2
ALTER TABLE inventory ADD  is_available  Boolean default false ;
DELIMITER $$
DROP TRIGGER if exists update_inventory;
CREATE TRIGGER update_inventory AFTER UPDATE  ON rental
FOR EACH ROW
update inventory set  is_available = true
where inventory.inventory_id in (select rental.inventory_id from rental where rental.return_date is not null);
END$$
DELIMITER ;
#3
CREATE VIEW customer_list
AS
select * from customer;

#4
CREATE VIEW info_rental
AS
select customer.customer_id, count(rental.rental_id) from customer 
join rental on customer.customer_id = rental.customer_id
and month(rental.rental_date) = month(now()) - 1 and year(rental.rental_date) = year(now())
group by customer.customer_id;
#5
select * from  sales_by_store;
show create view  sales_by_store;
#CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `sales_by_store` AS 
select concat(`c`.`city`,_utf8mb3',',`cy`.`country`) AS `store`,
concat(`m`.`first_name`,_utf8mb3' ',`m`.`last_name`) AS `manager`,sum(`p`.`amount`) AS `total_sales` 
from (((((((`payment` `p` join `rental` `r` on((`p`.`rental_id` = `r`.`rental_id`))) 
join `inventory` `i` on((`r`.`inventory_id` = `i`.`inventory_id`))) 
join `store` `s` on((`i`.`store_id` = `s`.`store_id`))) 
join `address` `a` on((`s`.`address_id` = `a`.`address_id`))) 
join `city` `c` on((`a`.`city_id` = `c`.`city_id`))) 
join `country` `cy` on((`c`.`country_id` = `cy`.`country_id`))) 
join `staff` `m` on((`s`.`manager_staff_id` = `m`.`staff_id`))) 
group by `s`.`store_id` order by `cy`.`country`,`c`.`city`

CREATE VIEW  sales_by_store_month
AS
select store.store_id, store., sum(payment.amount) from store 
join inventory on inventory.store_id = store.store_id
join rental on rental.inventory_id = inventory.inventory_id
join payment on payment.rental_id = rental.rental_id
group by store.store_id, month(rental.rental_date);

select * from sales_by_store_month;



show databases;
use information_schema;
show tables;
select * from views;
show create view customer_list;
select * from customer_list;
update customer_list set address = '32 Tran Dai Nghia' where zipcode = 40301;
update customer_list set phone = 123456743 where id = 441;

CREATE VIEW film_details
AS
select film.title, film.description, film.rating, language.name from film
join language on film.language_id = language.language_id;
select * from film_details;

select * from inventory;



show create table payments;
show create table orders;
