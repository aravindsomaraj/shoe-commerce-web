
CREATE OR REPLACE FUNCTION check_seller_login(
  in_email character varying,
  in_password character varying
)
RETURNS TABLE(status text, sellr_id integer) AS
$$
DECLARE
  id integer;
BEGIN
  SELECT seller_id INTO id
  FROM seller
  WHERE seller_email = in_email;

  IF NOT FOUND THEN
    RETURN QUERY SELECT 'invalid username'::text, 0::integer;
  ELSIF (SELECT password FROM seller WHERE seller_email = in_email) <> in_password THEN
    RETURN QUERY SELECT 'invalid password'::text , 0::integer;
  ELSE
    RETURN QUERY SELECT 'accept'::text, id::integer ;
  END IF;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM check_seller_login('sales@sportsunlimited.com',  'sporunli');

------------------------------------------------------------------------------------------------------------ 
CREATE OR REPLACE FUNCTION check_customer_login(
  in_email character varying,
  in_password character varying
)
RETURNS TABLE(status text, cust_id integer) AS
$$
DECLARE
  id integer;
BEGIN
  SELECT customer_id INTO id
  FROM customer
  WHERE customer_email = in_email;

  IF NOT FOUND THEN
    RETURN QUERY SELECT 'invalid username'::text, 0::integer;
  ELSIF (SELECT password FROM customer WHERE customer_email = in_email) <> in_password THEN
    RETURN QUERY SELECT 'invalid password'::text , 0::integer;
  ELSE
    RETURN QUERY SELECT 'accept'::text, id::integer ;
  END IF;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM check_customer_login('johndoe@example.com',  'password');

------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION add_to_cart(
    cust_id INTEGER, invent_id INTEGER
) RETURNS INTEGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM cart WHERE customer_id = cust_id and inventory_id = invent_id ) THEN 
        RETURN 0;
    END IF;

        INSERT INTO cart (customer_id,inventory_id, quantity) VALUES (cust_id,invent_id,1);
    RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE change_quantity_cart(
    cust_id INTEGER, invent_id INTEGER, quant INTEGER)
AS $$
BEGIN 
    -- INSERT INTO cart (customer_id,inventory_id, quantity) VALUES (cust_id,invent_id,1);
    UPDATE cart SET quantity = quant WHERE customer_id = cust_id AND inventory_id = invent_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE  

CREATE OR REPLACE FUNCTION check_inventory_exists(cust_id INTEGER, inve_id INTEGER)
RETURNS BOOLEAN AS
$$
BEGIN
    RETURN EXISTS(SELECT * FROM cart WHERE customer_id = cust_id AND inventory_id = inve_id);
END;
$$
LANGUAGE plpgsql;

----------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION insert_customer(
    name varchar(255),
    email varchar(255),
    addresses varchar(255),
    contact_number varchar(20),
    payment_details varchar(255),
    password varchar(225)
)
RETURNS integer AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM customer WHERE customer_email = email) THEN
        RETURN 2;
    END IF;

    INSERT INTO customer (
        customer_name,
        customer_email,
        customer_addresses,
        customer_contact_number,
        payment_details,
        password
    )
    VALUES (
        name,
        email,
        addresses,
        contact_number,
        payment_details,
        password
    );

    RETURN 1;
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_seller(
    name character varying(255),
    email character varying(255),
    contact_number character varying(20),
    address character varying(255),
    password character varying(225)
)
RETURNS integer AS $$
DECLARE
    email_exists boolean;
BEGIN
    -- Check if the email already exists
    SELECT EXISTS(SELECT 1 FROM seller WHERE seller_email = insert_seller.email)
    INTO email_exists;
    
    IF email_exists THEN
        -- Email already exists
        RETURN 2;
    ELSE
        -- Insert a new row into the seller table
        INSERT INTO seller (
            seller_name, seller_email, seller_contact_number, seller_address, password
        ) VALUES (
            name, 
            email,
            contact_number, 
            address,
            password
        );
        
        RETURN 1;
    END IF;
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_inventory(
    p_shoe_id integer, 
    p_seller_id integer, 
    p_shoe_size integer, 
    p_quantity integer, 
    p_price numeric, 
    p_location character varying(255), 
    p_status character varying(20)
) RETURNS integer AS $$

BEGIN
    IF NOT EXISTS (SELECT 1 FROM shoe WHERE shoe_id = p_shoe_id) THEN
        RETURN 2; -- if the shoe_id does not exist
    END IF;

    IF NOT EXISTS (SELECT 1 FROM seller WHERE seller_id = p_seller_id) THEN
        RETURN 3; -- if the seller id does not exist
    END IF;

    INSERT INTO inventory(shoe_id, seller_id, shoe_size, quantity, price, location, status)
    VALUES(p_shoe_id, p_seller_id, p_shoe_size, p_quantity, p_price, p_location, p_status);

    RETURN 1; 
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION change_quantity_inventory (
    inve_id integer,
    quant integer
) RETURNS integer AS $$

BEGIN
    IF NOT EXISTS (SELECT 1 FROM inventory WHERE inventory_id = inve_id) THEN 
        RETURN 0;
    END IF;

    UPDATE inventory SET quantity = quant WHERE inventory_id = inve_id;

    RETURN 1;
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION view_cart (
    cust_id integer
)
RETURNS TABLE  (p_invetory_id integer,p_quantity integer, 
p_shoe_name character varying, p_brand_name character varying, 
p_shoe_type character varying, p_price numeric ,img_url character varying) 
AS $$
BEGIN
    RETURN QUERY SELECT  
    inventory_id, 
    c.quantity,
    shoe_name,
    brand_name,
    shoe_type,
    price,
    image_url 
    FROM CART c join inventory using(inventory_id) 
    join shoe s using(shoe_id) 
    join brand using(brand_id)  WHERE customer_id = cust_id;
END;
$$ LANGUAGE plpgsql;

--------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION update_inventory(
    inve_id integer,
    p_shoe_id integer, 
    p_seller_id integer, 
    p_shoe_size integer, 
    p_quantity integer, 
    p_price numeric, 
    p_location character varying(255), 
    p_status character varying(20)
) RETURNS integer AS $$

BEGIN
    IF NOT EXISTS (SELECT 1 FROM shoe WHERE shoe_id = p_shoe_id) THEN
        RETURN 2; -- if the shoe_id does not exist
    END IF;

    IF NOT EXISTS (SELECT 1 FROM seller WHERE seller_id = p_seller_id) THEN
        RETURN 3; -- if the seller id does not exist
    END IF;

    IF NOT EXISTS (SELECT 1 FROM inventory WHERE inventory_id = inve_id) THEN 
        RETURN 0; -- if the inventory id does not exist
    END IF;

    UPDATE inventory SET
    shoe_id = p_shoe_id,
    shoe_size = p_shoe_size,
    quantity = p_quantity,
    price = p_price,
    location = p_location,
    status = p_status;

    RETURN 1; 
END;
$$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION update_order_status(
--     o_id integer, 
--     o_status varchar (50)
-- ) RETURNS integer AS $$

-------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_review(p_review_text TEXT, stars INT, p_order_id INT, p_customer_id INT)
RETURNS INTEGER
AS $$
BEGIN

    IF NOT EXISTS (SELECT 1 FROM orders WHERE order_id = p_order_id AND customer_id = p_customer_id) THEN
        RETURN 2; -- invalid order id
    END IF;

    IF EXISTS (SELECT 1 FROM review WHERE order_id = p_order_id) THEN
        RETURN 3; -- trying to review again
    END IF;
    
    INSERT INTO review (customer_id, review_text, stars_out_of_5, order_id)
    VALUES (p_customer_id, p_review_text, stars, p_order_id);

    RETURN 1;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM insert_review ('good',4,2,4);
SELECT * FROM insert_review ('delay',2,1,2);
SELECT * FROM insert_review ('ok!',4,8,4);


-------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION new_order(
    in_inventory_id integer,
    in_customer_id integer,
    in_order_number character varying(50),
    in_delivery_address character varying(255),
    in_quantity integer
)
RETURNS integer AS $$
BEGIN

    IF NOT EXISTS (SELECT 1 FROM customer WHERE customer_id = in_customer_id) THEN
        RETURN 2; --invalid customer id 
    END IF;

    IF NOT EXISTS (SELECT 1 FROM inventory WHERE inventory_id = in_inventory_id) THEN
        RETURN 3; --invalid inventory id 
    END IF;

    INSERT INTO orders (
        inventory_id,
        order_status,
        customer_id,
        order_date,
        order_number,
        delivery_address,
        quantity
    ) VALUES (
        in_inventory_id,
        'Order Placed',
        in_customer_id,
        NOW()::DATE,
        in_order_number,
        in_delivery_address,
        in_quantity
    );
    
    UPDATE inventory SET quantity = quantity-in_quantity
    WHERE inventory_id = in_inventory_id;   

    DELETE FROM cart WHERE customer_id = in_customer_id;

    RETURN 1;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM new_order (13,2,'1', '123 Main St, Anytown USA',1);
SELECT * FROM new_order (11,4,'1', '123 Main St, Sometown USA',1);
SELECT * FROM new_order (9,7,'1', '123 Main St, Thattown USA',1);
SELECT * FROM new_order (12,6,'1', '135 Walnut St, Anytown USA',1);


-------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION shoe_details (
    r_inventory_id integer
)
RETURNS TABLE (
    p_shoe_name character varying, p_brand_name character varying, p_shoe_type character varying,
    p_shoe_size integer, p_shoe_color character varying, p_price numeric, 
    p_status character varying, p_quantity integer, p_rating real, p_image_url character varying,
    p_shoe_id integer, p_inventory_id integer 
) AS $$
BEGIN

  RETURN QUERY SELECT shoe_name, brand_name, shoe_type, 
  shoe_size, shoe_color, 
  price, status, quantity,rating, image_url,
  shoe_id, inventory_id 
  from shoe join inventory using(shoe_id) join brand using(brand_id) WHERE inventory_id = r_inventory_id;

END;
$$ LANGUAGE plpgsql;


--------------------------------------------------------------------------------------------------------

-- revove from cart

CREATE OR REPLACE FUNCTION remove_from_cart (
    p_inventory_id integer,
    p_customer_id integer
)
RETURNS INTEGER AS $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM cart WHERE inventory_id = p_inventory_id AND customer_id = p_customer_id) THEN 
        RETURN 0;
    END IF ;

    DELETE FROM orders WHERE  inventory_id = p_inventory_id AND customer_id = p_customer_id;
    
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION view_seller_inventory (
    seller_idz integer
)
RETURNS TABLE  (p_brand_name character varying(255), 
                p_shoe_name character varying(255), 
                p_shoe_type character varying(255),
                p_price numeric,
                p_rating real,
                p_image_url character varying(255),
                p_shoe_id integer,
                p_inventory_id integer,
                p_seller_id integer,
                p_quantity integer
                ) 
AS $$
BEGIN
    
    RETURN QUERY SELECT brand_name, shoe_name, shoe_type, price, rating, 
    image_url, shoe_id, inventory_id , seller_id, quantity
    FROM inventory natural join shoe natural join brand WHERE seller_id = seller_idz;

END;
$$ LANGUAGE plpgsql;


-------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION remove_inventory (
    p_inventory_id integer,
    p_seller_id integer
)
RETURNS INTEGER AS $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inventory WHERE inventory_id = p_inventory_id AND seller_id = p_seller_id) THEN 
        RETURN 0;
    END IF ;

    DELETE FROM inventory WHERE inventory_id = p_inventory_id AND seller_id = p_seller_id;
    
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION purchase_cart (
    p_customer_id integer
)
RETURNS INTEGER AS $$
DECLARE 
    no_of_orders integer;
    d_address varchar (225);
    inv record;
BEGIN 

SELECT max(order_number::integer) INTO no_of_orders FROM orders WHERE customer_id = p_customer_id;
SELECT customer_addresses INTO d_address FROM customer WHERE customer_id = p_customer_id;

IF no_of_orders IS NULL THEN
    no_of_orders := 0;
END IF;

no_of_orders := no_of_orders + 1;

FOR inv IN SELECT inventory_id,quantity FROM cart WHERE customer_id = p_customer_id LOOP
    PERFORM * FROM new_order (inv.inventory_id, p_customer_id, no_of_orders::varchar,d_address, inv.quantity);
END LOOP;

RETURN 1;

END;
$$ LANGUAGE plpgsql;