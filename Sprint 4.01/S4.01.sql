## NIVEL 1
-- Base de datos
CREATE DATABASE IF NOT EXISTS companies_transactions;
USE companies_transactions;

-- Tabla american_users
CREATE TABLE american_users (
	id INT PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(15),
	email VARCHAR(100),
	birth_date VARCHAR (15),
	country VARCHAR(30),
	city VARCHAR(30),
	postal_code VARCHAR(15),
	address VARCHAR(100)    
);

-- Datos users 
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\american_users.csv"
INTO TABLE american_users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

   -- Tabla european_users
CREATE TABLE european_users (
	id INT PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(15),
	email VARCHAR(100),
	birth_date VARCHAR (15),
	country VARCHAR(30),
	city VARCHAR(30),
	postal_code VARCHAR(15),
	address VARCHAR(100)
);

-- Datos european_users 
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\european_users.csv"
INTO TABLE european_users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Tabla users
CREATE TABLE users (
	id INT PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(15),
	email VARCHAR(100),
	birth_date VARCHAR(15),
	country VARCHAR(30),
	city VARCHAR(30),
	postal_code VARCHAR(15),
	address VARCHAR(100)  
);

-- UNION
INSERT INTO users (id, name, surname, phone, email, birth_date, country, city, postal_code, address)
SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address
FROM american_users
UNION ALL
SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address
FROM european_users;

-- Elimino tablas american y european users que ya estan unificadas
DROP TABLE american_users;
DROP TABLE european_users;
 
-- Tabla credit_cards
CREATE TABLE IF NOT EXISTS credit_cards ( 
	id VARCHAR(15) PRIMARY KEY,
	user_id INT,
	iban VARCHAR(35) ,
	pan VARCHAR (35),
	pin CHAR (4),
	cvv CHAR(3),
	track1 VARCHAR(100),
	track2 VARCHAR(100),
	expiring_date VARCHAR (15), 
    FOREIGN KEY (user_id) REFERENCES users(id)
);
     
-- Datos credit_cards 
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\credit_cards.csv"
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Actualizo los valores a un formato válido de DATE
UPDATE credit_cards
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y')
WHERE id >= '0';

-- Cambio el tipo de la columna
ALTER TABLE credit_cards
MODIFY COLUMN expiring_date DATE;

SHOW COLUMNS FROM credit_cards;

-- Tabla companies
CREATE TABLE IF NOT EXISTS companies (
	company_id VARCHAR(100) PRIMARY KEY,
	company_name VARCHAR(100),
	phone VARCHAR(15),
	email VARCHAR(50),
	country VARCHAR(50),
	website VARCHAR(100)
);
-- Datos companies 
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Tabla transactions
CREATE TABLE IF NOT EXISTS transactions (
	id VARCHAR(100) PRIMARY KEY,
	card_id VARCHAR(15),
	business_id VARCHAR(100), 
	timestamp TIMESTAMP,
	amount DECIMAL(10, 2),
	declined BOOLEAN,
	product_ids VARCHAR(100),
	user_id INT,
	lat FLOAT,
	longitude FLOAT,
	FOREIGN KEY (business_id) REFERENCES companies(company_id), 
	FOREIGN KEY (card_id) REFERENCES credit_cards(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Datos transactions 
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

# Ejercicio 1
SELECT u.id, u.name, u.surname
FROM users u
WHERE EXISTS (
    SELECT t.user_id
    FROM transactions t
    WHERE t.declined = 0 AND t.user_id = u.id
    GROUP BY t.user_id 
    HAVING COUNT(*) > 80
);

# Ejercicio 2
SELECT ROUND(AVG(t.amount),2) media_amount, cc.iban
FROM transactions t 
JOIN companies c ON t.business_id = c.company_id
JOIN credit_cards cc ON t.card_id = cc.id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban;

## NIVEL 2
# Ejercicio 1
-- Tabla credit_card_status
CREATE TABLE credit_card_status (
	id VARCHAR(15) PRIMARY KEY,
    card_status VARCHAR(20),
    FOREIGN KEY (id) REFERENCES credit_cards(id)
    );

-- Datos credit_card_status    
INSERT INTO credit_card_status (id,card_status)
SELECT cc.id, CASE
	WHEN MIN(t1.declined) = 0 THEN 'Active'
    ELSE 'Inactive'
END card_status
FROM credit_cards cc
JOIN ( SELECT t.card_id, t.declined, t.timestamp,
		ROW_NUMBER () OVER(PARTITION BY t.card_id 
				   ORDER BY t.timestamp DESC) card_transaction
	   FROM transactions t) t1
ON cc.id = t1.card_id
WHERE card_transaction <= 3
GROUP BY cc.id; 

SELECT COUNT(*) active_cards
FROM credit_card_status
WHERE card_status = 'Active';

## NIVEL 3
-- Tabla products
CREATE TABLE IF NOT EXISTS products (
	id VARCHAR(100) PRIMARY KEY,
    product_name VARCHAR (100),
    price VARCHAR (50),
    colour VARCHAR (50),
    weight FLOAT,
    warehouse_id VARCHAR(50)
);

-- Datos products 
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\products.csv"
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Tabla products_transactions
CREATE TABLE IF NOT EXISTS products_transactions (
    product_id VARCHAR(100),
    transaction_id VARCHAR(100),
    PRIMARY KEY (product_id, transaction_id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id)
);

-- Datos products_transactions
INSERT INTO products_transactions (transaction_id, product_id)
SELECT t.id,
       TRIM(jt.product_id) AS product_id
FROM transactions AS t
JOIN JSON_TABLE(
       CONCAT('["', REPLACE(REPLACE(t.product_ids, ' ', ''), ',', '","'), '"]'),
       '$[*]' COLUMNS (
           product_id VARCHAR(100) PATH '$'
       )
) AS jt
JOIN products p
  ON p.id = TRIM(jt.product_id);

# Ejercicio 1
SELECT product_id, COUNT(transaction_id) times_sold
FROM products_transactions
GROUP BY product_id;

-- Elimino la llave foranea de user_id 
SHOW CREATE TABLE transactions;

ALTER TABLE transactions
DROP FOREIGN KEY transactions_ibfk_3;