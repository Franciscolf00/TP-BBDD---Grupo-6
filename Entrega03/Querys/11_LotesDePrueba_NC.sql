USE Com2900G06

-- Caso 1: No hay motivo
EXEC dbFactura.GenerarNotaDeCredito 1, '';
GO

--Caso 2: No existe factura
EXEC dbFactura.GenerarNotaDeCredito 3856333, 'Nota de crédito por feriado';
GO

--Caso 3: Caso de éxito
EXEC dbFactura.GenerarNotaDeCredito 11, 'Nota de crédito por fondos insuficientes';
GO

CREATE OR ALTER PROCEDURE dbFactura.PruebaFacturasVentasYNotasDeCredito
AS
BEGIN
	DECLARE @IDFactura INT;
	--Creo la factura
	EXEC dbFactura.CrearFactura @IDFacturaGenerada=@IDFactura OUTPUT;

	--Inserto detalles
	EXEC dbFactura.InsertarDetalleDeFactura
		@cantidad=5,
		@FKProducto=1,
		@FKFactura=@IDFactura;
	EXEC dbFactura.InsertarDetalleDeFactura
		@cantidad=2,
		@FKProducto=2,
		@FKFactura=@IDFactura;

	--Emito la factura
	EXEC dbFactura.EmitirFactura
		@IDFactura=@IDFactura,			
		@numeroFactura=546665241,	
		@tipoFactura='A';

	--Le asigno la factura a la venta
	EXEC dbVenta.InsertarVenta
		@tipoCliente = 'Normal',
		@genero = 'Male',
		@identificadorDePago = '1234-5678-9012-3456', 
		@FKempleado = 54321,              
		@FKMetodoDePago = 1,                       
		@FKSucursal = 1,
		@FKFactura = @IDFactura;

	--Recibo pago factura
	EXEC dbFactura.RecibirPagoFactura @IDFactura

	--Genero NC factura
	EXEC dbFactura.GenerarNotaDeCredito @IDFactura, 'Devolución de compra por insatisfacción.'

END
GO
EXEC dbFactura.PruebaFacturasVentasYNotasDeCredito

SELECT * FROM dbVenta.Venta
GO
SELECT * FROM dbFactura.Factura
GO
SELECT * FROM dbFactura.NotaDeCredito
GO
