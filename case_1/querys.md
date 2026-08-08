## 1. Cantidad total que ha gastado cada cliente en el restaurante

```sql
SELECT customer_id, SUM(m.price) AS consumiciones_totales
FROM sales s
    LEFT JOIN menu m ON s.product_id = m.product_id
GROUP BY customer_id;
```

### Explicación

Se hace un **LEFT JOIN** para volcar los datos de los productos en la tabla
`menu` y poder obtener el precio. Se agrupan los datos por el id del cliente y
con la función suma se obtiene el total de cada cliente.

### Resultado

| customer_id | consumiciones_totales |
| :---------: | :-------------------: |
|      A      |          76           |
|      B      |          74           |
|      C      |          36           |

## 2. Cuantos días ha visitado cada cliente el restaurante

```sql
Select customer_id,
    count(DISTINCT order_date) AS dias_visitados
FROM sales
GROUP BY customer_id;
```

### Explicación

Se agrupa por el id del ciente y se hace la cuenta de las fecha en las que ha
realizado un pedido. Se usa **DISTINCT** para evitar que tenga en cuenta los las
fechas donde ha se ha realizado mas de un pedido.

### Resultado

| customer_id | dias_visitados |
| :---------: | :------------: |
|      A      |       4        |
|      B      |       6        |
|      C      |       2        |

## 3. Cual ha sido el primer producto ordenado por cada cliente

```sql
SELECT customer_id,
    product_name
FROM sales s
    LEFT JOIN menu m ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY order_date;
```

### Explicación

Se agrupa por el id del cliente y se ordena por la fecha para que que el
producto que muestre sea el primero que se ha ordenado.

### Resultado

| customer_id | product_name |
| :---------: | :----------: |
|      A      |    sushi     |
|      B      |    curry     |
|      C      |    ramen     |

### 2º Forma

```sql
WITH temp AS (
    SELECT customer_id,
        MIN(order_date) AS first_order_date
    FROM sales
    GROUP BY customer_id
)

SELECT s.customer_id,
    t.first_order_date,
    m.product_name
FROM sales s
    INNER JOIN temp t ON s.customer_id = t.customer_id
    AND s.order_date = t.first_order_date
    LEFT JOIN menu m ON s.product_id = m.product_id;
```

### Explicación

La primera forma solo mostraba el primer producto en base de datos, si el
cliente pidió mas de un producto el primer día, no lo mostrará.

Primero se almacena en un CTE[^1] la información de cada cliente, su ID y la
primera fecha en el que realizó una orden. En la siguiente consulta se cruza los
datos de las tabla de `sales` con los de la tabla temporal para obtener los
productos del ordenados en la primera vez. El **LEFT JOIN** simplemente permite
obtener el nombre del producto.

### Resultado

| customer_id | first_order_date | product_name |
| :---------: | :--------------: | :----------: |
|      A      |    2021-01-01    |    sushi     |
|      A      |    2021-01-01    |    curry     |
|      B      |    2021-01-01    |    curry     |
|      C      |    2021-01-01    |    ramen     |
|      C      |    2021-01-01    |    ramen     |

## 4. Cual es el producto mas comprado y cuantas veces ha sido comprado por todos los consumidores

```sql
-- 4 - Cual es el producto mas comprado y cuantas veces ha sido comprado por todos los consumidores -- ** Podria hacerse order by sobre la consulta y un limit, pero en caso de 2 elementos con el mismo volumen de ventas solo mostraria el primero.-- ** Usando rank ambos elementos tendrian un valor de 1 y la query mostraria ambos productos 
WITH temp AS (
        SELECT product_id,
            COUNT(product_id) AS TOTAL,
            RANK() OVER (
                ORDER BY TOTAL DESC
            ) AS rank
        FROM sales s
        GROUP BY product_id
    )

SELECT product_name,
    TOTAL
FROM menu m
    JOIN temp t ON m.product_id = t.product_id
WHERE rank = 1;
```

### Explicación

En la tabla temporal, se agrupa los datos de la tabla ventas por el id de
producto y se hace cuenta cuantas veces aparece cada uno. Con la función ventana[^2]
se calcula el rango de cada producto usando el **TOTAL** calculado anterior
mente.

Después se hace una selección sobre el la tabla temporal donde se obtiene el
producto filtra por el rango 1. El join permite obtener el nombre del producto
de la tabla `menu`.

\* Otra forma de obtener el producto mas comprado es usando un order by y un
limit de 1. Sin embargo, si 2 productos estuvieran igualados, limit solo
mostraría 1 de ellos, mientras que rank le asignaría 1 a ambos. Permitiendo
recuperar los 2.

### Resultado

| product_name | TOTAL |
| :----------: | :---: |
|    ramen     |   8   |

## 5. Cual ha sido el producto mas popular entre cada consumidor

```sql
WITH temp AS (
    SELECT customer_id,
        product_id,
        COUNT(product_id) AS TOTAL,
        RANK() OVER(
            PARTITION BY customer_id
            ORDER BY TOTAL DESC
        ) AS rank
    FROM sales
    GROUP BY customer_id,
        product_id
)

SELECT customer_id,
    product_name,
    TOTAL
FROM menu m
    RIGHT JOIN temp t ON m.product_id = t.product_id
WHERE rank = 1;
```

### Explicación

En la tabla temporal selecciona de la tabla `sales` la cantidad de productos que
ha comprado cada cliente, agrupando primero por el id del cliente y después por
el id de producto. Con `COUNT(product_id)` se obtiene el total de productos por
cada cliente. Con rank se hace obtiene los productos mas consumidos, al
ordenarlo por el total y agruparlos por el id del cliente

### Resultado

| customer_id | product_name | TOTAL |
| :---------: | :----------: | :---: |
|      A      |    ramen     |   3   |
|      B      |    sushi     |   2   |
|      B      |    curry     |   2   |
|      B      |    ramen     |   2   |
|      C      |    ramen     |   3   |

## 6. Primer producto comprado después convertirse en miembro

```sql
--  --Dependiendo de si en la fecha usas un mayor o igual o simplemente mayor obtendras resultados distintos para el cliente A 
WITH temp AS (
    SELECT product_id,
        customer_id,
        RANK() OVER (
            PARTITION BY s.customer_id
            ORDER BY order_date
        ) AS rank
    FROM sales s
        INNER JOIN members m USING (customer_id)
    WHERE join_date <= order_date
)
SELECT customer_id,
    product_name
FROM temp t
    LEFT JOIN menu m ON t.product_id = m.product_id
WHERE rank = 1;
```

### Explicación

En la tabla temporal se obtiene el id del producto y el id del consumidor de la
tabla `sales`. También se clasifican los pedidos por el por el id del usuario y
ordenándolo por por la fecha del pedido. Se hace un **INNER JOIN** con `members`
para obtener el join_date y saber la fecha en que se registraron. El uso de la
palabra clave USING evita tener hacer las relaciones[^3].

Luego seleccionamos el id del cliente y el nombre del producto obtenido por un
**LEFT JOIN**. Se filtra unicamente los productos clasificados con el valor 1.

### Resultado

| customer_id | product_name |
| :---------: | :----------: |
|      A      |    curry     |
|      B      |    sushi     |

## 7. El ultimo producto que el cliente compro antes de convertirse en miembro --

```sql
WITH temp AS (
        SELECT *,
            RANK() OVER (
                PARTITION BY s.customer_id
                ORDER BY order_date DESC
            ) AS rank
        FROM sales s
            INNER JOIN members m USING (customer_id)
        WHERE join_date > order_date
    )

SELECT customer_id,
    product_name
FROM temp t
    LEFT JOIN menu m ON t.product_id = m.product_id
WHERE rank = 1;
```

### Explicación

La lógica es casi igual al punto anterior, cambia el orden dentro del **OVER**
que pasa a ser DESC y la comparación con las fechas de `join_date` y
`order_date` que se invierten. El resto se mantiene igual.

### Resultado

|                                     customer_id                                      | product_name |
| :----------------------------------------------------------------------------------: | :----------: |
|                                          A                                           |    sushi     |
|                                          A                                           |    curry     |
|                                          B                                           |    sushi     |
| What is the total items and amount spent for each member before they became a member |              |

## 8. Total de productos y cantidad gastada por cada miembros antes de convertirse en miembro

```sql
SELECT customer_id,
    count(product_id) AS TOTAL_PRODUCTOS,
    SUM(price) AS TOTAL_GASTADO
FROM sales s
    INNER JOIN members mb USING (customer_id)
    LEFT JOIN menu m USING(product_id)
where order_date < join_date
GROUP BY customer_id;
```

### Explicación

Se obtiene el id del cliente, la cuenta de los productos, ademas de la suma de
precios. Se agrupa por el id del consumidor y se filtra por la fecha del pedido
anterior a la fecha en que el cliente se hizo miembro. Con el **INNER JOIN** a
la tabla `members` se filtra para mostrar unicamente los miembros. Y el **LEFT
JOIN** a la tabla `menu` nos permite obtener el precio de los productos.

### Resultado

| customer_id | TOTAL_PRODUCTOS | TOTAL_GASTADO |
| :---------: | :-------------: | :-----------: |
|      A      |        2        |      25       |
|      B      |        3        |      40       |

## 9. Si cada $1 gastado equivale a 10 puntos salvo el sushi que equivale a 2x - Puntos totales de cada consumidor

```sql
WITH temp AS (
    SELECT customer_id,
        CASE
            product_id
            WHEN 1 THEN price * 2 * 10
            ELSE price * 10
        END AS puntos
    FROM sales s
        LEFT JOIN menu m USING(product_id)
)

SELECT customer_id,
    SUM(puntos) AS TOTAL_PUNTOS
FROM temp
GROUP BY customer_id;
```

### Explicación

En la tabla temporal se obtiene el id del consumidor y usando **CASE** se
comprueba si el tipo de producto es sushi (que tiene el id **1**) o no, después
se multiplica el precio por **10** o **20**, dependiendo del producto, para
obtener los puntos resultantes. Se utiliza un **LEFT JOIN** para obtener el
precio.

Después se hace un nuevo SELECT sobre la tabla temporal y se agrupa por el id
del cliente. El `SUM(puntos)` devuelve el total de puntos del cliente.

### Resultado

| customer_id | TOTAL_PUNTOS |
| :---------: | :----------: |
|      A      |     860      |
|      B      |     940      |
|      C      |     360      |

## 10. La primera semana en que los clientes se unieron al programa (incluyendo el dia en que lo hicieron) ganan 2x puntos en cada producto, no solo el sushi, ¿ Cuantos puntos tiene los clientes A y B al final de enero ?

```sql
SELECT customer_id,
    SUM(
        CASE
            WHEN product_id = 1 THEN price * 2 * 10
            WHEN order_date BETWEEN join_date AND ADDDATE(join_date, 6) THEN price * 2 * 10
            ELSE price * 10
        END
    ) AS PUNTOS
FROM sales s
    LEFT JOIN menu m USING(product_id)
    INNER JOIN members USING (customer_id)
WHERE MONTH(order_date) = 1
GROUP BY customer_id;
```

### Explicación

Se obtiene el id del consumidor, con case se calcula, si el producto es sushi el
precio se multiplica por 20, si la fecha de cuando se realizo la orden esta
comprendida entre al fecha que se hizo miembro y una semana posterior también se
multiplica el precio por 20 de lo contrario el precio se multiplica por 10. El
**INNER JOIN** filtra los clientes que son miembros, y el **LEFT JOIN** permite
obtener el precio. Las fecha del pedido se filtra para que corresponda solo al
mes de enero e ignore los pedidos de febrero.

### Resultado

| customer_id | PUNTOS |
| :---------: | :----: |
|      A      |  1370  |
|      B      |  820   |

## Pregunta bonus 1

Recrear la siguiente tabla

<details>
<summary>Tabla para recrear</summary>

| customer_id | order_date | product_name | price | member |
| :---------: | :--------: | :----------: | :---: | :----: |
|      A      | 2021-01-01 |    curry     |  15   |   N    |
|      A      | 2021-01-01 |    sushi     |  10   |   N    |
|      A      | 2021-01-07 |    curry     |  15   |   Y    |
|      A      | 2021-01-10 |    ramen     |  12   |   Y    |
|      A      | 2021-01-11 |    ramen     |  12   |   Y    |
|      A      | 2021-01-11 |    ramen     |  12   |   Y    |
|      B      | 2021-01-01 |    curry     |  15   |   N    |
|      B      | 2021-01-02 |    curry     |  15   |   N    |
|      B      | 2021-01-04 |    sushi     |  10   |   N    |
|      B      | 2021-01-11 |    sushi     |  10   |   Y    |
|      B      | 2021-01-16 |    ramen     |  12   |   Y    |
|      B      | 2021-02-01 |    ramen     |  12   |   Y    |
|      C      | 2021-01-01 |    ramen     |  12   |   N    |
|      C      | 2021-01-01 |    ramen     |  12   |   N    |
|      C      | 2021-01-07 |    ramen     |  12   |   N    |

</details>

```sql
SELECT customer_id,
    order_date,
    product_name,
    price,
    CASE
        WHEN join_date IS NULL
        OR join_date > order_date THEN 'N'
        ELSE 'Y'
    END AS members
FROM sales
    LEFT JOIN members USING (customer_id)
    LEFT JOIN menu USING (product_id)
ORDER BY customer_id,
    order_date,
    price DESC;
```

### Explicación

De la tabla `sales` se obtiene la mayoría de los datos, se usa la tabla
`members` para saber si el cliente era miembro cuando ser realizo el pedido o
no. Y de la tabla menú se obtienen los precios. En el case se muestra N si en la
fecha en la que se realizo es anterior a la fecha en la que se hizo miembro,
para los casos donde nunca ha sido miembro se comprueba si **join_date** es
null. Por ultimo se ordena por la fecha del pedido y el precio de mayor a menor.

### Resultado

| customer_id | order_date | product_name | price | members |
| :---------: | :--------: | :----------: | :---: | :-----: |
|      A      | 2021-01-01 |    curry     |  15   |    N    |
|      A      | 2021-01-01 |    sushi     |  10   |    N    |
|      A      | 2021-01-07 |    curry     |  15   |    Y    |
|      A      | 2021-01-10 |    ramen     |  12   |    Y    |
|      A      | 2021-01-11 |    ramen     |  12   |    Y    |
|      A      | 2021-01-11 |    ramen     |  12   |    Y    |
|      B      | 2021-01-01 |    curry     |  15   |    N    |
|      B      | 2021-01-02 |    curry     |  15   |    N    |
|      B      | 2021-01-04 |    sushi     |  10   |    N    |
|      B      | 2021-01-11 |    sushi     |  10   |    Y    |
|      B      | 2021-01-16 |    ramen     |  12   |    Y    |
|      B      | 2021-02-01 |    ramen     |  12   |    Y    |
|      C      | 2021-01-01 |    ramen     |  12   |    N    |
|      C      | 2021-01-01 |    ramen     |  12   |    N    |
|      C      | 2021-01-07 |    ramen     |  12   |    N    |

## Pregunta bonus 1

Recrear la siguiente tabla

<details>
<summary>Tabla para recrear</summary>

| customer_id | order_date | product_name | price | members | ranking |
| :---------: | :--------: | :----------: | :---: | :-----: | :-----: |
|      A      | 2021-01-01 |    curry     |  15   |    N    |  null   |
|      A      | 2021-01-01 |    sushi     |  10   |    N    |  null   |
|      A      | 2021-01-07 |    curry     |  15   |    Y    |    1    |
|      A      | 2021-01-10 |    ramen     |  12   |    Y    |    2    |
|      A      | 2021-01-11 |    ramen     |  12   |    Y    |    3    |
|      A      | 2021-01-11 |    ramen     |  12   |    Y    |    3    |
|      B      | 2021-01-01 |    curry     |  15   |    N    |  null   |
|      B      | 2021-01-02 |    curry     |  15   |    N    |  null   |
|      B      | 2021-01-04 |    sushi     |  10   |    N    |  null   |
|      B      | 2021-01-11 |    sushi     |  10   |    Y    |    1    |
|      B      | 2021-01-16 |    ramen     |  12   |    Y    |    2    |
|      B      | 2021-02-01 |    ramen     |  12   |    Y    |    3    |
|      C      | 2021-01-01 |    ramen     |  12   |    N    |  null   |
|      C      | 2021-01-01 |    ramen     |  12   |    N    |  null   |
|      C      | 2021-01-07 |    ramen     |  12   |    N    |  null   |

</details>

```sql
WITH temp as ( 
SELECT customer_id,
order_date,
product_name,
price,
CASE
    WHEN join_date IS NULL
    OR join_date > order_date THEN 'N'
    ELSE 'Y'
END AS member
FROM sales
    LEFT JOIN members USING (customer_id)
    LEFT JOIN menu USING (product_id)
)


Select *,
    CASE
        member
        WHEN 'Y' THEN rank() over(
            PARTITION BY customer_id,
            member
            order by order_date
        )
        ELSE NULL
    END AS ranking
from temp
ORDER BY customer_id,
    order_date,
    price DESC
```

### Explicación

La tabla temporal es similar a la anterior comprobando si es miembro y
obteniendo los datos del precio. En la siguiente consulta, comprueba si es
miembro, en caso de serlo se hace una clasificación por el id del usuario y
después por si los miembros, en caso de no ser miembro se muestra un null. Por
ultimo se ordena por el id, la fecha del pedido y el precio de mayor a menor.

### Resultado

| customer_id | order_date | product_name | price | members | ranking |
| :---------: | :--------: | :----------: | :---: | :-----: | :-----: |
|      A      | 2021-01-01 |    curry     |  15   |    N    |  null   |
|      A      | 2021-01-01 |    sushi     |  10   |    N    |  null   |
|      A      | 2021-01-07 |    curry     |  15   |    Y    |    1    |
|      A      | 2021-01-10 |    ramen     |  12   |    Y    |    2    |
|      A      | 2021-01-11 |    ramen     |  12   |    Y    |    3    |
|      A      | 2021-01-11 |    ramen     |  12   |    Y    |    3    |
|      B      | 2021-01-01 |    curry     |  15   |    N    |  null   |
|      B      | 2021-01-02 |    curry     |  15   |    N    |  null   |
|      B      | 2021-01-04 |    sushi     |  10   |    N    |  null   |
|      B      | 2021-01-11 |    sushi     |  10   |    Y    |    1    |
|      B      | 2021-01-16 |    ramen     |  12   |    Y    |    2    |
|      B      | 2021-02-01 |    ramen     |  12   |    Y    |    3    |
|      C      | 2021-01-01 |    ramen     |  12   |    N    |  null   |
|      C      | 2021-01-01 |    ramen     |  12   |    N    |  null   |
|      C      | 2021-01-07 |    ramen     |  12   |    N    |  null   |

[^1]: Tablas temporales que existen unicamente mientras se realiza la consulta [documentación](https://mariadb.com/docs/server/reference/sql-statements/data-manipulation/selecting-data/common-table-expressions).

[^2]: Funciones que permiten realizar cálculos sobre un conjunto de filas sin agruparlas en un mismo valor [documentación](https://mariadb.com/docs/server/reference/sql-functions/special-functions/window-functions/window-functions-overview).

[^3]: Permite indicar columnas compartidas entre tablas, en los **JOINS**, cuando estas comparten el mismo nombre y tipo. Página [data camp](https://www.datacamp.com/doc/mysql/mysql-using) explicando la palabra **USING**.
