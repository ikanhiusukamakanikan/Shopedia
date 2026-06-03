DROP TABLE IF EXISTS staging.payments_clean;
DROP TABLE IF EXISTS staging.order_items_clean;
DROP TABLE IF EXISTS staging.orders_clean;
DROP TABLE IF EXISTS staging.addresses_clean;
DROP TABLE IF EXISTS staging.areas_clean;
DROP TABLE IF EXISTS staging.products_clean;
DROP TABLE IF EXISTS staging.product_categories_clean;
DROP TABLE IF EXISTS staging.sellers_clean;
DROP TABLE IF EXISTS staging.customers_clean;

-- ID dari raw CSV disimpan sebagai source/natural ID, tetapi tidak dijadikan
-- primary key karena data raw dapat berisi ID yang duplikat.
-- Setiap row staging mendapat surrogate key baru dari GENERATED IDENTITY.

CREATE TABLE staging.customers_clean (
    customer_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id text,
    customer_name text,
    email text,
    phone_number text,
    registered_at date,
    customer_type text,
    city text,
    province text,
    account_status text
);

CREATE TABLE staging.sellers_clean (
    seller_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    seller_id text,
    store_name text,
    owner_name text,
    joined_at date,
    store_rating numeric(3, 2),
    seller_level text,
    city text,
    province text,
    store_status text
);

CREATE TABLE staging.product_categories_clean (
    category_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id text,
    category_name text,
    category_group text,
    description text
);

CREATE TABLE staging.products_clean (
    product_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id text,
    product_name text,
    brand text,
    base_price numeric(14, 2),
    weight_kg numeric(10, 3),
    product_status text,
    category_id text
);

CREATE TABLE staging.areas_clean (
    area_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    area_id text,
    district text,
    city text,
    province text,
    country text
);

CREATE TABLE staging.addresses_clean (
    address_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    address_id text,
    address_line text,
    house_number text,
    postal_code text,
    area_id text,
    district text,
    city text,
    province text
);

CREATE TABLE staging.orders_clean (
    order_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id text,
    order_datetime timestamp,
    order_date date,
    customer_id text,
    seller_id text,
    shipping_address_id text,
    order_status text,
    items_total numeric(14, 2),
    shipping_fee numeric(14, 2),
    grand_total numeric(14, 2)
);

CREATE TABLE staging.order_items_clean (
    order_item_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_item_id text,
    order_id text,
    product_id text,
    product_name text,
    seller_id text,
    quantity integer,
    unit_price numeric(14, 2),
    discount_amount numeric(14, 2),
    line_total numeric(14, 2)
);

CREATE TABLE staging.payments_clean (
    payment_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    payment_id text,
    order_id text,
    payment_method text,
    payment_type text,
    provider text,
    payment_status text,
    paid_at date,
    payment_amount numeric(14, 2)
);
