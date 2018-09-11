#1
create view employee_customer as
select employees.lastName, employees.firstName, customers.contactlastName, customers.contactFirstName, customers.customerNumber,
count(orders.orderNumber) as 'orderCount', sum(orderdetails.quantityOrdered * orderdetails.priceEach) as 'total_pay'
from employees inner join customers on employees.employeeNumber = customers.salesRepEmployeeNumber
inner join orders on orders.customerNumber = customers.customerNumber
inner join orderdetails on orders.orderNumber = orderdetails.orderNumber
group by orders.customerNumber;

#2
CREATE DEFINER=`root`@`localhost` PROCEDURE `getOrderByTimeAndValue`(IN start_date date, IN end_date date , IN min_value double, IN max_value double)
BEGIN
	select orders.*, sum(orderdetails.priceEach * orderdetails.quantityOrdered) as total
    from orders inner join orderdetails on orders.orderNumber = orderdetails.orderNumber
    where if(start_date is null, true, orders.orderDate < start_date) and if(end_date is null, true, orders.orderDate < end_date)
    group by orders.orderNumber
    having total > min_value and if(max_value = 0, true, total < max_value);
END

#3
CREATE DEFINER=`root`@`localhost` FUNCTION `getProductsTotalByOffice`(in_officeCode int, in_month int, in_year int) RETURNS int(11)
BEGIN

declare office_order_count int default 0;

select sum(orderdetails.quantityOrdered) into office_order_count
from offices inner join employees on offices.officeCode = employees.officeCode
inner join customers on customers.salesRepEmployeeNumber = employees.employeeNumber
inner join orders on customers.customerNumber = orders.customerNumber
inner join orderdetails on orders.orderNumber = orderdetails.orderNumber
where offices.officeCode = in_officeCode
and month(orders.orderDate) = in_month
and year(orders.orderDate) = in_year;

if (office_order_count is null) then
	RETURN 0;
end if;

RETURN office_order_count;
END

#4
create table goldenmember(
customerNumber int unique not null primary key, total double);

DELIMITER $$
CREATE TRIGGER golden_member_trigger AFTER INSERT ON orderdetails
FOR EACH ROW
BEGIN

DECLARE customer_number int;
declare customer_order_value double;
declare customer_exist int;

select customerNumber into customer_number from orders where orders.orderNumber = NEW.orderNumber;

select sum(quantityOrdered * priceEach) into customer_order_value 
from orderdetails inner join orders on orderdetails.orderNumber = orders.orderNumber
where orders.customerNumber = customer_number
group by orders.customerNumber;

if customer_order_value > 100000 then
	select count(*) into customer_exist from goldenmember where customerNumber = customer_number;
	if customer_exist > 0 then
		update goldenmember set total = customer_order_value where customerNumber = customer_number;
	else
		INSERT INTO goldenmember values(customer_number, customer_order_value);
	end if;
end if;

END$$
DELIMITER ;

#5
explain select employees.lastName, employees.firstName, customers.contactlastName, customers.contactFirstName, customers.customerNumber,
count(orders.orderNumber) as 'orderCount', sum(orderdetails.quantityOrdered * orderdetails.priceEach) as 'total_pay'
from employees inner join customers on employees.employeeNumber = customers.salesRepEmployeeNumber
inner join orders on orders.customerNumber = customers.customerNumber
inner join orderdetails on orders.orderNumber = orderdetails.orderNumber
group by orders.customerNumber;