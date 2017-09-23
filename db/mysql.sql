CREATE DATABASE usuarios DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON usuarios.* TO 'wso2'@'%' WITH GRANT OPTION;

create table users 
(username varchar(100) not null primary key,
password varchar(100),
nombre   varchar(100) not null,
apel1    varchar(100) not null,
apel2    varchar(100),
telefono varchar(9));

insert into users values (
'admin',
'42d9d2622f862cd803d4395be2c1edd362213525', --temporal
'admin',
'temporal',
null,
'986123456');
