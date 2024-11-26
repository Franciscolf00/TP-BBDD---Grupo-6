USE Com2900G06
--Borrados(Lógicos)
GO
CREATE OR ALTER PROCEDURE dbSucursal.ModificarEstadoSucursal
	@IDSucursal INT,
	@estado BIT
AS
BEGIN
	DECLARE	 @error VARCHAR(max)=''
		--Me fijo que exista y si lo hace que esté activa
	IF NOT EXISTS (SELECT 1 FROM dbSucursal.Sucursal WHERE IDSucursal = @IDSucursal)
		SET	@error=@error+'La sucursal no existe. '
	IF @error=''
	BEGIN
        IF EXISTS (SELECT 1 FROM dbSucursal.Sucursal WHERE IDSucursal = @IDSucursal AND @estado = 1)
		BEGIN
			UPDATE dbSucursal.Sucursal
			SET estado = 1,fechaBaja=NULL
			WHERE IDSucursal = @IDSucursal;
			PRINT 'La sucursal ha sido activada correctamente. ';
		END
		ELSE
		BEGIN
			UPDATE dbSucursal.Sucursal
			SET estado = 0,fechaBaja=GETDATE()
			WHERE IDSucursal = @IDSucursal;
			PRINT 'La sucursal ha sido desactivada correctamente. ';
		END
	END
	ELSE
		RAISERROR(@error, 16, 1);
END
------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbSucursal.ModificarEstadoEmpleado
	@Legajo INT,
	@estado BIT
AS
BEGIN
	DECLARE	 @error VARCHAR(max)=''
	--Me fijo que exista y si lo hace que esté activa
    IF NOT EXISTS (SELECT 1 FROM dbSucursal.Empleado WHERE Legajo = @Legajo)
        SET	@error=@error+'El empleado no existe. '
	IF @error=''
	BEGIN
        IF EXISTS (SELECT 1 FROM dbSucursal.Empleado WHERE Legajo = @Legajo AND @estado = 1)
		BEGIN
			UPDATE dbSucursal.Empleado
			SET estado = 1,fechaBaja=NULL
			WHERE Legajo = @Legajo;
			PRINT 'El empleado ha sido dado de alta correctamente.';
		END
		ELSE
		BEGIN
			UPDATE dbSucursal.Empleado
			SET estado = 0,fechaBaja=GETDATE()
			WHERE Legajo = @Legajo;
			PRINT 'El empleado ha sido dado de baja correctamente.';
		END
	END
    ELSE
		RAISERROR(@error, 16, 1);
END
------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbProducto.ModificarEstadoLineaDeProducto
	@IDLineaDeProducto INT,
	@estado BIT
AS
BEGIN
	DECLARE	 @error VARCHAR(max)=''
	--Me fijo que exista y si lo hace que esté activa
    IF NOT EXISTS (SELECT 1 FROM dbProducto.LineaDeProducto WHERE IDLineaDeProducto = @IDLineaDeProducto)
		SET	@error=@error+'La linea de producto no existe. '
	IF @error=''
	BEGIN
        IF EXISTS (SELECT 1 FROM dbProducto.LineaDeProducto WHERE IDLineaDeProducto = @IDLineaDeProducto AND @estado = 1)
		BEGIN
			UPDATE dbProducto.LineaDeProducto
			SET estado = 1,fechaBaja=NULL
			WHERE IDLineaDeProducto = @IDLineaDeProducto;
			PRINT 'La linea de producto ha sido activada correctamente.';
		END
		ELSE
		BEGIN
			UPDATE dbProducto.LineaDeProducto
			SET estado = 0,fechaBaja=GETDATE()
			WHERE IDLineaDeProducto = @IDLineaDeProducto;
			PRINT 'La linea de producto ha sido desactivada correctamente.';
		END
    END 
    ELSE
		RAISERROR(@error, 16, 1);
END
------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbProducto.ModificarEstadoCategoria
	@IDCategoria INT,
	@estado BIT
AS
BEGIN
	DECLARE	 @error VARCHAR(max)=''
		--Me fijo que exista y si lo hace que esté activa
    IF NOT EXISTS (SELECT 1 FROM dbProducto.Categoria WHERE IDCategoria = @IDCategoria)
        SET	@error=@error+'La categoria no existe. '
	IF @error=''
	BEGIN
        IF EXISTS (SELECT 1 FROM dbProducto.Categoria WHERE IDCategoria = @IDCategoria AND @estado = 1)	
		BEGIN
			UPDATE dbProducto.Categoria
			SET estado = 1,fechaBaja=NULL
			WHERE IDCategoria = @IDCategoria;
			PRINT 'La categoria ha sido activada correctamente.';
		END
		ELSE
		BEGIN
			UPDATE dbProducto.Categoria
			SET estado = 0,fechaBaja=GETDATE()
			WHERE IDCategoria = @IDCategoria;
			PRINT 'La categoria ha sido desactivada correctamente.';
		END
    END
    ELSE
		RAISERROR(@error, 16, 1);
END
------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbProducto.ModificarEstadoProducto
	@IDProducto INT,
	@estado BIT
AS
BEGIN
	DECLARE	 @error VARCHAR(max)=''
		--Me fijo que exista y si lo hace que esté activa
    IF NOT EXISTS (SELECT 1 FROM dbProducto.Producto WHERE IDProducto = @IDProducto)
        SET	@error=@error+'El producto no existe. '
	IF @error=''
	BEGIN
        IF EXISTS (SELECT 1 FROM dbProducto.Producto WHERE IDProducto = @IDProducto AND @estado = 1)
		BEGIN
			UPDATE dbProducto.Producto
			SET estado = 1,fechaBaja=NULL
			WHERE IDProducto = @IDProducto;
			PRINT 'El producto ha sido activado correctamente.';
		END
		ELSE
		BEGIN
			UPDATE dbProducto.Producto
			SET estado = 0,fechaBaja=GETDATE()
			WHERE IDProducto = @IDProducto;
			PRINT 'El producto ha sido desactivado correctamente.';
		END
    END
    ELSE
		RAISERROR(@error, 16, 1);
END
------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbVenta.ModificarEstadoMetodoDePago
	@IDMetodoDePago INT,
	@estado BIT
AS
BEGIN
	DECLARE	 @error VARCHAR(max)=''
		--Me fijo que exista y si lo hace que esté activa
    IF NOT EXISTS (SELECT 1 FROM dbVenta.MetodoDePago WHERE IDMetodoDePago = @IDMetodoDePago)
        SET	@error=@error+'El metodo de pago no existe. '
	IF @error=''
	BEGIN
        IF EXISTS (SELECT 1 FROM dbVenta.MetodoDePago WHERE IDMetodoDePago = @IDMetodoDePago AND @estado = 1)
        BEGIN
			UPDATE dbVenta.MetodoDePago
			SET estado = 1,fechaBaja=NULL
			WHERE IDMetodoDePago = @IDMetodoDePago;
			PRINT 'El metodo de pago ha sido activado correctamente.';
		END
		ELSE
		BEGIN
			UPDATE dbVenta.MetodoDePago
			SET estado = 0,fechaBaja=GETDATE()
			WHERE IDMetodoDePago = @IDMetodoDePago;
			PRINT 'El metodo de pago ha sido desactivado correctamente.';
		END
    END
    ELSE
		RAISERROR(@error, 16, 1);
END
GO
------------------------------------------------------------------------------------
--Modificar Cliente
CREATE OR ALTER PROCEDURE dbCliente.ModificarEstadoCliente
	@IDCliente INT,
	@estado BIT
AS
BEGIN
	DECLARE @error VARCHAR(MAX)= ''
	IF NOT EXISTS (SELECT 1 FROM dbCliente.Cliente WHERE IDCliente = @IDCliente)
		SET @error =@error + 'El cliente no existe. '
	IF @IDCliente >= 1 AND @IDCliente <= 4
		SET @error =@error + 'No se puede modificar IDs entre 1 y 4. '
	IF @error = ''
	BEGIN
		IF(@estado = 1)
		BEGIN
			UPDATE dbCliente.Cliente
			SET fechaBaja = NULL
			WHERE IDCliente = @IDCliente
			PRINT 'El cliente ha sido dada de alta correctamente'
		END
		ELSE
			UPDATE dbCliente.Cliente
			SET fechaBaja = GETDATE()
			WHERE IDCliente = @IDCliente
			PRINT 'El cliente ha sido dada de baja correctamente'
	END
	ELSE
		RAISERROR(@error, 16, 1);
END
GO