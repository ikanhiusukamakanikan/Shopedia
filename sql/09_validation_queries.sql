SELECT COUNT(*) AS total_fact_rows
FROM warehouse.fact_transaksi;

SELECT
    SUM(jumlah_produk) AS total_quantity,
    SUM(total_harga) AS total_sales,
    SUM(diskon) AS total_discount
FROM warehouse.fact_transaksi;

SELECT
    SUM(CASE WHEN waktu_key IS NULL THEN 1 ELSE 0 END) AS null_waktu_key,
    SUM(CASE WHEN pelanggan_key IS NULL THEN 1 ELSE 0 END) AS null_pelanggan_key,
    SUM(CASE WHEN penjual_key IS NULL THEN 1 ELSE 0 END) AS null_penjual_key,
    SUM(CASE WHEN produk_key IS NULL THEN 1 ELSE 0 END) AS null_produk_key,
    SUM(CASE WHEN pembayaran_key IS NULL THEN 1 ELSE 0 END) AS null_pembayaran_key,
    SUM(CASE WHEN lokasi_key IS NULL THEN 1 ELSE 0 END) AS null_lokasi_key
FROM warehouse.fact_transaksi;

SELECT
    SUM(CASE WHEN jumlah_produk <= 0 THEN 1 ELSE 0 END) AS invalid_quantity,
    SUM(CASE WHEN harga_satuan < 0 THEN 1 ELSE 0 END) AS negative_unit_price,
    SUM(CASE WHEN total_harga < 0 THEN 1 ELSE 0 END) AS negative_line_total
FROM warehouse.fact_transaksi;

SELECT
    source_order_id,
    SUM(total_harga) AS calculated_items_total
FROM warehouse.fact_transaksi
GROUP BY source_order_id
HAVING SUM(total_harga) < 0;

