USE Com2900G06;
GO

-- Un cajero no tiene el rol asignado para poder generar NC:
EXECUTE AS LOGIN = 'Empleado';
GO
EXEC dbFactura.GenerarNotaDeCredito 11, 'Nota de crédito por fondos insuficientes', 1234, 123;
GO

-- Un cajero  tiene el rol asignado para poder generar ventas:
DECLARE @venta INT;
EXEC dbVenta.InsertarVenta 1111111111111111111111, 1, 1, 1, 1, @IDVentaGenerada = @venta;
GO