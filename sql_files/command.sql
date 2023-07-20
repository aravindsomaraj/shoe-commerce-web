CREATE TABLE shoe (
	shoe_id SERIAL PRIMARY KEY,
	shoe_name VARCHAR (225) NOT NULL,
	brand_id  INTEGER NOT NULL,
	shoe_type VARCHAR(225) NOT NULL,
	shoe_color VARCHAR(225) NOT NULL
);

CREATE TABLE brand (
  brand_id SERIAL PRIMARY KEY,
  brand_name VARCHAR(255) NOT NULL,
  brand_email VARCHAR(255) NOT NULL,
  brand_contact_number VARCHAR(20) NOT NULL
);

ALTER TABLE shoe
ADD CONSTRAINT fk_brand_id
FOREIGN KEY (brand_id)
REFERENCES brand (brand_id);

CREATE TABLE seller (
  seller_id SERIAL PRIMARY KEY,
  seller_name VARCHAR(255) NOT NULL,
  seller_email VARCHAR(255) NOT NULL,
  seller_contact_number VARCHAR(20) NOT NULL,
  seller_address VARCHAR(255) NOT NULL
);

CREATE TABLE shoe_type (
  shoe_type_id SERIAL PRIMARY KEY,
  shoe_type_name VARCHAR(255) NOT NULL UNIQUE
);

INSERT INTO shoe_type (shoe_type_name) VALUES ('Sneakers'), ('Boots'), ('Sandals'), ('Flats'), ('Heels');

ALTER TABLE shoe
ADD CONSTRAINT fk_shoe_type
FOREIGN KEY (shoe_type)
REFERENCES shoe_type (shoe_type_name);


CREATE TABLE inventory (
  inventory_id SERIAL PRIMARY KEY,
  shoe_id INTEGER NOT NULL,
  seller_id INTEGER NOT NULL,
  shoe_size INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  price NUMERIC(8, 2) NOT NULL,
  location VARCHAR(255) NOT NULL,
  status VARCHAR(20) NOT NULL,
  FOREIGN KEY (shoe_id) REFERENCES shoe(shoe_id),
  FOREIGN KEY (seller_id) REFERENCES seller(seller_id)
);

CREATE TABLE customer (
  customer_id SERIAL PRIMARY KEY,
  customer_name VARCHAR(255) NOT NULL,
  customer_email VARCHAR(255) NOT NULL,
  customer_addresses VARCHAR(255) NOT NULL,
  customer_contact_number VARCHAR(20) NOT NULL,
  payment_details VARCHAR(255) NOT NULL,
  cart_id INTEGER NOT NULL,
);

CREATE TABLE orders (
  order_id SERIAL PRIMARY KEY,
  inventory_id INTEGER NOT NULL,
  order_status VARCHAR(20) NOT NULL,
  dispatch_date DATE,
  delivery_date DATE,
  customer_id INTEGER NOT NULL,
  order_date DATE NOT NULL,
  order_number VARCHAR(50) NOT NULL,
  delivery_address VARCHAR(255) NOT NULL,
  FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id),
  FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE cart (
  customer_id INTEGER NOT NULL,
  inventory_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
  FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id),
  PRIMARY KEY (customer_id, inventory_id)
);

ALTER TABLE customer
ADD CONSTRAINT fk_cart_id
FOREIGN KEY (cart_id) REFERENCES Cart(cart_id);

CREATE TABLE Review (
  review_id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  review_text TEXT NOT NULL,
  stars_out_of_5 INTEGER NOT NULL,
  order_id INTEGER NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
  FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

CREATE TABLE Returns (
  return_id SERIAL PRIMARY KEY,
  return_date DATE NOT NULL,
  return_status VARCHAR(20) NOT NULL,
  order_id INTEGER NOT NULL,
  refund_status VARCHAR(20) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES Order(order_id)
);

-- Listing all tables

SELECT table_name
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
AND table_schema = 'public';

-- Entering DATA

INSERT INTO brand (brand_name, brand_email, brand_contact_number) 
VALUES ('Nike', 'info@nike.com', '1-800-344-6453'),
       ('Converse', 'customersupport@converse.com', '1-888-792-3307'),
       ('Adidas', 'contact@adidas.com', '1-800-982-9337'),
       ('Reebok',	'info@reebok.com',	'1-866-870-1743'),
       ('ASICS','info@asics.com'	,'1-800-678-9435');


INSERT INTO shoe (shoe_name, brand_id, shoe_type, shoe_color) 
VALUES ('Air Max', 1, 'Running', 'Black/White'),
       ('Chuck Taylor', 2, 'Casual', 'White'),
       ('Superstar', 3, 'Sneakers', 'Black/White/Gold'),
       ('Classic Leather',4,'Sneakers','Black'),
       ('Gel-Kayano 28',5,'Running Shoes','Blue/Orange');

ALTER TABLE customer
ADD CONSTRAINT uniq_email UNIQUE (customer_email);


INSERT INTO seller (seller_id,seller_name,seller_email,seller_contact_number,seller_address)
VALUES
('Sports Unlimited',	'sales@sportsunlimited.com'	,'1-800-693-6368',	'123 Main St, Anytown USA'),
('Shoe Palace'	,'sales@shoepalace.com',	'1-888-772-5223',	'456 Maple Ave, Anytown USA'),
('Foot Locker',	'sales@footlocker.com',	'1-800-991-6815'	,'789 Oak St, Anytown USA'),
('JD Sports'	,'sales@jdsports.com',	'1-877-977-4337',	'101 Elm St, Anytown USA'),
('Finish Line',	'sales@finishline.com',	'1-888-777-3949',	'555 Pine St, Anytown USA');

INSERT INTO customer (customer_name, customer_email, customer_addresses, customer_contact_number, payment_details, password)
VALUES 
  ('John Doe', 'johndoe@example.com', '123 Main St, Anytown USA', '555-1234', 'Credit card ending in 1234', 'password1'),
  ('Jane Smith', 'janesmith@example.com', '456 Elm St, Anytown USA', '555-5678', 'Credit card ending in 5678', 'password2'),
  ('Bob Johnson', 'bobjohnson@example.com', '789 Oak St, Anytown USA', '555-9012', 'Credit card ending in 9012', 'password3'),
  ('Sara Williams', 'sarawilliams@example.com', '246 Maple St, Anytown USA', '555-3456', 'Credit card ending in 3456', 'password4'),
  ('Mike Davis', 'mikedavis@example.com', '135 Walnut St, Anytown USA', '555-7890', 'Credit card ending in 7890', 'password5');


ALTER TABLE cart
ADD CONSTRAINT cart_inventory_id_fkey
FOREIGN KEY (inventory_id)
REFERENCES inventory (inventory_id)
ON DELETE CASCADE;
