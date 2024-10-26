USE [Com2900G06]
go
DROP TABLE IF EXISTS #Electrodomesticos
go
--CREATE TABLE #Electrodomesticos (
--    id INT IDENTITY(1,1) PRIMARY KEY, 
--    product VARCHAR(100),
--	precio_unitario_dolares decimal(5,2),
--);
GO
--exec sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--exec sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO
SELECT * into #Electrodomesticos
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0;Database=C:\TP_integrador_Archivos\Productos\Electronic accessories.xlsx;HDR=YES;IMEX=1',
                'SELECT * FROM [Sheet1$]')
go
select * from #Electrodomesticos
go
