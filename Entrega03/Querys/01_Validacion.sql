USE Com2900G06
GO

CREATE OR ALTER PROCEDURE dbVenta.InsertarMetodoDePago
    @nombre VARCHAR(200)
AS
BEGIN
    DECLARE @error varchar(max) = '';
	/*
    -- Validar id_metodoPago
    IF (@id_metodoPago IS NULL OR @id_metodoPago = 0)
        SET @error = 'IDMetodoDePago vacío o nulo. ';
    IF EXISTS (SELECT IDMetodoDePago FROM dbVenta.MetodoDePago WHERE IDMetodoDePago = @id_metodoPago)
        SET @error = @error + 'El IDMetodoDePago ingresado ya existe. '; */

    -- Validar nombre 
    IF (COALESCE(@nombre, '') = '')
        SET @error = @error + 'Falta nombre. ';
	IF (LEN(@nombre)>200)
		SET @error = @error + 'Nombre demasiado largo. Tamaño maximo de 11 caracteres. ';
    IF EXISTS (SELECT nombre FROM dbVenta.MetodoDePago WHERE nombre = @nombre)
        SET @error = @error + 'El nombre del metodo de pago ingresado ya existe. ';

    -- Insertar datos si no hay errores
    IF (@error = '')
    BEGIN
        INSERT INTO dbVenta.MetodoDePago (nombre)
        VALUES (@nombre);
    END
    ELSE
    BEGIN
        RAISERROR (@error, 16, 1);
    END
END


