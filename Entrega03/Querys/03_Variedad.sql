USE Com2900G06
--use master
GO
CREATE OR ALTER PROCEDURE dbVenta.MostrarVentas
AS
BEGIN
	SELECT 
		STUFF(STUFF(CONVERT(VARCHAR(9), Factura), 4, 0, '-'), 7, 0, '-')  AS ID_Factura,	--Lo muestro con formato DDD-DD-DDDD
		tipoFactura AS Tipo_de_Factura,
		s.ciudad AS Ciudad,
		tipoCliente AS Tipo_de_Cliente,
		genero AS Genero,
		l.nombre AS Linea_de_Producto,
		p.nombre AS Producto,
		p.precioUnitario AS Precio_Unitario,
		cantidad AS Cantidad,
		fecha AS Fecha,
		hora AS Hora,
		m.nombre AS Medio_de_Pago,
		e.Legajo AS Empleado,
		s.sucursal AS Sucursal
	FROM dbVenta.Venta v
	JOIN dbProducto.Producto p
		ON p.IDProducto=v.FKproducto
	JOIN dbVenta.MetodoDePago m
		ON m.IDMetodoDePago=v.FKMetodoDePago
	JOIN dbSucursal.Empleado e
		ON e.Legajo=v.FKempleado
	JOIN dbSucursal.Sucursal s
		ON s.IDSucursal=e.FKSucursal
	JOIN dbProducto.Categoria c
		ON c.IDCategoria=p.FKCategoria
	JOIN dbProducto.LineaDeProducto l
		ON l.IDLineaDeProducto=c.FKLineaDeProducto
	ORDER BY Fecha,Hora
END
GO
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
	--Inserto Linea de producto "Importado" para luego poder buscarla al insertar productos importados
	INSERT INTO dbProducto.LineaDeProducto(nombre,estado)
	VALUES('Importado',1)
	
	--Inserto Linea de producto "Tecnología" y ,asociada a la misma, categoría "Electrónicos" para luego poder buscarla al insertar 
	--productos que sean accesorios electrónicos
	INSERT INTO dbProducto.LineaDeProducto(nombre,estado)
	VALUES('Tecnología',1)

	INSERT INTO dbProducto.Categoria(nombre,FKLineaDeProducto,estado)
	SELECT 'Electrónicos',IDLineaDeProducto,1
	FROM dbProducto.LineaDeProducto
	WHERE nombre='Tecnología'
END
GO
EXEC dbProducto.CargaInicialLineaYCategoria
