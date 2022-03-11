CREATE DATABASE IF NOT EXISTS `zrp_framework`;
USE `zrp_framework`;

CREATE TABLE `users` (
	`identifier` VARCHAR(40) NOT NULL,
	`group` VARCHAR(50) NULL DEFAULT 'user',
	`inventory` LONGTEXT NULL DEFAULT NULL,
	`position` VARCHAR(255) NULL DEFAULT '{"x":-269.4,"y":-955.3,"z":31.2,"heading":205.8}',

	PRIMARY KEY (`identifier`)
);