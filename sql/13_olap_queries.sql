-- Refresh materialized view setelah warehouse diperbarui.
REFRESH MATERIALIZED VIEW olap.mart_sales_monthly;
REFRESH MATERIALIZED VIEW olap.mart_product_performance;
REFRESH MATERIALIZED VIEW olap.mart_seller_performance;
REFRESH MATERIALIZED VIEW olap.mart_payment_performance;
REFRESH MATERIALIZED VIEW olap.mart_region_performance;

-- Roll-up: penjualan tahunan dari mart bulanan.
SELECT
    tahun,
    SUM(total_orders) AS total_orders,
    SUM(total_quantity) AS total_quantity,
    SUM(total_sales) AS total_sales
FROM olap.mart_sales_monthly
GROUP BY tahun
ORDER BY tahun;

-- Drill-down: penjualan dari provinsi ke kota.
SELECT
    nama_provinsi,
    nama_kota,
    SUM(total_orders) AS total_orders,
    SUM(total_quantity) AS total_quantity,
    SUM(total_sales) AS total_sales
FROM olap.mart_region_performance
GROUP BY nama_provinsi, nama_kota
ORDER BY nama_provinsi, total_sales DESC;

-- Slice: hanya kategori Elektronik.
SELECT
    nama_produk,
    brand,
    SUM(total_quantity) AS total_quantity,
    SUM(total_sales) AS total_sales
FROM olap.mart_product_performance
WHERE nama_kategori = 'Elektronik'
GROUP BY nama_produk, brand
ORDER BY total_sales DESC;

-- Dice: kombinasi tahun, kategori, dan metode pembayaran.
SELECT
    tahun,
    bulan,
    nama_kategori,
    metode_pembayaran,
    COUNT(DISTINCT source_order_id) AS total_orders,
    SUM(jumlah_produk) AS total_quantity,
    SUM(total_harga) AS total_sales
FROM olap.vw_transaksi_detail
WHERE tahun = 2025
  AND nama_kategori IN ('Elektronik', 'Fashion Pria', 'Fashion Wanita')
  AND metode_pembayaran IN ('E-Wallet', 'Bank Transfer', 'COD')
GROUP BY tahun, bulan, nama_kategori, metode_pembayaran
ORDER BY tahun, bulan, total_sales DESC;

-- Pivot sederhana: metode pembayaran menjadi kolom.
SELECT
    tahun,
    bulan,
    SUM(CASE WHEN metode_pembayaran = 'E-Wallet' THEN total_harga ELSE 0 END) AS e_wallet_sales,
    SUM(CASE WHEN metode_pembayaran = 'Bank Transfer' THEN total_harga ELSE 0 END) AS bank_transfer_sales,
    SUM(CASE WHEN metode_pembayaran = 'COD' THEN total_harga ELSE 0 END) AS cod_sales,
    SUM(CASE WHEN metode_pembayaran = 'Kartu Kredit' THEN total_harga ELSE 0 END) AS kartu_kredit_sales,
    SUM(total_harga) AS total_sales
FROM olap.vw_transaksi_detail
GROUP BY tahun, bulan
ORDER BY tahun, bulan;

-- Top 10 produk berdasarkan revenue.
SELECT
    nama_produk,
    nama_kategori,
    SUM(total_sales) AS total_sales,
    SUM(total_quantity) AS total_quantity
FROM olap.mart_product_performance
GROUP BY nama_produk, nama_kategori
ORDER BY total_sales DESC
LIMIT 10;

-- Top 10 seller berdasarkan revenue.
SELECT
    nama_toko,
    nama_penjual,
    SUM(total_sales) AS total_sales,
    SUM(total_quantity) AS total_quantity
FROM olap.mart_seller_performance
GROUP BY nama_toko, nama_penjual
ORDER BY total_sales DESC
LIMIT 10;

-- Kontribusi penjualan per provinsi.
SELECT
    nama_provinsi,
    SUM(total_sales) AS total_sales,
    ROUND(
        SUM(total_sales) * 100.0 / NULLIF(SUM(SUM(total_sales)) OVER (), 0),
        2
    ) AS sales_percentage
FROM olap.mart_region_performance
GROUP BY nama_provinsi
ORDER BY total_sales DESC;

-- KPI ringkas untuk dashboard Power BI.
SELECT
    SUM(total_harga) AS total_revenue,
    COUNT(DISTINCT source_order_id) AS total_orders,
    COUNT(DISTINCT pelanggan_key) AS total_customers,
    AVG(total_harga) AS average_order_item_value
FROM olap.vw_transaksi_detail;
