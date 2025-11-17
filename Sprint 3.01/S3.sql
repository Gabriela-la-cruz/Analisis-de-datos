USE transactions;
# Ejercicio 1
CREATE TABLE IF NOT EXISTS credit_card ( 
	 id VARCHAR(10) PRIMARY KEY,
     iban VARCHAR(35) ,
     pan VARCHAR (35),
     pin CHAR (4),
     cvv CHAR(3),
     expiring_date VARCHAR (8));
     
ALTER TABLE transaction 
	ADD CONSTRAINT fk_transaction_credit_card_id
    FOREIGN KEY (credit_card_id) 
    REFERENCES credit_card(id);

# Ejercicio 2 
UPDATE credit_card SET iban = 'TR323456312213576817699999' 
WHERE id = 'CcU-2938';

SELECT iban 
FROM credit_card
WHERE id = 'CcU-2938';

# Ejercicio 3 
INSERT INTO company (id) VALUES ('b-9999');
INSERT INTO credit_card (id) VALUES ('CcU-9999');
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11 , 0);

# Ejercicio 4
ALTER TABLE credit_card DROP COLUMN pan;
SHOW COLUMNS from credit_card;

# NIVEL 2
# Ejercicio 1
DELETE FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

# Ejercicio 2
CREATE VIEW `VistaMarketing`AS
SELECT c.company_name, c.phone, c.country, ROUND(AVG(t.amount),2) media_compras
FROM transaction t
JOIN company c ON t.company_id = c.id
GROUP BY c.id, c.company_name
ORDER BY media_compras DESC; 

SELECT * FROM transactions.vistamarketing;

#Ejercicio 3 
SELECT * FROM transactions.vistamarketing
WHERE country = 'Germany';

# NIVEL 3
# Ejercicio 1
CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
); 

DELETE FROM transaction
WHERE company_id = 'b-9999';

ALTER TABLE user 
    MODIFY id INT;
   
ALTER TABLE transaction 
	ADD CONSTRAINT fk_transaction_user
    FOREIGN KEY (user_id) 
    REFERENCES user(id);

# Ejercicio 2
CREATE VIEW `InformeTecnico` AS
SELECT t.id AS Transaction_ID, u.name AS User_Name, u.surname AS User_Surname,
    cc.iban AS Credit_card_iban, c.company_name AS Company_Name
FROM transaction t
JOIN user u ON t.user_id = u.id
JOIN credit_card cc ON t.credit_card_id = cc.id
JOIN company c ON t.company_id = c.id
ORDER BY Transaction_ID DESC;

SELECT * FROM transactions.informetecnico;
