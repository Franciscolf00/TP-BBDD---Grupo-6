CREATE DATABASE Com2900G06 COLLATE Modern_Spanish_CI_AS
GO

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
returns VARCHAR(4000)
AS
BEGIN
	RETURN 'C:\TP_integrador_Archivos'; --Aca copiar�as tu ruta base hasta los archivos.
END
go
CREATE TABLE dbSucursal.Sucursal(
	IDSucursal INT IDENTITY(1,1) PRIMARY KEY,
	direccion VARCHAR(100),
	numTelefono CHAR(9),
	ciudad VARCHAR(9),
	sucursal VARCHAR(20),
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
	turno CHAR(16) CHECK(turno in('TM', 'TT' , 'Jornada Completa')),
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
	Factura INT	UNIQUE,				--Lo tengo que guardar como int para verificar duplicados a la hora de insertar
	tipoFactura CHAR(1) CHECK(tipoFactura in ('A', 'B', 'C')),
	tipoCliente CHAR(6) CHECK(tipoCliente in ('Member', 'Normal')),
	genero CHAR(6) CHECK(genero in ('Male', 'Female')),
	cantidad INT,
	fecha DATE,
	hora TIME,
	identificadorDePago VARCHAR(30) CHECK((LEN(identificadorDePago) = 22 AND identificadorDePago NOT LIKE '%[^0-9]%')
											OR (LEN(identificadorDePago) = 19 AND identificadorDePago LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')								
											OR identificadorDePago IS NULL),
	FKEmpleado INT NOT NULL REFERENCES dbSucursal.Empleado(Legajo),
	FKMetodoDePago INT NOT NULL REFERENCES dbVenta.MetodoDePago(IDMetodoDePago),
	FKProducto INT NOT NULL REFERENCES dbProducto.Producto(IDProducto),
	FKSucursal INT NOT NULL REFERENCES dbSucursal.Sucursal(IDSucursal)
)

