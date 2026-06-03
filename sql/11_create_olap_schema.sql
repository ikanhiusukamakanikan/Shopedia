CREATE SCHEMA IF NOT EXISTS olap;

DROP MATERIALIZED VIEW IF EXISTS olap.mart_region_performance;
DROP MATERIALIZED VIEW IF EXISTS olap.mart_payment_performance;
DROP MATERIALIZED VIEW IF EXISTS olap.mart_seller_performance;
DROP MATERIALIZED VIEW IF EXISTS olap.mart_product_performance;
DROP MATERIALIZED VIEW IF EXISTS olap.mart_sales_monthly;
DROP VIEW IF EXISTS olap.vw_transaksi_detail;

