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

### 1. Cuantas pizzas se han pedido

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

### 2. Cuantas ordenes únicas se han realizado

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

### 3. Cuantas ordenes satisfactorias ha realizado cada corredor

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

### 4. Cuantas pizzas de cada tipo han sido enviadas

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

### 5. Cuantas Vegetarian y MeatLover han sido pedidas por cada consumidor

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

Se agrupa por el id del consumidor y el id de la pizza para obtener el total de
cada tipo de pizza que ha pedido. Se hace un **LEFT JOIN** para obtener el
nombre de las pizzas

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

### 6. Cual es el máximo de pizzas enviadas en una misma orden

```sql
WITH temp AS (
    SELECT order_id,
        COUNT(pizza_id) as TOTAL,
        RANK() OVER(
            ORDER BY TOTAL DESC
        ) AS RANK
    FROM customer_orders
    GROUP BY order_id
)

SELECT order_id,
    TOTAL AS TOTAL_PIZZAS
FROM temp
WHERE RANK = 1;
```

#### Explicación

Se obtienen los datos de `customer_orders`, agrupando las ordenes por su id, se
cuenta el total de pedidos por cada orden y se clasifican según el valor de la
cuenta **TOTAL**, se indica que el orden es descendiente para que la
clasificación sea de mayor a menor. Se almacena en una CTE y se filtra por el
rango 1 que será la orden/ordenes con pizzas enviadas a la vez.

#### Resultado

| order_id | TOTAL_PIZZAS |
| :------: | :----------: |
|    4     |      3       |

### 7. Por cada consumidor, cuantas pizzas enviadas tienen al menos un cambio y cuantas no tienen cambios

```sql
WITH temp AS(
    SELECT count(*) AS TOTAL_CAMBIOS,
        co.customer_id
    FROM customer_orders co
        INNER JOIN runner_orders ro USING (order_id)
    WHERE (
            co.exclusions IS NOT NULL
            OR co.extras IS NOT NULL
        )
        AND ro.cancellation IS NULL
    GROUP BY co.customer_id
),
temp2 AS (
    SElECT COUNT(*) AS TOTAL_PEDIDOS,
        co.customer_id
    FROM customer_orders co
        INNER JOIN runner_orders ro USING (order_id)
    WHERE ro.cancellation IS NULL
    GROUP BY co.customer_id
)

SELECT customer_id,
    TOTAL_PEDIDOS,
    IFNULL(TOTAL_CAMBIOS, 0) as 'PEDIDOS CON CAMBIOS',
    (TOTAL_PEDIDOS - IFNULL(TOTAL_CAMBIOS, 0)) AS 'PEDIDOS SIN CAMBIOS'
FROM temp2
    LEFT JOIN temp USING (customer_id);
```

#### Explicación

Se realizan varias consultas para poder simplificar la tarea.

La primera consulta obtiene el numero de pedidos, realizados por cada cliente,
cuya columna de **extras** o **exclusiones** era distinta de null. También se
comprobaba que la orden del runner no había sido cancelada. La segunda consulta
simplemente calcula el total de pizzas que ha pedido cada cliente, comprobando
de nuevo que la orden no haya sido cancelada.

En la ultima consulta se obtienen los datos de las 2 anteriores CTE, se utiliza
un `LEFT JOIN` de la primera CTE sobre la segunda, pues la segunda CTE contiene
los pedidos de todos los clientes. Como los datos de la primera CTE pueden ser
nulos, con IFNULL se establecen a 0, para que si un cliente no ha realizado
ningún cambio en cualquiera de sus pedidos, se cuente como 0.

#### Resultado

| customer_id | TOTAL_PEDIDOS | PEDIDOS CON CAMBIOS | PEDIDOS SIN CAMBIOS |
| :---------: | :-----------: | :-----------------: | :-----------------: |
|     101     |       2       |          0          |          2          |
|     102     |       3       |          0          |          3          |
|     103     |       3       |          3          |          0          |
|     104     |       3       |          2          |          1          |
|     105     |       1       |          1          |          0          |

### 8. Cuantas pizzas han sido entregadas que con extras y exclusiones

```sql
-- 
SELECT COUNT(*) AS TOTAL
FROM customer_orders cu
    LEFT JOIN runner_orders ro USING(order_id)
WHERE exclusions IS NOT NULL
    AND extras IS NOT NULL
    AND cancellation IS NOT NULL;
```

#### Explicación

De la tabla `customer_orders` se obtienen la pizza que tenga tanto un añadido
como una exclusion, se hace un left join con la tabla `exclusions` para excluir
a los pizzas que han sido cancelas

#### Resultado

| TOTAL |
| :---: |
|   1   |

### 9. Cual es el total de pizzas pedidas por cada hora del dia

```sql
WITH temp AS (
    SELECT pizza_id,
        HOUR(order_date) AS HORA
    FROM customer_orders
        INNER JOIN runner_orders ro USING (order_id)
    WHERE ro.cancellation IS NULL
)

SELECT HORA,
    SUM(pizza_id) AS TOTAL_PIZZAS
FROM temp
GROUP BY HORA
```

#### Explicación

En una tabla temporal se obtiene la hora del dia y el `pizza_id`, se hace un
inner join para eliminar las pizzas que han sido canceladas.

En el siguiente select se agrupa por la hora del dia y se muestran la hora y el
numero total de pizzas que se han pedido esa pizza

#### Resultado

| HORA | TOTAL_PIZZAS |
| :--: | :----------: |
|  13  |      4       |
|  18  |      3       |
|  19  |      1       |
|  21  |      3       |
|  23  |      4       |

### 10. Total de pizzas pedidas cada dia de la semana

```sql
-- Pizzas por dia
SET lc_time_names = 'es_ES';
WITH temp AS (
    SELECT pizza_id,
        DAYNAME(order_date) AS DIA,
        WEEKDAY(order_date) as NUM_DIA
    FROM customer_orders
        INNER JOIN runner_orders ro USING (order_id)
    WHERE ro.cancellation IS NULL
)

SELECT UPPER(DIA) AS DIA,
    SUM(pizza_id) AS TOTAL_PIZZAS
FROM temp
GROUP BY NUM_DIA
ORDER BY NUM_DIA;
```

#### Explicación

El `SET lc_time_names = 'es_ES';` establece los nombre de los días en español
para la sesión por si no están ya establecidos.

Se obtiene de `customer_orders` el id de cada pizza pedida, el nombre del día y
el día de la semana en el que se realizo la orden y se comprueba que el pedido
no haya sido cancelado.

En la siguiente consulta se agrupa por el numero del dia de la semana y también
se ordena por este. Se hace un upper para mostrar el nombre del dia en mayúscula
y se muestra el numero de pizzas totales pedidas en ese dia.

|   DIA   | TOTAL_PIZZAS |
| :-----: | :----------: |
|  LUNES  |      6       |
| VIERNES |      5       |
| SÁBADO  |      4       |

#### Resultado

```sql
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

```sql
-- Funcione moito importatne 
DELIMITER $$
CREATE OR REPLACE FUNCTION convertirAJson(texto VARCHAR(255)) RETURNS JSON DETERMINISTIC
BEGIN
	RETURN JSON_EXTRACT(CONCAT('[ "', REPLACE(texto, ', ', '", "'), '" ]'), '$[*]');
END$$

DELIMITER ;

with temp as (SELECT pizza_id, topping_id
FROM pizza_recipes CROSS
JOIN JSON_TABLE(convertirAJSON(toppings), '$[*]' COLUMNS(topping_id INT PATH '$')) AS JSON_TAB)

SELECT pizza_id, GROUP_CONCAT(topping_name SEPARATOR ', ') FROM temp t LEFT JOIN  pizza_toppings pt USING(topping_id) GROUP BY pizza_id;

-- Metricas punto 3
 
with temp as (SELECT extrass
FROM customer_orders CROSS
JOIN JSON_TABLE(convertirAJSON(extras), '$[*]' COLUMNS(extra INT PATH '$')) AS JSON_TAB),
temp2 as (SELECT count(extra) as TOTAL, extra, RANK() OVER (ORDER BY TOTAL DESC) as rango from temp GROUP BY extra)

SELECT extra, pt.topping_name, TOTAL from temp2 INNER JOIN pizza_toppings pt ON pt.topping_id = extra where rango = 1;


-- Extra mas añadido

with temp as (
    Select COUNT(extra) AS TOTAL,
        extra as topping_id,
        RANK() OVER (
            ORDER BY TOTAL DESC
        ) AS RANGO
    FROM customer_orders co
        CROSS JOIN JSON_TABLE(
            convertirAJSON(co.extras),
            '$[*]' COLUMNS(extra INT PATH '$')
        ) AS JSON_TAB
    GROUP BY extra
)

SELECT topping_id,
    TOTAL,
    topping_name
FROM temp
    INNER JOIN pizza_toppings USING (topping_id)
WHERE RANGO = 1;

-- Exclusion mas usada

with temp as (
    Select COUNT(exclusion) AS TOTAL,
        exclusion as topping_id,
        RANK() OVER (
            ORDER BY TOTAL DESC
        ) AS RANGO
    FROM customer_orders co
        CROSS JOIN JSON_TABLE(
            convertirAJSON(co.exclusions),
            '$[*]' COLUMNS(exclusion INT PATH '$')
        ) AS JSON_TAB
    GROUP BY exclusion
)

SELECT topping_id,
    TOTAL,
    topping_name
FROM temp
    INNER JOIN pizza_toppings USING (topping_id)
WHERE RANGO = 1;



-- Esta mierda me ha costado mas de lo que deberia

WITH temp as (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY order_id) AS ROW_ID
    FROM customer_orders
),
temp2 as (
    SELECT pizza_name,
        GROUP_CONCAT(DISTINCT tp1.topping_name SEPARATOR ', ') AS EXTRA_NAMES,
        GROUP_CONCAT(DISTINCT tp2.topping_name SEPARATOR ', ') AS EXCLUSION_NAMES
    FROM temp co
        LEFT JOIN JSON_TABLE(
            convertirAJSON(co.extras),
            '$[*]' COLUMNS(extra INT PATH '$')
        ) AS EXT_TAB ON TRUE
        LEFT JOIN JSON_TABLE(
            convertirAJSON(co.exclusions),
            '$[*]' COLUMNS(exclusion INT PATH '$')
        ) AS EXC_TAB ON TRUE
        LEFT JOIN pizza_toppings tp1 ON extra = tp1.topping_id
        LEFT JOIN pizza_toppings tp2 ON exclusion = tp2.topping_id
        INNER JOIN pizza_names pn USING(pizza_id)
    GROUP BY order_id,
        ROW_ID
)

Select CONCAT(
        pizza_name,
        IF(
            EXCLUSION_NAMES IS NOT NULL,
            CONCAT(' - Exclude ', EXCLUSION_NAMES),
            ''
        ),
        IF(
            EXTRA_NAMES IS NOT NULL,
            CONCAT(' - Extra ', EXTRA_NAMES),
            ''
        )
    )
FROM temp2;
```
