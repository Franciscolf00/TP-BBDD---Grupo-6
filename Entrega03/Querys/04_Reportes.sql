USE Com2900G06
GO

SET LANGUAGE Spanish;

SELECT DATEPART(QUARTER, getDate())

GO
CREATE OR ALTER PROCEDURE dbReporte.mostrarTotalDias
    @mes TINYINT,
    @anio SMALLINT
AS
BEGIN
	SELECT * 
	FROM (SELECT p.precioUnitario * v.cantidad as Cantidad_vendida, p.nombre, DATENAME(WEEKDAY, v.fecha) AS dia
	FROM dbVenta.Venta v
	INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto
	WHERE DATEPART(MONTH, v.fecha) = @mes AND DATEPART(YEAR, v.fecha) = @anio) AS cantPorDia
	PIVOT (SUM(Cantidad_vendida)
		FOR dia in ([Lunes],[Martes],[Miercoles],[Jueves],[Viernes],[Sábado],[Domingo])) Cruzado
END
GO   

CREATE OR ALTER PROCEDURE dbReporte.mostrarTotalTrimestre
    @mes TINYINT,
    @anio SMALLINT
AS
BEGIN
	SELECT * 
	FROM (SELECT p.precioUnitario * v.cantidad as Cantidad_vendida, e.turno, DATEPART(QUARTER, v.fecha) AS trimestre
	FROM dbVenta.Venta v
	INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto
	INNER JOIN dbSucursal.Empleado e ON e.Legajo = v.FKEmpleado
	WHERE DATEPART(MONTH, v.fecha) = @mes AND DATEPART(YEAR, v.fecha) = @anio) AS cantCuatrimestre
	PIVOT (SUM(Cantidad_vendida)
		FOR trimestre in ([1],[2],[3],[4])) Cruzado
END
go   

CREATE OR ALTER PROCEDURE dbReporte.mostrarCantidadPorFecha
    @inicioFecha DATE,
    @finFecha DATE
AS
BEGIN
	SELECT p.nombre, COUNT(v.FKProducto) as Cantidad_vendida
	FROM dbVenta.Venta v
	INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto
	WHERE v.fecha >= @inicioFecha AND v.fecha <= @finFecha
	GROUP BY v.FKProducto, p.nombre
	ORDER BY COUNT(v.FKProducto) desc
END
go

CREATE OR ALTER PROCEDURE dbReporte.mostrarCantidadSucursalPorFecha
    @inicioFecha DATE,
    @finFecha DATE
AS
BEGIN
	SELECT s.sucursal, p.nombre, COUNT(v.FKProducto) OVER (PARTITION BY v.FKSucursal) as Cantidad_vendida
	FROM dbVenta.Venta v
	INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto
	INNER JOIN dbSucursal.Sucursal s ON s.IDSucursal = v.FKSucursal
	WHERE v.fecha >= @inicioFecha AND v.fecha <= @finFecha
	ORDER BY Cantidad_vendida desc
END
go


CREATE OR ALTER PROCEDURE dbReporte.mostrarCantidadSucursalPorFecha
    @inicioFecha DATE,
    @finFecha DATE
AS
BEGIN
	SELECT s.sucursal, p.nombre, COUNT(v.FKProducto) OVER (PARTITION BY v.FKSucursal) as Cantidad_vendida
	FROM dbVenta.Venta v
	INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto
	INNER JOIN dbSucursal.Sucursal s ON s.IDSucursal = v.FKSucursal
	WHERE v.fecha >= @inicioFecha AND v.fecha <= @finFecha
	ORDER BY Cantidad_vendida desc
END
go

CREATE OR ALTER PROCEDURE dbReporte.mostrarTop5ProductosPorSemana
AS
BEGIN 
	SELECT *
	FROM (
		SELECT 
			p.nombre, DATEPART(WEEK, v.fecha) as Semana, DATEPART(MONTH, v.fecha) as Mes,
			RANK() OVER (PARTITION BY DATEPART(WEEK, v.fecha), DATEPART(MONTH, v.fecha) ORDER BY DATEPART(WEEK, v.fecha), DATEPART(MONTH, v.fecha)) AS ranking_producto
		FROM dbVenta.Venta v
		INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto
	) ranked_clients
	WHERE ranking_producto <= 5
	ORDER BY Mes, Semana, ranking_producto;
END
go

CREATE OR ALTER PROCEDURE dbReporte.mostrarTopMenos5ProductosPorMes
AS
BEGIN 
	SELECT *
	FROM (
		SELECT 
			p.nombre, DATEPART(MONTH, v.fecha) as Mes,
			RANK() OVER (PARTITION BY DATEPART(MONTH, v.fecha) ORDER BY DATEPART(MONTH, v.fecha)) AS ranking_producto
		FROM dbVenta.Venta v 
		INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto 
	) ranked_clients
	WHERE ranking_producto <= 5
	ORDER BY Mes, ranking_producto
END
go

CREATE OR ALTER PROCEDURE dbReporte.mostrarAcumuladoSucursal
@fecha DATE,
@idSucursal TINYINT
AS
BEGIN
	SELECT v.Factura,  v.tipoFactura, v.identificadorDePago, v.fecha, v.hora, s.sucursal, v.cantidad, p.nombre, p.precioUnitario, SUM(p.precioUnitario * v.cantidad) OVER (PARTITION BY v.fecha, v.FKSucursal ORDER BY v.fecha) as Acumulado
	FROM dbVenta.Venta v
	INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto
	INNER JOIN dbSucursal.Sucursal s ON s.IDSucursal = v.FKSucursal
	WHERE v.fecha <= @fecha AND s.IDSucursal = @idSucursal
END
go