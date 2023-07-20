CREATE VIEW SHOE_LIST AS 
SELECT brand_name, shoe_name, shoe_type, price, rating, 
image_url, shoe_id, inventory_id 
FROM inventory natural join shoe natural join brand ;

CREATE VIEW SHOE_NAMES AS
SELECT shoe_name, shoe_id from shoe;

CREATE VIEW SHOE_BRANDS AS
SELECT brand_name from brand;

CREATE VIEW SHOE_TYPES AS
SELECT shoe_type_name FROM shoe_type; 