USE transactions;
# NIVEL 1
# Ejercicio 2
# Utilizando JOIN realizarás las siguientes consultas:
	
# Listado de los países que están generando ventas.
SELECT DISTINCT c.country  ventas_por_paises
FROM company c 
INNER JOIN transaction t ON c.id = t.company_id
WHERE  t.declined = 0; 

# Desde cuántos países se generan las ventas.
SELECT COUNT(DISTINCT c.country) cantidad_paises
FROM company c 
INNER JOIN transaction t ON c.id = t.company_id
WHERE  declined = 0; 

# Identifica a la compañía con la mayor media de ventas.
SELECT c.company_name compañia, ROUND(AVG(t.amount),2) media_ventas
FROM company c 
INNER JOIN transaction t ON c.id = t.company_id
WHERE  declined = 0
GROUP BY c.id
ORDER BY media_ventas DESC
LIMIT 1 ; 

# Ejercicio 3
# Utilizando sólo subconsultas (sin utilizar JOIN):

# Muestra todas las transacciones realizadas por empresas de Alemania.
SELECT t.* 
FROM transaction t
WHERE declined = 0 AND EXISTS (
	SELECT c.country
	FROM company c
	WHERE c.id = t.company_id
    AND c.country = 'Germany');
    
# Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.
SELECT c.company_name
FROM company c
WHERE id IN (
	SELECT t.company_id
    FROM transaction t
    WHERE t.declined = 0 AND t.amount > (
		SELECT AVG(t2.amount)
        FROM transaction t2)
        );

# Eliminarán del sistema las empresas que carecen de transacciones registradas,
# entrega el listado de estas empresas.
SELECT c.id,c.company_name
FROM company c
WHERE c.id NOT IN (
	SELECT t.company_id
    FROM transaction t);

# NIVEL 2
# Ejercicio 1
# Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. 
# Muestra la fecha de cada transacción junto con el total de las ventas.
SELECT DATE(timestamp) fecha, SUM(amount) total_venta
FROM transaction  
WHERE declined = 0 
GROUP BY fecha
ORDER BY total_venta DESC
LIMIT 5;

# Ejercicio 2
#¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor medio.
SELECT c.country, ROUND(AVG(t.amount),2) media_ventas
FROM transaction t  
JOIN company c ON t.company_id = c.id
GROUP BY c.country
ORDER BY media_ventas DESC; 

# Ejercicio 3
# En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía “Non Institute”. 
# Para ello, te piden la lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que esta compañía.

# Muestra el listado aplicando JOIN y subconsultas.
SELECT c.country, c.company_name, t.*
FROM transaction t
INNER JOIN company c ON t.company_id = c.id
WHERE c.company_name <> 'Non Institute' AND declined = 0
AND c.country = (
    SELECT country
    FROM company
    WHERE company_name = 'Non Institute'
);

#Muestra el listado aplicando solo subconsultas.
SELECT t.*
FROM transaction t
WHERE EXISTS (
	SELECT c.company_name
    FROM company c
    WHERE t.company_id = c.id AND t.declined = 0 
    AND c.company_name <> 'Non institute'
    AND c.country = (
    SELECT c2.country
    FROM company c2
    WHERE c2.company_name = 'Non Institute'))
    ;

# NIVEL 3
# Ejercicio 1
# Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor comprendido entre 350 y 400 euros 
# y en alguna de estas fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. Ordena los resultados de mayor a menor cantidad.

SELECT c.company_name, c.phone, c.country, DATE(t.timestamp) fecha, t.amount 
FROM company c
INNER JOIN transaction t ON c.id = t.company_id
WHERE t.declined = '0'
AND t.amount BETWEEN 350 AND 400 
AND DATE(t.timestamp) IN ('2015-04-29', '2018-07-20','2024-03-13')
ORDER BY t.amount DESC; 

# Ejercicio 2
# Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, 
# por lo que te piden la información sobre la cantidad de transacciones que realizan las empresas, 
# pero el departamento de recursos humanos es exigente y quiere un listado de las empresas en las que especifiques si tienen más de 400 transacciones o menos.

SELECT c.company_name, COUNT(t.id) AS transacciones, 
CASE 
    WHEN COUNT(t.id)> 400 THEN 'mas de 400' 
    ELSE 'menos de 400'
END total_transacciones
FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE declined = 0
GROUP BY c.id
ORDER BY transacciones DESC;