ALTER TABLE warehouse.fact_transaksi
    DROP CONSTRAINT IF EXISTS fact_transaksi_source_order_item_id_key;

ALTER TABLE warehouse.fact_transaksi
    ADD COLUMN IF NOT EXISTS source_order_item_key bigint;

TRUNCATE TABLE warehouse.fact_transaksi RESTART IDENTITY;

INSERT INTO warehouse.fact_transaksi (
    source_order_item_key,
    source_order_item_id,
    source_order_id,
    waktu_key,
    produk_key,
    pelanggan_key,
    penjual_key,
    pembayaran_key,
    lokasi_key,
    jumlah_produk,
    harga_satuan,
    total_harga,
    diskon,
    ongkir
)
SELECT
    oi.order_item_key,
    oi.order_item_id,
    oi.order_id,
    w.waktu_key,
    dp.produk_key,
    dc.pelanggan_key,
    ds.penjual_key,
    pay_dim.pembayaran_key,
    dl.lokasi_key,
    oi.quantity,
    oi.unit_price,
    oi.line_total,
    oi.discount_amount,
    o.shipping_fee
FROM staging.order_items_clean oi
JOIN staging.orders_clean o
    ON o.order_id = oi.order_id
LEFT JOIN staging.payments_clean pay
    ON pay.order_id = o.order_id
LEFT JOIN warehouse.dim_waktu w
    ON w.tanggal = o.order_date
LEFT JOIN warehouse.dim_produk dp
    ON dp.source_product_id = oi.product_id
LEFT JOIN warehouse.dim_pelanggan dc
    ON dc.source_customer_id = o.customer_id
LEFT JOIN warehouse.dim_penjual ds
    ON ds.source_seller_id = oi.seller_id
LEFT JOIN warehouse.dim_pembayaran pay_dim
    ON pay_dim.metode_pembayaran = pay.payment_method
    AND pay_dim.jenis_pembayaran = pay.payment_type
    AND pay_dim.provider = pay.provider
    AND pay_dim.status_pembayaran = pay.payment_status
LEFT JOIN warehouse.dim_lokasi dl
    ON dl.source_address_id = o.shipping_address_id
WHERE oi.quantity > 0
  AND oi.unit_price >= 0
  AND oi.line_total >= 0;
