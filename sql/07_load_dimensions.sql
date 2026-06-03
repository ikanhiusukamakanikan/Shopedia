TRUNCATE TABLE
    warehouse.fact_transaksi,
    warehouse.dim_lokasi,
    warehouse.dim_pelanggan,
    warehouse.dim_penjual,
    warehouse.dim_produk,
    warehouse.dim_kecamatan,
    warehouse.dim_kota,
    warehouse.dim_provinsi,
    warehouse.dim_pembayaran,
    warehouse.dim_kategori,
    warehouse.dim_waktu
RESTART IDENTITY;

INSERT INTO warehouse.dim_waktu (tanggal, hari, bulan, tahun, minggu_ke, kuartal)
SELECT DISTINCT
    d::date AS tanggal,
    TO_CHAR(d, 'Day') AS hari,
    TO_CHAR(d, 'Month') AS bulan,
    EXTRACT(YEAR FROM d)::integer AS tahun,
    EXTRACT(WEEK FROM d)::integer AS minggu_ke,
    EXTRACT(QUARTER FROM d)::integer AS kuartal
FROM (
    SELECT order_date AS d FROM staging.orders_clean WHERE order_date IS NOT NULL
    UNION
    SELECT paid_at AS d FROM staging.payments_clean WHERE paid_at IS NOT NULL
) dates;

INSERT INTO warehouse.dim_kategori (source_category_id, nama_kategori, jenis_kategori, deskripsi_kategori)
SELECT category_id, category_name, category_group, description
FROM (
    SELECT
        pc.*,
        ROW_NUMBER() OVER (
            PARTITION BY pc.category_id
            ORDER BY pc.category_key
        ) AS rn
    FROM staging.product_categories_clean pc
    WHERE pc.category_id IS NOT NULL
) dedup
WHERE rn = 1;

INSERT INTO warehouse.dim_pembayaran (metode_pembayaran, jenis_pembayaran, provider, status_pembayaran)
SELECT DISTINCT payment_method, payment_type, provider, payment_status
FROM staging.payments_clean;

INSERT INTO warehouse.dim_provinsi (nama_provinsi, negara)
SELECT DISTINCT province, country
FROM staging.areas_clean
WHERE province IS NOT NULL
UNION
SELECT DISTINCT province, 'Indonesia'
FROM staging.customers_clean
WHERE province IS NOT NULL
UNION
SELECT DISTINCT province, 'Indonesia'
FROM staging.sellers_clean
WHERE province IS NOT NULL;

INSERT INTO warehouse.dim_kota (nama_kota, provinsi_key)
SELECT DISTINCT src.city, p.provinsi_key
FROM (
    SELECT city, province, country FROM staging.areas_clean
    UNION
    SELECT city, province, 'Indonesia' FROM staging.customers_clean
    UNION
    SELECT city, province, 'Indonesia' FROM staging.sellers_clean
) src
JOIN warehouse.dim_provinsi p
    ON p.nama_provinsi = src.province
    AND p.negara = src.country
WHERE src.city IS NOT NULL;

INSERT INTO warehouse.dim_kecamatan (nama_kecamatan, kota_key)
SELECT DISTINCT a.district, k.kota_key
FROM staging.areas_clean a
JOIN warehouse.dim_provinsi p
    ON p.nama_provinsi = a.province
    AND p.negara = a.country
JOIN warehouse.dim_kota k
    ON k.nama_kota = a.city
    AND k.provinsi_key = p.provinsi_key
WHERE a.district IS NOT NULL;

INSERT INTO warehouse.dim_lokasi (source_address_id, alamat, nomor_rumah, kode_pos, kecamatan_key)
SELECT
    a.address_id,
    a.address_line,
    a.house_number,
    a.postal_code,
    kec.kecamatan_key
FROM (
    SELECT
        ac.*,
        ROW_NUMBER() OVER (
            PARTITION BY ac.address_id
            ORDER BY ac.address_key
        ) AS rn
    FROM staging.addresses_clean ac
    WHERE ac.address_id IS NOT NULL
) a
JOIN warehouse.dim_provinsi p
    ON p.nama_provinsi = a.province
    AND p.negara = 'Indonesia'
JOIN warehouse.dim_kota k
    ON k.nama_kota = a.city
    AND k.provinsi_key = p.provinsi_key
JOIN warehouse.dim_kecamatan kec
    ON kec.nama_kecamatan = a.district
    AND kec.kota_key = k.kota_key
WHERE a.rn = 1;

INSERT INTO warehouse.dim_pelanggan (
    source_customer_id,
    nama_pelanggan,
    email,
    nomor_telepon,
    tanggal_daftar,
    tipe_pelanggan,
    status_akun,
    kota_key
)
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    c.phone_number,
    c.registered_at,
    c.customer_type,
    c.account_status,
    k.kota_key
FROM (
    SELECT
        cc.*,
        ROW_NUMBER() OVER (
            PARTITION BY cc.customer_id
            ORDER BY cc.customer_key
        ) AS rn
    FROM staging.customers_clean cc
    WHERE cc.customer_id IS NOT NULL
) c
LEFT JOIN warehouse.dim_provinsi p
    ON p.nama_provinsi = c.province
    AND p.negara = 'Indonesia'
LEFT JOIN warehouse.dim_kota k
    ON k.nama_kota = c.city
    AND k.provinsi_key = p.provinsi_key
WHERE c.rn = 1;

INSERT INTO warehouse.dim_penjual (
    source_seller_id,
    nama_toko,
    nama_penjual,
    tanggal_gabung,
    rating_toko,
    level_penjual,
    status_toko,
    kota_key
)
SELECT
    s.seller_id,
    s.store_name,
    s.owner_name,
    s.joined_at,
    s.store_rating,
    s.seller_level,
    s.store_status,
    k.kota_key
FROM (
    SELECT
        sc.*,
        ROW_NUMBER() OVER (
            PARTITION BY sc.seller_id
            ORDER BY sc.seller_key
        ) AS rn
    FROM staging.sellers_clean sc
    WHERE sc.seller_id IS NOT NULL
) s
LEFT JOIN warehouse.dim_provinsi p
    ON p.nama_provinsi = s.province
    AND p.negara = 'Indonesia'
LEFT JOIN warehouse.dim_kota k
    ON k.nama_kota = s.city
    AND k.provinsi_key = p.provinsi_key
WHERE s.rn = 1;

INSERT INTO warehouse.dim_produk (
    source_product_id,
    nama_produk,
    brand,
    harga,
    berat_produk,
    status_produk,
    kategori_key
)
SELECT
    p.product_id,
    p.product_name,
    p.brand,
    p.base_price,
    p.weight_kg,
    p.product_status,
    k.kategori_key
FROM (
    SELECT
        pc.*,
        ROW_NUMBER() OVER (
            PARTITION BY pc.product_id
            ORDER BY pc.product_key
        ) AS rn
    FROM staging.products_clean pc
    WHERE pc.product_id IS NOT NULL
) p
LEFT JOIN warehouse.dim_kategori k
    ON k.source_category_id = p.category_id
WHERE p.rn = 1;
