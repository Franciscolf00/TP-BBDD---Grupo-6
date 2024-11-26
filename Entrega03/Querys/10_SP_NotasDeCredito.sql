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
	DECLARE @totalConIva DECIMAL(10,2);
    DECLARE @totalNotasCredito DECIMAL(10,2);

	IF @motivo IS NULL OR @motivo = ''
		SET @error = @error + 'Es necesario ingresar un motivo para la generación de la Nota de Crédito.';

	IF NOT EXISTS(SELECT 1 FROM dbFactura.Factura WHERE IDFactura=@IDFactura)
		SET @error = @error + 'No existe factura con el ID ingresado.';
	ELSE IF EXISTS(SELECT 1 FROM dbFactura.Factura WHERE IDFactura=@IDFactura AND (estadoFactura = 'E' OR estadoFactura IS NULL))
		SET @error = @error + 'Para realizar una nota de crédito, debe existir una factura en estado pagada.';
	
	IF (@numeroComprobante=0 OR @numeroComprobante IS NULL)
		SET @error = @error + 'Falta el numero de comprobante. ';
	ELSE IF(@numeroComprobante < 1 OR @numeroComprobante > 99999999)
		SET @error = @error + 'Numero de comprobante inválido, debe encontrarse entre 1-99999999. ';
	ELSE IF EXISTS(SELECT numeroComprobante FROM dbFactura.NotaDeCredito WHERE numeroComprobante=@numeroComprobante)
		SET @error = @error + 'Numero de comprobante ya existente. ';
	
	IF (@monto <= 0 OR @monto IS NULL )
		SET @error = @error + 'El monto debe ser mayor a 0. ';
	--ELSE IF(@monto > (SELECT totalConIva FROM dbFactura.Factura WHERE IDFactura=@IDFactura) )
	--	SET @error = @error + 'El monto no puede ser mayor al total pagado. ';

	 -- Validar monto acumulado de notas de crédito
    IF @error = ''
    BEGIN
        --Obtengo el total con IVA
        SELECT @totalConIva = totalConIva 
        FROM dbFactura.Factura 
        WHERE IDFactura = @IDFactura;

        --Calculo el total acumulado por NCs
        SELECT @totalNotasCredito = ISNULL(SUM(ISNULL(monto, 0)), 0)
        FROM dbFactura.NotaDeCredito 
        WHERE FKFactura = @IDFactura;

        --Verifico no excederme del total entre las NCs anteriores y la nueva que estoy queriendo generar
        IF (@monto + @totalNotasCredito) > @totalConIva
            SET @error = @error + 'El monto acumulado de las notas de crédito no puede exceder el total con IVA de la factura. ';
    END

	

	IF (@error = '')
    BEGIN
		INSERT INTO dbFactura.NotaDeCredito(motivo, fechaHoraNota, numeroComprobante, FKFactura, monto)
		SELECT @motivo, GETDATE(), @numeroComprobante, @IDFactura,@monto
	END
	ELSE
	BEGIN
		RAISERROR(@error, 16, 1);
	END
END
GO