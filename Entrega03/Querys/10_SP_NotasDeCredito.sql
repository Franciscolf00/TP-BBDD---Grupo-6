USE Com2900G06
GO
-- SP Generación de nota de crédito
CREATE OR ALTER PROCEDURE dbFactura.GenerarNotaDeCredito
	@IDFactura INT,
	@motivo VARCHAR(150)
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = '';

	IF @motivo IS NULL OR @motivo = ''
		SET @error = @error + 'Es necesario ingresar un motivo para la generación de la Nota de Crédito.';

	IF NOT EXISTS(SELECT 1 FROM dbFactura.Factura WHERE IDFactura=@IDFactura)
		SET @error = @error + 'No existe factura con el ID ingresado.';

	IF EXISTS(SELECT 1 FROM dbFactura.Factura WHERE IDFactura=@IDFactura AND (estadoFactura = 'E' OR estadoFactura IS NULL))
		SET @error = @error + 'Para realizar una nota de crédito, debe existir una factura en estado pagada.';

	IF (@error = '')
    BEGIN
		INSERT INTO dbFactura.NotaDeCredito(motivo, fechaHoraNota, FKFactura)
		SELECT @motivo, GETDATE(), @IDFactura
	END
	ELSE
	BEGIN
		RAISERROR(@error, 16, 1);
	END
END
GO