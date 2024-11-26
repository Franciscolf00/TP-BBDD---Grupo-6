USE Com2900G06
GO
CREATE OR ALTER PROCEDURE dbFactura.PruebaFacturasVentasYNotasDeCredito
AS
BEGIN
	DECLARE @IDVenta INT;

	EXEC dbVenta.InsertarVenta				
		@FKempleado = 54321,              
		@FKMetodoDePago = 1,                       
		@FKSucursal = 1,
		@IDVentaGenerada=@IDVenta OUTPUT;	

	EXEC dbVenta.InsertarDetalleDeVenta	
		@cantidad=5,
		@FKProducto=1,
		@FKVenta=@IDVenta;
	EXEC dbVenta.InsertarDetalleDeVenta	
		@cantidad=2,
		@FKProducto=2,
		@FKVenta=@IDVenta;

	EXEC dbFactura.EmitirFactura
		@IDVenta=@IDVenta,			
		@numeroFactura=996665244,			
		@identificadorDePago = '1234-5678-9012-3456', 
		@tipoFactura='B',
		@puntoDeVenta=1;


	EXEC dbFactura.GenerarNotaDeCredito 10, '',756,-30;	--No hay motivo, no existe factura, numero comprobante invalido y monto invalido
	EXEC dbFactura.GenerarNotaDeCredito					--monto excedido al total y no esta pagada
		1, 
		'Nota de crédito por feriado',
		99965999,
		500;

	EXEC dbFactura.RecibirPagoFactura 1;

	EXEC dbFactura.GenerarNotaDeCredito					--Se genera exitosamente la NC($93 restantes)
		1,
		'Devolución de compra por insatisfacción.',
		99965500,
		100.60;
	EXEC dbFactura.GenerarNotaDeCredito					--Se genera exitosamente la NC($3 restantes)
		1,
		'Devolución de compra por mucha insatisfacción.',
		99965501,
		90;
	EXEC dbFactura.GenerarNotaDeCredito					--monto excedido al total
		1,
		'Devolución de compra por exceso de insatisfacción.',
		99965502,
		5;

END
GO
EXEC dbFactura.PruebaFacturasVentasYNotasDeCredito

SELECT * FROM dbVenta.Venta
GO
SELECT * FROM dbFactura.Factura
GO
SELECT * FROM dbFactura.NotaDeCredito
GO
delete from dbFactura.NotaDeCredito