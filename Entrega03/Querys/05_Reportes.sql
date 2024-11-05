USE Com2900G06
GO

SET LANGUAGE Spanish;
GO

--Mensual: ingresando un mes y año determinado mostrar el total facturado por días de la semana, incluyendo sábado y domingo. 
CREATE OR ALTER PROCEDURE dbReporte.mostrarTotalDias
    @mes TINYINT,
    @anio SMALLINT
AS
BEGIN
	--'Total facturado'
	SELECT isnull(Lunes, 0) Lunes, isnull(Martes, 0) Martes, isnull(Miércoles, 0) Miércoles,
	isnull(Jueves, 0) Jueves, isnull(Sábado, 0) Sábado, isnull(Domingo, 0) Domingo 
	FROM (SELECT p.precioUnitario * v.cantidad as Cantidad_vendida, DATENAME(WEEKDAY, v.fecha) AS dia
	FROM dbVenta.Venta v
	INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto
	WHERE DATEPART(MONTH, v.fecha) = @mes AND DATEPART(YEAR, v.fecha) = @anio) AS cantPorDia
	PIVOT (SUM(Cantidad_vendida)
		FOR dia in ([Lunes],[Martes],[Miércoles],[Jueves],[Viernes],[Sábado],[Domingo])) Producto
	FOR XML PATH('Producto'), ROOT ('Total_facturado'), ELEMENTS XSINIL;
END
GO   

--Otra version, separando por producto
--CREATE OR ALTER PROCEDURE dbReporte.mostrarTotalDias
--    @mes TINYINT,
--    @anio SMALLINT
--AS
--BEGIN
--	SELECT 'Total facturado', isnull(Lunes, 0) Lunes, isnull(Martes, 0) Martes, isnull(Miércoles, 0) Miércoles,
--	isnull(Jueves, 0) Jueves, isnull(Sábado, 0) Sábado, isnull(Domingo, 0) Domingo 
--	FROM (SELECT p.precioUnitario * v.cantidad as Cantidad_vendida,  DATENAME(WEEKDAY, v.fecha) AS dia
--	FROM dbVenta.Venta v
--	INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto
--	WHERE DATEPART(MONTH, v.fecha) = @mes AND DATEPART(YEAR, v.fecha) = @anio) AS cantPorDia
--	PIVOT (SUM(Cantidad_vendida)
--		FOR dia in ([Lunes],[Martes],[Miércoles],[Jueves],[Viernes],[Sábado],[Domingo])) Producto
--	--FOR XML PATH('Producto'), ROOT ('Total_facturado'), ELEMENTS XSINIL;
--END
--GO   

exec dbReporte.mostrarTotalDias 1,2019
GO


-- Trimestral: mostrar el total facturado por turnos de trabajo por mes. 
CREATE OR ALTER PROCEDURE dbReporte.mostrarTotalTrimestre
    @trimestre TINYINT,
    @anio SMALLINT
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @meses VARCHAR(MAX);
    DECLARE @columnas VARCHAR(MAX);

    SET @meses = CASE @trimestre
                    WHEN 1 THEN '[Enero], [Febrero], [Marzo]'
                    WHEN 2 THEN '[Abril], [Mayo], [Junio]'
                    WHEN 3 THEN '[Julio], [Agosto], [Septiembre]'
                    WHEN 4 THEN '[Octubre], [Noviembre], [Diciembre]'
                 END;

    SET @columnas = CASE @trimestre
                            WHEN 1 THEN 'ISNULL([Enero], 0) AS Enero, ISNULL([Febrero], 0) AS Febrero, ISNULL([Marzo], 0) AS Marzo'
                            WHEN 2 THEN 'ISNULL([Abril], 0) AS Abril, ISNULL([Mayo], 0) AS Mayo, ISNULL([Junio], 0) AS Junio'
                            WHEN 3 THEN 'ISNULL([Julio], 0) AS Julio, ISNULL([Agosto], 0) AS Agosto, ISNULL([Septiembre], 0) AS Septiembre'
                            WHEN 4 THEN 'ISNULL([Octubre], 0) AS Octubre, ISNULL([Noviembre], 0) AS Noviembre, ISNULL([Diciembre], 0) AS Diciembre'
                         END;

    SET @sql = '
    SELECT Turno AS ''@Nombre'','+@columnas+'
    FROM (
        SELECT 
            p.precioUnitario * v.cantidad AS Cantidad_vendida, 
            e.turno AS Turno, 
            DATENAME(MONTH, v.fecha) AS mes
        FROM dbVenta.Venta v
        INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto
        INNER JOIN dbSucursal.Empleado e ON e.Legajo = v.FKEmpleado
        WHERE DATEPART(QUARTER, v.fecha) = @trimestre AND DATEPART(YEAR, v.fecha) = @anio
    ) AS cantCuatrimestre
    PIVOT (
        SUM(Cantidad_vendida)
        FOR mes IN (' + @meses + ')
    ) AS Producto 
	FOR XML PATH(''Turno''), ROOT (''Trimestre''), ELEMENTS XSINIL;';

    EXEC sp_executesql @sql, N'@trimestre TINYINT, @anio SMALLINT', @trimestre, @anio;
END
GO

exec dbReporte.mostrarTotalTrimestre 1,2019

go
-- Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango, ordenado de mayor a menor. 
CREATE OR ALTER PROCEDURE dbReporte.mostrarCantidadPorFecha
    @inicioFecha DATE,
    @finFecha DATE
AS
BEGIN
	SELECT v.FKProducto AS '@IDProducto', p.nombre as Nombre, COUNT(v.FKProducto) as Cantidad_vendida
	FROM dbVenta.Venta v
	INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto
	WHERE v.fecha >= @inicioFecha AND v.fecha <= @finFecha
	GROUP BY v.FKProducto, p.nombre
	ORDER BY COUNT(v.FKProducto) desc
	FOR XML PATH ('Producto'), ROOT ('Productos'), ELEMENTS XSINIL
END
go


exec dbReporte.mostrarCantidadPorFecha '2019-01-15', '2019-03-15'
go

-- Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor a menor. 
CREATE OR ALTER PROCEDURE dbReporte.mostrarCantidadSucursalPorFecha
    @inicioFecha DATE,
    @finFecha DATE
AS
BEGIN
	SELECT distinct v.FKSucursal as '@IDSucursal', s.sucursal as Nombre, COUNT(v.FKProducto) OVER (PARTITION BY v.FKSucursal) as Cantidad_vendida
	FROM dbVenta.Venta v
	INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto
	INNER JOIN dbSucursal.Sucursal s ON s.IDSucursal = v.FKSucursal
	WHERE v.fecha >= @inicioFecha AND v.fecha <= @finFecha
	ORDER BY Cantidad_vendida desc
	FOR XML PATH('Sucursal'), ROOT ('CantidadSucursal'), ELEMENTS XSINIL;
END
go


exec dbReporte.mostrarCantidadSucursalPorFecha '2019-01-15', '2019-03-15'
go

-- Mostrar los 5 productos más vendidos en un mes, por semana
CREATE OR ALTER PROCEDURE dbReporte.mostrarTop5ProductosPorSemana
    @mes TINYINT,
    @anio SMALLINT
AS
BEGIN 
    SELECT *
    FROM (
        SELECT v.FKProducto AS '@IDProducto',
            p.nombre AS Nombre, 
			--Se resta la semana del año en la que cae el primer día del mes de la semana del año en la que está actualmente
            (DATEPART(WEEK, v.fecha) - DATEPART(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0, v.fecha), 0)) + 1) AS SemanaMes,
            COUNT(v.FKProducto) AS Cantidad_vendida,
            DENSE_RANK() OVER (PARTITION BY (DATEPART(WEEK, v.fecha) - DATEPART(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0, v.fecha), 0)) + 1)
                         ORDER BY COUNT(v.FKProducto) DESC) AS Ranking_Semana
        FROM dbVenta.Venta v
        INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto
        WHERE DATEPART(MONTH, v.fecha) = @mes AND DATEPART(YEAR, v.fecha) = @anio
        GROUP BY v.FKProducto, p.nombre, 
                 (DATEPART(WEEK, v.fecha) - DATEPART(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0, v.fecha), 0)) + 1)
    ) ranked
    WHERE Ranking_Semana <= 5
    ORDER BY SemanaMes, Ranking_Semana
	FOR XML PATH('Producto'), ROOT ('TopProductos'), ELEMENTS XSINIL;
END
GO

EXEC dbReporte.mostrarTop5ProductosPorSemana 1, 2019;
GO

--Mostrar los 5 productos menos vendidos en el mes. 
CREATE OR ALTER PROCEDURE dbReporte.mostrarTopMenos5ProductosPorMes
    @mes TINYINT,
	@anio SMALLINT
AS
BEGIN 
    SELECT *
    FROM (
        SELECT 
            v.FKProducto AS '@IDProducto', p.nombre AS Nombre, 
            COUNT(v.FKProducto) AS Cantidad_vendida,
            DENSE_RANK() OVER (ORDER BY COUNT(v.FKProducto)) AS Ranking
        FROM dbVenta.Venta v
        INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto
        WHERE DATEPART(MONTH, v.fecha) = @mes AND DATEPART(YEAR, v.fecha) = @anio
        GROUP BY v.FKProducto, p.nombre
    ) ranked
    WHERE Ranking <= 5
    ORDER BY Ranking
	FOR XML PATH('Producto'), ROOT ('TopProductos'), ELEMENTS XSINIL;
END
GO

EXEC dbReporte.mostrarTopMenos5ProductosPorMes 1, 2019;
GO

--Mostrar total acumulado de ventas (o sea tambien mostrar el detalle) para una fecha y sucursal particulares 
CREATE OR ALTER PROCEDURE dbReporte.mostrarAcumuladoSucursal
@fecha DATE,
@idSucursal TINYINT
AS
BEGIN
	SELECT v.IDVenta AS '@IDVenta', v.Factura, v.tipoFactura, v.identificadorDePago, v.fecha, v.hora, s.sucursal, v.cantidad, p.nombre, p.precioUnitario, 
	SUM(p.precioUnitario * v.cantidad) OVER (ORDER BY v.fecha) as Acumulado
	FROM dbVenta.Venta v
	INNER JOIN dbProducto.Producto p ON p.IDProducto = v.FKProducto
	INNER JOIN dbSucursal.Sucursal s ON s.IDSucursal = v.FKSucursal
	WHERE v.fecha = @fecha AND s.IDSucursal = @idSucursal
	FOR XML PATH('Venta'), ROOT ('Ventas'), ELEMENTS XSINIL;
END
go

EXEC dbReporte.mostrarAcumuladoSucursal '2019-03-01', 1;
GO