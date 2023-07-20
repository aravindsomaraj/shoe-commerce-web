CREATE INDEX idx_inventory_price_btree ON inventory USING BTREE(price);

CREATE INDEX idx_brand_name_hash ON brand USING HASH(brand_name);

CREATE INDEX idx_shoe_type_hash ON shoe USING HASH(shoe_type);

CREATE INDEX idx_seller_id_hash ON inventory USING HASH (seller_id);

CREATE INDEX trgm_shoe_name ON shoe USING gin (shoe_name gin_trgm_ops);
CREATE INDEX trgm_brand_name ON brand USING gin (brand_name gin_trgm_ops);
CREATE INDEX trgm_shoe_type ON shoe USING gin (shoe_type gin_trgm_ops);