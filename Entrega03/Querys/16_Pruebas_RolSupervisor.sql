USE Com2900G06;
GO

-- Un supervisor tiene el rol asignado para poder generar NC:
EXECUTE AS LOGIN = 'Supervisor';
GO
EXEC dbFactura.GenerarNotaDeCredito 11, 'Nota de crédito por fondos insuficientes', 1234, 123;
GO

-- Un supervisor no tiene el rol asignado para poder generar ventas:
DECLARE @venta INT;
EXEC dbVenta.InsertarVenta 1111111111111111111111, 1, 1, 1, 1, @IDVentaGenerada = @venta;
GO