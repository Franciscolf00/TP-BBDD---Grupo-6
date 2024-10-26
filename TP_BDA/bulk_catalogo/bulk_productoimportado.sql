DROP TABLE IF EXISTS ddbba.ProductoImportado
GO


exec sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
exec sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
go
INSERT INTO ddbba.ProductoImportado
SELECT *
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0 Xml;HDR=YES;Database=C:\TP_integrador_Archivos\Productos\Productos_importados.xlsx',
    'SELECT * FROM [Listado de Productos$]'
);
go
SELECT * FROM ddbba.ProductoImportado
go
--EXEC sp_enum_oledb_providers; --- PARA VER SI TENGO INSTALADO OLEDB
