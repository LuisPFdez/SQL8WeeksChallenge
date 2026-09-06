# **Case Study #1 - Danny's Diner**

## Creación de las tablas

Las tablas para este reto son:
1. Menú (*Menu*) Guarda el id del producto, su nombre y su precio
2. Miembros(*Members*) Guarda el id del cliente y la fecha en que se registro.
3. Ventas(*Sales*) Guarda el cliente que ha realizado la compra, la fecha de compra, el id del producto comprado. Ademas de relacionar las tablas[^1]

### Relaciones
1. La tabla `sales` se relaciona con la tabla `members` a traves del **customer_id**, presente en ambas tablas. Aunque para esta relación no se usa una Foreign key por que hay ventas con clientes que no están dentro de la tabla `members`.
2. La tabla `sales` se relaciona con la tabla `menu` a traves de **product_id** presente en ambas tablas.

## Diagrama 
[Diagrama de Danny](https://dbdiagram.io/d/Dannys-Diner-608d07e4b29a09603d12edbd)

```mermaid
---
tittle: Danny's Dinner
---
erDiagram
   direction RL

    SALES }o--o| MEMBERS : -
    SALES }|--|| MENU : -

    SALES {
        VARCHAR(1) customer_id
        DATE order_date
        INT product_id
    }

    MEMBERS {
        VARCHAR(1) customer_id
        TIMESTAMP join_date
    }

    MENU {
        INT product_id
        VARCHAR(5) product_name
        INT price
    }
```

```sql
CREATE TABLE IF NOT EXISTS menu (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(5),
    price INT
);

CREATE TABLE IF NOT EXISTS members (
    customer_id VARCHAR(1) PRIMARY KEY,
    join_date TIMESTAMP
);

create TABLE IF NOT EXISTS sales (
    customer_id VARCHAR(1),
    order_date DATE,
    product_id INT,
    CONSTRAINT `product_id_fk` FOREIGN KEY (`product_id`) REFERENCES menu (`product_id`) ON UPDATE NO ACTION ON DELETE NO ACTION
);
```

## Carga de datos

```sql
INSERT INTO menu VALUES
(1, 'sushi', 10),
(2,	'curry', 15),
(3, 'ramen',	12);

INSERT INTO members VALUES
('A', '2021-01-07'),
('B', '2021-01-09');

INSERT INTO sales VALUES
('A', '2021-01-01', 1),
('A', '2021-01-01', 2),
('A', '2021-01-07', 2),
('A', '2021-01-10', 3),
('A', '2021-01-11', 3),
('A', '2021-01-11', 3),
('B', '2021-01-01', 2),
('B', '2021-01-02', 2),
('B', '2021-01-04', 1),
('B', '2021-01-11', 1),
('B', '2021-01-16', 3),
('B', '2021-02-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-07', 3);
```

[^1]: Solo se ha hecho la relación de los productos, pues en el caso de los consumidores pueden no estar registrados como miembros. 
