DROP TABLE IF EXISTS ddbba.Ventas
GO
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

EXEC ddbba.importarVentasRegistradas 'C:\TP_integrador_Archivos\Ventas_registradas.csv'

UPDATE ddbba.Ventas
SET producto = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    producto, N'á', '�'),   -- Reemplaza �
    N'é', '�'),        -- Reemplaza �
    N'í', '�'),        -- Reemplaza �
    N'ó', '�'),        -- Reemplaza �
    N'ú', '�'),         -- Reemplaza �
	N'ñ', '�'),         -- Reemplaza �
	N'Ãº', '�'),		-- Reemplaza �, tiene que ir antes que el de abajo porque comparten caracter
	N'º', '�')         -- Reemplaza �

WHERE producto LIKE N'%á%' OR
      producto LIKE N'%é%' OR
      producto LIKE N'%í%' OR
      producto LIKE N'%ó%' OR
      producto LIKE N'%ú%' OR
	  producto LIKE N'%ñ%' OR
	  producto LIKE N'%Ãº%' OR
	  producto LIKE N'%º%';

select * from ddbba.Ventas
