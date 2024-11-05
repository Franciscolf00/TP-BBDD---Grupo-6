USE Com2900G06
GO

----------INSERTAR EN SUCURSAL----------

CREATE OR ALTER PROCEDURE dbSucursal.insertarSucursal 
	@direccion VARCHAR(200),
	@numTelefono CHAR(9),
	@ciudad VARCHAR(50),
	@sucursal VARCHAR(50)
AS
BEGIN
	IF EXISTS(SELECT 1 FROM dbSucursal.Sucursal --Aca verificamos si existe la sucursal con la misma dirección y ciudad
			WHERE direccion = @direccion 
               AND ciudad = @ciudad)
	BEGIN
		UPDATE dbSucursal.Sucursal	--Si existe updateamos el estado de 0 a 1
		SET estado = 1
		WHERE direccion = @direccion
		AND ciudad = @ciudad
	END
	ELSE
	BEGIN --Si no existe insertamos la nueva sucursal
		INSERT INTO dbSucursal.Sucursal(direccion, numTelefono, ciudad, sucursal, estado)
		VALUES(@direccion, @numTelefono, @ciudad, @sucursal, 1)
	END
END
GO
---PRUEBA
exec dbSucursal.insertarSucursal 'El Aguila', '4487', 'Ciudad Evita', 'sucursal 1'
select * from dbSucursal.Sucursal


----------ACTUALIZAR SUCURSAL----------

CREATE OR ALTER PROCEDURE dbSucursal.actualizarSucursal
	@IDSucursal INT,
	@direccion VARCHAR(200) = NULL,
	@numTelefono CHAR(9) = NULL,
	@ciudad VARCHAR(50) = NULL,
	@sucursal VARCHAR(50) = NULL
AS
BEGIN
	IF(SELECT 1 FROM db.Sucursal WHERE IDSucursal = @IDSucursal)
	BEGIN
		UPDATE dbSucursal.Sucursal
		SET	direccion = COALESCE(@direccion, direccion),
			numTelefono = COALESCE(@numTelefono, numTelefono),
			ciudad = COALESCE(@ciudad, ciudad),
			sucursal = COALESCE(@sucursal, sucursal)
		WHERE IDSucursal = @IDSucursal
	END
	ELSE
		PRINT 'ID no encontrado'

END
GO
---PRUEBA
EXEC dbSucursal.ActualizarSucursal 
    @IDSucursal = 1, 
    @direccion = 'Nueva Dirección 12345'
select * from dbSucursal.Sucursal
----------ELIMINAR SUCURSAL----------

CREATE OR ALTER PROCEDURE dbSucursal.eliminarSucursal --Solo hacemos un borrado lógico
	@IDSucursal INT
AS
BEGIN
	IF(SELECT 1 FROM db.Sucursal WHERE IDSucursal = @IDSucursal)
	BEGIN
		UPDATE dbSucursal.Sucursal
		SET estado = 0
		WHERE IDSucursal = @IDSucursal
	ELSE
		PRINT 'ID no encontrado'
END
GO
---PRUEBA
EXEC dbSucursal.eliminarSucursal 
    @IDSucursal = 1
select * from dbSucursal.Sucursal