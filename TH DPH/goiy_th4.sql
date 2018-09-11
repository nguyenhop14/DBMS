DELIMITER $$
CREATE TRIGGER before_insert_orderdetails 
    AFTER INSERT ON orderdetails
    FOR EACH ROW 
BEGIN
    DECLARE order_value decimal(10,2);
    declare km_count int;
    
    select sum(quantityOrdered * priceEach) into order_value from orderdetails where orderNumber = NEW.orderNumber;
    
    if order_value > 65000 then
		select count(*) into km_count from khuyen_mai where mahoadon = NEW.orderNumber;
        if km_count > 0 then
			update khuyen_mai set sotien = order_value where mahoadon = NEW.orderNumber;
		else
			INSERT INTO khuyen_mai values(NEW.orderNumber, order_value);
		end if;
    end if;
END$$
DELIMITER ;