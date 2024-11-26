USE Com2900G06
--use master
GO
CREATE OR ALTER PROCEDURE dbSistema.ConfiguracionInicial
	@CUITAurora CHAR(13),
	@PorcentajeIVA DECIMAL(5,2),
	@montoMinimoDatos DECIMAL(10,2)
AS
BEGIN
	DECLARE @error VARCHAR(max)='';
	IF( dbSistema.ValidarCUIT(@CUITAurora) = 0)
		SET @error=@error + 'CUIT de la empresa invalido. ';

	IF (@PorcentajeIVA < 0 OR @PorcentajeIVA IS NULL )
		SET @error = @error + 'El IVA debe ser mayor o igual a 0. ';	--se vale soñar

	IF (@montoMinimoDatos <= 0 OR @montoMinimoDatos IS NULL )
		SET @error = @error + 'El monto minimo para exigir datos para factura tipo B y C debe ser mayor a 0. ';

	IF EXISTS(SELECT 1 FROM dbSistema.Parametrizacion)
		SET @error = @error + 'No se puede tener más de una configuración. ';
	IF (@error = '')
    BEGIN
        INSERT INTO dbSistema.Parametrizacion (CUITAurora,PorcentajeIVA,montoMinimoDatos)
		VALUES (@CUITAurora,@PorcentajeIVA,@montoMinimoDatos);
    END
    ELSE
        RAISERROR (@error, 16, 1);
END
GO
--Ingreso el CUIT validado, el porcentaje de IVA y el monto minimo a partir del cual se piden los datos del cliente
EXEC dbSistema.ConfiguracionInicial
	@CUITAurora='30-68584975-1',
	@PorcentajeIVA=0.21,
	@montoMinimoDatos=100;
GO
CREATE OR ALTER PROCEDURE dbSistema.CambiarConfiguracion
	@CUITAurora CHAR(13),
	@PorcentajeIVA DECIMAL(5,2),
	@montoMinimoDatos DECIMAL(10,2)
AS
BEGIN
	DECLARE @error VARCHAR(max)='';
	IF( dbSistema.ValidarCUIT(@CUITAurora) = 0)
		SET @error=@error + 'CUIT de la empresa invalido. ';

	IF (@PorcentajeIVA < 0 OR @PorcentajeIVA IS NULL )
		SET @error = @error + 'El IVA debe ser mayor o igual a 0. ';	--se vale soñar

	IF (@montoMinimoDatos <= 0 OR @montoMinimoDatos IS NULL )
		SET @error = @error + 'El monto minimo para exigir datos para factura tipo B y C debe ser mayor a 0. ';

	IF NOT EXISTS(SELECT 1 FROM dbSistema.Parametrizacion)
		SET @error = @error + 'No se cargó la configuración inicial. ';
	IF (@error = '')
    BEGIN
        UPDATE dbSistema.Parametrizacion
		SET CUITAurora=@CUITAurora,
			PorcentajeIVA=@PorcentajeIVA,
			montoMinimoDatos=@montoMinimoDatos
    END
    ELSE
        RAISERROR (@error, 16, 1);
END
GO
--EXEC dbSistema.CambiarConfiguracion
--	@CUITAurora='30-68584975-1',
--	@PorcentajeIVA=0.21,
--	@montoMinimoDatos=1000;
--GO
CREATE OR ALTER PROCEDURE dbCliente.clientesGenericos
AS
BEGIN
	--Inserto previamente a las inserciones por SP cuatro combinaciones de clientes "genéricos", usados cuando no pedimos datos
	--del cliente o bien estamos importandolo y no contamos con todos los datos
	INSERT INTO dbCliente.Cliente (tipoCliente, genero,cui)
	VALUES 
		('Member', 'M','20-22222222-3'),
		('Member', 'F','20-22222222-3'),
		('Normal', 'M','20-22222222-3'),
		('Normal', 'F','20-22222222-3')
END
GO
EXEC dbCliente.clientesGenericos
GO