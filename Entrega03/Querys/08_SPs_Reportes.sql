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
	FROM (SELECT f.total as Total, DATENAME(WEEKDAY, f.fechaHoraEmision) AS dia
	FROM dbFactura.Factura f
	WHERE DATEPART(MONTH, f.fechaHoraEmision) = @mes AND DATEPART(YEAR, f.fechaHoraEmision) = @anio) AS cantPorDia
	PIVOT (SUM(Total)
		FOR dia in ([Lunes],[Martes],[Miércoles],[Jueves],[Viernes],[Sábado],[Domingo])) Producto
	FOR XML PATH('Producto'), ROOT ('Total_facturado'), ELEMENTS XSINIL;
END
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
    SELECT RTRIM(Turno) AS ''@Nombre'','+@columnas+'
    FROM (
        SELECT 
            f.total AS Cantidad_vendida, 
            e.turno AS Turno, 
            DATENAME(MONTH, v.fechaHoraVenta) AS mes
        FROM dbVenta.Venta v
        INNER JOIN dbFactura.Factura f ON f.IDFactura=v.FKFactura
        INNER JOIN dbSucursal.Empleado e ON e.Legajo = v.FKEmpleado
        WHERE DATEPART(QUARTER, v.fechaHoraVenta) = @trimestre AND DATEPART(YEAR, v.fechaHoraVenta) = @anio
    ) AS cantCuatrimestre
    PIVOT (
        SUM(Cantidad_vendida)
        FOR mes IN (' + @meses + ')
    ) AS Producto 
	FOR XML PATH(''Turno''), ROOT (''Trimestre''), ELEMENTS XSINIL;';

    EXEC sp_executesql @sql, N'@trimestre TINYINT, @anio SMALLINT', @trimestre, @anio;
END
GO

-- Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango, ordenado de mayor a menor. 
CREATE OR ALTER PROCEDURE dbReporte.mostrarCantidadPorFecha
    @inicioFecha DATE,
    @finFecha DATE
AS
BEGIN
	SELECT p.IDProducto AS '@IDProducto', p.nombre as Nombre, SUM(df.cantidad) as Cantidad_vendida
	FROM dbVenta.Venta v
	INNER JOIN dbFactura.Factura f ON f.IDFactura = v.FKFactura
	INNER JOIN dbFactura.DetalleDeFactura df ON df.FKFactura = f.IDFactura
	INNER JOIN dbProducto.Producto p ON p.IDProducto=df.FKProducto
	WHERE v.fechaHoraVenta >= @inicioFecha AND v.fechaHoraVenta <= @finFecha
	GROUP BY p.IDProducto, p.nombre
	ORDER BY SUM(df.cantidad) desc
	FOR XML PATH ('Producto'), ROOT ('Productos'), ELEMENTS XSINIL
END
GO

-- Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor a menor. 
CREATE OR ALTER PROCEDURE dbReporte.mostrarCantidadSucursalPorFecha
    @inicioFecha DATE,
    @finFecha DATE
AS
BEGIN
	SELECT distinct v.FKSucursal as '@IDSucursal', s.sucursal as Nombre, SUM(df.cantidad) OVER (PARTITION BY v.FKSucursal) as Cantidad_vendida
	FROM dbVenta.Venta v
	INNER JOIN dbFactura.Factura f ON f.IDFactura = v.FKFactura
	INNER JOIN dbFactura.DetalleDeFactura df ON df.FKFactura = f.IDFactura
	INNER JOIN dbProducto.Producto p ON p.IDProducto=df.FKProducto
	INNER JOIN dbSucursal.Sucursal s ON s.IDSucursal = v.FKSucursal
	WHERE v.fechaHoraVenta >= @inicioFecha AND v.fechaHoraVenta <= @finFecha
	ORDER BY Cantidad_vendida desc
	FOR XML PATH('Sucursal'), ROOT ('CantidadSucursal'), ELEMENTS XSINIL;
END
GO

-- Mostrar los 5 productos más vendidos en un mes, por semana
CREATE OR ALTER PROCEDURE dbReporte.mostrarTop5ProductosPorSemana
    @mes TINYINT,
    @anio SMALLINT
AS
BEGIN 
    SELECT *
    FROM (
        SELECT df.FKProducto AS '@IDProducto',
            p.nombre AS Nombre, 
			--Se resta la semana del año en la que cae el primer día del mes de la semana del año en la que está actualmente
            (DATEPART(WEEK, v.fechaHoraVenta) - DATEPART(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0, v.fechaHoraVenta), 0)) + 1) AS SemanaMes,
            SUM(df.cantidad) AS Cantidad_vendida,
            DENSE_RANK() OVER (PARTITION BY (DATEPART(WEEK, v.fechaHoraVenta) - DATEPART(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0, v.fechaHoraVenta), 0)) + 1)
                         ORDER BY SUM(df.cantidad) DESC) AS Ranking_Semana
        FROM dbVenta.Venta v
		INNER JOIN dbFactura.Factura f ON f.IDFactura = v.FKFactura
		INNER JOIN dbFactura.DetalleDeFactura df ON df.FKFactura = f.IDFactura
		INNER JOIN dbProducto.Producto p ON p.IDProducto= df.FKProducto
        WHERE DATEPART(MONTH, v.fechaHoraVenta) = @mes AND DATEPART(YEAR, v.fechaHoraVenta) = @anio
        GROUP BY df.FKProducto, p.nombre, 
                 (DATEPART(WEEK, v.fechaHoraVenta) - DATEPART(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0, v.fechaHoraVenta), 0)) + 1)
    ) ranked
    WHERE Ranking_Semana <= 5
    ORDER BY SemanaMes, Ranking_Semana
	FOR XML PATH('Producto'), ROOT ('TopProductos'), ELEMENTS XSINIL;
END
GO

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
            df.FKProducto AS '@IDProducto', p.nombre AS Nombre, 
            SUM(df.cantidad) AS Cantidad_vendida,
            DENSE_RANK() OVER (ORDER BY SUM(df.cantidad)) AS Ranking
        FROM dbVenta.Venta v
		INNER JOIN dbFactura.Factura f ON f.IDFactura = v.FKFactura
		INNER JOIN dbFactura.DetalleDeFactura df ON df.FKFactura = f.IDFactura
		INNER JOIN dbProducto.Producto p ON p.IDProducto = df.FKProducto

        WHERE DATEPART(MONTH, v.fechaHoraVenta) = @mes AND DATEPART(YEAR, v.fechaHoraVenta) = @anio
        GROUP BY df.FKProducto, p.nombre
    ) ranked
    WHERE Ranking <= 5
    ORDER BY Ranking
	FOR XML PATH('Producto'), ROOT ('TopProductos'), ELEMENTS XSINIL;
END
GO


--Mostrar total acumulado de ventas (o sea tambien mostrar el detalle) para una fecha y sucursal particulares 
CREATE OR ALTER PROCEDURE dbReporte.mostrarAcumuladoSucursal
@fecha DATE,
@idSucursal TINYINT
AS
BEGIN
		SELECT 
		-- Formateo del número de factura (con guiones en la posición adecuada)
		STUFF(STUFF(CONVERT(VARCHAR(9), f.numeroFactura), 4, 0, '-'), 7, 0, '-') AS ID_Factura,
		f.tipoFactura AS Tipo_de_Factura,
		s.Ciudad AS Ciudad,
		v.tipoCliente AS Tipo_de_Cliente,
		v.genero AS Genero,
		lp.nombre AS Linea_de_Producto,
		p.nombre AS Producto,
		p.precioUnitario AS Precio_Unitario,
		df.cantidad AS Cantidad,
		CAST(f.fechaHoraEmision AS DATE) AS Fecha,
		CAST(f.fechaHoraEmision AS TIME) AS Hora,
		m.nombre AS Medio_de_Pago,
		e.Legajo AS Empleado,
		s.sucursal AS Sucursal,
		SUM(f.total) OVER (ORDER BY v.fechaHoraVenta) as Acumulado
	FROM dbVenta.Venta v
	-- Relacionar Venta con Factura
	JOIN dbFactura.Factura f
		ON f.IDFactura = v.FKFactura
	-- Relacionar Factura con detalleDeFactura (productos vendidos)
	JOIN dbFactura.detalleDeFactura df
		ON df.FKFactura = f.IDFactura
	-- Relacionar detalleDeFactura con Producto
	JOIN dbProducto.Producto p
		ON p.IDProducto = df.FKProducto
	-- Relacionar Producto con LineaDeProducto
	JOIN dbProducto.Categoria c
		ON c.IDCategoria = p.FKCategoria
	JOIN dbProducto.LineaDeProducto lp
		ON lp.IDLineaDeProducto = c.FKLineaDeProducto
	-- Relacionar Venta con MetodoDePago
	JOIN dbVenta.MetodoDePago m
		ON m.IDMetodoDePago = v.FKMetodoDePago
	-- Relacionar Venta con Empleado (que está relacionado con Sucursal)
	JOIN dbSucursal.Empleado e
		ON e.Legajo = v.FKEmpleado
	JOIN dbSucursal.Sucursal s
		ON s.IDSucursal = v.FKSucursal

	WHERE CAST(v.fechaHoraVenta AS DATE) = @fecha
     AND s.IDSucursal = @idSucursal

	FOR XML PATH('Venta'), ROOT ('Ventas'), ELEMENTS XSINIL;

END
GO
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbVenta.MostrarVentas
AS
BEGIN
	SELECT 
		-- Formateo del número de factura (con guiones en la posición adecuada)
		STUFF(STUFF(CONVERT(VARCHAR(9), f.numeroFactura), 4, 0, '-'), 7, 0, '-') AS ID_Factura,
		f.tipoFactura AS Tipo_de_Factura,
		s.Ciudad AS Ciudad,
		cl.tipoCliente AS Tipo_de_Cliente,
		cl.genero AS Genero,
		lp.nombre AS Linea_de_Producto,
		p.nombre AS Producto,
		p.precioUnitario AS Precio_Unitario,
		dv.cantidad AS Cantidad,
		f.total AS Total,
		f.totalConIva AS Con_IVA,			--cambiar con la parametrizacion
		CAST(f.fechaHoraEmision AS DATE) AS Fecha,
		CAST(f.fechaHoraEmision AS TIME) AS Hora,
		m.nombre AS Medio_de_Pago,
		REPLICATE('0', 5 - DATALENGTH(f.puntoDeVenta)) + f.puntoDeVenta AS Punto_de_Venta,
		e.Legajo AS Empleado,
		s.sucursal AS Sucursal
	FROM dbVenta.Venta v
	-- Relacionar Venta con Factura
	JOIN dbFactura.Factura f
		ON f.IDFactura = v.FKFactura
	-- Relacionar Factura con detalleDeFactura (productos vendidos)
	JOIN dbVenta.DetalleDeVenta dv
		ON dv.FKVenta = v.IDVenta
	-- Relacionar detalleDeFactura con Producto
	JOIN dbProducto.Producto p
		ON p.IDProducto = dv.FKProducto
	-- Relacionar Producto con LineaDeProducto
	JOIN dbProducto.Categoria c
		ON c.IDCategoria = p.FKCategoria
	JOIN dbProducto.LineaDeProducto lp
		ON lp.IDLineaDeProducto = c.FKLineaDeProducto
	-- Relacionar Venta con MetodoDePago
	JOIN dbVenta.MetodoDePago m
		ON m.IDMetodoDePago = v.FKMetodoDePago
	-- Relacionar Venta con Empleado (que está relacionado con Sucursal)
	JOIN dbSucursal.Empleado e
		ON e.Legajo = v.FKEmpleado
	JOIN dbSucursal.Sucursal s
		ON s.IDSucursal = v.FKSucursal
	-- Relacionar Venta con Cliente
	JOIN dbCliente.Cliente cl
		ON v.FKCliente = cl.IDCliente
	ORDER BY f.fechaHoraEmision
END;
GO




