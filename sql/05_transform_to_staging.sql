CREATE OR REPLACE FUNCTION staging.safe_to_date(value text)
RETURNS date
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    cleaned text;
    parsed date;
BEGIN
    cleaned := NULLIF(TRIM(value), '');

    IF cleaned IS NULL THEN
        RETURN NULL;
    END IF;

    BEGIN
        IF cleaned ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN
            parsed := TO_DATE(cleaned, 'YYYY-MM-DD');
            IF TO_CHAR(parsed, 'YYYY-MM-DD') = cleaned THEN
                RETURN parsed;
            END IF;
        ELSIF cleaned ~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN
            parsed := TO_DATE(cleaned, 'DD-MM-YYYY');
            IF TO_CHAR(parsed, 'DD-MM-YYYY') = cleaned THEN
                RETURN parsed;
            END IF;
        ELSIF cleaned ~ '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' THEN
            parsed := TO_DATE(cleaned, 'YYYY/MM/DD');
            IF TO_CHAR(parsed, 'YYYY/MM/DD') = cleaned THEN
                RETURN parsed;
            END IF;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RETURN NULL;
    END;

    RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION staging.safe_to_time(value text)
RETURNS time
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    cleaned text;
BEGIN
    cleaned := NULLIF(TRIM(value), '');

    IF cleaned IS NULL THEN
        RETURN NULL;
    END IF;

    BEGIN
        RETURN cleaned::time;
    EXCEPTION WHEN OTHERS THEN
        RETURN NULL;
    END;
END;
$$;

TRUNCATE TABLE
    staging.payments_clean,
    staging.order_items_clean,
    staging.orders_clean,
    staging.addresses_clean,
    staging.areas_clean,
    staging.products_clean,
    staging.product_categories_clean,
    staging.sellers_clean,
    staging.customers_clean
RESTART IDENTITY;

INSERT INTO staging.customers_clean (
    customer_key,
    customer_id,
    customer_name,
    email,
    phone_number,
    registered_at,
    customer_type,
    city,
    province,
    account_status
)
OVERRIDING SYSTEM VALUE
SELECT
    ROW_NUMBER() OVER (),
    NULLIF(TRIM(customer_id), ''),
    NULLIF(TRIM(customer_name), ''),
    COALESCE(NULLIF(LOWER(TRIM(email)), ''), 'unknown'),
    COALESCE(NULLIF(TRIM(phone_number), ''), 'unknown'),
    staging.safe_to_date(registered_at),
    NULLIF(TRIM(customer_type), ''),
    NULLIF(TRIM(city), ''),
    NULLIF(TRIM(province), ''),
    CASE
        WHEN LOWER(TRIM(account_status)) IN ('aktif', 'active') THEN 'Active'
        WHEN LOWER(TRIM(account_status)) IN ('nonaktif', 'inactive', 'blocked') THEN 'Inactive'
        ELSE COALESCE(NULLIF(TRIM(account_status), ''), 'Unknown')
    END
FROM raw.customers;

INSERT INTO staging.sellers_clean (
    seller_key,
    seller_id,
    store_name,
    owner_name,
    joined_at,
    store_rating,
    seller_level,
    city,
    province,
    store_status
)
OVERRIDING SYSTEM VALUE
SELECT
    ROW_NUMBER() OVER (),
    NULLIF(TRIM(seller_id), ''),
    NULLIF(TRIM(store_name), ''),
    NULLIF(TRIM(owner_name), ''),
    staging.safe_to_date(joined_at),
    NULLIF(store_rating, '')::numeric(3, 2),
    NULLIF(TRIM(seller_level), ''),
    NULLIF(TRIM(city), ''),
    NULLIF(TRIM(province), ''),
    CASE
        WHEN LOWER(TRIM(store_status)) IN ('aktif', 'active') THEN 'Active'
        WHEN LOWER(TRIM(store_status)) IN ('nonaktif', 'inactive', 'blocked') THEN 'Inactive'
        ELSE COALESCE(NULLIF(TRIM(store_status), ''), 'Unknown')
    END
FROM raw.sellers;

INSERT INTO staging.product_categories_clean (
    category_key,
    category_id,
    category_name,
    category_group,
    description
)
OVERRIDING SYSTEM VALUE
SELECT
    ROW_NUMBER() OVER (),
    NULLIF(TRIM(category_id), ''),
    NULLIF(TRIM(category_name), ''),
    NULLIF(TRIM(category_group), ''),
    NULLIF(TRIM(description), '')
FROM raw.product_categories;

INSERT INTO staging.products_clean (
    product_key,
    product_id,
    product_name,
    brand,
    base_price,
    weight_kg,
    product_status,
    category_id
)
OVERRIDING SYSTEM VALUE
SELECT
    ROW_NUMBER() OVER (),
    NULLIF(TRIM(product_id), ''),
    NULLIF(TRIM(product_name), ''),
    NULLIF(TRIM(brand), ''),
    NULLIF(base_price, '')::numeric(14, 2),
    NULLIF(weight_kg, '')::numeric(10, 3),
    CASE
        WHEN LOWER(TRIM(product_status)) IN ('aktif', 'active') THEN 'Active'
        WHEN LOWER(TRIM(product_status)) IN ('nonaktif', 'inactive', 'blocked') THEN 'Inactive'
        ELSE COALESCE(NULLIF(TRIM(product_status), ''), 'Unknown')
    END,
    NULLIF(TRIM(category_id), '')
FROM raw.products;

INSERT INTO staging.areas_clean (
    area_key,
    area_id,
    district,
    city,
    province,
    country
)
OVERRIDING SYSTEM VALUE
SELECT
    ROW_NUMBER() OVER (),
    NULLIF(TRIM(area_id), ''),
    NULLIF(TRIM(district), ''),
    NULLIF(TRIM(city), ''),
    NULLIF(TRIM(province), ''),
    COALESCE(NULLIF(TRIM(country), ''), 'Indonesia')
FROM raw.areas;

INSERT INTO staging.addresses_clean (
    address_key,
    address_id,
    address_line,
    house_number,
    postal_code,
    area_id,
    district,
    city,
    province
)
OVERRIDING SYSTEM VALUE
SELECT
    ROW_NUMBER() OVER (),
    NULLIF(TRIM(address_id), ''),
    NULLIF(TRIM(address_line), ''),
    NULLIF(TRIM(house_number), ''),
    NULLIF(TRIM(postal_code), ''),
    NULLIF(TRIM(area_id), ''),
    NULLIF(TRIM(district), ''),
    NULLIF(TRIM(city), ''),
    NULLIF(TRIM(province), '')
FROM raw.addresses;

INSERT INTO staging.orders_clean (
    order_key,
    order_id,
    order_datetime,
    order_date,
    customer_id,
    seller_id,
    shipping_address_id,
    order_status,
    items_total,
    shipping_fee,
    grand_total
)
OVERRIDING SYSTEM VALUE
SELECT
    ROW_NUMBER() OVER (),
    NULLIF(TRIM(order_id), ''),
    CASE
        WHEN staging.safe_to_date(order_date) IS NOT NULL
         AND staging.safe_to_time(order_time) IS NOT NULL
        THEN staging.safe_to_date(order_date) + staging.safe_to_time(order_time)
        ELSE NULL
    END,
    staging.safe_to_date(order_date),
    NULLIF(TRIM(customer_id), ''),
    NULLIF(TRIM(seller_id), ''),
    NULLIF(TRIM(shipping_address_id), ''),
    CASE
        WHEN LOWER(TRIM(order_status)) IN ('completed', 'selesai') THEN 'Completed'
        WHEN LOWER(TRIM(order_status)) IN ('cancelled', 'canceled', 'dibatalkan') THEN 'Cancelled'
        ELSE COALESCE(NULLIF(TRIM(order_status), ''), 'Unknown')
    END,
    NULLIF(items_total, '')::numeric(14, 2),
    NULLIF(shipping_fee, '')::numeric(14, 2),
    NULLIF(grand_total, '')::numeric(14, 2)
FROM raw.orders;

INSERT INTO staging.order_items_clean (
    order_item_key,
    order_item_id,
    order_id,
    product_id,
    product_name,
    seller_id,
    quantity,
    unit_price,
    discount_amount,
    line_total
)
OVERRIDING SYSTEM VALUE
SELECT
    ROW_NUMBER() OVER (),
    NULLIF(TRIM(order_item_id), ''),
    NULLIF(TRIM(order_id), ''),
    NULLIF(TRIM(product_id), ''),
    NULLIF(TRIM(product_name), ''),
    NULLIF(TRIM(seller_id), ''),
    NULLIF(quantity, '')::integer,
    NULLIF(unit_price, '')::numeric(14, 2),
    NULLIF(discount_amount, '')::numeric(14, 2),
    NULLIF(line_total, '')::numeric(14, 2)
FROM raw.order_items;

INSERT INTO staging.payments_clean (
    payment_key,
    payment_id,
    order_id,
    payment_method,
    payment_type,
    provider,
    payment_status,
    paid_at,
    payment_amount
)
OVERRIDING SYSTEM VALUE
SELECT
    ROW_NUMBER() OVER (),
    NULLIF(TRIM(payment_id), ''),
    NULLIF(TRIM(order_id), ''),
    NULLIF(TRIM(payment_method), ''),
    NULLIF(TRIM(payment_type), ''),
    COALESCE(NULLIF(TRIM(provider), ''), 'Not Applicable'),
    CASE
        WHEN LOWER(TRIM(payment_status)) IN ('berhasil', 'sukses', 'success') THEN 'Success'
        WHEN LOWER(TRIM(payment_status)) IN ('gagal', 'failed') THEN 'Failed'
        ELSE COALESCE(NULLIF(TRIM(payment_status), ''), 'Unknown')
    END,
    staging.safe_to_date(paid_at),
    NULLIF(payment_amount, '')::numeric(14, 2)
FROM raw.payments;
