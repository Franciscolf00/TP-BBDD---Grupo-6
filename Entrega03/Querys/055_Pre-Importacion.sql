USE Com2900G06
-----------------------------------------------------------
--API PARA PASAR DE DOLARES A PESOS(CAMBIO OFICIAL)
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

	--SELECT @tasaCambio AS [Tasa de conversión];
END
GO
CREATE OR ALTER PROCEDURE dbProducto.CargaInicialLineaYCategoria
AS
BEGIN
	----Inserto Linea de producto "Importado" para luego poder buscarla al insertar productos importados
	--EXEC dbProducto.InsertarLineaDeProducto 
	--	@nombreLineaDeProducto='Importado';

	----Inserto Linea de producto "Tecnología" y ,asociada a la misma, categoría "Electrónicos" para luego poder buscarla al insertar 
	----productos que sean accesorios electrónicos
	--EXEC dbProducto.InsertarLineaDeProducto 
	--	@nombreLineaDeProducto='Tecnología';
	--DECLARE @IDTecnologicos INT;
	--SELECT @IDTecnologicos=IDLineaDeProducto FROM dbProducto.LineaDeProducto WHERE nombre='Tecnología';
	--EXEC dbProducto.InsertarCategoria
	--	@nombreCategoria='Eletrónicos',
	--	@FKLineaDeProducto=@IDTecnologicos;

	--DEBUG(no valido duplicados porque inserto directo)
	INSERT INTO dbProducto.LineaDeProducto(nombre,estado)
	VALUES('Importado',1)
	
	INSERT INTO dbProducto.LineaDeProducto(nombre,estado)
	VALUES('Tecnología',1)

	INSERT INTO dbProducto.Categoria(nombre,FKLineaDeProducto,estado)
	SELECT 'Electrónicos',IDLineaDeProducto,1
	FROM dbProducto.LineaDeProducto
	WHERE nombre='Tecnología'
END
GO
EXEC dbProducto.CargaInicialLineaYCategoria