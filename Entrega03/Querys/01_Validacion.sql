USE Com2900G06
--use master;
GO
CREATE OR ALTER PROCEDURE dbVenta.InsertarMetodoDePago
    @nombre VARCHAR(200)
AS
BEGIN
    DECLARE @error varchar(max) = '';

    -- Validar nombre 
    IF (COALESCE(@nombre, '') = '')
        SET @error = @error + 'Falta nombre. ';
	ELSE IF (LEN(@nombre)>200)
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
go
CREATE OR ALTER PROCEDURE dbVenta.InsertarEmpleado
	@Legajo INT,
	@dni INT,
	@nombre VARCHAR(40),
	@apellido VARCHAR(20),
	@emailEmpresa VARCHAR(50),
	@emailPersonal VARCHAR(50),
	@direccion VARCHAR(100),
	@cargo CHAR(22),
	@turno CHAR(16),
	@nombreSucursal varchar(20)
AS
BEGIN
    DECLARE @error varchar(max) = '';
	DECLARE @FKSucursal INT
	
    --Validar Legajo
    IF (@Legajo IS NULL OR @Legajo = 0)
        SET @error = 'Legajo vacío o nulo. ';
    IF EXISTS (SELECT @Legajo FROM dbSucursal.Empleado WHERE Legajo = @Legajo)
        SET @error = @error + 'El Legajo ingresado ya existe. '; 

	--Validar dni
	IF (@dni IS NULL OR @Legajo = 0)
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
	OR LEN(@emailEmpresa) >= 50)
        SET @error = @error + 'Mail(empresa) inválido. ';

	--Validar email Personal
    IF (COALESCE(@emailPersonal, '') = '' OR @emailPersonal NOT LIKE '%@%.com' 
	OR LEN(@emailPersonal) >= 50)
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


	-- Validar la sucursal(IMPORTANTE: paso el nombre y no la ID porque son 3 sucursales, veo mas normal esto ya que no es como el nombre de una persona
	-- que puede haber 100 'Jhon')
    IF (COALESCE(@nombreSucursal, '') = '')
	BEGIN
		SET @error = @error + 'Falta el nombre de la sucursal. ';
	END
	ELSE
	BEGIN
		SELECT @FKSucursal = IDSucursal
		FROM dbSucursal.Sucursal
		WHERE sucursal = @nombreSucursal;
    
		IF @FKSucursal IS NULL
		BEGIN
			SET @error = @error + 'La sucursal ingresada no existe. ';
		END
	END
	
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
	@nombreLineaDeProducto VARCHAR(30)
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
	@nombreCategoria VARCHAR(30),
	@nombreLineaDeProducto VARCHAR(30)
AS
BEGIN
	DECLARE @error varchar(max) = '';
	--Validar categoria
	IF (COALESCE(@nombreCategoria, '') = '')
		SET @error = @error + 'Falta categoria. ';
	ELSE IF (LEN(@nombreCategoria) > 30)
		SET @error = @error + 'Categoria demasiado larga. Tamaño máximo de 30 caracteres. ';
	ELSE IF EXISTS (SELECT nombre FROM dbProducto.LineaDeProducto WHERE nombre = @nombreCategoria)
		SET @error = @error + 'La categoria ingresada ya existe. ';

	--FALTA VALIDAR FK
	IF (@error = '')
    BEGIN
        INSERT INTO dbProducto.Categoria(nombre,FKLineaDeProducto,estado)
        VALUES (@nombreCategoria,,1);
    END
    ELSE
    BEGIN
        RAISERROR (@error, 16, 1);
    END
END
----------------------------------------
go
CREATE OR ALTER PROCEDURE dbProducto.InsertarProducto
	@nombre VARCHAR(50),
	@precioUnitario DECIMAL(10,2),
	@precioReferencia DECIMAL(10,2),
	@unidadReferencia VARCHAR(10),
	@fechaCreacion SMALLDATETIME,	--No se valida, hago getDate() al momento de insertar
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
	IF (@precioReferencia <= 0 OR @precioReferencia IS NULL)
		SET @error = @error + 'El precio de referencia debe ser mayor que 0. ';

	--Validar unidad de referencia
	IF (COALESCE(@unidadReferencia, '') = '')
		SET @error = @error + 'Falta la unidad de referencia. ';
	ELSE IF (LEN(@unidadReferencia) > 10)
		SET @error = @error + 'Unidad de referencia demasiado larga. Tamaño máximo de 10 caracteres. ';

	--FALTA VALIDAR FK
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
go
CREATE OR ALTER PROCEDURE dbVenta.InsertarVenta
	@Factura CHAR(12),
	@tipoFactura CHAR(1),
	@tipoCliente CHAR(6),	
	@genero CHAR(6),
	@cantidad INT,
	@identificadorDePago VARCHAR(30),
	@FKempleado INT,
	@FKMetodoDEPago INT,	--|| nombre metodo?
	@FKproducto INT,
	@FKSucursal INT		--|| nombre sucursal?
AS
BEGIN
	DECLARE @error varchar(max) = '';

	--Validar factura
	IF (COALESCE(@Factura, '') = '')
		SET @error = @error + 'Falta el numero de factura. ';
	ELSE IF(@Factura not like '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]')
		SET @error = @error + 'Numero de factura inválido, debe tener el formato XXX-XX-XXXX siendo X un numero del 0-9. ';

	--Validar tipo de factura
	IF (COALESCE(@Factura, '') = '' OR @Factura not in('A', 'B', 'C'))
		SET @error = @error + 'Tipo de factura inválido(Tipos disponibles: A, B, C). ';
	
	--Validar tipo de cliente
	IF (COALESCE(@tipoCliente, '') = '')
		SET @error = @error + 'Falta el tipo de cliente. ';
	ELSE IF(@tipoCliente not in ('Member', 'Normal'))
		SET @error = @error + 'Tipo de cliente inválido(Tipos disponibles: Member, Normal). ';

	--Validar genero
	IF(@genero is not null)	-- si es NULL entonces no especifica, caso contrario entonces valido F o M
	BEGIN
		IF (@genero not in ('F','M'))
			SET @error = @error + 'Genero inválido(F o M). ';
	END

	--Validar cantidad
	IF (@cantidad <= 0 OR @cantidad IS NULL )
		SET @error = @error + 'La cantidad debe ser mayor a 0. ';

	--Validar identificador de pago
	IF (@identificadorDePago IS NOT NULL)	-- si es NULL es el caso de pago en efectivo, si no lo es entonces valido
	BEGIN
		IF (LEN(@identificadorDePago) = 22 AND @identificadorDePago LIKE '%[^0-9]%')
			SET @error = @error + 'El identificador de pago de 22 caracteres debe contener solo números(0-9). ';
		ELSE IF (LEN(@identificadorDePago) = 19 AND @identificadorDePago NOT LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
			SET @error = @error + 'El identificador de pago de 19 caracteres debe tener el siguiente formato: ''XXXX-XXXX-XXXX-XXXX'',
			siendo X un número del 0-9. ';
		ELSE IF (LEN(@identificadorDePago) <> 22 AND LEN(@identificadorDePago) <> 19)
			SET @error = @error + 'El identificador de pago debe tener 19 o 22 caracteres. ';
	END

	--Validar legajo
	IF (@FKempleado IS NULL OR @FKempleado = 0)
        SET @error = 'Legajo vacío o nulo. ';
    IF NOT EXISTS (SELECT Legajo FROM dbSucursal.Empleado WHERE legajo = @FKempleado)
        SET @error = @error + 'El legajo ingresado no esta registrado. ';

	--Validar producto
	IF (@FKproducto IS NULL OR @FKproducto = 0)
        SET @error = 'Producto vacío o nulo. ';
    IF NOT EXISTS (SELECT IDProducto FROM dbProducto.Producto WHERE IDProducto = @FKproducto)
        SET @error = @error + 'El ID de producto ingresado no esta registrado. ';

	--FALTA VALIDAR @FKMetodoDEPago y @FKSucursal
	
	IF (@error = '')
    BEGIN
        INSERT INTO dbVenta.Venta(Factura, tipoCliente, tipoCliente, genero, cantidad, identificadorDePago, FKempleado, FKMetodoDEPago, FKproducto, FKSucursal)
		VALUES (@Factura, @tipoFactura, @tipoFactura, @genero, @cantidad, CAST(GETDATE() as DATE), CAST(GETDATE() as TIME), @identificadorDePago, 
		@FKempleado, @FKMetodoDEPago, @FKproducto, @FKSucursal);
    END
    ELSE
    BEGIN
        RAISERROR (@error, 16, 1);
    END
END
