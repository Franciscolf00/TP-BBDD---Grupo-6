CREATE DATABASE Com2900G06 COLLATE Modern_Spanish_CI_AS
-------------------------------------------------------------------------------------
--CONFIGURACIONES INICIALES
--Para poder habilitar "Ole Automation Procedures"
EXEC sp_configure 'show advanced options', 1;
GO
--Para poder acceder a fuentes de datos externas(archivo xslx de Excel) con OPENROWSET
sp_configure 'Ad Hoc Distributed Queries', 1;
GO
--Para poder usar los procedures automaticos de OLE dentro de nuestros propios SP
EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE;
--EXEC sp_MSSet_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;
--EXEC sp_MSSet_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;

SET DATEFORMAT mdy; --Seteo el formato de fecha al formato que tienen los archivos
-------------------------------------------------------------------------------------
--use master;drop database Com2900G06;

USE Com2900G06
GO
CREATE SCHEMA dbProducto
GO
CREATE SCHEMA dbVenta
GO
CREATE SCHEMA dbSucursal
GO
CREATE SCHEMA dbReporte
GO

create or alter function dbVenta.RutaImportacion()
returns VARCHAR(max)
AS
BEGIN
	RETURN 'D:\Github\gitops\TP-BBDD---Grupo-6\TP_integrador_Archivos'; --Aca copiar�as tu ruta base hasta los archivos.
END
go

DROP TABLE IF EXISTS dbVenta.Venta;
DROP TABLE IF EXISTS dbSucursal.Empleado;    
DROP TABLE IF EXISTS dbSucursal.Sucursal; 
DROP TABLE IF EXISTS dbProducto.Producto; 
DROP TABLE IF EXISTS dbProducto.Categoria;   
DROP TABLE IF EXISTS dbProducto.LineaDeProducto; 
DROP TABLE IF EXISTS dbVenta.MetodoDePago;   

CREATE TABLE dbSucursal.Sucursal(
	IDSucursal INT IDENTITY(1,1) PRIMARY KEY,
	direccion VARCHAR(100),
	numTelefono CHAR(9),
	ciudad VARCHAR(50),
	sucursal VARCHAR(50),
	estado BIT,
	fechaBaja DATETIME
)
go
CREATE TABLE dbSucursal.Empleado(
	Legajo INT PRIMARY KEY,
	dni INT UNIQUE,
	nombre VARCHAR(40),
	apellido VARCHAR(20),
	emailEmpresa VARCHAR(100) CHECK(emailEmpresa like '%@superA.com'),
	emailPersonal VARCHAR(100) CHECK(emailPersonal like '%@%.com'),
	direccion VARCHAR(100),
	cargo CHAR(22) CHECK(cargo in ('Cajero', 'Supervisor', 'Gerente de sucursal')),
	turno VARCHAR(16) CHECK(turno in('TM', 'TT' , 'Jornada Completa')),
	FKSucursal INT NOT NULL REFERENCES dbSucursal.Sucursal(IDSucursal),
	estado BIT,
	fechaBaja DATETIME
)
go
CREATE TABLE dbProducto.LineaDeProducto(
	IDLineaDeProducto INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(30),
	estado BIT,
	fechaBaja DATETIME
)
go
CREATE TABLE dbProducto.Categoria(
	IDCategoria INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(50),
	FKLineaDeProducto INT NOT NULL REFERENCES dbProducto.LineaDeProducto(IDLineaDeProducto),
	estado BIT,
	fechaBaja DATETIME
)
go
CREATE TABLE dbProducto.Producto(
	IDProducto INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(100),
	precioUnitario DECIMAL(10,2),
	precioReferencia DECIMAL(10,2),
	unidadReferencia VARCHAR(20),
	fechaCreacion SMALLDATETIME,
	FKCategoria INT NOT NULL REFERENCES dbProducto.Categoria(IDCategoria),
	estado BIT,
	fechaBaja DATETIME
)
go
CREATE TABLE dbVenta.MetodoDePago(
	IDMetodoDePago INT IDENTITY (1,1) PRIMARY KEY,
	nombre VARCHAR(11),
	estado BIT,
	fechaBaja DATETIME
)
go
CREATE TABLE dbVenta.Venta(
	IDVenta INT IDENTITY(1,1) PRIMARY KEY,
	Factura INT,				--Lo tengo que guardar como int para verificar duplicados a la hora de insertar
	tipoFactura CHAR(1) CHECK(tipoFactura in ('A', 'B', 'C')),
	tipoCliente CHAR(6) CHECK(tipoCliente in ('Member', 'Normal')),
	genero CHAR(6) CHECK(genero in ('Male', 'Female')),
	cantidad INT,
	fecha DATE,
	hora TIME,
	identificadorDePago VARCHAR(30) CHECK((LEN(identificadorDePago) = 22 AND identificadorDePago LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
											OR (LEN(identificadorDePago) = 19 AND identificadorDePago LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')								
											OR identificadorDePago IS NULL),
	FKEmpleado INT NOT NULL REFERENCES dbSucursal.Empleado(Legajo),
	FKMetodoDePago INT NOT NULL REFERENCES dbVenta.MetodoDePago(IDMetodoDePago),
	FKProducto INT NOT NULL REFERENCES dbProducto.Producto(IDProducto),
	FKSucursal INT NOT NULL REFERENCES dbSucursal.Sucursal(IDSucursal)
)

