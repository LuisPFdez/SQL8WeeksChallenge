# DESAFÍO SQL 8 SEMANAS

Repositorio con las respuestas al desafío [8 weeks sql challenge](https://8weeksqlchallenge.com/) de Data with Danny

Cada caso se compone de los scripts para cargar la información y las soluciones de cada pregunta.

## Preparación de entorno
Para el reto se creará un nuevo usuario y una base de datos sobre la que poder crear y modificar las tablas

La base de datos será [MariaDB](https://mariadb.org/) en un servidor en LAN de Linux. 

Para crear el usuario y la base de datos del reto es necesario tener permisos de: 
* `Create user` para crear el usuario
* `Create` para crear la base de datos
* `Grant option` para otorgar los permisos

El comando `sudo mariadb` nos conectará directamente como root a la base de datos. 
El siguiente script creara un entorno mas controlado: 
1. Crea el usuario con la contraseña 'pwd' 
2. Crea la base de datos db1
3. Otorga todos los permisos al usuario usr sobre la base de datos db1

```sql
CREATE USER 'usr'@'%' IDENTIFIED BY PASSWORD 'pwd';

CREATE DATABASE IF NOT EXISTS 'db1';

GRANT ALL ON db1.* TO 'usuario'@'%';
```

En caso de usar directamente un script es necesario usar `USE db1;` en caso de usar un cliente no será necesario, bastará con indicarle que base de datos usar

Los clientes utilizados han sido [HeidiSQL](https://www.heidisql.com/) y [sqltools](https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools) de visual studio code.

## **Case Study #1 - Danny's Diner**
[Scripts iniciales](/case_1/create.md)