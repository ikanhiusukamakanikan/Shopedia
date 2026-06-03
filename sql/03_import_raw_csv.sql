-- Supabase Table Editor:
-- 1. Buka schema raw.
-- 2. Pilih tabel tujuan.
-- 3. Import CSV dengan opsi "Header row" aktif.
-- 4. Ulangi untuk seluruh file pada folder Data/.

-- Jika menjalankan dari psql lokal, sesuaikan path absolut berikut.
-- \copy raw.customers FROM 'Data/customers.csv' WITH (FORMAT csv, HEADER true);
-- \copy raw.sellers FROM 'Data/sellers.csv' WITH (FORMAT csv, HEADER true);
-- \copy raw.product_categories FROM 'Data/product_categories.csv' WITH (FORMAT csv, HEADER true);
-- \copy raw.products FROM 'Data/products.csv' WITH (FORMAT csv, HEADER true);
-- \copy raw.areas FROM 'Data/areas.csv' WITH (FORMAT csv, HEADER true);
-- \copy raw.addresses FROM 'Data/addresses.csv' WITH (FORMAT csv, HEADER true);
-- \copy raw.orders FROM 'Data/orders.csv' WITH (FORMAT csv, HEADER true);
-- \copy raw.order_items FROM 'Data/order_items.csv' WITH (FORMAT csv, HEADER true);
-- \copy raw.payments FROM 'Data/payments.csv' WITH (FORMAT csv, HEADER true);

