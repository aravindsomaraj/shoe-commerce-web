CREATE OR REPLACE FUNCTION inventory_out_of_stock() 
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantity = 0 THEN
        NEW.status := 'Out of Stock';
    END IF;

    IF NEW.quantity > 0 THEN
        NEW.status := 'In Stock';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER inventory_out_of_stock_trigger 
BEFORE INSERT OR UPDATE ON inventory 
FOR EACH ROW 
EXECUTE FUNCTION inventory_out_of_stock();

------------------------------------------------------------------

CREATE OR REPLACE FUNCTION update_rating() 
RETURNS TRIGGER AS $$
DECLARE
    p_rating real;
    p_invetory_id integer;
BEGIN
    
    IF TG_OP = 'DELETE' THEN
        SELECT inventory_id INTO p_invetory_id
        FROM orders WHERE order_id = OLD.order_id;
    ELSE 
        SELECT inventory_id INTO p_invetory_id
        FROM orders WHERE order_id = NEW.order_id;
    END IF ;
        SELECT avg(stars_out_of_5) INTO p_rating
        FROM review join orders using(order_id) 
        WHERE inventory_id = p_invetory_id; 

        UPDATE inventory SET rating = p_rating 
        WHERE inventory_id = p_invetory_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_rating_trigger 
AFTER INSERT OR UPDATE OR DELETE ON review 
FOR EACH ROW 
EXECUTE FUNCTION update_rating();