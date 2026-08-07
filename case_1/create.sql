-- Es necesario tener acceso a una cuenta con permisos para crear el usuari y darle permisos sobre la nueva tabla
-- Crea el usuario 
CREATE USER 'usr'@'%' IDENTIFIED BY PASSWORD 'pwd';

-- Crea la base de datos
CREATE DATABASE IF NOT EXISTS 'db1';

-- Otorga todos los permisos sobre la base de datos que se ha creado
GRANT ALL ON db1.* TO 'usuario'@'%';

-- Nos movemos a la base de datos
USE db1;

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
    `customer_id` VARCHAR(1),
    `order_date` DATE,
    `product_id` INT,
    CONSTRAINT `product_id_fk` FOREIGN KEY (`product_id`) REFERENCES menu (`product_id`) ON UPDATE NO ACTION ON DELETE NO ACTION
);


-- Datos para las tablas

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
