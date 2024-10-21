-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 16-09-2024 a las 22:49:49
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `test`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_deteccion_microorganismos` (`deteccion` INT)   begin
	delete from monitoreos_detecciones where id_deteccion_microorganismo=deteccion;
	delete from deteccion_microorganismos where id_deteccion_microorganismo=deteccion;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_producto` (IN `producto` VARCHAR(30))   begin
delete from entradas_productos where numero_registro_producto=producto;
delete from cajas_bioburden where id_prueba_recuento in (select id_prueba_recuento from pruebas_recuento where numero_registro_producto=producto);
delete from pruebas_recuento where numero_registro_producto=producto;
delete from controles_negativos_medios where numero_registro_producto=producto;
delete from monitoreos_detecciones where id_deteccion_microorganismo in (select id_deteccion_microorganismo from deteccion_microorganismos where numero_registro_producto=producto);
delete from deteccion_microorganismos where numero_registro_producto=producto;
delete from analisis where numero_registro_producto=producto;
delete from peticiones_cambio where numero_registro_producto=producto;
delete from productos where numero_registro_producto=producto;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_prueba_recuento` (`prueba` INT)   begin
	delete from cajas_bioburden where id_prueba_recuento=prueba;
	delete from pruebas_recuento where id_prueba_recuento=prueba;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `filtrar_log_accion` (`accion` VARCHAR(20))   select * from log_transaccional where accion = accion$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `filtrar_log_modulo` (`modulo` INT)   begin
select * from log_transaccional where id_modulo=modulo;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `filtrar_peticiones_cambio_estado` (IN `estado` VARCHAR(30))   select * from detalles_peticiones_cambio where nombre_estado=estado$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `filtrar_productos_categoria` (`categoria` VARCHAR(30))   begin
select * from registro_entrada_productos where numero_registro_producto like concat(categoria, '%');
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `filtrar_usuarios_estado_ingreso` (IN `estado_usuario` VARCHAR(10))   begin
select id_usuario, nombre_completo, nombre_usuario, rol_usuario, firma_usuario, fecha_inscripcion, estado from usuarios where estado=estado_usuario;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `numero_productos_analizados_ano` (`ano` INT)   begin
select u.nombre_completo, u.nombre_usuario, u.id_usuario, count(*) from usuarios as u join entradas_productos as ep on u.id_usuario=ep.id_usuario where ep.numero_registro_producto in (select numero_registro_producto from productos where id_modulo=8 or id_modulo=9) and YEAR(ep.fecha_final_analisis)=ano  group by u.id_usuario;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `numero_productos_analizados_mes` (IN `mes_final_analisis` INT)   begin
select u.nombre_completo, u.nombre_usuario, u.id_usuario, count(*) from usuarios as u join entradas_productos as ep on u.id_usuario=ep.id_usuario where ep.numero_registro_producto in (select numero_registro_producto from productos where id_modulo=8 or id_modulo=9) and MONTH(ep.fecha_final_analisis)=mes_final_analisis  group by u.id_usuario;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `numero_productos_analizados_semana` (`semana` INT)   begin
select u.nombre_completo, u.nombre_usuario, u.id_usuario, count(*) from usuarios as u join entradas_productos as ep on u.id_usuario=ep.id_usuario where ep.numero_registro_producto in (select numero_registro_producto from productos where id_modulo=8 or id_modulo=9) and WEEK(ep.fecha_final_analisis)=semana  group by u.id_usuario;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `peticiones_cambio_usuario` (IN `usuario` VARCHAR(15))   begin
select id_usuario, nombre_usuario, nombre_estado, count(*) as n_peticiones from detalles_peticiones_cambio where id_usuario=usuario group by nombre_estado;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rechazar_solicitud_registro_usuario` (`id` VARCHAR(15))   delete from usuarios where id_usuario=id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registro_producto` (IN `numero_registro_producto` VARCHAR(30), IN `nombre_producto` VARCHAR(30), IN `fecha_fabricacion` DATE, IN `fecha_vencimiento` DATE, IN `descripcion_producto` TEXT, IN `activo_producto` VARCHAR(50), IN `presentacion_producto` VARCHAR(30), IN `cantidad_producto` VARCHAR(15), IN `numero_lote_producto` VARCHAR(30), IN `tamano_lote_producto` VARCHAR(30), IN `id_cliente` INT, IN `id_fabricante` INT, IN `proposito_analisis` TEXT, IN `condiciones_ambientales` VARCHAR(30), IN `fecha_recepcion` DATE, IN `fecha_inicio_analisis` DATE, IN `id_usuario` VARCHAR(15))   begin
insert into productos(numero_registro_producto, nombre_producto, fecha_fabricacion, fecha_vencimiento, descripcion_producto, activo_producto, presentacion_producto, cantidad_producto, numero_lote_producto, tamano_lote_producto, id_cliente, id_fabricante)
values (numero_registro_producto, nombre_producto, fecha_fabricacion, fecha_vencimiento, descripcion_producto, activo_producto, presentacion_producto, cantidad_producto, numero_lote_producto, tamano_lote_producto, id_cliente, id_fabricante);
insert into entradas_productos(proposito_analisis, condiciones_ambientales, fecha_recepcion, fecha_inicio_analisis, numero_registro_producto, id_usuario)
values (proposito_analisis, condiciones_ambientales, fecha_recepcion, fecha_inicio_analisis, numero_registro_producto, id_usuario);
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `analisis`
--

CREATE TABLE `analisis` (
  `id_analisis` int(11) NOT NULL,
  `numero_registro_producto` varchar(30) DEFAULT NULL,
  `id_modulo` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `analisis_por_producto`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `analisis_por_producto` (
`numero_registro_producto` varchar(30)
,`nombre_producto` varchar(50)
,`nombre_modulo` varchar(100)
,`nombre_microorganismo` text
,`nombre_recuento` text
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cajas_bioburden`
--

CREATE TABLE `cajas_bioburden` (
  `id_caja_bioburden` int(11) NOT NULL,
  `codigo_caja_bioburden` varchar(10) DEFAULT 'CJB-',
  `tipo` varchar(15) NOT NULL,
  `resultado` varchar(15) DEFAULT NULL,
  `metodo_siembra` varchar(30) NOT NULL,
  `medida_aritmetica` varchar(15) NOT NULL,
  `fechayhora_incubacion` datetime NOT NULL,
  `fechayhora_lectura` datetime DEFAULT NULL,
  `factor_disolucion` varchar(5) DEFAULT NULL,
  `nombre_recuento` text NOT NULL,
  `id_prueba_recuento` int(11) NOT NULL,
  `id_usuario` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `cajas_bioburden`
--
DELIMITER $$
CREATE TRIGGER `delete_cajas_bioburden` BEFORE DELETE ON `cajas_bioburden` FOR EACH ROW BEGIN
declare numero_registro_producto, nombre_completo varchar(50);
set numero_registro_producto := (SELECT pr.numero_registro_producto from cajas_bioburden as cj join pruebas_recuento as pr on cj.id_prueba_recuento=pr.id_prueba_recuento where id_caja_bioburden=old.id_caja_bioburden), nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = old.id_usuario);



INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values
(
CONCAT('El usuario ', nombre_completo, ' elimino un resultado de  la prueba de recuento ', old.nombre_recuento ,' del producto ', (select nombre_producto from productos as pro WHERE pro.numero_registro_producto=numero_registro_producto),' con identificacion: ', numero_registro_producto),
 
JSON_object('tipo', old.tipo, 'resultado', old.resultado, 'metodo_siembra', old.metodo_siembra, 'medida_aritmetica', old.medida_aritmetica, 'fechayhora_incubacion', old.fechayhora_incubacion, 'fechayhora_lectura', old.fechayhora_lectura, 'factor_disolucion', old.factor_disolucion, 'nombre_recuento', old.nombre_recuento),
 
'eliminar', now(), 3, concat(old.codigo_caja_bioburden, old.id_caja_bioburden), numero_registro_producto);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_cajas_bioburden` AFTER INSERT ON `cajas_bioburden` FOR EACH ROW BEGIN
declare numero_registro_producto, nombre_completo varchar(50);
set numero_registro_producto := (SELECT pr.numero_registro_producto from cajas_bioburden as cj join pruebas_recuento as pr on cj.id_prueba_recuento=pr.id_prueba_recuento where id_caja_bioburden=new.id_caja_bioburden), nombre_completo:=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = new.id_usuario);




INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values
(
CONCAT('El usuario ', nombre_completo, ' registro un resultado de  la prueba de recuento ', new.nombre_recuento ,' del producto ', (select nombre_producto from productos as pro WHERE pro.numero_registro_producto=numero_registro_producto),' con identificacion: ', numero_registro_producto),
 
JSON_object('tipo', new.tipo, 'resultado', new.resultado, 'metodo_siembra', new.metodo_siembra, 'medida_aritmetica', new.medida_aritmetica, 'fechayhora_incubacion', new.fechayhora_incubacion, 'fechayhora_lectura', new.fechayhora_lectura, 'factor_disolucion', new.factor_disolucion, 'nombre_recuento', new.nombre_recuento),
 
'registrar', now(), 3, concat(new.codigo_caja_bioburden, new.id_caja_bioburden), numero_registro_producto);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_cajas_bioburden` BEFORE UPDATE ON `cajas_bioburden` FOR EACH ROW BEGIN
declare numero_registro_producto, nombre_completo varchar(50);
set numero_registro_producto := (SELECT pr.numero_registro_producto from cajas_bioburden as cj join pruebas_recuento as pr on cj.id_prueba_recuento=pr.id_prueba_recuento where id_caja_bioburden=new.id_caja_bioburden), nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = old.id_usuario);

INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values
(
CONCAT('El usuario ', nombre_completo, ' edito un resultado de  la prueba de recuento ', new.nombre_recuento ,' del producto ', (select nombre_producto from productos as pro WHERE pro.numero_registro_producto=numero_registro_producto),' con identificacion: ', numero_registro_producto),

JSON_OBJECT('registro_anterior', 
JSON_object('tipo', old.tipo, 'resultado', old.resultado, 'metodo_siembra', old.metodo_siembra, 'medida_aritmetica', old.medida_aritmetica, 'fechayhora_incubacion', old.fechayhora_incubacion, 'fechayhora_lectura', old.fechayhora_lectura, 'factor_disolucion', old.factor_disolucion, 'nombre_recuento', old.nombre_recuento), 
'registro_nuevo', 
JSON_object('tipo', new.tipo, 'resultado', new.resultado, 'metodo_siembra', new.metodo_siembra, 'medida_aritmetica', new.medida_aritmetica, 'fechayhora_incubacion', new.fechayhora_incubacion, 'fechayhora_lectura', new.fechayhora_lectura, 'factor_disolucion', new.factor_disolucion, 'nombre_recuento', new.nombre_recuento)),    


'editar', now(), 3, concat(new.codigo_caja_bioburden, new.id_caja_bioburden), numero_registro_producto);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `id_cliente` int(11) NOT NULL,
  `nombre_cliente` varchar(50) NOT NULL,
  `direccion_cliente` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `controles_negativos_medios`
--

CREATE TABLE `controles_negativos_medios` (
  `id_control_negativo` int(11) NOT NULL,
  `codigo_control_negativo` varchar(10) DEFAULT 'CNM-',
  `medio_cultivo` text DEFAULT NULL,
  `fechayhora_incubacion` datetime NOT NULL,
  `fechayhora_lectura` datetime DEFAULT NULL,
  `resultado` varchar(30) DEFAULT NULL,
  `id_usuario` varchar(15) NOT NULL,
  `numero_registro_producto` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `controles_negativos_medios`
--
DELIMITER $$
CREATE TRIGGER `delete_controles_negativos_medios` BEFORE DELETE ON `controles_negativos_medios` FOR EACH ROW BEGIN

declare nombre_completo varchar(50);
set nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = old.id_usuario);

INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values


(CONCAT('El usuario ', nombre_completo, ' elimino un control negativo de medio del producto ', (select nombre_producto from productos WHERE numero_registro_producto = old.numero_registro_producto), ' con indentificacion: ', old.numero_registro_producto),
 
 JSON_object('medio_cultivo', old.medio_cultivo, 'fechayhora_incubacion', old.fechayhora_incubacion, 'fechayhora_lectura', old.fechayhora_lectura, 'resultado', old.resultado, 'id_usuario', old.id_usuario, 'numero_registro_producto', old.numero_registro_producto),
 
'eliminar', now(), 4, concat(old.codigo_control_negativo, old.id_control_negativo), old.numero_registro_producto);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_controles_negativos_medios` AFTER INSERT ON `controles_negativos_medios` FOR EACH ROW BEGIN

declare nombre_completo varchar(50);
set nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = new.id_usuario);

INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values


(CONCAT('El usuario ', nombre_completo, ' registro un control negativo de medio del producto ', (select nombre_producto from productos WHERE numero_registro_producto = new.numero_registro_producto), ' con indentificacion: ', new.numero_registro_producto),
 
 JSON_object('medio_cultivo', new.medio_cultivo, 'fechayhora_incubacion', new.fechayhora_incubacion, 'fechayhora_lectura', new.fechayhora_lectura, 'resultado', new.resultado, 'id_usuario', new.id_usuario, 'numero_registro_producto', new.numero_registro_producto),
 
'registrar', now(), 4, concat(new.codigo_control_negativo, new.id_control_negativo), new.numero_registro_producto);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_controles_negativos_medios` BEFORE UPDATE ON `controles_negativos_medios` FOR EACH ROW BEGIN

declare nombre_completo varchar(50);
set nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = new.id_usuario);

INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values


(CONCAT('El usuario ', nombre_completo, ' edito un control negativo de medio del producto ', (select nombre_producto from productos WHERE numero_registro_producto = new.numero_registro_producto), ' con indentificacion: ', new.numero_registro_producto),

 JSON_OBJECT('registro_anterior',  JSON_object('medio_cultivo', old.medio_cultivo, 'fechayhora_incubacion', old.fechayhora_incubacion, 'fechayhora_lectura', old.fechayhora_lectura, 'resultado', old.resultado, 'id_usuario', old.id_usuario, 'numero_registro_producto', old.numero_registro_producto), 'registro_nuevo',  JSON_object('medio_cultivo', new.medio_cultivo, 'fechayhora_incubacion', new.fechayhora_incubacion, 'fechayhora_lectura', new.fechayhora_lectura, 'resultado', new.resultado, 'id_usuario', new.id_usuario, 'numero_registro_producto', new.numero_registro_producto)),
 
'editar', now(), 4, concat(new.codigo_control_negativo, new.id_control_negativo), new.numero_registro_producto);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `detalles_peticiones_cambio`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `detalles_peticiones_cambio` (
`id_peticion_cambio` int(11)
,`descripcion_peticion` longtext
,`fechayhora_creacion_peticion` datetime
,`id_usuario` varchar(15)
,`nombre_usuario` varchar(83)
,`nombre_estado` varchar(30)
,`nombre_modulo` varchar(100)
,`numero_registro_producto` varchar(30)
,`nombre_producto` varchar(50)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `deteccion_microorganismos`
--

CREATE TABLE `deteccion_microorganismos` (
  `id_deteccion_microorganismo` int(11) NOT NULL,
  `codigo_deteccion_microorganismo` varchar(10) DEFAULT 'DCM-',
  `nombre_microorganismo` text DEFAULT NULL,
  `especificacion` varchar(15) NOT NULL,
  `concepto` tinyint(1) DEFAULT 0,
  `tratamiento` text NOT NULL,
  `metodo_usado` varchar(30) NOT NULL,
  `cantidad_muestra` varchar(15) NOT NULL,
  `volumen_diluyente` varchar(15) NOT NULL,
  `resultado` varchar(15) DEFAULT NULL,
  `numero_registro_producto` varchar(30) NOT NULL,
  `id_usuario` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `deteccion_microorganismos`
--
DELIMITER $$
CREATE TRIGGER `delete_deteccion_microorganismos` BEFORE DELETE ON `deteccion_microorganismos` FOR EACH ROW BEGIN

declare nombre_completo varchar(50);
set nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = old.id_usuario);

INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values


(CONCAT('El usuario ', nombre_completo, ' elimino la deteccion del microorganismo ', old.nombre_microorganismo, ' en el producto ', (select nombre_producto from productos WHERE numero_registro_producto = old.numero_registro_producto), ' con indentificacion: ', old.numero_registro_producto),
 
 JSON_object('nombre_microorganismo', old.nombre_microorganismo, 'especificacion', old.especificacion, 'concepto', old.concepto, 'tratamiento', old.tratamiento, 'metodo_usado', old.metodo_usado, 'cantidad_muestra', old.cantidad_muestra, 'volumen_diluyente', old.volumen_diluyente, 'resultado', old.resultado, 'numero_registro_producto', old.numero_registro_producto, 'id_usuario', old.id_usuario),
 
'eliminar', now(), 5, concat(old.codigo_deteccion_microorganismo, old.id_deteccion_microorganismo), old.numero_registro_producto);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_deteccion_microorganismos` AFTER INSERT ON `deteccion_microorganismos` FOR EACH ROW BEGIN

declare nombre_completo varchar(50);
set nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = new.id_usuario);

INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values


(CONCAT('El usuario ', nombre_completo, ' registro la deteccion del microorganismo ', new.nombre_microorganismo, ' en el producto ', (select nombre_producto from productos WHERE numero_registro_producto = new.numero_registro_producto), ' con indentificacion: ', new.numero_registro_producto),
 
 JSON_object('nombre_microorganismo', new.nombre_microorganismo, 'especificacion', new.especificacion, 'concepto', new.concepto, 'tratamiento', new.tratamiento, 'metodo_usado', new.metodo_usado, 'cantidad_muestra', new.cantidad_muestra, 'volumen_diluyente', new.volumen_diluyente, 'resultado', new.resultado, 'numero_registro_producto', new.numero_registro_producto, 'id_usuario', new.id_usuario),
 
'registrar', now(), 5, concat(new.codigo_deteccion_microorganismo, new.id_deteccion_microorganismo), new.numero_registro_producto);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_deteccion_microorganismos` BEFORE UPDATE ON `deteccion_microorganismos` FOR EACH ROW BEGIN

declare nombre_completo varchar(50);
set nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = new.id_usuario);

INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values


(CONCAT('El usuario ', nombre_completo, ' edito la deteccion del microorganismo ', new.nombre_microorganismo, ' en el producto ', (select nombre_producto from productos WHERE numero_registro_producto = new.numero_registro_producto), ' con indentificacion: ', new.numero_registro_producto),

 JSON_OBJECT('registro_anterior',  JSON_object('nombre_microorganismo', old.nombre_microorganismo, 'especificacion', old.especificacion, 'concepto', old.concepto, 'tratamiento', old.tratamiento, 'metodo_usado', old.metodo_usado, 'cantidad_muestra', old.cantidad_muestra, 'volumen_diluyente', old.volumen_diluyente, 'resultado', old.resultado, 'numero_registro_producto', old.numero_registro_producto, 'id_usuario', old.id_usuario), 'registro_nuevo',  JSON_object('nombre_microorganismo', new.nombre_microorganismo, 'especificacion', new.especificacion, 'concepto', new.concepto, 'tratamiento', new.tratamiento, 'metodo_usado', new.metodo_usado, 'cantidad_muestra', new.cantidad_muestra, 'volumen_diluyente', new.volumen_diluyente, 'resultado', new.resultado, 'numero_registro_producto', new.numero_registro_producto, 'id_usuario', new.id_usuario)),

 
'editar', now(), 5, concat(new.codigo_deteccion_microorganismo, new.id_deteccion_microorganismo), new.numero_registro_producto);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entradas_productos`
--

CREATE TABLE `entradas_productos` (
  `id_entrada` int(11) NOT NULL,
  `codigo_entrada` varchar(30) DEFAULT 'ENT-',
  `proposito_analisis` text NOT NULL,
  `condiciones_ambientales` varchar(30) NOT NULL,
  `fecha_recepcion` date NOT NULL,
  `fecha_inicio_analisis` date NOT NULL,
  `fecha_final_analisis` date DEFAULT NULL,
  `numero_registro_producto` varchar(30) NOT NULL,
  `id_usuario` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `entradas_productos`
--
DELIMITER $$
CREATE TRIGGER `delete_entradas_productos` BEFORE DELETE ON `entradas_productos` FOR EACH ROW BEGIN
declare nombre_completo varchar(50);
set nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = old.id_usuario);

INSERT INTO log_transaccional(descripcion,detalles_registro,  accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values

(CONCAT('El usuario ', nombre_completo, ' eliminò  la entrada al area del producto ', (select nombre_producto from productos WHERE numero_registro_producto = old.numero_registro_producto), ' con indentificacion: ', (old.numero_registro_producto)),
 
  JSON_object('id_entrada', old.id_entrada, 'proposito_analisis', old.proposito_analisis, 'condiciones_ambientales', old.condiciones_ambientales, 'fecha_recepcion', old.fecha_recepcion, 'fecha_inicio_analisis', old.fecha_inicio_analisis, 'fecha_final_analisis', old.fecha_final_analisis, 'numero_registro_producto', old.numero_registro_producto, 'id_usuario', old.id_usuario),
 
 'eliminar', now(), 1, concat(old.codigo_entrada, old.id_entrada), old.numero_registro_producto);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_entradas_productos` AFTER INSERT ON `entradas_productos` FOR EACH ROW BEGIN
declare nombre_completo varchar(50);
set nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = new.id_usuario);

INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values


(CONCAT('El usuario ', nombre_completo, ' registro la entrada al area del producto ', (select nombre_producto from productos WHERE numero_registro_producto = new.numero_registro_producto), ' con indentificacion: ', (new.numero_registro_producto)),
 
 JSON_object('id_entrada', new.id_entrada, 'proposito_analisis', new.proposito_analisis, 'condiciones_ambientales', new.condiciones_ambientales, 'fecha_recepcion', new.fecha_recepcion, 'fecha_inicio_analisis', new.fecha_inicio_analisis, 'fecha_final_analisis', new.fecha_final_analisis, 'numero_registro_producto', new.numero_registro_producto, 'id_usuario', new.id_usuario),
 
'registrar', now(), 1, concat(new.codigo_entrada, new.id_entrada), new.numero_registro_producto);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_entradas_productos` BEFORE UPDATE ON `entradas_productos` FOR EACH ROW BEGIN

declare nombre_completo varchar(50);
set nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = new.id_usuario);

INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values

(CONCAT('El usuario ', nombre_completo, 
' editò la entrada al area del producto ', (select nombre_producto from productos WHERE numero_registro_producto = new.numero_registro_producto), ' con indentificacion: ', new.numero_registro_producto),
 
JSON_OBJECT('registro_anterior', JSON_OBJECT('proposito_analisis', old.proposito_analisis, 'condiciones_ambientales', old.condiciones_ambientales, 'fecha_recepcion', old.fecha_recepcion, 'fecha_inicio_analisis', old.fecha_inicio_analisis, 'fecha_final_analisis', old.fecha_final_analisis, 'numero_registro_producto', old.numero_registro_producto, 'id_usuario', old.id_usuario), 'registro_nuevo', JSON_OBJECT('proposito_analisis', new.proposito_analisis, 'condiciones_ambientales', new.condiciones_ambientales, 'fecha_recepcion', new.fecha_recepcion, 'fecha_inicio_analisis', new.fecha_inicio_analisis, 'fecha_final_analisis', new.fecha_final_analisis, 'numero_registro_producto', new.numero_registro_producto, 'id_usuario', new.id_usuario)),
 
 
'editar', now(), 1, concat(old.codigo_entrada, old.id_entrada),  old.numero_registro_producto);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estados`
--

CREATE TABLE `estados` (
  `id_estado` int(11) NOT NULL,
  `nombre_estado` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `etapas_deteccion`
--

CREATE TABLE `etapas_deteccion` (
  `id_etapa_deteccion` int(11) NOT NULL,
  `nombre_etapa` varchar(30) NOT NULL,
  `tiempo_etapa` varchar(30) NOT NULL,
  `temperatura_etapa` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `fabricantes`
--

CREATE TABLE `fabricantes` (
  `id_fabricante` int(11) NOT NULL,
  `nombre_fabricante` varchar(50) NOT NULL,
  `direccion_fabricante` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_transaccional`
--

CREATE TABLE `log_transaccional` (
  `id_log` int(11) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `detalles_registro` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`detalles_registro`)),
  `accion` enum('registrar','editar','eliminar') NOT NULL,
  `fechayhora_log` datetime NOT NULL,
  `id_modulo` int(11) NOT NULL,
  `codigo_registro` varchar(30) NOT NULL,
  `numero_registro_producto` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `modulos`
--

CREATE TABLE `modulos` (
  `id_modulo` int(11) NOT NULL,
  `nombre_modulo` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `monitoreos_detecciones`
--

CREATE TABLE `monitoreos_detecciones` (
  `id_monitoreo_deteccion` int(11) NOT NULL,
  `codigo_monitoreo_deteccion` varchar(10) DEFAULT 'MTD-',
  `volumen_muestra` varchar(15) NOT NULL,
  `nombre_diluyente` varchar(30) NOT NULL,
  `fechayhora_inicio` datetime NOT NULL,
  `fechayhora_final` datetime DEFAULT NULL,
  `id_etapa_deteccion` int(11) NOT NULL,
  `id_deteccion_microorganismo` int(11) NOT NULL,
  `id_usuario` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `monitoreos_detecciones`
--
DELIMITER $$
CREATE TRIGGER `delete_monitoreos_detecciones` BEFORE DELETE ON `monitoreos_detecciones` FOR EACH ROW BEGIN
declare numero_registro_producto, nombre_completo varchar(50);
set numero_registro_producto := (SELECT DISTINCT dm.numero_registro_producto from monitoreos_detecciones as md join deteccion_microorganismos as dm on md.id_deteccion_microorganismo=dm.id_deteccion_microorganismo where md.id_monitoreo_deteccion=old.id_monitoreo_deteccion),
nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = old.id_usuario);


INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values
(
CONCAT('El usuario ', nombre_completo, ' elimino un monitoreo de la deteccion del microrganismo ', (select dm.nombre_microorganismo from monitoreos_detecciones as md join deteccion_microorganismos as dm on md.id_deteccion_microorganismo=dm.id_deteccion_microorganismo where id_monitoreo_deteccion=old.id_monitoreo_deteccion) ,' del producto ', (select nombre_producto from productos as pro WHERE pro.numero_registro_producto=numero_registro_producto),' con identificacion: ', numero_registro_producto),
 
JSON_object('volumen_muestra', old.volumen_muestra, 'nombre_diluyente', old.nombre_diluyente, 'fechayhora_inicio', old.fechayhora_inicio, 'fechayhora_final', old.fechayhora_final, 'id_etapa_deteccion', old.id_etapa_deteccion, 'id_deteccion_microorganismo', old.id_deteccion_microorganismo, 'id_usuario', old.id_usuario),
 
'eliminar', now(), 6, concat(old.codigo_monitoreo_deteccion, old.id_monitoreo_deteccion), numero_registro_producto);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_monitoreos_detecciones` AFTER INSERT ON `monitoreos_detecciones` FOR EACH ROW BEGIN
declare numero_registro_producto, nombre_completo varchar(50);
set numero_registro_producto := (SELECT DISTINCT dm.numero_registro_producto from monitoreos_detecciones as md join deteccion_microorganismos as dm on md.id_deteccion_microorganismo=dm.id_deteccion_microorganismo where md.id_monitoreo_deteccion=new.id_monitoreo_deteccion),
nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = new.id_usuario);

INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values
(
CONCAT('El usuario ', nombre_completo, ' registro un monitoreo de la deteccion del microrganismo ', (select dm.nombre_microorganismo from monitoreos_detecciones as md join deteccion_microorganismos as dm on md.id_deteccion_microorganismo=dm.id_deteccion_microorganismo where id_monitoreo_deteccion=new.id_monitoreo_deteccion) ,' del producto ', (select nombre_producto from productos as pro WHERE pro.numero_registro_producto=numero_registro_producto),' con identificacion: ', numero_registro_producto),
 
JSON_object('volumen_muestra', new.volumen_muestra, 'nombre_diluyente', new.nombre_diluyente, 'fechayhora_inicio', new.fechayhora_inicio, 'fechayhora_final', new.fechayhora_final, 'id_etapa_deteccion', new.id_etapa_deteccion, 'id_deteccion_microorganismo', new.id_deteccion_microorganismo, 'id_usuario', new.id_usuario),
 
'registrar', now(), 6, concat(new.codigo_monitoreo_deteccion, new.id_monitoreo_deteccion), numero_registro_producto);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_monitoreos_detecciones` BEFORE UPDATE ON `monitoreos_detecciones` FOR EACH ROW BEGIN
declare numero_registro_producto, nombre_completo varchar(50);
set numero_registro_producto := (SELECT DISTINCT dm.numero_registro_producto from monitoreos_detecciones as md join deteccion_microorganismos as dm on md.id_deteccion_microorganismo=dm.id_deteccion_microorganismo where md.id_monitoreo_deteccion=new.id_monitoreo_deteccion),
nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = new.id_usuario);


INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values
(
CONCAT('El usuario ', nombre_completo, ' edito un monitoreo de la deteccion del microrganismo ', (select dm.nombre_microorganismo from monitoreos_detecciones as md join deteccion_microorganismos as dm on md.id_deteccion_microorganismo=dm.id_deteccion_microorganismo where id_monitoreo_deteccion=new.id_monitoreo_deteccion) ,' del producto ', (select nombre_producto from productos as pro WHERE pro.numero_registro_producto=numero_registro_producto),' con identificacion: ', numero_registro_producto),
 
JSON_OBJECT('registro_anterior', JSON_object('volumen_muestra', old.volumen_muestra, 'nombre_diluyente', old.nombre_diluyente, 'fechayhora_inicio', old.fechayhora_inicio, 'fechayhora_final', old.fechayhora_final, 'id_etapa_deteccion', old.id_etapa_deteccion, 'id_deteccion_microorganismo', old.id_deteccion_microorganismo, 'id_usuario', old.id_usuario), 'registro_nuevo', JSON_object('volumen_muestra', new.volumen_muestra, 'nombre_diluyente', new.nombre_diluyente, 'fechayhora_inicio', new.fechayhora_inicio, 'fechayhora_final', new.fechayhora_final, 'id_etapa_deteccion', new.id_etapa_deteccion, 'id_deteccion_microorganismo', new.id_deteccion_microorganismo, 'id_usuario', new.id_usuario)),
 
'editar', now(), 6, concat(new.codigo_monitoreo_deteccion, new.id_monitoreo_deteccion), numero_registro_producto);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `peticiones_cambio`
--

CREATE TABLE `peticiones_cambio` (
  `id_peticion_cambio` int(11) NOT NULL,
  `descripcion_peticion` longtext NOT NULL,
  `fechayhora_creacion_peticion` datetime NOT NULL,
  `id_usuario` varchar(15) NOT NULL,
  `id_estado` int(11) NOT NULL,
  `id_modulo` int(11) NOT NULL,
  `numero_registro_producto` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `numero_registro_producto` varchar(30) NOT NULL,
  `nombre_producto` varchar(50) NOT NULL,
  `fecha_fabricacion` date NOT NULL,
  `fecha_vencimiento` date NOT NULL,
  `descripcion_producto` text NOT NULL,
  `activo_producto` varchar(50) NOT NULL,
  `presentacion_producto` varchar(30) NOT NULL,
  `cantidad_producto` varchar(15) NOT NULL,
  `numero_lote_producto` varchar(30) NOT NULL,
  `tamano_lote_producto` varchar(30) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `id_fabricante` int(11) NOT NULL,
  `id_modulo` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pruebas_recuento`
--

CREATE TABLE `pruebas_recuento` (
  `id_prueba_recuento` int(11) NOT NULL,
  `codigo_prueba_recuento` varchar(10) DEFAULT 'PRC-',
  `metodo_usado` varchar(30) NOT NULL,
  `concepto` tinyint(1) NOT NULL DEFAULT 0,
  `especificacion` varchar(15) NOT NULL,
  `volumen_diluyente` varchar(15) NOT NULL,
  `tiempo_disolucion` varchar(5) DEFAULT NULL,
  `cantidad_muestra` varchar(15) NOT NULL,
  `tratamiento` text NOT NULL,
  `id_usuario` varchar(15) NOT NULL,
  `numero_registro_producto` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `pruebas_recuento`
--
DELIMITER $$
CREATE TRIGGER `delete_pruebas_recuento` BEFORE DELETE ON `pruebas_recuento` FOR EACH ROW BEGIN

declare nombre_completo varchar(50);
set nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = old.id_usuario);

INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values


(CONCAT('El usuario ', nombre_completo, ' elimino el registro de una prueba de recuento del producto ', (select nombre_producto from productos WHERE numero_registro_producto = old.numero_registro_producto), ' con indentificacion: ', (old.numero_registro_producto)),
 
 JSON_object('metodo_usado', old.metodo_usado, 'concepto', old.metodo_usado, 'concepto', old.concepto, 'especificacion', old.especificacion, 'volumen_diluyente', old.volumen_diluyente, 'tiempo_disolucion', old.tiempo_disolucion, 'cantidad_muestra', old.cantidad_muestra, 'tratamiento', old.tratamiento, 'id_usaurio', old.id_usuario, 'numero_registro_producto', old.numero_registro_producto),
 
'eliminar', now(), 2, concat(old.codigo_prueba_recuento, old.id_prueba_recuento) , old.numero_registro_producto);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_pruebas_recuento` AFTER INSERT ON `pruebas_recuento` FOR EACH ROW BEGIN

declare nombre_completo varchar(50);
set nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = new.id_usuario);

INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values


(CONCAT('El usuario ',nombre_completo, ' registro una prueba de recuento del producto ', (select nombre_producto from productos WHERE numero_registro_producto = new.numero_registro_producto), ' con indentificacion: ', (new.numero_registro_producto)),
 
 JSON_object('metodo_usado', new.metodo_usado, 'concepto', new.metodo_usado, 'concepto', new.concepto, 'especificacion', new.especificacion, 'volumen_diluyente', new.volumen_diluyente, 'tiempo_disolucion', new.tiempo_disolucion, 'cantidad_muestra', new.cantidad_muestra, 'tratamiento', new.tratamiento, 'id_usaurio', new.id_usuario, 'numero_registro_producto', new.numero_registro_producto),
 
'registrar', now(), 2, concat(new.codigo_prueba_recuento, new.id_prueba_recuento) , new.numero_registro_producto);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_pruebas_recuento` BEFORE UPDATE ON `pruebas_recuento` FOR EACH ROW BEGIN

declare nombre_completo varchar(50);
set nombre_completo :=(select concat(primer_nombre, ' ', segundo_nombre, ' ', primer_apellido, ' ', segundo_apellido) from usuarios where id_usuario = new.id_usuario);

INSERT INTO log_transaccional(descripcion, detalles_registro, accion, fechayhora_log, id_modulo, codigo_registro, numero_registro_producto) values

(CONCAT('El usuario ', nombre_completo, ' edito el registro de una prueba de recuento del producto ', (select nombre_producto from productos WHERE numero_registro_producto = new.numero_registro_producto), ' con indentificacion: ', (new.numero_registro_producto)),
 
JSON_OBJECT('registro_anterior', 
JSON_object('metodo_usado', old.metodo_usado, 'concepto', old.metodo_usado, 'concepto', old.concepto, 'especificacion', old.especificacion, 'volumen_diluyente', old.volumen_diluyente, 'tiempo_disolucion', old.tiempo_disolucion, 'cantidad_muestra', old.cantidad_muestra, 'tratamiento', old.tratamiento, 'id_usaurio', old.id_usuario, 'numero_registro_producto', old.numero_registro_producto), 
'registro_nuevo', 
JSON_object('metodo_usado', new.metodo_usado, 'concepto', new.metodo_usado, 'concepto', new.concepto, 'especificacion', new.especificacion, 'volumen_diluyente', new.volumen_diluyente, 'tiempo_disolucion', new.tiempo_disolucion, 'cantidad_muestra', new.cantidad_muestra, 'tratamiento', new.tratamiento, 'id_usaurio', new.id_usuario, 'numero_registro_producto', new.numero_registro_producto)),
 
'editar', now(), 2, concat(new.codigo_prueba_recuento, new.id_prueba_recuento) , new.numero_registro_producto);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `registro_entrada_productos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `registro_entrada_productos` (
`numero_registro_producto` varchar(30)
,`nombre_producto` varchar(50)
,`proposito_analisis` text
,`condiciones_ambientales` varchar(30)
,`fecha_recepcion` date
,`fecha_inicio_analisis` date
,`fecha_final_analisis` date
,`id_usuario` varchar(15)
,`nombre_usuario` varchar(83)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `solicitudes_registro`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `solicitudes_registro` (
`nombre_completo` varchar(83)
,`id_usuario` varchar(15)
,`nombre_usuario` varchar(50)
,`fecha_inscripcion` date
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` varchar(15) NOT NULL,
  `primer_nombre` varchar(20) NOT NULL,
  `segundo_nombre` varchar(20) NOT NULL,
  `primer_apellido` varchar(20) NOT NULL,
  `segundo_apellido` varchar(20) NOT NULL,
  `foto_usuario` mediumblob DEFAULT NULL,
  `nombre_usuario` varchar(50) NOT NULL,
  `contraseña_usuario` longtext NOT NULL,
  `rol_usuario` enum('analista','coordinador') NOT NULL DEFAULT 'analista',
  `firma_usuario` varchar(20) DEFAULT NULL,
  `fecha_inscripcion` date DEFAULT current_timestamp(),
  `estado` enum('activo','inactivo') DEFAULT 'inactivo',
  `solicitud_registro` enum('aceptada','en revision') DEFAULT 'en revision'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `primer_nombre`, `segundo_nombre`, `primer_apellido`, `segundo_apellido`, `foto_usuario`, `nombre_usuario`, `contraseña_usuario`, `rol_usuario`, `firma_usuario`, `fecha_inscripcion`, `estado`, `solicitud_registro`) VALUES
('0872783316', '', '', '', '', NULL, 'ginchbald7@lycos.com', '$2a$04$AXy4LOpB4jsqhO6dzsv/c.qQ0Jgx.mN4boL6I2KIZAWoryr2KAmFa', 'analista', 'Georgeta', '2024-07-30', 'activo', 'en revision'),
('2595285254', '', '', '', '', NULL, 'kdmitrovic3@engadget.com', '$2a$04$fijrResNeypnBePp79CxJutWkmfamPogm6l264CSVLBX6/VU0Of0y', 'analista', 'Kelly', '2024-07-23', 'inactivo', 'en revision'),
('321', 'David', '', 'Gonzalez', '', NULL, 'David123', '', 'analista', 'D. Gonzalez', '2024-09-11', 'inactivo', 'en revision'),
('3769554418', '', '', '', '', NULL, 'nwhapple4@geocities.com', '$2a$04$5NtEHlRo/9KCtAujcRQRR.Xg9CqfbtwcmbvDjBJsL3zzqwfjMUDAS', 'analista', 'Normie', '2024-01-11', 'inactivo', 'en revision'),
('4730702816', '', '', '', '', NULL, 'grichmont8@infoseek.co.jp', '$2a$04$GHEKibIVbMqFPZgk/9/5tORoxgEz3gWSx/bOWUtJIaA1LlWd3Tf8a', 'analista', 'Glory', '2023-12-22', 'activo', 'en revision'),
('4787502077', '', '', '', '', NULL, 'jmcgahey9@bloomberg.com', '$2a$04$dQROvHpLyi1cawPJyTT73u7bUcwOeih8lD.mFhwmJnZVmcnNV3H9C', 'analista', 'Jessica', '2024-06-12', 'inactivo', 'en revision'),
('4804064141', '', '', '', '', NULL, 'cmalcher1@tamu.edu', '$2a$04$ZW4Ry3wzleKl1KINrRva3.YUXbNAPfXzBjQz7kE6q7dVZd5gVolg.', 'analista', 'Calvin', '2024-07-08', 'inactivo', 'en revision'),
('6573136446', '', '', '', '', NULL, 'rbroadhurst5@squarespace.com', '$2a$04$CCXeEPWde11Ozb75QeDPuej6UfOaQQIT2gIwDUAywxbPWX95XzuqG', 'analista', 'Rois', '2024-05-19', 'inactivo', 'en revision'),
('7514280510', '', '', '', '', NULL, 'mcrotty6@wiley.com', '$2a$04$sDe8WZM3KkxmKBHSqhmDm.4nrIp02C8J0Tf.RBEWPcPt4Lfktmv7O', 'analista', 'Marietta', '2023-12-09', 'inactivo', 'en revision');

--
-- Disparadores `usuarios`
--
DELIMITER $$
CREATE TRIGGER `generar_firma_usuario` BEFORE INSERT ON `usuarios` FOR EACH ROW BEGIN
set new.firma_usuario = CONCAT(LEFT(new.primer_nombre, 1), '. ', new. primer_apellido);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura para la vista `analisis_por_producto`
--
DROP TABLE IF EXISTS `analisis_por_producto`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `analisis_por_producto`  AS SELECT `a`.`numero_registro_producto` AS `numero_registro_producto`, `p`.`nombre_producto` AS `nombre_producto`, `m`.`nombre_modulo` AS `nombre_modulo`, `d`.`nombre_microorganismo` AS `nombre_microorganismo`, `cb`.`nombre_recuento` AS `nombre_recuento` FROM (((((`analisis` `a` left join `productos` `p` on(`a`.`numero_registro_producto` = `p`.`numero_registro_producto`)) left join `deteccion_microorganismos` `d` on(`p`.`numero_registro_producto` = `d`.`numero_registro_producto`)) left join `modulos` `m` on(`a`.`id_modulo` = `m`.`id_modulo`)) left join `pruebas_recuento` `pr` on(`pr`.`numero_registro_producto` = `a`.`numero_registro_producto`)) left join `cajas_bioburden` `cb` on(`pr`.`id_prueba_recuento` = `cb`.`id_prueba_recuento`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `detalles_peticiones_cambio`
--
DROP TABLE IF EXISTS `detalles_peticiones_cambio`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `detalles_peticiones_cambio`  AS SELECT `p`.`id_peticion_cambio` AS `id_peticion_cambio`, `p`.`descripcion_peticion` AS `descripcion_peticion`, `p`.`fechayhora_creacion_peticion` AS `fechayhora_creacion_peticion`, `u`.`id_usuario` AS `id_usuario`, concat(`u`.`primer_nombre`,' ',`u`.`segundo_nombre`,' ',`u`.`primer_apellido`,' ',`u`.`segundo_apellido`) AS `nombre_usuario`, `e`.`nombre_estado` AS `nombre_estado`, `m`.`nombre_modulo` AS `nombre_modulo`, `pr`.`numero_registro_producto` AS `numero_registro_producto`, `pr`.`nombre_producto` AS `nombre_producto` FROM ((((`peticiones_cambio` `p` join `usuarios` `u` on(`p`.`id_usuario` = `u`.`id_usuario`)) join `estados` `e` on(`p`.`id_estado` = `e`.`id_estado`)) join `modulos` `m` on(`p`.`id_modulo` = `m`.`id_modulo`)) join `productos` `pr` on(`p`.`numero_registro_producto` = `pr`.`numero_registro_producto`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `registro_entrada_productos`
--
DROP TABLE IF EXISTS `registro_entrada_productos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `registro_entrada_productos`  AS SELECT `p`.`numero_registro_producto` AS `numero_registro_producto`, `p`.`nombre_producto` AS `nombre_producto`, `e`.`proposito_analisis` AS `proposito_analisis`, `e`.`condiciones_ambientales` AS `condiciones_ambientales`, `e`.`fecha_recepcion` AS `fecha_recepcion`, `e`.`fecha_inicio_analisis` AS `fecha_inicio_analisis`, `e`.`fecha_final_analisis` AS `fecha_final_analisis`, `u`.`id_usuario` AS `id_usuario`, concat(`u`.`primer_nombre`,' ',`u`.`segundo_nombre`,' ',`u`.`primer_apellido`,' ',`u`.`segundo_apellido`) AS `nombre_usuario` FROM ((`entradas_productos` `e` join `productos` `p` on(`e`.`numero_registro_producto` = `p`.`numero_registro_producto`)) join `usuarios` `u` on(`e`.`id_usuario` = `u`.`id_usuario`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `solicitudes_registro`
--
DROP TABLE IF EXISTS `solicitudes_registro`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `solicitudes_registro`  AS SELECT concat(`usuarios`.`primer_nombre`,' ',`usuarios`.`segundo_nombre`,' ',`usuarios`.`primer_apellido`,' ',`usuarios`.`segundo_apellido`) AS `nombre_completo`, `usuarios`.`id_usuario` AS `id_usuario`, `usuarios`.`nombre_usuario` AS `nombre_usuario`, `usuarios`.`fecha_inscripcion` AS `fecha_inscripcion` FROM `usuarios` WHERE `usuarios`.`solicitud_registro` = 'en revision' ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `analisis`
--
ALTER TABLE `analisis`
  ADD PRIMARY KEY (`id_analisis`),
  ADD KEY `numero_registro_producto` (`numero_registro_producto`),
  ADD KEY `id_modulo` (`id_modulo`);

--
-- Indices de la tabla `cajas_bioburden`
--
ALTER TABLE `cajas_bioburden`
  ADD PRIMARY KEY (`id_caja_bioburden`),
  ADD KEY `id_prueba_recuento` (`id_prueba_recuento`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id_cliente`);

--
-- Indices de la tabla `controles_negativos_medios`
--
ALTER TABLE `controles_negativos_medios`
  ADD PRIMARY KEY (`id_control_negativo`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `numero_registro_producto` (`numero_registro_producto`);

--
-- Indices de la tabla `deteccion_microorganismos`
--
ALTER TABLE `deteccion_microorganismos`
  ADD PRIMARY KEY (`id_deteccion_microorganismo`),
  ADD KEY `numero_registro_producto` (`numero_registro_producto`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `entradas_productos`
--
ALTER TABLE `entradas_productos`
  ADD PRIMARY KEY (`id_entrada`),
  ADD KEY `numero_registro_producto` (`numero_registro_producto`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `estados`
--
ALTER TABLE `estados`
  ADD PRIMARY KEY (`id_estado`);

--
-- Indices de la tabla `etapas_deteccion`
--
ALTER TABLE `etapas_deteccion`
  ADD PRIMARY KEY (`id_etapa_deteccion`);

--
-- Indices de la tabla `fabricantes`
--
ALTER TABLE `fabricantes`
  ADD PRIMARY KEY (`id_fabricante`);

--
-- Indices de la tabla `log_transaccional`
--
ALTER TABLE `log_transaccional`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `id_modulo` (`id_modulo`);

--
-- Indices de la tabla `modulos`
--
ALTER TABLE `modulos`
  ADD PRIMARY KEY (`id_modulo`);

--
-- Indices de la tabla `monitoreos_detecciones`
--
ALTER TABLE `monitoreos_detecciones`
  ADD PRIMARY KEY (`id_monitoreo_deteccion`),
  ADD KEY `id_etapa_deteccion` (`id_etapa_deteccion`),
  ADD KEY `id_deteccion_microorganismo` (`id_deteccion_microorganismo`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `peticiones_cambio`
--
ALTER TABLE `peticiones_cambio`
  ADD PRIMARY KEY (`id_peticion_cambio`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_estado` (`id_estado`),
  ADD KEY `id_modulo` (`id_modulo`),
  ADD KEY `numero_registro_producto` (`numero_registro_producto`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`numero_registro_producto`),
  ADD KEY `id_cliente` (`id_cliente`),
  ADD KEY `id_fabricante` (`id_fabricante`),
  ADD KEY `id_modulo` (`id_modulo`);

--
-- Indices de la tabla `pruebas_recuento`
--
ALTER TABLE `pruebas_recuento`
  ADD PRIMARY KEY (`id_prueba_recuento`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `numero_registro_producto` (`numero_registro_producto`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `analisis`
--
ALTER TABLE `analisis`
  MODIFY `id_analisis` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0;

--
-- AUTO_INCREMENT de la tabla `cajas_bioburden`
--
ALTER TABLE `cajas_bioburden`
  MODIFY `id_caja_bioburden` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0;

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0;

--
-- AUTO_INCREMENT de la tabla `controles_negativos_medios`
--
ALTER TABLE `controles_negativos_medios`
  MODIFY `id_control_negativo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0;

--
-- AUTO_INCREMENT de la tabla `deteccion_microorganismos`
--
ALTER TABLE `deteccion_microorganismos`
  MODIFY `id_deteccion_microorganismo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0;

--
-- AUTO_INCREMENT de la tabla `entradas_productos`
--
ALTER TABLE `entradas_productos`
  MODIFY `id_entrada` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0;

--
-- AUTO_INCREMENT de la tabla `estados`
--
ALTER TABLE `estados`
  MODIFY `id_estado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0;

--
-- AUTO_INCREMENT de la tabla `etapas_deteccion`
--
ALTER TABLE `etapas_deteccion`
  MODIFY `id_etapa_deteccion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0;

--
-- AUTO_INCREMENT de la tabla `fabricantes`
--
ALTER TABLE `fabricantes`
  MODIFY `id_fabricante` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0;

--
-- AUTO_INCREMENT de la tabla `log_transaccional`
--
ALTER TABLE `log_transaccional`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0;

--
-- AUTO_INCREMENT de la tabla `modulos`
--
ALTER TABLE `modulos`
  MODIFY `id_modulo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0;

--
-- AUTO_INCREMENT de la tabla `monitoreos_detecciones`
--
ALTER TABLE `monitoreos_detecciones`
  MODIFY `id_monitoreo_deteccion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0;

--
-- AUTO_INCREMENT de la tabla `peticiones_cambio`
--
ALTER TABLE `peticiones_cambio`
  MODIFY `id_peticion_cambio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0;

--
-- AUTO_INCREMENT de la tabla `pruebas_recuento`
--
ALTER TABLE `pruebas_recuento`
  MODIFY `id_prueba_recuento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `analisis`
--
ALTER TABLE `analisis`
  ADD CONSTRAINT `analisis_ibfk_1` FOREIGN KEY (`numero_registro_producto`) REFERENCES `productos` (`numero_registro_producto`),
  ADD CONSTRAINT `analisis_ibfk_2` FOREIGN KEY (`id_modulo`) REFERENCES `modulos` (`id_modulo`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
