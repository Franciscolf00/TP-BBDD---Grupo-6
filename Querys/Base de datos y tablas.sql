CREATE DATABASE Com2900G06 COLLATE Modern_Spanish_CI_AS
GO

USE Com2900G06
GO

CREATE SCHEMA Producto
GO

CREATE SCHEMA Venta
GO

CREATE SCHEMA Sucursal
GO



CREATE TABLE Sucursal.Sucursal(
	IDSucursal INT IDENTITY(1,1) PRIMARY KEY,
	direccion VARCHAR(70),
	numTelefono CHAR(9) CHECK(numTelefono like '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
	ciudad varchar(9),
	sucursal varchar(20)
)

CREATE TABLE Sucursal.Empleado(
	Legajo INT PRIMARY KEY,
	dni INT UNIQUE,
	nombre VARCHAR(40),
	apellido VARCHAR(20),
	emailEmpresa VARCHAR(50) CHECK(emailEmpresa like '%@superA.com'),
	emailPersonal VARCHAR(50) CHECK(emailEmpresa like '%@%.com'),
	direccion VARCHAR(70),
	cargo CHAR(22) CHECK(cargo in ('Cajero', 'Supervisor', 'Gerente de sucursal')),
	turno CHAR(16) CHECK(turno in('TM', 'TT' , 'Jornada Completa')),
	FKSucursal INT NOT NULL REFERENCES Sucursal(IDSucursal)
)

CREATE TABLE Producto.LineaDeProducto(
	IDLineaDeProducto INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(30),
)

CREATE TABLE Producto.Categoria(
	IDCategoria INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(30),
	FKLineaDeProducto INT NOT NULL REFERENCES LineaDeProducto(IDLineaDeProducto)
)

CREATE TABLE Producto.Producto(
	IDProducto INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(50),
	precioUnitario DECIMAL(10,2),
	precioReferencia DECIMAL(10,2),
	unidadReferencia VARCHAR(10),
	fechaCreacion SMALLDATETIME,
	FKCategoria INT NOT NULL REFERENCES Categoria(IDCategoria)
)

CREATE TABLE Venta.MetodoDePago(
	IDMetodoDePago INT IDENTITY (1,1) PRIMARY KEY,
	nombre VARCHAR(11)
)

CREATE TABLE Venta.Venta(
	IDVenta INT IDENTITY(1,1) PRIMARY KEY,
	Factura CHAR(12) UNIQUE CHECK(Factura like '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'),
	tipoFactura CHAR(1) CHECK(tipoFactura in ('A', 'B', 'C')),
	tipoCliente CHAR(6) CHECK(tipoCliente in ('Member', 'Normal')),
	genero CHAR(6) CHECK(genero in ('Male', 'Female')),
	cantidad INT,
	fecha DATE,
	hora TIME,
	identificadorDePago VARCHAR(30) CHECK((LEN(identificadorDePago) = 22 AND identificadorDePago NOT LIKE '%[^0-9]%')
											OR (LEN(identificadorDePago) = 19 AND identificadorDePago LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')								
											OR identificadorDePago IS NULL),
	FKempleado INT NOT NULL REFERENCES Empleado(Legajo),
	FKMetodoDEPago INT NOT NULL REFERENCES MetodoDePago(IDMetodoDePago),
	FKproducto INT NOT NULL REFERENCES Producto(IDProducto),
)



------------------------------------------------------

--CREATE TABLE ddbba.ProductoImportado (
--    id INT IDENTITY(1,1) PRIMARY KEY, 
--	nombre VARCHAR(50),
--	proveedor NVARCHAR(50),
--	categoria VARCHAR(50),
--	cantidadPorUnidad VARCHAR(50),
--	precioPorUnidad DECIMAL(6,2)
--);
--GO

--CREATE TABLE ddbba.accesoriosElectronicos(
--	ID INT IDENTITY(1,1) PRIMARY KEY, 
--	producto VARCHAR(50),
--	precioUnitarioUSD DECIMAL(6,2)
--);
--GO

--CREATE TABLE ddbba.ProductoDeCatalogo (
--    idProducto INT IDENTITY(1,1) PRIMARY KEY,
--    categoria VARCHAR(100),
--	nombre VARCHAR(100),
--    precio DECIMAL(10,2),
--    precioReferencia DECIMAL(10,2),
--    unidadReferencia VARCHAR(10),
--    fecha SMALLDATETIME
--);
--GO