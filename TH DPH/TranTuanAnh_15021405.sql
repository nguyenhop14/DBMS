/* Bai 2  
 Tại 1 thời điềm 1 inventory chỉ được mượn bởi 1 người và mỗi lần mượn có mã rental riêng
 Khi 1 phim bị mượn thì sẽ thấy trong rental id đó 
 khi bị trả thì retal_date và rental_return thay đổi */

alter table inventory
add is_available tinyint(1)

DELIMITER $$
CREATE TRIGGER Muontra
AFTER UPDATE ON rental
FOR EACH ROW
BEGIN
	IF NEW.rental_date= now()
    THEN
		UPDATE inventory SET is_available = true WHERE inventory_id = old.inventory_id;
	ELSE IF NEW.return_date= now() then
	    UPDATE inventory SET is_available = true WHERE inventory_id = old.inventory_id;
	END IF;
    END IF;
END$$
DELIMITER ;

/* Bai tap trong Slide
Bai 1 */
create table Note(
OrderNumber int primary key,
ProductCode varchar(15),
Note varchar(255)
) 

DELIMITER $$
CREATE TRIGGER A_insert_orderdetails 
    AFTER INSERT ON orderdetails
    FOR EACH ROW 
BEGIN
    DECLARE gia decimal(10,2);
    select buyPrice into gia from products where productCode=new.productCode;
    if  gia > new.priceEach
    then
		insert into note values(new.orderNumber,new.productCode,'Ban lo');
    end if;
END$$
DELIMITER ;


/*Bai 2*/
DELIMITER $$
CREATE TRIGGER slhang2
    BEFORE INSERT ON orderdetails
    FOR EACH ROW 
BEGIN
    if new.quantityOrdered > (select quantityInStock from products where productCode = new.productCode)
    then 
    signal sqlstate '42001' set message_text='Hang khong du de cung cap';
    end if;
END$$
DELIMITER ;

/*Bai 3*/
DELIMITER $$
CREATE TRIGGER before_delete_orderdetails
	BEFORE DELETE ON orders
    FOR EACH ROW 
     BEGIN 
     DECLARE gia varchar(255);
     select status into gia from orders where orderNumber = old.orderNumber;
     if gia = "Shipped"
	 then
        SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Khong xoa don hang da giao xong';
    end if;
END$$
DELIMITER ;

