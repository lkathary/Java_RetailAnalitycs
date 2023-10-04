-- Creating data_base:
--CREATE DATABASE retail_analytics;

-- Drop tables:
DROP TABLE IF EXISTS personal_data CASCADE;
DROP TABLE IF EXISTS cards CASCADE;
DROP TABLE IF EXISTS sku_groups CASCADE;
DROP TABLE IF EXISTS sku CASCADE;
DROP TABLE IF EXISTS stores CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS checks CASCADE;

-- Creating tables:
CREATE TABLE IF NOT EXISTS personal_data (
     Customer_ID serial primary key,
     Customer_Name varchar not null,
     Customer_Surname varchar not null,
     Customer_Primary_Email varchar not null,
     Customer_Primary_Phone varchar not null
);

CREATE TABLE IF NOT EXISTS cards (
    Customer_Card_ID serial primary key,
    Customer_ID int not null,
    constraint fk_cards_customer_id foreign key (Customer_ID) references personal_data (Customer_ID) on delete cascade
);

CREATE TABLE IF NOT EXISTS sku_groups (
    Group_ID serial primary key,
    Group_Name varchar not null
);

CREATE TABLE IF NOT EXISTS sku (
    SKU_ID serial primary key,
    SKU_Name varchar not null,
    Group_ID int not null,
    constraint fk_sku_group_id foreign key (Group_ID) references sku_groups (Group_ID) on delete cascade
);

CREATE TABLE IF NOT EXISTS stores (
    Store_ID serial primary key,
    Transaction_Store_ID int,
    SKU_ID int not null,
    SKU_Purchase_Price decimal not null,
    SKU_Retail_Price decimal not null,
    constraint fk_stores_sku_id foreign key (SKU_ID) references sku (SKU_ID) on delete cascade
);

CREATE TABLE IF NOT EXISTS transactions (
    Transaction_ID serial primary key,
    Customer_Card_ID int not null,
    Transaction_Summ decimal not null,
    Transaction_DateTime timestamp not null,
    Transaction_Store_ID serial not null,
    constraint fk_transactions_customer_card_id foreign key (Customer_Card_ID) references cards (Customer_Card_ID) on delete cascade
    --,constraint fk_transactions_transaction_store_id foreign key (Transaction_Store_ID)
    --                                                references stores (Transaction_Store_ID)
);

CREATE TABLE IF NOT EXISTS checks(
     Checks_ID serial primary key,
     Transaction_ID int not null,
     SKU_ID int not null,
     SKU_Amount decimal not null,
     SKU_Summ decimal not null,
     SKU_Summ_Paid decimal not null,
     SKU_Discount decimal not null,
     constraint fk_checks_transaction_id foreign key (Transaction_ID) references transactions (Transaction_ID) on delete cascade,
     constraint fk_checks_sku_id foreign key (SKU_ID) references sku (SKU_ID) on delete cascade
);


-- ===============================================
-- Import / Export data --

CREATE OR REPLACE PROCEDURE import_table(file_name varchar,
                                         table_name varchar,
                                         delimiter varchar(1) default E'\t')  -- tab ('\t')
    LANGUAGE plpgsql
AS $BODY$
DECLARE
    path varchar = (SELECT setting
                    FROM pg_settings
                    WHERE name = 'data_directory') || '/' || file_name;
    count_record int;
BEGIN
    RAISE NOTICE 'Import from file: %', path;
    EXECUTE 'COPY ' || table_name || ' FROM ' || quote_literal(path) ||
            ' WITH DELIMITER ' || quote_literal(delimiter);
    EXECUTE 'SELECT count(*) FROM ' || quote_ident(table_name) INTO count_record;
    RAISE NOTICE 'Table name: %', table_name;
    RAISE NOTICE '% of records are imported successfully', count_record;
END
$BODY$;

CREATE OR REPLACE PROCEDURE export_table(file_name varchar,
                                         table_name varchar,
                                         delimiter varchar(1) default E'\t')  -- tab ('\t'))
    LANGUAGE plpgsql
AS $BODY$
DECLARE
    path varchar = (SELECT setting
                    FROM pg_settings
                    WHERE name = 'data_directory') || '/' || file_name;
BEGIN
    RAISE NOTICE 'Export to file: %', path;
    EXECUTE 'COPY ' || table_name || ' TO ' || quote_literal(path) ||
            ' WITH DELIMITER ' || quote_literal(delimiter);
END
$BODY$;

-- ATTENTION!!!
-- Before importing make sure all '*.csv' '*.tvc' files are copied/moved from './datasets/' to Postgres data folder!
-- WINDOWS (path example: 'C:/Program Files/PostgreSQL/14/data/')
-- Darwin (path example: '/var/lib/postgresql/12/main/')

-- Find the dir:
SHOW data_directory;

-- Also clear (TRUNCATE) the table before import

-- Truncate tables:
TRUNCATE TABLE personal_data RESTART IDENTITY CASCADE;
TRUNCATE TABLE cards RESTART IDENTITY CASCADE;
TRUNCATE TABLE sku_groups RESTART IDENTITY CASCADE;
TRUNCATE TABLE sku RESTART IDENTITY CASCADE;
TRUNCATE TABLE stores RESTART IDENTITY CASCADE;
TRUNCATE TABLE transactions RESTART IDENTITY CASCADE;
TRUNCATE TABLE checks RESTART IDENTITY CASCADE;

SHOW datestyle;
SET datestyle TO DMY;
SHOW datestyle;

--- Import ---
-- CALL import_table('personal_data.tsv', 'personal_data');
-- CALL import_table('groups_sku.tsv', 'sku_groups');
-- CALL import_table('cards.tsv', 'cards');
-- CALL import_table('sku.tsv', 'sku');
-- CALL import_table('stores.tsv', 'stores');
-- CALL import_table('transactions.tsv', 'transactions');
-- CALL import_table('checks.tsv', 'checks');

--- Import Data_mini---
CALL import_table('personal_data_mini.tsv', 'personal_data');
CALL import_table('groups_sku_mini.tsv', 'sku_groups');
CALL import_table('cards_mini.tsv', 'cards');
CALL import_table('sku_mini.tsv', 'sku');
CALL import_table('stores_mini.tsv', 'stores');
CALL import_table('transactions_mini.tsv', 'transactions');
CALL import_table('checks_mini.tsv', 'checks');

--- Init sequences ---
SELECT setval('personal_data_customer_id_seq', count(*)) FROM personal_data;
SELECT setval('sku_groups_group_id_seq', count(*)) FROM sku_groups;
SELECT setval('cards_customer_card_id_seq', count(*)) FROM cards;
SELECT setval('sku_sku_id_seq', count(*)) FROM sku;
SELECT setval('stores_store_id_seq', count(*)) FROM stores;
SELECT setval('transactions_transaction_id_seq', count(*)) FROM transactions;
SELECT setval('checks_checks_id_seq', count(*)) FROM checks;

--- Export ---
CALL export_table('Personal_Data.csv', 'personal_data',',');
CALL export_table('Cards.csv', 'cards',',');
CALL export_table('Groups_SKU.csv', 'sku_groups',',');
CALL export_table('SKU.csv', 'sku',',');
CALL export_table('Stores.csv', 'stores',',');
CALL export_table('Transactions.csv', 'transactions',',');
CALL export_table('Checks.csv', 'checks',',');


--- Checking ---
SELECT * FROM personal_data;
SELECT * FROM cards;
SELECT * FROM sku_groups;
SELECT * FROM sku;
SELECT * FROM stores;
SELECT * FROM transactions;
SELECT * FROM checks;

DROP TABLE IF EXISTS databasechangelog CASCADE;
SELECT * FROM  databasechangelog;
