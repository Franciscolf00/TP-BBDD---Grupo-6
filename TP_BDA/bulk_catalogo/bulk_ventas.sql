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
    producto, N'Ã¡', 'á'),   -- Reemplaza á
    N'Ã©', 'é'),        -- Reemplaza é
    N'Ã­', 'í'),        -- Reemplaza í
    N'Ã³', 'ó'),        -- Reemplaza ó
    N'Ãº', 'ú'),         -- Reemplaza ú
	N'Ã±', 'ñ'),         -- Reemplaza ñ
	N'ÃƒÂº', 'ú'),		-- Reemplaza ú, tiene que ir antes que el de abajo porque comparten caracter
	N'Âº', '°')         -- Reemplaza °

WHERE producto LIKE N'%Ã¡%' OR
      producto LIKE N'%Ã©%' OR
      producto LIKE N'%Ã­%' OR
      producto LIKE N'%Ã³%' OR
      producto LIKE N'%Ãº%' OR
	  producto LIKE N'%Ã±%' OR
	  producto LIKE N'%ÃƒÂº%' OR
	  producto LIKE N'%Âº%';

select * from ddbba.Ventas
