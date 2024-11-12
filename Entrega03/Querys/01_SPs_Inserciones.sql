USE Com2900G06
--use master;
/*///////////////////////////////////////////////////////////////////////////////////////// */
--Inserciones

GO
CREATE OR ALTER PROCEDURE dbVenta.InsertarMetodoDePago
    @nombre VARCHAR(max)
AS
BEGIN
    DECLARE @error varchar(max) = '';

    -- Validar nombre 
    IF (COALESCE(@nombre, '') = '')
        SET @error = @error + 'Falta nombre. ';
	ELSE IF (LEN(@nombre)>11)
		SET @error = @error + 'Nombre demasiado largo. Tamaño maximo de 11 caracteres. ';
    ELSE IF EXISTS (SELECT nombre FROM dbVenta.MetodoDePago WHERE nombre = @nombre)
        SET @error = @error + 'El nombre del metodo de pago ingresado ya existe. ';

    -- Insertar datos si no hay errores
    IF (@error = '')
    BEGIN
        INSERT INTO dbVenta.MetodoDePago (nombre,estado)
        VALUES (@nombre,1);
    END
    ELSE
    BEGIN
        RAISERROR (@error, 16, 1);
    END
END
------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbSucursal.InsertarSucursal
	@direccion VARCHAR(max) = '',
	@numTelefono CHAR(9),
	@ciudad VARCHAR(max),
	@sucursal VARCHAR(max)
AS
BEGIN
    DECLARE @error varchar(max) = '';

	--Validar sucursal
	IF (COALESCE(@sucursal, '') = '')
        SET @error = @error + 'Falta la sucursal. ';
	ELSE IF (LEN(@sucursal)>20)
		SET @error = @error + 'Sucursal demasiado larga. Tamaño maximo de 20 caracteres. ';
    ELSE IF EXISTS (SELECT sucursal FROM dbSucursal.Sucursal WHERE sucursal = @sucursal)
        SET @error = @error + 'La sucursal ingresada ya existe. ';

	--Validar ciudad
	IF (COALESCE(@ciudad, '') = '')
        SET @error = @error + 'Falta la ciudad. ';
	ELSE IF (LEN(@ciudad)>9)
		SET @error = @error + 'Ciudad demasiado larga. Tamaño maximo de 9 caracteres. ';
	--Validar numTelefono
	IF (COALESCE(@numTelefono, '') = '')
		SET @error = @error + 'Falta el numero de telefono de la sucursal. ';

    -- Validar direccion 
    IF (COALESCE(@direccion, '') = '')
        SET @error = @error + 'Falta direccion. ';
	ELSE IF (LEN(@direccion)>100)
		SET @error = @error + 'Dirección demasiado larga. Tamaño maximo de 100 caracteres. ';

    -- Insertar datos si no hay errores
    IF (@error = '')
    BEGIN
        INSERT INTO dbSucursal.Sucursal(direccion,numTelefono,ciudad,sucursal,estado)
        VALUES (@direccion,@numTelefono,@ciudad,@sucursal,1);
    END
    ELSE
    BEGIN
        RAISERROR (@error, 16, 1);
    END
END
------------------------------------------------------------------------------------
go
CREATE OR ALTER PROCEDURE dbVenta.InsertarEmpleado
	@Legajo INT,
	@dni INT,
	@nombre VARCHAR(max),
	@apellido VARCHAR(max),
	@emailEmpresa VARCHAR(max),
	@emailPersonal VARCHAR(max),
	@direccion VARCHAR(max),
	@cargo CHAR(22),
	@turno CHAR(16),
	@FKSucursal INT
AS
BEGIN
    DECLARE @error varchar(max) = '';
	
    --Validar Legajo
    IF (@Legajo IS NULL OR @Legajo = 0)
        SET @error = 'Legajo vacío o nulo. ';
    IF EXISTS (SELECT @Legajo FROM dbSucursal.Empleado WHERE Legajo = @Legajo)
        SET @error = @error + 'El Legajo ingresado ya existe. '; 

	--Validar dni
	IF (@dni IS NULL OR @dni = 0)
        SET @error = 'DNI vacío o nulo. ';
    IF EXISTS (SELECT @dni FROM dbSucursal.Empleado WHERE dni = @dni)
        SET @error = @error + 'El DNI ingresado ya existe. '; 

    --Validar nombre 
    IF (COALESCE(@nombre, '') = '')
        SET @error = @error + 'Falta nombre. ';
	ELSE IF (LEN(@nombre)>40)
		SET @error = @error + 'Nombre demasiado largo. Tamaño maximo de 40 caracteres. ';
	
	--Validar apellido
	IF (COALESCE(@apellido, '') = '')
        SET @error = @error + 'Falta apellido. ';
	ELSE IF (LEN(@apellido)>20)
		SET @error = @error + 'Apellido demasiado largo. Tamaño maximo de 20 caracteres. ';
	
	--Validar email Empresa
    IF (COALESCE(@emailEmpresa, '') = '' OR @emailEmpresa NOT LIKE '%@superA.com' 
	OR LEN(@emailEmpresa) >= 100)
        SET @error = @error + 'Mail(empresa) inválido. ';

	--Validar email Personal
    IF (COALESCE(@emailPersonal, '') = '' OR @emailPersonal NOT LIKE '%@%.com' 
	OR LEN(@emailPersonal) >= 100)
        SET @error = @error + 'Mail(personal) inválido. ';

	--Validar dirección
	IF (COALESCE(@direccion, '') = '')
		SET @error = @error + 'Falta la dirección. ';
	ELSE IF (LEN(@direccion) > 100)
		SET @error = @error + 'Dirección del empleado demasiado larga. Tamaño máximo de 100 caracteres. ';

	--Validar cargo
	IF (COALESCE(@cargo, '') = '' OR @cargo NOT in('Cajero', 'Supervisor', 'Gerente de sucursal'))
		SET @error = @error + 'Cargo inválido(Cargos disponibles: Cajero,Supervisor,Gerente de sucursal). ';

	--Validar turno
	IF (COALESCE(@turno, '') = '' OR @turno NOT in('TM', 'TT' , 'Jornada Completa'))
		SET @error = @error + 'Turno inválido(Turnos disponibles: TM,TT,Jornada Completa). ';

	--Validar FK de sucursal 
	IF (@FKSucursal IS NULL OR @FKSucursal = 0)
        SET @error = 'ID de sucursal vacio o nulo. ';
	ELSE IF NOT EXISTS (SELECT IDSucursal FROM dbSucursal.Sucursal WHERE IDSucursal = @FKSucursal)
		SET @error = @error + 'El ID de sucursal ingresado no existe. ';
	
    -- Insertar datos si NO hay errores
    IF (@error = '')
    BEGIN
        INSERT INTO dbSucursal.Empleado(Legajo,dni,nombre,apellido,emailEmpresa,emailPersonal,direccion,cargo,turno,FKSucursal,estado)
        VALUES (@Legajo,@dni,@nombre,@apellido,@emailEmpresa,@emailPersonal,@direccion,@cargo,@turno,@FKSucursal,1);
    END
    ELSE
    BEGIN
        RAISERROR (@error, 16, 1);
    END
END
----------------------------------------
go
CREATE OR ALTER PROCEDURE dbProducto.InsertarLineaDeProducto
	@nombreLineaDeProducto VARCHAR(max)
AS
BEGIN
	DECLARE @error varchar(max) = '';
	--Validar nombre de la linea de producto
	IF (COALESCE(@nombreLineaDeProducto, '') = '')
		SET @error = @error + 'Falta la linea de producto. ';
	ELSE IF (LEN(@nombreLineaDeProducto) > 30)
		SET @error = @error + 'Linea de producto demasiado larga. Tamaño máximo de 30 caracteres. ';
	ELSE IF EXISTS (SELECT nombre FROM dbProducto.LineaDeProducto WHERE nombre = @nombreLineaDeProducto)
		SET @error = @error + 'La linea de producto ingresada ya existe. ';

	IF (@error = '')
    BEGIN
        INSERT INTO dbProducto.LineaDeProducto (nombre,estado)
        VALUES (@nombreLineaDeProducto,1);
    END
    ELSE
    BEGIN
        RAISERROR (@error, 16, 1);
    END
END
----------------------------------------
go
CREATE OR ALTER PROCEDURE dbProducto.InsertarCategoria
	@nombreCategoria VARCHAR(max),
	@FKLineaDeProducto INT
AS
BEGIN
	DECLARE @error varchar(max) = '';
	--Validar categoria
	IF (COALESCE(@nombreCategoria,'')='')
		SET @error = @error + 'Falta categoria. ';
	ELSE IF (LEN(@nombreCategoria) > 50)
		SET @error = @error + 'Categoria demasiado larga. Tamaño máximo de 50 caracteres. ';
	ELSE IF EXISTS (SELECT nombre FROM dbProducto.Categoria WHERE nombre = @nombreCategoria)
		SET @error = @error + 'La categoria ingresada ya existe. ';

	--Validar FK de linea de producto
	IF (@FKLineaDeProducto IS NULL OR @FKLineaDeProducto = 0)
		SET @error = @error + 'ID de linea de producto vacio o nulo. ';
	ELSE IF NOT EXISTS (SELECT IDLineaDeProducto FROM dbProducto.LineaDeProducto WHERE IDLineaDeProducto = @FKLineaDeProducto)
		SET @error = @error + 'ID de linea de producto ingresado no existe. ';

	IF (@error = '')
	BEGIN
		INSERT INTO dbProducto.Categoria(nombre,FKLineaDeProducto,estado)
		VALUES (@nombreCategoria,@FKLineaDeProducto,1);
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
----------------------------------------
go
CREATE OR ALTER PROCEDURE dbProducto.InsertarProducto
	@nombre VARCHAR(max),
	@precioUnitario DECIMAL(10,2),
	@precioReferencia DECIMAL(10,2),
	@unidadReferencia VARCHAR(max),
	@FKCategoria INT
AS
BEGIN
	DECLARE @error varchar(max) = '';

	--Validar nombre
	IF (COALESCE(@nombre, '') = '')
		SET @error = @error + 'Falta el nombre del producto. ';
	ELSE IF (LEN(@nombre) > 30)
		SET @error = @error + 'Nombre del producto demasiado larga. Tamaño máximo de 50 caracteres. ';
	ELSE IF EXISTS (SELECT nombre FROM dbProducto.Producto WHERE nombre = @nombre)
		SET @error = @error + 'El nombre del producto ingresado ya existe. ';

	--Validar precio unitario
	IF (@precioUnitario <= 0 OR @precioUnitario IS NULL )
		SET @error = @error + 'El precio unitario debe ser mayor a 0. ';

	--Validar precio de referencia
	IF (@precioReferencia <= 0)
		SET @error = @error + 'El precio de referencia debe ser mayor que 0. ';

	--Validar unidad de referencia
	IF (COALESCE(@unidadReferencia, '') = '')
		SET @error = @error + 'Falta la unidad de referencia. ';
	ELSE IF (LEN(@unidadReferencia) > 10)
		SET @error = @error + 'Unidad de referencia demasiado larga. Tamaño máximo de 10 caracteres. ';

	--Validar FK de categoria
	IF (@FKCategoria IS NULL OR @FKCategoria = 0)
        SET @error = @error + 'ID de categoria vacio o nulo. ';
	ELSE IF NOT EXISTS (SELECT IDCategoria FROM dbProducto.Categoria WHERE IDCategoria = @FKCategoria)
		SET @error = @error + 'ID de categoria ingresado no existe. ';

	IF (@error = '')
    BEGIN
        INSERT INTO dbProducto.Producto (nombre, precioUnitario, precioReferencia, unidadReferencia, fechaCreacion, FKCategoria,estado)
		VALUES (@nombre, @precioUnitario, @precioReferencia, @unidadReferencia, getdate(), @FKCategoria,1);
    END
    ELSE
    BEGIN
        RAISERROR (@error, 16, 1);
    END
END
----------------------------------------
/*
	logica de facturación:
		Ok, luego de cranearlo...
		1-creo la factura, solo con ID (la pk, no el numero). El resto lo dejo vacio
		2-inserto detalles
		3-cierro la factura, levantando el flag de "ultimoDetalle"
		4-ahora si, estoy habilitado para insertar el resto de datos de la factura(el numero). fecha y hora se generan con getdate. monto lo calculo con los subtotales
*/
----------------------------------------
GO
CREATE OR ALTER PROCEDURE dbFactura.CrearFactura
	@IDFacturaGenerada INT OUTPUT
AS
BEGIN
	INSERT dbFactura.Factura(fechaHoraEmision)	--Hago este INSERT nada mas para que se genere el IDFactura, y asi pueda insertar detalles
	VALUES(NULL);

	SET @IDFacturaGenerada = SCOPE_IDENTITY();	--Capturo el ID generado por el IDENTITY
END
----------------------------------------
GO
CREATE OR ALTER PROCEDURE dbFactura.InsertarDetalleDeFactura
	@cantidad INT,
	@FKProducto INT,
	@FKFactura INT
AS
BEGIN
	DECLARE @error varchar(max) = '';

	--Validar cantidad									
	IF (@cantidad <= 0 OR @cantidad IS NULL )
		SET @error = @error + 'La cantidad debe ser mayor a 0. ';

	--Validar producto							
	IF (@FKProducto IS NULL OR @FKProducto = 0)
        SET @error = @error + 'Producto vacío o nulo. ';
    IF NOT EXISTS (SELECT IDProducto FROM dbProducto.Producto WHERE IDProducto = @FKProducto)
        SET @error = @error + 'El ID de producto ingresado no esta registrado. ';

	--Validar que haya creado (no emitido) la factura				
	IF (@FKFactura IS NULL OR @FKFactura = 0)
        SET @error = @error + 'Factura vacía o nulo. ';
    ELSE IF NOT EXISTS (SELECT IDFactura FROM dbFactura.Factura WHERE IDFactura = @FKFactura)
        SET @error = @error + 'La factura todavia no existe. ';
	ELSE IF EXISTS(SELECT 1 FROM dbFactura.Factura WHERE IDFactura = @FKFactura AND fechaHoraEmision IS NOT NULL)
		SET  @error= @error + 'La factura ya fue emitida, no se pueden insertar más detalles. '

	IF(@error='')
	BEGIN
		INSERT dbFactura.DetalleDeFactura(cantidad,subtotal,precioUnitarioAlMomento,FKProducto,FKFactura)
		SELECT @cantidad,@cantidad*p.precioUnitario,p.precioUnitario,@FKProducto,@FKFactura
		FROM dbProducto.Producto p
		WHERE p.IDProducto = @FKProducto;
	END
	ELSE
		RAISERROR (@error, 16, 1);
END
------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbFactura.EmitirFactura
	@IDFactura INT,
	@numeroFactura INT,
	@tipoFactura CHAR(1)
AS
BEGIN
	DECLARE @error varchar(max) = '';

	--Validar factura.												
	IF (@numeroFactura=0 OR @numeroFactura IS NULL)
		SET @error = @error + 'Falta el numero de factura. ';
	ELSE IF(@numeroFactura < 100000000 OR @numeroFactura > 999999999)
		SET @error = @error + 'Numero de factura inválido, deben ser 9 digitos exactos del 0-9. ';
	ELSE IF EXISTS(SELECT numeroFactura FROM dbFactura.Factura WHERE numeroFactura=@numeroFactura )
		SET @error = @error + 'Numero de factura ya existente. ';

	--Validar tipo de factura												
	IF (@tipoFactura IS NULL OR @tipoFactura not in('A', 'B', 'C'))
		SET @error = @error + 'Tipo de factura inválido(Tipos disponibles: A, B, C). ';

	--Validar que la factura exista y no este emitida
	IF (@IDFactura IS NULL OR @IDFactura = 0)
        SET @error = @error + 'ID de factura vacio o nulo. ';
	ELSE IF NOT EXISTS (SELECT IDFactura FROM dbFactura.Factura WHERE IDFactura = @IDFactura)
		SET @error = @error + 'El ID de factura ingresado no existe. ';
	ELSE IF EXISTS(SELECT 1 FROM dbFactura.Factura WHERE IDFactura = @IDFactura AND fechaHoraEmision IS NOT NULL)
		SET @error = @error + 'La factura ya fué emitida anteriormente. ';

	--Validar que tenga al menos un detalle
	IF NOT EXISTS (SELECT 1 FROM dbFactura.DetalleDeFactura WHERE FKFactura = @IDFactura)
		SET @error = @error + 'La factura no tiene ningún detalle asociado. ';

	IF @error=''
	BEGIN
		UPDATE dbFactura.Factura 
		SET 
		numeroFactura=@numeroFactura,
		estadoFactura='E',				--pongo estado en Emitida
		tipoFactura=@tipoFactura,
		fechaHoraEmision=GETDATE(),
		total=(
			SELECT SUM(subtotal)
			FROM dbFactura.DetalleDeFactura
			WHERE FKFactura = dbFactura.Factura.IDFactura
		)
		WHERE IDFactura=@IDFactura
	END
	ELSE
		RAISERROR (@error, 16, 1);
END
------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbVenta.InsertarVenta
	@tipoCliente CHAR(6),	
	@genero CHAR(6),
	@identificadorDePago VARCHAR(max),
	@FKempleado INT,
	@FKMetodoDePago INT,	
	@FKSucursal INT,
	@FKFactura INT
AS
BEGIN
	DECLARE @error varchar(max) = '';

	--Validar tipo de cliente
	IF (COALESCE(@tipoCliente, '') = '')
		SET @error = @error + 'Falta el tipo de cliente. ';
	ELSE IF(@tipoCliente not in ('Member', 'Normal'))
		SET @error = @error + 'Tipo de cliente inválido(Tipos disponibles: Member, Normal). ';

	--Validar genero
	IF(@genero is not null)	-- si es NULL entonces no especifica, caso contrario entonces valido F o M
	BEGIN
		IF (@genero not in ('Female','Male'))
			SET @error = @error + 'Genero inválido(Female o Male). ';
	END

	--Validar identificador de pago
	IF (@identificadorDePago IS NOT NULL)	-- si es NULL es el caso de pago en efectivo, si no lo es entonces valido
	BEGIN
		IF (LEN(@identificadorDePago) = 22 AND @identificadorDePago LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
			SET @error = @error + 'El identificador de pago de 22 caracteres debe contener solo números(0-9). ';
		ELSE IF (LEN(@identificadorDePago) = 19 AND @identificadorDePago NOT LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
			SET @error = @error + 'El identificador de pago de 19 caracteres debe tener el siguiente formato: ''XXXX-XXXX-XXXX-XXXX'', siendo X un número del 0-9. ';
		ELSE IF (LEN(@identificadorDePago) <> 22 AND LEN(@identificadorDePago) <> 19)
			SET @error = @error + 'El identificador de pago debe tener 19 o 22 caracteres. ';
	END

	--Validar legajo
	IF (@FKempleado IS NULL OR @FKempleado = 0)
        SET @error = @error + 'Legajo vacío o nulo. ';
    IF NOT EXISTS (SELECT Legajo FROM dbSucursal.Empleado WHERE legajo = @FKempleado)
        SET @error = @error + 'El legajo ingresado no esta registrado. ';

	--Validar FK de sucursal 
	IF (@FKSucursal IS NULL OR @FKSucursal = 0)
        SET @error = @error + 'ID de sucursal vacio o nulo. ';
	ELSE IF NOT EXISTS (SELECT IDSucursal FROM dbSucursal.Sucursal WHERE IDSucursal = @FKSucursal)
		SET @error = @error + 'El ID de sucursal ingresado no existe. ';

	--Validar FK de metodo de pago 
	IF (@FKMetodoDePago IS NULL OR @FKMetodoDePago = 0)
        SET @error = @error + 'ID de metodo de pago vacio o nulo. ';
	ELSE IF NOT EXISTS (SELECT IDMetodoDePago FROM dbVenta.MetodoDePago WHERE IDMetodoDePago = @FKMetodoDePago)
		SET @error = @error + 'El ID de metodo de pago ingresado no existe. ';
	
	--Validar FK de factura 
	IF (@FKFactura IS NULL OR @FKFactura = 0)
        SET @error = @error + 'ID de factura vacio o nulo. ';
	ELSE IF NOT EXISTS (SELECT IDFactura FROM dbFactura.Factura WHERE IDFactura = @FKFactura)
		SET @error = @error + 'El ID de factura ingresado no existe. ';

	-- Validar que la factura ya haya sido emitida
	IF EXISTS (SELECT 1 FROM dbFactura.Factura WHERE IDFactura = @FKFactura AND estadoFactura IS NULL)
	BEGIN
		SET @error = @error + 'La factura aún no ha sido emitida, no se puede asociar una venta. ';
	END

	-- Solo si no hay error de emisión, verificar la venta asociada
	IF @error = ''
	BEGIN
		-- Validar que la factura no tenga una venta asociada
		IF EXISTS (SELECT 1 FROM dbVenta.Venta WHERE FKFactura = @FKFactura)
			SET @error = @error + 'La factura ya tiene una venta asociada. ';
	END

	IF (@error = '')
    BEGIN
        INSERT INTO dbVenta.Venta(tipoCliente, genero, fechaHoraVenta,identificadorDePago, FKempleado, FKMetodoDePago, FKSucursal, FKFactura)
		VALUES (@tipoCliente, @genero, GETDATE(), @identificadorDePago,@FKempleado, @FKMetodoDePago,@FKSucursal,@FKFactura)
	END
    ELSE
    BEGIN
        RAISERROR (@error, 16, 1);
    END
END
/*///////////////////////////////////////////////////////////////////////////////////////// */
/*///////////////////////////////////////////////////////////////////////////////////////// */
/*///////////////////////////////////////////////////////////////////////////////////////// */
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
