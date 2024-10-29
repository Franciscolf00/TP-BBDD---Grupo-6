USE Com2900G06
GO
--------------------------------------------------------------
--CATALOGO IMPORTACION 
CREATE OR ALTER PROCEDURE dbVenta.CargaMasivaCatalogo
AS
BEGIN
	drop table if exists #ProductoDeCatalogoTemp
	CREATE TABLE #ProductoDeCatalogoTemp (
		id INT PRIMARY KEY, --no mandar identity o sino los que tiene ID desordenados en el archivo original quedan mal
		category nVARCHAR(100),
		name nVARCHAR(100),
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
		raiserror('No se encuentra la ruta al archivo catalogo.csv. Actualizarlo en dbVenta.RutaImportacion(Query 00)', 16, 1);
	END CATCH

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
		raiserror('No se encuentra la ruta al archivo Ventas_registradas.csv. Actualizarlo en dbVenta.RutaImportacion(Query 00)', 16, 1);
	END CATCH

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
		print @sql
		exec sp_executesql @sql;
	END TRY

	BEGIN CATCH
		raiserror('No se encuentra la ruta al archivo Productos_importados.csv. Actualizarlo en dbVenta.RutaImportacion(Query 00)', 16, 1);
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

	--DECLARE @datos NVARCHAR(MAX) = (SELECT DATA FROM @json)
	--SELECT * FROM OPENJSON(@datos)
	--WITH
	--(
	--	[Tasa de conversión] real '$.rates.ARS'
	--	--[Fecha] NVARCHAR(50) '$.date'
	--);
	--EXEC sp_OADestroy @Object

	--SELECT @tasaCambio AS [Tasa de conversión];
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
		RAISERROR('No se encuentra la ruta al archivo Electronic accessories.xlsx. Actualizarlo en dbVenta.RutaImportacion(Query 00)', 16, 1);
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

