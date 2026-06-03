DROP TABLE IF EXISTS raw.payments;
DROP TABLE IF EXISTS raw.order_items;
DROP TABLE IF EXISTS raw.orders;
DROP TABLE IF EXISTS raw.addresses;
DROP TABLE IF EXISTS raw.areas;
DROP TABLE IF EXISTS raw.products;
DROP TABLE IF EXISTS raw.product_categories;
DROP TABLE IF EXISTS raw.sellers;
DROP TABLE IF EXISTS raw.customers;

CREATE TABLE raw.customers (
    customer_id text,
    customer_name text,
    email text,
    phone_number text,
    registered_at text,
    customer_type text,
    city text,
    province text,
    account_status text
);

CREATE TABLE raw.sellers (
    seller_id text,
    store_name text,
    owner_name text,
    joined_at text,
    store_rating text,
    seller_level text,
    city text,
    province text,
    store_status text
);

CREATE TABLE raw.product_categories (
    category_id text,
    category_name text,
    category_group text,
    description text
);

CREATE TABLE raw.products (
    product_id text,
    product_name text,
    brand text,
    base_price text,
    weight_kg text,
    product_status text,
    category_id text
);

CREATE TABLE raw.areas (
    area_id text,
    district text,
    city text,
    province text,
    country text
);

CREATE TABLE raw.addresses (
    address_id text,
    address_line text,
    house_number text,
    postal_code text,
    area_id text,
    district text,
    city text,
    province text
);

CREATE TABLE raw.orders (
    order_id text,
    order_date text,
    order_time text,
    customer_id text,
    seller_id text,
    shipping_address_id text,
    order_status text,
    items_total text,
    shipping_fee text,
    grand_total text
);

CREATE TABLE raw.order_items (
    order_item_id text,
    order_id text,
    product_id text,
    product_name text,
    seller_id text,
    quantity text,
    unit_price text,
    discount_amount text,
    line_total text
);

CREATE TABLE raw.payments (
    payment_id text,
    order_id text,
    payment_method text,
    payment_type text,
    provider text,
    payment_status text,
    paid_at text,
    payment_amount text
);

