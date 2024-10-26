CREATE DATABASE Com2900G06 COLLATE Modern_Spanish_CI_AS
GO

USE Com2900G06
GO

CREATE SCHEMA ddbba
GO

--------------------------------------------
--Obtener Ventas registradas

EXEC ddbba.importarVentasRegistradas 'C:\Users\Francisco\OneDrive - Enta Consulting\Escritorio\BBDD Aplicada\TP BBDD Aplicada\TP_integrador_Archivos\Ventas_registradas.csv'

SELECT * FROM ddbba.Ventas
--------------------------------------------


CREATE OR ALTER PROCEDURE ddbba.importarVentasRegistradas
@rutaArchivo varchar(MAX)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX);
	SET @sql = N'
	BULK INSERT ddbba.Ventas
	FROM ''' + @rutaArchivo + N'''
	WITH
	(
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''\n'',
		FIRSTROW = 2,
		CODEPAGE = ''65001''
	)'
	EXEC sp_executesql @sql;
END
GO
-----------------------------------------

SELECT * FROM ddbba.ProductoImportado
-------------------------------------
--Configuración de oledb
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

EXEC sp_MSSet_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;
EXEC sp_MSSet_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;
GO

-------------------------------------
--Obtener archivo de productos importados


INSERT INTO ddbba.ProductoImportado
SELECT *
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0 Xml;HDR=YES;Database=C:\Users\Francisco\OneDrive - Enta Consulting\Escritorio\BBDD Aplicada\TP BBDD Aplicada\TP_integrador_Archivos\Productos\Productos_importados.xlsx',
    'SELECT * FROM [Listado de Productos$]'
);

SELECT * FROM ddbba.ProductoImportado

EXEC sp_enum_oledb_providers; --- PARA VER SI TENGO INSTALADO OLEDB

SELECT * FROM ddbba.ProductoImportado

----------------------------------------
-- Obtener archivo de accesorios electrónicos


INSERT INTO ddbba.accesoriosElectronicos
SELECT *
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0 Xml;HDR=YES;Database=C:\Users\Francisco\OneDrive - Enta Consulting\Escritorio\BBDD Aplicada\TP BBDD Aplicada\TP_integrador_Archivos\Productos\Electronic accessories.xlsx',
    'SELECT * FROM [Sheet1$B:C]'
);