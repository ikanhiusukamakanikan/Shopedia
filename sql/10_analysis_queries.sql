SELECT
    k.nama_kategori,
    COUNT(*) AS total_transaction_items,
    SUM(f.jumlah_produk) AS total_quantity,
    SUM(f.total_harga) AS total_sales
FROM warehouse.fact_transaksi f
LEFT JOIN warehouse.dim_produk p
    ON f.produk_key = p.produk_key
LEFT JOIN warehouse.dim_kategori k
    ON p.kategori_key = k.kategori_key
GROUP BY k.nama_kategori
ORDER BY total_sales DESC;

SELECT
    w.tahun,
    w.bulan,
    COUNT(*) AS total_transaction_items,
    SUM(f.total_harga) AS total_sales
FROM warehouse.fact_transaksi f
LEFT JOIN warehouse.dim_waktu w
    ON f.waktu_key = w.waktu_key
GROUP BY w.tahun, w.bulan
ORDER BY w.tahun, w.bulan;

SELECT
    p.metode_pembayaran,
    p.provider,
    COUNT(*) AS total_payments,
    SUM(f.total_harga) AS total_sales
FROM warehouse.fact_transaksi f
LEFT JOIN warehouse.dim_pembayaran p
    ON f.pembayaran_key = p.pembayaran_key
GROUP BY p.metode_pembayaran, p.provider
ORDER BY total_sales DESC;

SELECT
    s.nama_toko,
    COUNT(*) AS total_transaction_items,
    SUM(f.jumlah_produk) AS total_quantity,
    SUM(f.total_harga) AS total_sales
FROM warehouse.fact_transaksi f
LEFT JOIN warehouse.dim_penjual s
    ON f.penjual_key = s.penjual_key
GROUP BY s.nama_toko
ORDER BY total_sales DESC;

SELECT
    prov.nama_provinsi,
    kota.nama_kota,
    COUNT(*) AS total_transaction_items,
    SUM(f.total_harga) AS total_sales
FROM warehouse.fact_transaksi f
LEFT JOIN warehouse.dim_lokasi l
    ON f.lokasi_key = l.lokasi_key
LEFT JOIN warehouse.dim_kecamatan kec
    ON l.kecamatan_key = kec.kecamatan_key
LEFT JOIN warehouse.dim_kota kota
    ON kec.kota_key = kota.kota_key
LEFT JOIN warehouse.dim_provinsi prov
    ON kota.provinsi_key = prov.provinsi_key
GROUP BY prov.nama_provinsi, kota.nama_kota
ORDER BY total_sales DESC;

