## Limpieza de datos

### Limpieza de la tabla `customer_orders`

**Comprobamos los datos antes del update**

```sql
SELECT * from customer_orders WHERE exclusions = 'null' or exclusions = '';
SELECT * FROM customer_orders WHERE extras = 'null' OR extras = 'NaN' OR extras = '';
```

**Ejecutamos la actualización**

```sql
UPDATE customer_orders SET exclusions = NULL WHERE exclusions = 'null' or exclusions = '';
UPDATE customer_orders SET extras = NULL WHERE extras = 'null' OR extras = 'NaN' OR extras = '';
```

#### Explicación

Algunos datos aparecen **vacíos**, con **null** en texto o con **NaN**.

Usando las **select** podemos verificar los datos incorrectos, mientras que con
los updates cambiamos estos datos por valores a `NULL`,

#### Resultado

| order_id | customer_id | pizza_id | exclusions | extras |     order_date      |
| :------: | :---------: | :------: | :--------: | :----: | :-----------------: |
|    1     |     101     |    1     |   `NULL`   | `NULL` | 2021-01-01 18:05:02 |
|    2     |     101     |    1     |   `NULL`   | `NULL` | 2021-01-01 19:00:52 |
|    3     |     102     |    1     |   `NULL`   | `NULL` | 2021-01-02 23:51:23 |
|    3     |     102     |    2     |   `NULL`   | `NULL` | 2021-01-02 23:51:23 |
|    4     |     103     |    1     |     4      | `NULL` | 2021-01-04 13:23:46 |
|    4     |     103     |    1     |     4      | `NULL` | 2021-01-04 13:23:46 |
|    4     |     103     |    2     |     4      | `NULL` | 2021-01-04 13:23:46 |
|    5     |     104     |    1     |   `NULL`   |   1    | 2021-01-08 21:00:29 |
|    6     |     101     |    2     |   `NULL`   | `NULL` | 2021-01-08 21:03:13 |
|    7     |     105     |    2     |   `NULL`   |   1    | 2021-01-08 21:20:29 |
|    8     |     102     |    1     |   `NULL`   | `NULL` | 2021-01-09 23:54:33 |
|    9     |     103     |    1     |     4      |  1, 5  | 2021-01-10 11:22:59 |
|    10    |     104     |    1     |   `NULL`   | `NULL` | 2021-01-11 18:34:49 |
|    10    |     104     |    1     |    2, 6    |  1, 4  | 2021-01-11 18:34:49 |

### Limpieza de la tabla `runner_orders`

**Comprobamos los datos antes del update**

```sql
SELECT * FROM runner_orders WHERE distance = 'null';
SELECT * FROM runner_orders WHERE duration = 'null';
SELECT * FROM runner_orders WHERE cancellation = 'null' OR cancellation = 'NaN' OR cancellation = '';
```

**Consultas para eliminar las palabras de las columnas `duration` y `distance`**

```sql
SELECT * FROM runner_orders WHERE duration REGEXP '[a-z]+' or duration REGEXP '[a-z]+';
SELECT order_id, runner_id, pickup_time, REGEXP_SUBSTR(distance, '[0-9]*') AS distance, REGEXP_SUBSTR(duration, '[0-9]*') AS duration,cancellation FROM runner_orders;
```

**Ejecutamos la actualización**

```sql
UPDATE runner_orders SET distance = NULL WHERE distance = 'null';
UPDATE runner_orders SET duration = NULL WHERE duration = 'null';
UPDATE runner_orders SET cancellation = NULL WHERE cancellation = 'null' OR cancellation = 'NaN' OR cancellation = '';
```

**Actualización de las columnas `duration` y `distance`**

```sql
UPDATE runner_orders SET distance = REGEXP_SUBSTR(distance, '[0-9]*'), duration = REGEXP_SUBSTR(duration, '[0-9]*');

ALTER TABLE runner_orders MODIFY distance INT, MODIFY duration INT;
```

**Comprobamos los datos para la limpieza de la columna `pickup_time`**

```sql
SELECT * FROM runner_orders WHERE pickup_time = 'null'
```

**Ejecutamos la actualización**

```sql
UPDATE runner_orders SET pickup_time = NULL WHERE pickup_time = 'null';
```

**Actualización de la columna `pickup_time`**

```sql
ALTER TABLE runner_orders MODIFY pickup_time TIMESTAMP;
```

### Explicación

Se eliminan los datos cuyo valor sea null (en texto), NaN o un valor vacío,
sustituyendo el valor por `NULL`. Antes de realizar las actualizaciones se
utilizan selects para verificar que el valor sea el correcto y solo afecte a los
campos con dichos valores.

Una vez realizado el update las columnas de `duration`, `distance`,
`pickup_time` se modifica el tipo a `INT` para `duration` y `distance` y
`DATETIME` para `pickup_time` para mantener la fecha y la hora.

### Resultado

| order_id | runner_id | pickup_time | distance | duration |      cancellation       |
| :------: | :-------: | :---------: | :------: | :------: | :---------------------: |
|    1     |     1     | 2021-01-01  |    20    |    32    |          NULL           |
|    2     |     1     | 2021-01-01  |    20    |    27    |          NULL           |
|    3     |     1     | 2021-01-03  |    13    |    20    |          NULL           |
|    4     |     2     | 2021-01-04  |    23    |    40    |          NULL           |
|    5     |     3     | 2021-01-08  |    10    |    15    |          NULL           |
|    6     |     3     |    NULL     |   NULL   |   NULL   | Restaurant Cancellation |
|    7     |     2     | 2020-01-08  |    25    |    25    |          NULL           |
|    8     |     2     | 2020-01-10  |    23    |    15    |          NULL           |
|    9     |     2     |    NULL     |   NULL   |   NULL   |  Customer Cancellation  |
|    10    |     1     | 2020-01-11  |    10    |    10    |          NULL           |

### Estado de la tabla `runner_orders`

```sql
DESCRIBE runner_orders;
```

|    Field     |    Type     |
| :----------: | :---------: |
|   order_id   |   int(11)   |
|  runner_id   |   int(11)   |
| pickup_time  |    date     |
|   distance   |   int(11)   |
|   duration   |   int(11)   |
| cancellation | varchar(23) |

## Métricas

### Cuantas pizzas se han pedido

```sql
SELECT count(*) AS 'PIZZAS TOTALES'
FROM customer_orders;
```

#### Explicación

Se obtiene el total de pedidos de la tabla `customer_orders`

#### Resultado

| PIZZAS TOTALES |
| :------------: |
|       14       |

### Cuantas ordenes únicas se han realizado

```sql
SELECT COUNT(DISTINCT(order_id)) AS TOTAL
FROM customer_orders;
```

#### Explicación

Se realiza la cuenta de la tabla `customer_orders` diferenciando el _order_id_
para evitar contar pedidos con con mas de una pizza.

#### Resultado

| TOTAL |
| :---: |
|  10   |

### Cuantas ordenes satisfactorias ha realizado cada corredor

```sql
SELECT count(order_id) AS 'PEDIDOS SATISFACTORIOS'
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;
```

#### Explicación

Se realiza la cuenta de la tabla `runner_id` agrupándolo por el id del corredor
y el campo de cancelación no tiene ninguna valor

#### Resultado

| PEDIDOS SATISFACTORIOS |
| :--------------------: |
|           4            |
|           3            |
|           1            |

### Cuantas pizzas de cada tipo han sido enviadas

```sql
SELECT pizza_name,
    count(*) AS TOTAL
FROM customer_orders
    INNER JOIN runner_orders USING(order_id)
    LEFT JOIN pizza_names using(pizza_id)
WHERE cancellation IS NULL
GROUP BY pizza_id;
```

#### Explicación

Se agrupa por el id de la pizza y se realiza la cuenta para saber el total que
han sido enviadas de cada una. El **INNER JOIN** permite eliminar los pedidos
que han sido cancelados para evitar contarlos. El **LEFT JOIN** nos permite
obtener el nombre de la pizza

#### Resultado

| pizza_name  | TOTAL |
| :---------: | :---: |
| Meat Lovers |   9   |
| Vegetarian  |   3   |

-- Cuantas Vegetarian y MeatLover han sido pedidas por cada consumidor

```sql
SELECT pizza_name,
    count(*) AS TOTAL,
    customer_id
FROM customer_orders
    LEFT JOIN pizza_names USING (pizza_id)
GROUP BY customer_id,
    pizza_id;
```

#### Explicación

Se agrupa por el id del consumidor y el id de la pizza para obtener el total de cada tipo de pizza que ha pedido. Se hace un **LEFT JOIN** para obtener el nombre de las pizzas

#### Resultado

| pizza_name  | TOTAL | customer_id |
| :---------: | :---: | :---------: |
| Meat Lovers |   2   |     101     |
| Vegetarian  |   1   |     101     |
| Meat Lovers |   2   |     102     |
| Vegetarian  |   1   |     102     |
| Meat Lovers |   3   |     103     |
| Vegetarian  |   1   |     103     |
| Meat Lovers |   3   |     104     |
| Vegetarian  |   1   |     105     |

```sql
-- Cual es el máximo de pizzas enviadas en una misma orden 
WITH temp AS (SELECT order_id, COUNT(pizza_id) as TOTAL, RANK() OVER(ORDER BY TOTAL DESC) AS RANK FROM customer_orders GROUP BY order_id)

SELECT order_id, TOTAL AS TOTAL_PIZZAS FROM temp WHERE RANK = 1;

-- 
SELECT COUNT(*) FROM customer_orders cu LEFT JOIN runner_orders ru USING(order_id) WHERE exclusions IS NOT NULL AND extras IS NOT NULL AND cancellation IS NOT NULL;


-- Pizzas por hora
WITH temp AS (SELECT pizza_id, HOUR(order_date) AS HORA FROM customer_orders)

SELECT HORA, SUM(pizza_id) FROM temp GROUP BY HORA

-- Pizzas por dia
SET lc_time_names = 'es_ES';
WITH temp AS (SELECT pizza_id, DAYNAME(order_date) AS DIA, WEEKDAY(order_date) as NUM_DIA FROM customer_orders)

SELECT UPPER(DIA), SUM(pizza_id) FROM temp GROUP BY DIA ORDER BY NUM_DIA;



-- Repartidores y Experiencia del consumidor
-- Cuantos runners se inscribieron en periodos de una semana
SELECT WEEK(registration_date, 1), COUNT(*) FROM runners GROUP BY WEEK(registration_date, 1);


-- Tiempo medio de recogida
SELECT AVG(MINUTE(TIMEDIFF(pickup_time, order_date))) FROM runner_orders LEFT JOIN customer_orders USING (order_id) WHERE cancellation IS NULL;

-- Relacion entre el numero de pizzas y el tiempo
WITH temp AS (SELECT AVG(MINUTE(TIMEDIFF(pickup_time, order_date))) AS PROMEDIO, SUM(pizza_id) AS TOTAL FROM runner_orders LEFT JOIN customer_orders USING (order_id) WHERE cancellation IS NULL GROUP BY order_id)

SELECT AVG(PROMEDIO), TOTAL FROM temp GROUP BY TOTAL;

-- Distancia recorrida por cada cliente

SELECT customer_id, AVG(DISTANCE) FROM runner_orders LEFT JOIN customer_orders USING (order_id) WHERE DISTANCE IS NOT NULL GROUP BY customer_id ;

-- Diferencia entre pedido que mas ha tardado y el que menos
SELECT MAX(duration) - MIN(duration) AS DIFERENCIA FROM runner_orders;

-- Velocidad media de cada repartidor por cada pedido
SELECT order_id, runner_id, CONCAT(ROUND((distance / duration) * 60, 2), ' km/h') AS Velocidad FROM runner_orders WHERE cancellation IS NULL;

-- Media de velocidad
SELECT order_id, runner_id, CONCAT(ROUND((distance / duration) * 60, 2), ' km/h') AS Velocidad FROM runner_orders LEFT JOIN customer_orders USING (order_id) WHERE cancellation IS NULL;

-- Porcentaje de envios exisotos
WITH temp AS (SELECT COUNT(*) AS PEDIDOS_COMPLETOS, runner_id FROM runner_orders WHERE cancellation IS NULL GROUP BY runner_id)

SELECT runner_id, CONCAT(FORMAT(PEDIDOS_COMPLETOS / COUNT(*) * 100, 1), ' %') FROM runner_orders LEFT JOIN temp USING (runner_id) GROUP BY runner_id;

--
```
