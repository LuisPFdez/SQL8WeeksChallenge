-- 1 - Cantidad total que ha consumido cada cliente en el restaurante
SELECT SUM(m.price) AS consumiciones_totales
FROM sales s
    LEFT JOIN menu m ON s.product_id = m.product_id
GROUP BY customer_id;
-- 2- Cuantos dias ha visitado cada cliente el restaurante
Select customer_id,
    count(DISTINCT order_date) AS dias_visitados
FROM sales
GROUP BY customer_id;
-- 3 - Cual ha sido el primer producto ordenado por cada cliente, solo muestra el primer producto del primer dia
SELECT customer_id,
    product_name
FROM sales s
    LEFT JOIN menu m ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY order_date;

-- Este script es similar pero muestra todos los productos comprados el prier dia en vez de un unico producto
WITH temp AS (
SELECT customer_id, MIN(order_date) AS first_order_date
FROM sales
GROUP BY customer_id)

SELECT s.customer_id, t.first_order_date, m.product_name
FROM sales s
INNER JOIN temp_table1 t ON s.customer_id= t.customer_id AND s.order_date=t.first_order_date
LEFT JOIN menu m ON s.product_id = m.product_id;


-- 4 - Cual es el producto mas comprado y cuantas veces ha sido comprado por todos los consumidores
-- ** Podria hacerse order by sobre la consulta y un limit, pero en caso de 2 elementos con el mismo volumen de ventas solo mostraria el primero. 
-- ** Usando rank ambos elementos tendrian un valor de 1 y la query mostraria ambos productos

WITH temp AS (SELECT product_id, COUNT(product_id) AS TOTAL, RANK() OVER (ORDER BY TOTAL DESC) AS rank FROM sales s GROUP BY product_id)

SELECT product_name, TOTAL FROM menu m JOIN temp t ON m.product_id = t.product_id WHERE rank = 1;

-- Cual ha sido el producto mas popular entre cada cliente

WITH temp AS (SELECT customer_id, product_id, COUNT(product_id) AS TOTAL, RANK() OVER(PARTITION BY customer_id ORDER BY TOTAL DESC) AS rank FROM sales GROUP BY customer_id, product_id)
SELECT customer_id, product_name, TOTAL FROM menu m RIGHT JOIN temp t ON m.product_id = t.product_id WHERE rank = 1;

-- Primer producto comprado despues convertirse en miembro
--Dependiendo de si en la fecha usas un mayor o igual o simplemente mayor obtendras resultados distintos para el cliente A

WITH temp AS (SELECT product_id, customer_id, RANK() OVER (PARTITION BY s.customer_id ORDER BY order_date) AS rank FROM sales s INNER JOIN members m USING (customer_id) WHERE join_date <= order_date order by rank)

SELECT customer_id, product_name FROM temp t LEFT JOIN menu m ON t.product_id = m.product_id WHERE rank = 1;

-- El ultimo producto que el cliente compro antes de combertirse en miembro
-- La logica es casi igual a la anterior, cambia el order by de dentro del over y la comparacion de fechas

WITH temp AS (SELECT *, RANK() OVER (PARTITION BY s.customer_id ORDER BY order_date DESC) AS rank FROM sales s INNER JOIN members m USING (customer_id) WHERE join_date > order_date order by rank)

SELECT customer_id, product_name FROM temp t LEFT JOIN menu m ON t.product_id = m.product_id WHERE rank = 1;

--Total gastado antes de convertirse en miembro
SELECT customer_id, count(product_id), SUM(price) FROM sales s INNER JOIN members mb USING (customer_id) LEFT JOIN menu m USING(product_id) where order_date < join_date GROUP BY s.customer_id;

-- Si cada $1 gastado equivale a 10 puntos salvo el sushi que equivale a 2x - Puntos totales de cada consumidor
WITH temp AS ( SELECT customer_id, CASE product_id WHEN 1 THEN price * 2 * 10 ELSE price * 10 END AS puntos
FROM sales s
LEFT JOIN menu m USING(product_id))

SELECT customer_id, SUM(puntos) FROM temp GROUP BY customer_id;

-- La primera semana en que los clientes se unieron al programa (incluyendo el dia en que lo hicieron) ganan 2x puntos en cada producto
-- no solo sushi, ¿Cuantos puntos tiene los clientes A y B al final de enero?

 SELECT customer_id, order_date, price, join_date, product_name,
 SUM(CASE WHEN product_id = 1 THEN price * 2 * 10 
 WHEN order_date BETWEEN join_date AND ADDDATE(join_date, 6) THEN price * 2 * 10
 ELSE price * 10 END) AS puntos
FROM sales s
LEFT JOIN menu m USING(product_id)
INNER JOIN members USING (customer_id)
WHERE order_date <= '2021-1-31'
GROUP BY customer_id;

-- Tabla 1

SELECT customer_id, order_date, product_name, price,
 CASE WHEN  join_date IS NULL OR join_date > order_date THEN 'N' 
 ELSE 'Y'
 END AS members
 FROM sales 
 LEFT JOIN members USING (customer_id)
 LEFT JOIN menu USING (product_id)
 ORDER BY customer_id, order_date, price DESC;
-- Tabla 2

WITH temp as (SELECT customer_id, order_date, product_name, price,
 CASE WHEN  join_date IS NULL OR join_date > order_date THEN 'N' 
 ELSE 'Y'
 END AS members
 FROM sales 
 LEFT JOIN members USING (customer_id)
 LEFT JOIN menu USING (product_id)
 ORDER BY customer_id, order_date, price DESC)

 Select *, 
 CASE members WHEN  'Y' THEN 
    rank() over(PARTITION BY customer_id, members order by order_date)
 ELSE NULL
 END AS ranking from temp;