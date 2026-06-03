CREATE OR REPLACE VIEW olap.vw_transaksi_detail AS
SELECT
    f.transaksi_key,
    f.source_order_item_id,
    f.source_order_id,
    f.produk_key,
    f.pelanggan_key,
    f.penjual_key,
    f.pembayaran_key,
    f.lokasi_key,
    f.jumlah_produk,
    f.harga_satuan,
    f.diskon,
    f.ongkir,
    f.total_harga,

    w.tanggal,
    TRIM(w.hari) AS hari,
    TRIM(w.bulan) AS bulan,
    w.tahun,
    w.minggu_ke,
    w.kuartal,

    p.nama_produk,
    p.brand,
    k.nama_kategori,
    k.jenis_kategori,

    pl.nama_pelanggan,
    pl.email AS email_pelanggan,
    pl.tipe_pelanggan,
    pl.status_akun,

    s.nama_toko,
    s.nama_penjual,
    s.level_penjual,
    s.rating_toko,

    pb.metode_pembayaran,
    pb.jenis_pembayaran,
    pb.provider,
    pb.status_pembayaran,

    l.alamat,
    l.nomor_rumah,
    l.kode_pos,
    kc.nama_kecamatan,
    kt.nama_kota,
    pr.nama_provinsi,
    pr.negara
FROM warehouse.fact_transaksi f
LEFT JOIN warehouse.dim_waktu w
    ON f.waktu_key = w.waktu_key
LEFT JOIN warehouse.dim_produk p
    ON f.produk_key = p.produk_key
LEFT JOIN warehouse.dim_kategori k
    ON p.kategori_key = k.kategori_key
LEFT JOIN warehouse.dim_pelanggan pl
    ON f.pelanggan_key = pl.pelanggan_key
LEFT JOIN warehouse.dim_penjual s
    ON f.penjual_key = s.penjual_key
LEFT JOIN warehouse.dim_pembayaran pb
    ON f.pembayaran_key = pb.pembayaran_key
LEFT JOIN warehouse.dim_lokasi l
    ON f.lokasi_key = l.lokasi_key
LEFT JOIN warehouse.dim_kecamatan kc
    ON l.kecamatan_key = kc.kecamatan_key
LEFT JOIN warehouse.dim_kota kt
    ON kc.kota_key = kt.kota_key
LEFT JOIN warehouse.dim_provinsi pr
    ON kt.provinsi_key = pr.provinsi_key;

CREATE MATERIALIZED VIEW olap.mart_sales_monthly AS
SELECT
    tahun,
    bulan,
    MIN(tanggal) AS first_transaction_date,
    COUNT(DISTINCT source_order_id) AS total_orders,
    COUNT(*) AS total_transaction_items,
    SUM(jumlah_produk) AS total_quantity,
    SUM(total_harga) AS total_sales,
    SUM(diskon) AS total_discount,
    AVG(total_harga) AS average_transaction_value
FROM olap.vw_transaksi_detail
GROUP BY tahun, bulan;

CREATE MATERIALIZED VIEW olap.mart_product_performance AS
SELECT
    nama_kategori,
    jenis_kategori,
    nama_produk,
    brand,
    COUNT(DISTINCT source_order_id) AS total_orders,
    COUNT(*) AS total_transaction_items,
    SUM(jumlah_produk) AS total_quantity,
    SUM(total_harga) AS total_sales,
    SUM(diskon) AS total_discount,
    AVG(harga_satuan) AS average_unit_price
FROM olap.vw_transaksi_detail
GROUP BY nama_kategori, jenis_kategori, nama_produk, brand;

CREATE MATERIALIZED VIEW olap.mart_seller_performance AS
SELECT
    nama_toko,
    nama_penjual,
    level_penjual,
    rating_toko,
    COUNT(DISTINCT source_order_id) AS total_orders,
    COUNT(*) AS total_transaction_items,
    SUM(jumlah_produk) AS total_quantity,
    SUM(total_harga) AS total_sales,
    AVG(total_harga) AS average_transaction_value
FROM olap.vw_transaksi_detail
GROUP BY nama_toko, nama_penjual, level_penjual, rating_toko;

CREATE MATERIALIZED VIEW olap.mart_payment_performance AS
SELECT
    metode_pembayaran,
    jenis_pembayaran,
    provider,
    status_pembayaran,
    COUNT(DISTINCT source_order_id) AS total_orders,
    COUNT(*) AS total_transaction_items,
    SUM(jumlah_produk) AS total_quantity,
    SUM(total_harga) AS total_sales
FROM olap.vw_transaksi_detail
GROUP BY metode_pembayaran, jenis_pembayaran, provider, status_pembayaran;

CREATE MATERIALIZED VIEW olap.mart_region_performance AS
SELECT
    nama_provinsi,
    nama_kota,
    nama_kecamatan,
    COUNT(DISTINCT source_order_id) AS total_orders,
    COUNT(*) AS total_transaction_items,
    SUM(jumlah_produk) AS total_quantity,
    SUM(total_harga) AS total_sales,
    AVG(total_harga) AS average_transaction_value
FROM olap.vw_transaksi_detail
GROUP BY nama_provinsi, nama_kota, nama_kecamatan;

CREATE INDEX idx_mart_sales_monthly_period
    ON olap.mart_sales_monthly (tahun, first_transaction_date);

CREATE INDEX idx_mart_product_performance_sales
    ON olap.mart_product_performance (total_sales);

CREATE INDEX idx_mart_seller_performance_sales
    ON olap.mart_seller_performance (total_sales);

CREATE INDEX idx_mart_payment_performance_method
    ON olap.mart_payment_performance (metode_pembayaran, provider);

CREATE INDEX idx_mart_region_performance_region
    ON olap.mart_region_performance (nama_provinsi, nama_kota);
