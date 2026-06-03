DROP TABLE IF EXISTS warehouse.fact_transaksi;
DROP TABLE IF EXISTS warehouse.dim_lokasi;
DROP TABLE IF EXISTS warehouse.dim_pelanggan;
DROP TABLE IF EXISTS warehouse.dim_penjual;
DROP TABLE IF EXISTS warehouse.dim_produk;
DROP TABLE IF EXISTS warehouse.dim_kecamatan;
DROP TABLE IF EXISTS warehouse.dim_kota;
DROP TABLE IF EXISTS warehouse.dim_provinsi;
DROP TABLE IF EXISTS warehouse.dim_pembayaran;
DROP TABLE IF EXISTS warehouse.dim_kategori;
DROP TABLE IF EXISTS warehouse.dim_waktu;

CREATE TABLE warehouse.dim_waktu (
    waktu_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tanggal date UNIQUE NOT NULL,
    hari text,
    bulan text,
    tahun integer,
    minggu_ke integer,
    kuartal integer
);

CREATE TABLE warehouse.dim_kategori (
    kategori_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_category_id text UNIQUE,
    nama_kategori text,
    jenis_kategori text,
    deskripsi_kategori text
);

CREATE TABLE warehouse.dim_pembayaran (
    pembayaran_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    metode_pembayaran text,
    jenis_pembayaran text,
    provider text,
    status_pembayaran text,
    UNIQUE (metode_pembayaran, jenis_pembayaran, provider, status_pembayaran)
);

CREATE TABLE warehouse.dim_provinsi (
    provinsi_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nama_provinsi text,
    negara text,
    UNIQUE (nama_provinsi, negara)
);

CREATE TABLE warehouse.dim_kota (
    kota_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nama_kota text,
    provinsi_key integer REFERENCES warehouse.dim_provinsi (provinsi_key),
    UNIQUE (nama_kota, provinsi_key)
);

CREATE TABLE warehouse.dim_kecamatan (
    kecamatan_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nama_kecamatan text,
    kota_key integer REFERENCES warehouse.dim_kota (kota_key),
    UNIQUE (nama_kecamatan, kota_key)
);

CREATE TABLE warehouse.dim_lokasi (
    lokasi_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_address_id text UNIQUE,
    alamat text,
    nomor_rumah text,
    kode_pos text,
    kecamatan_key integer REFERENCES warehouse.dim_kecamatan (kecamatan_key)
);

CREATE TABLE warehouse.dim_pelanggan (
    pelanggan_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_customer_id text UNIQUE,
    nama_pelanggan text,
    email text,
    nomor_telepon text,
    tanggal_daftar date,
    tipe_pelanggan text,
    status_akun text,
    kota_key integer REFERENCES warehouse.dim_kota (kota_key)
);

CREATE TABLE warehouse.dim_penjual (
    penjual_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_seller_id text UNIQUE,
    nama_toko text,
    nama_penjual text,
    tanggal_gabung date,
    rating_toko numeric(3, 2),
    level_penjual text,
    status_toko text,
    kota_key integer REFERENCES warehouse.dim_kota (kota_key)
);

CREATE TABLE warehouse.dim_produk (
    produk_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_product_id text UNIQUE,
    nama_produk text,
    brand text,
    harga numeric(14, 2),
    berat_produk numeric(10, 3),
    status_produk text,
    kategori_key integer REFERENCES warehouse.dim_kategori (kategori_key)
);

CREATE TABLE warehouse.fact_transaksi (
    transaksi_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_order_item_key bigint,
    source_order_item_id text,
    source_order_id text,
    waktu_key integer REFERENCES warehouse.dim_waktu (waktu_key),
    produk_key integer REFERENCES warehouse.dim_produk (produk_key),
    pelanggan_key integer REFERENCES warehouse.dim_pelanggan (pelanggan_key),
    penjual_key integer REFERENCES warehouse.dim_penjual (penjual_key),
    pembayaran_key integer REFERENCES warehouse.dim_pembayaran (pembayaran_key),
    lokasi_key integer REFERENCES warehouse.dim_lokasi (lokasi_key),
    jumlah_produk integer,
    harga_satuan numeric(14, 2),
    total_harga numeric(14, 2),
    diskon numeric(14, 2),
    ongkir numeric(14, 2)
);
