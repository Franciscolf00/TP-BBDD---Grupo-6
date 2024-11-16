USE Com2900G06
--Actualizaciones
GO
CREATE OR ALTER PROCEDURE dbSucursal.ActualizarSucursal
	@IDSucursal INT,
	@direccion VARCHAR(100) = NULL,
	@numTelefono CHAR(9) = NULL,
	@ciudad VARCHAR(50) = NULL,
	@sucursal VARCHAR(50) = NULL
AS
BEGIN
	IF EXISTS (SELECT 1 FROM dbSucursal.Sucursal WHERE IDSucursal = @IDSucursal)
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
------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbSucursal.ActualizarEmpleado
	@empleadoAactualizar INT,
	@dni INT,
	@nombre VARCHAR(40),
	@apellido VARCHAR(20),
	@emailEmpresa VARCHAR(100),
	@emailPersonal VARCHAR(100),
	@direccion VARCHAR(100),
	@cargo CHAR(22),
	@turno CHAR(16),
	@FKSucursal INT
AS
BEGIN
    DECLARE @error VARCHAR(max)='';
	--Existe el empleado (y la sucursal) que quiero actualizar?
    IF NOT EXISTS (SELECT Legajo FROM dbSucursal.Empleado WHERE Legajo = @empleadoAactualizar)
        SET @error = @error+'El empleado con el legajo especificado no existe. '

	IF NOT EXISTS(SELECT IDSucursal FROM dbSucursal.Sucursal WHERE IDSucursal=@FKSucursal)
		SET @error = @error+'La sucursal con el id especificado no existe. '
        
	IF @error=''
	BEGIN
		UPDATE dbSucursal.Empleado
		SET 
			dni=@dni,
			nombre=@nombre,
			apellido= @apellido,
			emailEmpresa=@emailEmpresa,
			emailPersonal=@emailPersonal,
			direccion=@direccion,
			cargo=@cargo,
			turno=@turno,
			FKSucursal=@FKSucursal
		WHERE Legajo=@empleadoAactualizar;
		PRINT 'Empleado actualizado exitosamente.';
	END
	ELSE
		RAISERROR(@error, 16, 1);
END
------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbProducto.ActualizarLineaDeProducto
	@lineaDeProductoAactualizar INT,
	@nombre VARCHAR(30)
AS
BEGIN
	DECLARE @error VARCHAR(max)=''
    --Existe la linea de producto que quiero actualizar?
    IF NOT EXISTS (SELECT 1 FROM dbProducto.LineaDeProducto WHERE IDLineaDeProducto=@lineaDeProductoAactualizar)
        SET @error=@error+'La linea de producto con el ID especificado no existe. '
	IF @error=''
	BEGIN
		UPDATE dbProducto.LineaDeProducto
		SET 
			nombre=@nombre
		WHERE IDLineaDeProducto=@lineaDeProductoAactualizar;

		PRINT 'Linea de producto actualizada exitosamente.';
	END
	ELSE
		RAISERROR(@error, 16, 1);

END
------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbProducto.ActualizarCategoria
	@categoriaAactualizar INT,
	@nombre VARCHAR(50),
	@FKLineaDeProducto INT
AS
BEGIN
	DECLARE @error VARCHAR(max)=''
    --Existe la categoria que quiero actualizar?
    IF NOT EXISTS (SELECT 1 FROM dbProducto.Categoria WHERE IDCategoria=@categoriaAactualizar)
		SET @error=@error+'La categoria con el ID especificado no existe. '
	IF NOT EXISTS(SELECT 1 FROM dbProducto.LineaDeProducto WHERE IDLineaDeProducto=@FKLineaDeProducto)
		SET @error = @error+'La linea de producto con el id especificado no existe. '
	IF @error='' 
	BEGIN
		UPDATE dbProducto.Categoria
		SET 
			nombre=@nombre,
			FKLineaDeProducto=@FKLineaDeProducto
		WHERE IDCategoria=@categoriaAactualizar;

		PRINT 'Categoria actualizada exitosamente.';
	END
	ELSE	
		RAISERROR(@error, 16, 1);

END
------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbProducto.ActualizarProducto
	@productoAactualizar INT,
	@nombre VARCHAR(100),
	@precioUnitario DECIMAL(10,2),
	@precioReferencia DECIMAL(10,2),
	@unidadReferencia VARCHAR(20),
	@FKCategoria INT
AS
BEGIN
	DECLARE @error VARCHAR(max)=''
    --Existe el producto que quiero actualizar?
    IF NOT EXISTS (SELECT 1 FROM dbProducto.Producto WHERE IDProducto=@productoAactualizar)
        SET @error=@error+'El producto con el ID especificado no existe. '
	IF NOT EXISTS (SELECT 1 FROM dbProducto.Categoria WHERE IDCategoria=@FKCategoria)
		SET @error=@error+'La categoria con el ID especificado no existe. '
    IF @error=''
	BEGIN
		UPDATE dbProducto.Producto
		SET 
			nombre=@nombre,
			precioUnitario=@precioUnitario,
			precioReferencia=@precioReferencia,
			unidadReferencia=@unidadReferencia,
			FKCategoria=@FKCategoria
		WHERE IDProducto=@productoAactualizar;

		PRINT 'Producto actualizado exitosamente.';
	END
	ELSE
		RAISERROR(@error, 16, 1);

END
------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbVenta.ActualizarMetodoDePago
	@metodoDePagoAactualizar INT,
	@nombre VARCHAR(11)
AS
BEGIN
	DECLARE @error VARCHAR(max)=''
        --Existe el metodo de pago que quiero actualizar?
    IF NOT EXISTS (SELECT 1 FROM dbVenta.MetodoDePago WHERE IDMetodoDePago=@metodoDePagoAactualizar)
		SET @error=@error+'El metodo de pago con el ID especificado no existe.'
    
	IF @error=''
    BEGIN   
		UPDATE dbVenta.MetodoDePago
		SET 
			nombre=@nombre
		WHERE IDMetodoDePago=@metodoDePagoAactualizar;

        PRINT 'Metodo de pago actualizado exitosamente.';
	END
	ELSE
		RAISERROR(@error, 16, 1);
END
------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbFactura.RecibirPagoFactura
	@IDFactura INT
AS
BEGIN
	DECLARE @error VARCHAR(max)=''

	IF NOT EXISTS (SELECT 1 FROM dbFactura.Factura WHERE IDFactura=@IDFactura)
		SET @error=@error+'La factura con el ID ingresado no existe.'
	ELSE IF EXISTS(SELECT 1 FROM dbFactura.Factura WHERE IDFactura=@IDFactura AND fechaHoraEmision IS NULL)
		SET @error=@error+'La factura con el ID ingresado todavia no ha sido emitida.'
	ELSE IF EXISTS(SELECT 1 FROM dbFactura.Factura WHERE IDFactura=@IDFactura AND estadoFactura='P')
		SET @error=@error+'La factura con el ID ingresado ya fue pagada.'

	IF @error=''
	BEGIN
		UPDATE dbFactura.Factura
		SET estadoFactura='P'
		WHERE IDFactura=@IDFactura
	END
	ELSE
		RAISERROR(@error, 16, 1);
END
GO