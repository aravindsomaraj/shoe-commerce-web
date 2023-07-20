CREATE ROLE customer
LOGIN 
PASSWORD 'newton_issac'; 

CREATE ROLE admin 
SUPERUSER 
LOGIN 
PASSWORD 'not_an_admin';

CREATE ROLE seller
LOGIN 
PASSWORD 'dont_have_any_idea';

GRANT select 
ON customer, shoe_list, orders, review, returns
TO customer;

GRANT insert,delete, update 
ON customer, cart, orders
TO customer;

GRANT select 
ON shoe_list, shoe_type, shoe, 
seller, returns, orders, 
inventory, brand 
TO SELLER ;

GRANT insert,delete, update 
ON orders, returns  
TO seller;

GRANT EXECUTE ON FUNCTION update_inventory(
    inve_id integer,
    p_shoe_id integer, 
    p_seller_id integer, 
    p_shoe_size integer, 
    p_quantity integer, 
    p_price numeric, 
    p_location character varying(255), 
    p_status character varying(20)
)
TO seller;

GRANT EXECUTE ON FUNCTION insert_review (
    p_review_text TEXT, 
    stars INT, 
    p_order_id INT, 
    p_customer_id INT
)
TO customer;

GRANT EXECUTE ON FUNCTION list_cart (
    cust_id integer
)
TO customer;

GRANT EXECUTE ON FUNCTION check_customer_login(
  in_email character varying,
  in_password character varying
)
TO customer;


GRANT EXECUTE ON FUNCTION 
shoe_details (
    r_inventory_id integer
)
TO customer, seller;

GRANT EXECUTE ON 
FUNCTION view_cart (
    cust_id integer
)
TO customer;

GRANT EXECUTE ON FUNCTION add_to_cart(
    cust_id INTEGER, invent_id INTEGER
)
TO customer;


GRANT EXECUTE ON FUNCTION insert_inventory(
    p_shoe_id integer, 
    p_seller_id integer, 
    p_shoe_size integer, 
    p_quantity integer, 
    p_price numeric, 
    p_location character varying(255), 
    p_status character varying(20)
) to seller;


GRANT EXECUTE ON FUNCTION purchase_cart (
    p_customer_id integer
) to customer;