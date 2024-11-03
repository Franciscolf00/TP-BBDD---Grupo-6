USE Com2900G06
GO
--use master
--Importar sucursales
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

	INSERT INTO dbSucursal.Sucursal(direccion,numTelefono,ciudad,sucursal,estado)
	SELECT direccion,numTelefono,ciudad,sucursal,1
	FROM #sucursalTemp t
	WHERE NOT EXISTS(
		SELECT 1
		FROM dbSucursal.Sucursal s
		WHERE s.sucursal=t.sucursal
	)
	--SELECT * FROM #sucursalTemp;
	DROP TABLE #sucursalTemp;
END
go
exec dbVenta.CargaInformacionComplementariaSucursal
select * from dbSucursal.Sucursal
GO
--Importar empleados
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
	
	INSERT INTO dbSucursal.Empleado(Legajo,dni,nombre,apellido,emailEmpresa,emailPersonal,direccion,cargo,turno,FKSucursal,estado)
	SELECT 
		t.Legajo,
		t.dni,
		t.nombre,
		t.apellido,
		t.emailEmpresa,
		t.emailPersonal,
		t.direccion,
		t.cargo,
		t.turno,
		s.IDSucursal,
		1
	FROM #empleadoTemp t
	JOIN dbSucursal.Sucursal s
		ON t.sucursal=s.sucursal
	WHERE NOT EXISTS(
		SELECT 1
		FROM dbSucursal.Empleado e
		WHERE e.Legajo=t.Legajo
	)

	--SELECT * FROM #empleadoTemp;
	DROP TABLE #empleadoTemp;

END
go
exec dbVenta.CargaInformacionComplementariaEmpleados
GO
--Importar clasificacion de productos
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
	
	INSERT INTO dbProducto.LineaDeProducto(nombre,estado)
	SELECT DISTINCT lineaDeProducto,1
	FROM #clasificacionProductosTemp t
	WHERE NOT EXISTS(
		SELECT 1
		FROM dbProducto.LineaDeProducto l
		WHERE l.nombre=t.lineaDeProducto
	)

	INSERT INTO dbProducto.Categoria(nombre,FKLineaDeProducto,estado)
	SELECT 
		t.categoria,
		l.IDLineaDeProducto,
		1
	FROM #clasificacionProductosTemp t
	JOIN dbProducto.LineaDeProducto l
		ON t.lineaDeProducto=l.nombre
	WHERE NOT EXISTS(
		SELECT 1
		FROM dbProducto.Categoria c
		WHERE c.nombre=t.categoria
	)

	--SELECT * FROM #clasificacionProductosTemp;
	DROP TABLE #clasificacionProductosTemp;
END
go
exec dbVenta.CargaInformacionComplementariaClasificacionProductos
GO

--Importar metodos de pago
CREATE OR ALTER PROCEDURE dbVenta.CargaInformacionComplementariaMetodosDePago
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

	END TRY
	BEGIN CATCH
		DECLARE @error NVARCHAR(MAX) = 'No se pudo importar el archivo ' + dbVenta.RutaImportacion() + '\Informacion_complementaria.xlsx. Actualizar ruta en dbVenta.RutaImportacion(Query 00) e intentar nuevamente.'
		raiserror(@error, 16, 1);
	END CATCH

	INSERT INTO dbVenta.MetodoDePago(nombre,estado)
	SELECT nombreENG,1
	FROM #metodoDePagoTemp t
	WHERE NOT EXISTS(
		SELECT 1
		FROM dbVenta.MetodoDePago m
		WHERE m.nombre=t.nombreENG
	)

	--SELECT * from #metodoDePagoTemp;
	DROP TABLE #metodoDePagoTemp;
END

go
exec dbVenta.CargaInformacionComplementariaMetodosDePago
select * from dbVenta.MetodoDePago
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
		reference_unit VARCHAR(20),
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

	UPDATE #ProductoDeCatalogoTemp
	SET name = REPLACE(name,N'?', 'ñ')	
	WHERE name LIKE N'%?%';

	UPDATE #ProductoDeCatalogoTemp
	SET name = REPLACE(name, N'Ã³', 'ó')
	WHERE name LIKE N'%Ã³%';

	-----------------------------
	INSERT INTO dbProducto.Producto(nombre, precioUnitario,unidadReferencia, fechaCreacion, FKCategoria, estado)
	SELECT 
		pc.name,
		pc.price,
		pc.reference_unit,
		GETDATE(),
		c.IDCategoria,
		1                      
	FROM #ProductoDeCatalogoTemp pc
	JOIN dbProducto.Categoria c
		ON pc.category = c.nombre  
	WHERE NOT EXISTS (
		SELECT 1 
		FROM dbProducto.Producto p 
		WHERE p.nombre = pc.name    
	);
	-----------------------------
	
	--SELECT * FROM #ProductoDeCatalogoTemp
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
			name varchar(100),
			proveedor varchar(50),
			categoria varchar(50),
			cantidadPorUnidad varchar(20),
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
		raiserror('No se encuentra la ruta al archivo Productos_importados.csv. Actualizarlo en dbVenta.RutaImportacion(Query 00)', 16, 1);
	END CATCH
	-----------------------------
	
	INSERT INTO dbProducto.LineaDeProducto(nombre,estado)	--mover
	VALUES('Importado',1)

	DECLARE @IDImportados INT
	SELECT @IDImportados=IDLineaDeProducto FROM dbProducto.LineaDeProducto WHERE nombre='Importado'
	--print @IDImportados

	INSERT INTO dbProducto.Categoria(nombre,FKLineaDeProducto,estado)
	SELECT DISTINCT i.categoria,@IDImportados,1
	FROM #productosImportadosTemp i
	WHERE NOT EXISTS (
		SELECT 1
		FROM dbProducto.Categoria c
		WHERE c.nombre = i.categoria
	)

	INSERT INTO dbProducto.Producto(nombre, precioUnitario,unidadReferencia, fechaCreacion, FKCategoria, estado)
	SELECT 
		i.name,
		i.precioPorUnidad,
		i.cantidadPorUnidad,
		GETDATE(),
		c.IDCategoria,
		1                      
	FROM #productosImportadosTemp i
	JOIN dbProducto.Categoria c
		ON i.categoria = c.nombre  
	WHERE NOT EXISTS (
		SELECT 1 
		FROM dbProducto.Producto p 
		WHERE p.nombre = i.name    
	);
	

	-----------------------------
	--SELECT * FROM #productosImportadosTemp
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
		RAISERROR('No se encuentra la ruta al archivo Electronic accessories.xlsx. Actualizarlo en dbVenta.RutaImportacion(Query 00)', 16, 1);
	END CATCH
	
	DECLARE @tasaCambio REAL;
	EXEC dbProducto.APIDolarAPeso @tasaCambio OUTPUT;
	print @tasaCambio

	update #accesoriosElectronicosTemp
	set precio_unitario_dolares=precio_unitario_dolares*@tasaCambio

	-----------------------------

	INSERT INTO dbProducto.LineaDeProducto(nombre,estado)	--mover
	VALUES('Tecnología',1)


	INSERT INTO dbProducto.Categoria(nombre,FKLineaDeProducto,estado)
	SELECT 'Electrónicos',IDLineaDeProducto,1
	FROM dbProducto.LineaDeProducto
	WHERE nombre='Tecnología'

	DECLARE @IDTecnologicos INT
	SELECT @IDTecnologicos=IDCategoria FROM dbProducto.Categoria WHERE nombre='Electrónicos'
	print @IDTecnologicos


	--INSERT INTO dbProducto.Producto(nombre, precioUnitario,unidadReferencia, fechaCreacion, FKCategoria, estado)
	--SELECT DISTINCT i.categoria,@IDImportados,1
	--FROM #productosImportadosTemp i
	--WHERE NOT EXISTS (
	--	SELECT 1
	--	FROM dbProducto.Categoria c
	--	WHERE c.nombre = i.categoria
	--)

	INSERT INTO dbProducto.Producto(nombre, precioUnitario,unidadReferencia, fechaCreacion, FKCategoria, estado)
	SELECT e.producto,e.precio_unitario_dolares,'1 unidad',GETDATE(),@IDTecnologicos,1                   
	FROM #accesoriosElectronicosTemp e
	WHERE NOT EXISTS (
		SELECT 1 
		FROM dbProducto.Producto p 
		WHERE p.nombre = e.producto
	);

	-----------------------------

	--SELECT * FROM #accesoriosElectronicosTemp;
	DROP TABLE #accesoriosElectronicosTemp;
END
go
exec dbProducto.cargaAccesoriosElectronicos
----------------------------------------
-- Obtener información complementaria(sucursal,empleados,medios de pago y clasificacion productos)
go
--CREATE OR ALTER PROCEDURE dbVenta.CargaInformacionComplementaria
--AS
--BEGIN
--	BEGIN TRY
--		DROP TABLE if exists #sucursalTemp;
--		CREATE TABLE #sucursalTemp(
--		    IDSucursal INT IDENTITY(1,1) PRIMARY KEY,
--			direccion VARCHAR(100),
--			numTelefono CHAR(9),
--			ciudad VARCHAR(9),
--			sucursal VARCHAR(20),
--			horario char(45)
--		);
--		DECLARE @sql NVARCHAR(MAX) = '
--			INSERT INTO #sucursalTemp(ciudad,sucursal,direccion,horario,numTelefono)
--			SELECT *
--			FROM OPENROWSET(
--				''Microsoft.ACE.OLEDB.12.0'',
--				''Excel 12.0 Xml;Database=' + dbVenta.RutaImportacion() + '\Informacion_complementaria.xlsx;HDR=NO;IMEX=1'',
--				''SELECT * FROM [sucursal$B3:F5]''
--			);'
--		EXEC sp_executesql @sql;

--		DROP TABLE if exists #empleadoTemp;
--		CREATE TABLE #empleadoTemp (
--		    Legajo INT PRIMARY KEY,
--			dni INT UNIQUE,
--			nombre VARCHAR(40),
--			apellido VARCHAR(20),
--			emailEmpresa VARCHAR(100),
--			emailPersonal VARCHAR(100),
--			direccion VARCHAR(100),
--			cargo CHAR(22),
--			turno CHAR(16),
--			CUIL VARCHAR(13),
--			sucursal VARCHAR(20)	--luego para mandarla a la tabla en la db tenemos que hacer un join con sucursal y mandar el idSucursal como fk
--			--FKSucursal INT NOT NULL REFERENCES dbSucursal.Sucursal(IDSucursal)
--		);
--		SET @sql='
--			INSERT INTO #empleadoTemp (Legajo,nombre,apellido,dni,direccion,emailPersonal,emailEmpresa,CUIL,cargo,sucursal,turno)
--			SELECT *
--			FROM OPENROWSET(
--				''Microsoft.ACE.OLEDB.12.0'',
--				''Excel 12.0 Xml;Database=' + dbVenta.RutaImportacion() + '\Informacion_complementaria.xlsx;HDR=NO;IMEX=1'',
--				''SELECT * FROM [Empleados$A3:K17]''
--			);'
--		EXEC sp_executesql @sql;

--		DROP TABLE if exists #clasificacionProductosTemp;
--		CREATE TABLE #clasificacionProductosTemp (
--		    id INT IDENTITY(1,1) PRIMARY KEY, 
--		    lineaDeProducto VARCHAR(30),
--			categoria VARCHAR(50)
--		);
--		SET @sql='
--			INSERT INTO #clasificacionProductosTemp (lineaDeProducto,categoria)
--			SELECT *
--			FROM OPENROWSET(
--				''Microsoft.ACE.OLEDB.12.0'',
--				''Excel 12.0 Xml;Database=' + dbVenta.RutaImportacion() + '\Informacion_complementaria.xlsx;HDR=NO;IMEX=1'',
--				''SELECT * FROM [Clasificacion productos$B2:C149]''
--			);'
--		EXEC sp_executesql @sql;
--	END TRY
--	BEGIN CATCH
--		RAISERROR('No se encuentra la ruta al archivo Informacion_complementaria.xlsx. Actualizarlo en dbVenta.RutaImportacion(Query 00)', 16, 1);
--	END CATCH

--	SELECT * FROM #sucursalTemp;
--	DROP TABLE #sucursalTemp;

--	SELECT * FROM #empleadoTemp;
--	DROP TABLE #empleadoTemp;

--	SELECT * FROM #clasificacionProductosTemp;
--	DROP TABLE #clasificacionProductosTemp;
--END
--go
--exec dbVenta.cargaInformacionComplementaria



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
		raiserror('Hubo un error importando los metodos de pago', 16, 1);
	END CATCH
END

go
exec dbVenta.CargaMetodosDePago

SELECT CONVERT(VARCHAR(10), GETDATE(), 105) AS 'Fecha Formato DD/MM/YYYY';

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
		DECLARE @var NVARCHAR(MAX) = 'No se encuentra la ruta al archivo ' + dbVenta.RutaImportacion() + '\Ventas_registradas.csv. Actualizarlo en dbVenta.RutaImportacion(Query 00)'
		raiserror(@var, 16, 1);
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