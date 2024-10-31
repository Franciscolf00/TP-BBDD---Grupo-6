USE Com2900G06
GO
--use master
--------------------------------------------------------------
--CATALOGO IMPORTACION 
CREATE OR ALTER PROCEDURE dbVenta.CargaMasivaCatalogo
AS
BEGIN
	drop table if exists #ProductoDeCatalogoTemp
	CREATE TABLE #ProductoDeCatalogoTemp (
		id INT PRIMARY KEY, --no mandar identity o sino los que tiene ID desordenados en el archivo original quedan mal
		category nVARCHAR(100),
		name VARCHAR(100),
		price DECIMAL(10,2),
		reference_price DECIMAL(10,2),
		reference_unit VARCHAR(10),
		date SMALLDATETIME
	);
	BEGIN TRY
		DECLARE @sql NVARCHAR(MAX) = 'BULK INSERT Com2900G06.#ProductoDeCatalogoTemp
		FROM ''' + dbVenta.RutaImportacion() + '\Productos\catalogo.csv''
		WITH
		(
			FORMAT = ''CSV'',
			FIELDTERMINATOR = '','',
			ROWTERMINATOR = ''0x0a'',
			FIRSTROW = 2,
			FIELDQUOTE = ''"'',
			CODEPAGE = ''65001''
		);'
		EXEC sp_executesql @sql;
	END TRY
	BEGIN CATCH
		DECLARE @error NVARCHAR(MAX) = 'No se pudo importar el archivo ' + dbVenta.RutaImportacion() + '\Productos\catalogo.csv. Actualizar ruta en dbVenta.RutaImportacion(Query 00) e intentar nuevamente.'
		raiserror(@error, 16, 1);
	END CATCH

	UPDATE #ProductoDeCatalogoTemp
	SET name = REPLACE(name,N'?', 'ñ')	
	WHERE name LIKE N'%?%';

	UPDATE #ProductoDeCatalogoTemp
	SET name = REPLACE(name, N'Ã³', 'ó')
	WHERE name LIKE N'%Ã³%';

	SELECT * FROM #ProductoDeCatalogoTemp
	DROP table #ProductoDeCatalogoTemp
END
go
exec dbVenta.CargaMasivaCatalogo
go
--------------------------------------------
--VENTAS REGISTRADAS IMPORTACION

CREATE OR ALTER PROCEDURE dbVenta.CargaMasivaVentas
AS
BEGIN
	drop table if exists #ventasRegistradasTemp
	CREATE TABLE #ventasRegistradasTemp (
		IDFactura CHAR(12),
		tipoFactura CHAR(1),
		Ciudad VARCHAR(15),
		tipoCliente CHAR(6),
		genero CHAR(6),
		producto VARCHAR(100),
		precioUnitario DECIMAL(10,2),
		cantidad INT,
		fecha DATE,
		hora TIME,
		medioDePago CHAR(11),
		empleado INT,
		identificadorDePago VARCHAR(30)
	);
	BEGIN TRY
		DECLARE @sql NVARCHAR(MAX) = 'BULK INSERT Com2900G06.#ventasRegistradasTemp
		FROM ''' + dbVenta.RutaImportacion() + '\Ventas_registradas.csv''
		WITH
		(
			FIELDTERMINATOR = '';'',
			ROWTERMINATOR = ''\n'',
			FIRSTROW = 2,
			CODEPAGE = ''65001''
		)'
		EXEC sp_executesql @sql;
	END TRY
	BEGIN CATCH
		DECLARE @error NVARCHAR(MAX) = 'No se pudo importar el archivo ' + dbVenta.RutaImportacion() + '\Ventas_registradas.csv. Actualizar ruta en dbVenta.RutaImportacion(Query 00) e intentar nuevamente.'
		raiserror(@error, 16, 1);
	END CATCH

	UPDATE #ventasRegistradasTemp
	SET producto = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		producto, N'Ã¡', 'á'),   -- Reemplaza á
		N'Ã©', 'é'),        -- Reemplaza é
		N'Ã­', 'í'),        -- Reemplaza í
		N'Ã³', 'ó'),        -- Reemplaza ó
		N'Ãº', 'ú'),         -- Reemplaza ú
		N'Ã±', 'ñ'),         -- Reemplaza ñ
		N'ÃƒÂº', 'ú'),        -- Reemplaza ú, tiene que ir antes que el de abajo porque comparten caracter
		N'Âº', '°')         -- Reemplaza °

	WHERE producto LIKE N'%Ã¡%' OR
		  producto LIKE N'%Ã©%' OR
		  producto LIKE N'%Ã­%' OR
		  producto LIKE N'%Ã³%' OR
		  producto LIKE N'%Ãº%' OR
		  producto LIKE N'%Ã±%' OR
		  producto LIKE N'%ÃƒÂº%' OR
		  producto LIKE N'%Âº%';

	SELECT * FROM #ventasRegistradasTemp
	DROP table #ventasRegistradasTemp
END
go
exec dbVenta.CargaMasivaVentas
GO

-------------------------------------
--Configuración de oledb
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

--EXEC sp_MSSet_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;
--EXEC sp_MSSet_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;

-------------------------------------
--Obtener archivo de productos importados

create or alter PROCEDURE dbProducto.CargaMasivaProductosImportados
AS
BEGIN
	BEGIN TRY
		drop table if exists #productosImportadosTemp
		CREATE TABLE #productosImportadosTemp(
			id int PRIMARY KEY, 
			name varchar(50),
			proveedor varchar(50),
			categoria varchar(50),
			cantidadPorUnidad varchar(50),
			precioPorUnidad decimal(6,2)
		);
		DECLARE @sql NVARCHAR(MAX)='
			INSERT INTO #productosImportadosTemp
			SELECT *
			FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.12.0'',
			''Excel 12.0 Xml;HDR=YES;Database='+ dbVenta.RutaImportacion() +'\Productos\Productos_importados.xlsx'',
			''SELECT * FROM [Listado de Productos$]''
		)'

		exec sp_executesql @sql;
	END TRY

	BEGIN CATCH
		DECLARE @error NVARCHAR(MAX) = 'No se pudo importar el archivo ' + dbVenta.RutaImportacion() + '\Productos\Productos_importados.xlsx. Actualizar ruta en dbVenta.RutaImportacion(Query 00) e intentar nuevamente.'
		raiserror(@error, 16, 1);
	END CATCH

	SELECT * FROM #productosImportadosTemp
	DROP table #productosImportadosTemp
END
go
exec dbProducto.CargaMasivaProductosImportados
--------------------------------------------------------------
--API PARA PASAR DE DOLARES A PESOS(CAMBIO OFICIAL)
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
EXEC sp_configure 'Ole Automation Procedures', 1;	
RECONFIGURE;
GO
CREATE OR ALTER PROCEDURE dbProducto.APIDolarAPeso
    @tasaCambio REAL OUTPUT 
as
BEGIN
	DECLARE @url NVARCHAR(256) = 'https://api.exchangerate-api.com/v4/latest/USD'
	DECLARE @Object INT
	DECLARE @json TABLE(DATA NVARCHAR(MAX))
	DECLARE @respuesta NVARCHAR(MAX)

	EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT
	EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @url, 'FALSE'
	EXEC sp_OAMethod @Object, 'SEND'
	EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT , @json OUTPUT

	INSERT INTO @json 
		EXEC sp_OAGetProperty @Object, 'RESPONSETEXT'

	DECLARE @datos NVARCHAR(MAX) = (SELECT DATA FROM @json)
	SELECT @tasaCambio = [Tasa de conversión]
	FROM OPENJSON(@datos)
	WITH
	(
		[Tasa de conversión] real '$.rates.ARS'
		--[Fecha] NVARCHAR(50) '$.date'
	);
	EXEC sp_OADestroy @Object

	SELECT @tasaCambio AS [Tasa de conversión];

END
----------------------------------------
-- Obtener archivo de accesorios electrónicos
go
CREATE OR ALTER PROCEDURE dbProducto.cargaAccesoriosElectronicos
AS
BEGIN
	BEGIN TRY
		DROP TABLE if exists #accesoriosElectronicosTemp;
		CREATE TABLE #accesoriosElectronicosTemp (
		    id INT IDENTITY(1,1) PRIMARY KEY, 
		    producto VARCHAR(100),
			precio_unitario_dolares DECIMAL(10,2)
		);
		DECLARE @sql NVARCHAR(MAX) = '
			INSERT INTO #accesoriosElectronicosTemp (producto, precio_unitario_dolares)
			SELECT *
			FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0 Xml;Database=' + dbVenta.RutaImportacion() + '\Productos\Electronic accessories.xlsx;HDR=YES;IMEX=1'',
				''SELECT * FROM [sheet1$]''
			)'
		EXEC sp_executesql @sql;

	END TRY
	BEGIN CATCH
		DECLARE @error NVARCHAR(MAX) = 'No se pudo importar el archivo ' + dbVenta.RutaImportacion() + '\Productos\Electronic accessories.xlsx. Actualizar ruta en dbVenta.RutaImportacion(Query 00) e intentar nuevamente.'
		raiserror(@error, 16, 1);
	END CATCH
	
	DECLARE @tasaCambio REAL;
	EXEC dbProducto.APIDolarAPeso @tasaCambio OUTPUT;
	print @tasaCambio

	update #accesoriosElectronicosTemp
	set precio_unitario_dolares=precio_unitario_dolares*@tasaCambio



	SELECT * FROM #accesoriosElectronicosTemp;
	DROP TABLE #accesoriosElectronicosTemp;
END
go
exec dbProducto.cargaAccesoriosElectronicos
----------------------------------------
-- Obtener información complementaria(sucursal,empleados,medios de pago y clasificacion productos)
go
USE Com2900G06
GO

CREATE OR ALTER PROCEDURE dbVenta.CargaInformacionComplementariaSucursal
AS
BEGIN
	BEGIN TRY
		DROP TABLE if exists #sucursalTemp;
		CREATE TABLE #sucursalTemp(
		    IDSucursal INT IDENTITY(1,1) PRIMARY KEY,
			direccion VARCHAR(100),
			numTelefono CHAR(9),
			ciudad VARCHAR(9),
			sucursal VARCHAR(20),
			horario char(45)
		);
		DECLARE @sql NVARCHAR(MAX) = '
			INSERT INTO #sucursalTemp(ciudad,sucursal,direccion,horario,numTelefono)
			SELECT *
			FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0 Xml;Database=' + dbVenta.RutaImportacion() + '\Informacion_complementaria.xlsx;HDR=NO;IMEX=1'',
				''SELECT * FROM [sucursal$B3:F5]''
			);'
		EXEC sp_executesql @sql;
	END TRY
	BEGIN CATCH
		DECLARE @error NVARCHAR(MAX) = 'No se pudo importar el archivo ' + dbVenta.RutaImportacion() + '\Informacion_complementaria.xlsx. Actualizar ruta en dbVenta.RutaImportacion(Query 00) e intentar nuevamente.'
		raiserror(@error, 16, 1);
	END CATCH

	SELECT * FROM #sucursalTemp;
	DROP TABLE #sucursalTemp;
END
go
exec dbVenta.CargaInformacionComplementariaSucursal
GO

CREATE OR ALTER PROCEDURE dbVenta.CargaInformacionComplementariaEmpleados
AS
BEGIN
	BEGIN TRY
		DROP TABLE if exists #empleadoTemp;
		CREATE TABLE #empleadoTemp (
		    Legajo INT PRIMARY KEY,
			dni INT UNIQUE,
			nombre VARCHAR(40),
			apellido VARCHAR(20),
			emailEmpresa VARCHAR(100),
			emailPersonal VARCHAR(100),
			direccion VARCHAR(100),
			cargo CHAR(22),
			turno CHAR(16),
			CUIL VARCHAR(13),
			sucursal VARCHAR(20)	--luego para mandarla a la tabla en la db tenemos que hacer un join con sucursal y mandar el idSucursal como fk
			--FKSucursal INT NOT NULL REFERENCES dbSucursal.Sucursal(IDSucursal)
		);
		DECLARE @sql NVARCHAR(MAX) = '
			INSERT INTO #empleadoTemp (Legajo,nombre,apellido,dni,direccion,emailPersonal,emailEmpresa,CUIL,cargo,sucursal,turno)
			SELECT *
			FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0 Xml;Database=' + dbVenta.RutaImportacion() + '\Informacion_complementaria.xlsx;HDR=NO;IMEX=1'',
				''SELECT * FROM [Empleados$A3:K17]''
			);'
		EXEC sp_executesql @sql;
	END TRY
	BEGIN CATCH
		DECLARE @error NVARCHAR(MAX) = 'No se pudo importar el archivo ' + dbVenta.RutaImportacion() + '\Informacion_complementaria.xlsx. Actualizar ruta en dbVenta.RutaImportacion(Query 00) e intentar nuevamente.'
		raiserror(@error, 16, 1);
	END CATCH

	SELECT * FROM #empleadoTemp;
	DROP TABLE #empleadoTemp;

END
go
exec dbVenta.CargaInformacionComplementariaEmpleados
GO

CREATE OR ALTER PROCEDURE dbVenta.CargaInformacionComplementariaClasificacionProductos
AS
BEGIN
	BEGIN TRY
		DROP TABLE if exists #clasificacionProductosTemp;
		CREATE TABLE #clasificacionProductosTemp (
		    id INT IDENTITY(1,1) PRIMARY KEY, 
		    lineaDeProducto VARCHAR(30),
			categoria VARCHAR(50)
		);
		DECLARE @sql NVARCHAR(MAX) = '
			INSERT INTO #clasificacionProductosTemp (lineaDeProducto,categoria)
			SELECT *
			FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0 Xml;Database=' + dbVenta.RutaImportacion() + '\Informacion_complementaria.xlsx;HDR=NO;IMEX=1'',
				''SELECT * FROM [Clasificacion productos$B2:C149]''
			);'
		EXEC sp_executesql @sql;
	END TRY
	BEGIN CATCH
		DECLARE @error NVARCHAR(MAX) = 'No se pudo importar el archivo ' + dbVenta.RutaImportacion() + '\Informacion_complementaria.xlsx. Actualizar ruta en dbVenta.RutaImportacion(Query 00) e intentar nuevamente.'
		raiserror(@error, 16, 1);
	END CATCH

	SELECT * FROM #clasificacionProductosTemp;
	DROP TABLE #clasificacionProductosTemp;
END
go
exec dbVenta.CargaInformacionComplementariaClasificacionProductos
GO

--Importar metodos de pago
go
CREATE OR ALTER PROCEDURE dbVenta.CargaMetodosDePago
AS
BEGIN
	BEGIN TRY
		DROP TABLE if exists #metodoDePagoTemp;
		CREATE TABLE #metodoDePagoTemp (
		    IDMetodoDePago INT IDENTITY (1,1) PRIMARY KEY,
			nombreENG VARCHAR(11),
			nombreESP VARCHAR(25)
		);

		print dbVenta.RutaImportacion()

		DECLARE @sql NVARCHAR(MAX) = '
			INSERT INTO #metodoDePagoTemp (nombreENG,nombreESP)
			SELECT *
			FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0 Xml;Database=' + dbVenta.RutaImportacion() + '\Informacion_complementaria.xlsx;HDR=NO;IMEX=1'',
				''SELECT * FROM [medios de pago$B3:C5]''
			);'

		EXEC sp_executesql @sql;
		SELECT * from #metodoDePagoTemp;
		DROP TABLE #metodoDePagoTemp;

	END TRY
	BEGIN CATCH
		DECLARE @error NVARCHAR(MAX) = 'No se pudo importar el archivo ' + dbVenta.RutaImportacion() + '\Informacion_complementaria.xlsx. Actualizar ruta en dbVenta.RutaImportacion(Query 00) e intentar nuevamente.'
		raiserror(@error, 16, 1);
	END CATCH
END

go
exec dbVenta.CargaMetodosDePago
