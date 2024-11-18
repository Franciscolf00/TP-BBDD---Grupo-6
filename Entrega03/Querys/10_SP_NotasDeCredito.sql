USE Com2900G06
GO
-- SP Generación de nota de crédito
CREATE OR ALTER PROCEDURE dbFactura.GenerarNotaDeCredito
	@IDFactura INT,
	@motivo VARCHAR(150),
	@numeroComprobante INT,
	@monto DECIMAL(10,2)
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = '';

	IF @motivo IS NULL OR @motivo = ''
		SET @error = @error + 'Es necesario ingresar un motivo para la generación de la Nota de Crédito.';

	IF NOT EXISTS(SELECT 1 FROM dbFactura.Factura WHERE IDFactura=@IDFactura)
		SET @error = @error + 'No existe factura con el ID ingresado.';
										
	IF (@numeroComprobante=0 OR @numeroComprobante IS NULL)
		SET @error = @error + 'Falta el numero de comprobante. ';
	ELSE IF(@numeroComprobante < 1 OR @numeroComprobante > 99999999)
		SET @error = @error + 'Numero de comprobante inválido, debe encontrarse entre 1-99999999. ';
	ELSE IF EXISTS(SELECT numeroComprobante FROM dbFactura.NotaDeCredito WHERE numeroComprobante=@numeroComprobante)
		SET @error = @error + 'Numero de comprobante ya existente. ';
	
	IF (@monto <= 0 OR @monto IS NULL )
		SET @error = @error + 'El monto debe ser mayor a 0. ';
	ELSE IF(@monto > (SELECT total FROM dbFactura.Factura WHERE IDFactura=@IDFactura) )
		SET @error = @error + 'El monto no puede ser mayor al total pagado. ';

	IF EXISTS(SELECT 1 FROM dbFactura.Factura WHERE IDFactura=@IDFactura AND (estadoFactura = 'E' OR estadoFactura IS NULL))
		SET @error = @error + 'Para realizar una nota de crédito, debe existir una factura en estado pagada.';

	IF (@error = '')
    BEGIN
		INSERT INTO dbFactura.NotaDeCredito(motivo, fechaHoraNota, numeroComprobante, FKFactura)
		SELECT @motivo, GETDATE(), @numeroComprobante, @IDFactura
	END
	ELSE
	BEGIN
		RAISERROR(@error, 16, 1);
	END
END
GO