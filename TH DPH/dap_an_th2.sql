#2.e
create view film_details as
select film.title, film.description, film.release_year, language.name, film.rating
from film inner join language on film.language_id = language.language_id;

#them 1
create view customer_product_quantity as 
select o.customerNumber, p.productCode, p.productName, sum(od.quantityOrdered)
from orders o
	inner join orderdetails od on od.orderNumber = o.orderNumber
    inner join products p on p.productCode = od.productCode
group by o.customerNumber, p.productCode;

#them 2
create view employee_sale_total as
select employees.employeeNumber, sum(od.quantityOrdered * od.priceEach)
from orders o
	inner join orderdetails od on od.orderNumber = o.orderNumber
    inner join customers on customers.customerNumber = o.customerNumber
    inner join employees on employees.employeeNumber = customers.salesRepEmployeeNumber
group by employees.employeeNumber;

#them 3
create view sale_per_month_year as
select year(orders.orderDate), month(orders.orderDate), sum(orderdetails.quantityOrdered)
from orderdetails inner join orders on orderdetails.orderNumber = orders.orderNumber
group by year(orders.orderDate), month(orders.orderDate);

#them 4
create view productline_sale as 
select products.productLine, sum(orderdetails.quantityOrdered)
from orderdetails
	inner join orders on orderdetails.orderNumber = orders.orderNumber
    inner join products on orderdetails.productCode = products.productCode
group by products.productLine;