--CREATE DATABASE [Com2900G06] COLLATE SQL_Latin1_General_CP1_CI_AS
--GO
USE [Com2900G06]
GO
DROP TABLE IF EXISTS #ProductoDeCatalogoTemp
GO

CREATE OR ALTER PROCEDURE importarCatalogo 
@path VARCHAR(MAX)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = '
        BULK INSERT [Com2900G06].ddbba.Catalogo
        FROM ''' + @path + '''
        WITH (
            FORMAT = ''CSV'',
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0a'',
            FIRSTROW = 2,
            FIELDQUOTE = ''"'',
            CODEPAGE = ''65001''
        );';

    EXEC sp_executesql @sql;
END;

CREATE TABLE #ProductoDeCatalogoTemp (
    id INT PRIMARY KEY, --no mandar identity o sino los que tiene ID desordenados en el archivo original quedan mal
    category nVARCHAR(100),
	name nVARCHAR(100),
    price DECIMAL(10,2),
    reference_price DECIMAL(10,2),
    reference_unit VARCHAR(10),
    date SMALLDATETIME
);
GO

BULK INSERT #ProductoDeCatalogoTemp
FROM 'C:\Users\Tomas_Arce\Desktop\usb pasar\Facultad\BBDDAplicadas\TP_integrador_Archivos\Productos\catalogo.csv'
WITH
(
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
	CODEPAGE = '65001'
)
GO

UPDATE #ProductoDeCatalogoTemp
SET name = REPLACE(name,N'?', '๑')
WHERE name LIKE N'%?%';

GO
UPDATE #ProductoDeCatalogoTemp
SET name = REPLACE(name, N'รณ', '๓')		
WHERE name LIKE N'%รณ%'; 
GO



SELECT *
FROM #ProductoDeCatalogoTemp
