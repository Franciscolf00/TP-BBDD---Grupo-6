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

	--Validar Dirección
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
		SET @error = @error + 'Unidad de referencia demasiado larga. Tamaño m�ximo de 10 caracteres. ';

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
		1-creo la factura, solo con ID (la pk, no el numero). El resto lo dejo vacio.
		2-casi simultaneamente, creo la venta con sus datos(FKCliente lo dejo por ahora como uno genérico).
		3-inserto detalles a la venta
		3-ahora si, estoy habilitado para insertar el resto de datos de la factura(el numero). fecha y hora se generan con GETDATE. 
		monto lo calculo con los subtotales
		4-opcional:paso ahora si FKCliente(si existe en la bd) o pido los datos para insertarlo, dependiendo de que tipo de factura sea
*/
----------------------------------------
GO
CREATE OR ALTER PROCEDURE dbVenta.InsertarVenta
	@FKempleado INT,
	@FKMetodoDePago INT,	
	@FKSucursal INT,
	--@FKCliente INT,
	@IDVentaGenerada INT OUTPUT
AS
BEGIN

	DECLARE @IDFacturaGenerada INT
	DECLARE @error varchar(max) = '';
	
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
	
	----Validar FK de Cliente
	--IF (@FKCliente IS NULL OR @FKCliente = 0)
 --       SET @error = @error + 'ID de cliente vacio o nulo. ';
	--ELSE IF NOT EXISTS (SELECT 1 FROM dbCliente.Cliente WHERE IDCliente = @FKCliente)
	--	SET @error = @error + 'El ID de cliente ingresado no existe. ';

	--INSERTAR
	IF (@error = '')
    BEGIN

		INSERT dbFactura.Factura(fechaHoraEmision)	--Hago este INSERT nada mas para que se genere el IDFactura, y asi pueda insertar la venta
		VALUES(NULL);

		SET @IDFacturaGenerada = SCOPE_IDENTITY();	--Capturo el ID generado por el IDENTITY

		--Inserto la venta, con todos los datos y sus FK validadas + FK Factura que acabo de generar. Ahora puedo insertarle detalles a esa venta 
        INSERT INTO dbVenta.Venta(fechaHoraVenta, FKempleado, FKMetodoDePago, FKSucursal, FKFactura, FKCliente)
		VALUES (GETDATE(),@FKempleado, @FKMetodoDePago,@FKSucursal,@IDFacturaGenerada, 1)	--

		SET @IDVentaGenerada = SCOPE_IDENTITY();	--Capturo el ID generado por el IDENTITY
	END
    ELSE
    BEGIN
        RAISERROR (@error, 16, 1);
    END
END
------------------------------------------------------------------------------------
GO
--INSERTAR CLIENTE
CREATE OR ALTER PROCEDURE dbCliente.InsertarCliente
	@IDCliente INT=NULL OUTPUT,		--
	@cui CHAR(11),
	@nombre VARCHAR(30),
	@apellido VARCHAR(30),
	@direccion VARCHAR(70),
	@email VARCHAR(70)=NULL,
	@fechaNac DATE,
	@tipoCliente CHAR(6),
	@genero CHAR(1)
AS
BEGIN
	DECLARE @error varchar(max) = '';
	--Validar que el cuil/cuit no sea null
	IF @cui IS NULL
		SET @error = @error + 'CUIL/CUIT vacio o null. '
	--Validar que no exista el mismo cuil
	IF EXISTS (SELECT 1 FROM dbCliente.Cliente WHERE cui = @cui)
		SET @error = @error + 'CUIL/CUIT existente. '
	--Validar que el cuil/cuit sea correcto
	IF (@cui LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]')
		SET @error = @error + 'El CUIL/CUIT ingresado es inválido. '
	IF @nombre IS NULL
		SET @error = @error + 'Nombre vacio o null. '
	--Validar que apellido no sea null
	IF @apellido IS NULL
		SET @error = @error + 'Apellido vacio o null. '
	--Validar que direccion no sea null
	IF @direccion IS NULL
		SET @error = @error + 'Direccion vacio o null. '
	--Validar que fechaNac no sea null
	IF @fechaNac IS NULL
		SET @error = @error + 'Fecha de nacimiento vacio o null. '
	--Validar que tipo de cliente no sea null
	IF @tipoCLiente IS NULL
		SET @error = @error + 'El tipo de cliente es vacio o null. '
	--Chequear que tipo de cliente sea Member o Normal
	IF @tipoCliente NOT IN('Member', 'Normal')
		SET @error = @error + 'El tipo de cliente debe ser "Member" o "Normal". '
	--Validar que genero no se null
	IF @genero IS NULL
		SET @error = @error + 'Genero vacio o null. '
	--Validar que genero sea M o F
	IF @genero NOT IN ('M', 'F')
		SET @error = @error + 'El tipo de genero debe ser "M" o "F". '

	IF (@error = '')
    BEGIN
        INSERT INTO dbCliente.Cliente(cui, nombre, apellido, direccion, email, fechaNac, tipoCliente, genero)
		VALUES (@cui, @nombre, @apellido, @direccion, @email,@fechaNac, @tipoCliente, @genero)
		SET @IDCliente = SCOPE_IDENTITY();	--
	END
    ELSE
    BEGIN
        RAISERROR (@error, 16, 1);
    END
END
--GO
--EXEC dbCliente.InsertarCliente 20421164348, 'Julian', 'Serna', 'Madero 285', 'julianserna@gmail.com', '1995-03-07', 'Member', 'M'

----------------------------------------
GO
CREATE OR ALTER PROCEDURE dbVenta.InsertarDetalleDeVenta
	@cantidad INT,
	@FKProducto INT,
	@FKVenta INT
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

	--Validar que haya creado la venta y que no haya emitido la factura			
	IF (@FKVenta IS NULL OR @FKVenta = 0)
        SET @error = @error + 'ID venta vacía o nula. ';
    ELSE IF NOT EXISTS (SELECT IDVenta FROM dbVenta.Venta WHERE IDVenta = @FKVenta)
        SET @error = @error + 'La venta no existe. ';
	ELSE IF EXISTS(
		SELECT 1 FROM dbVenta.Venta v
		JOIN dbFactura.Factura f ON f.IDFactura = v.FKFactura
		WHERE v.IDVenta = @FKVenta AND f.fechaHoraEmision IS NOT NULL
	)
		SET  @error= @error + 'Ya se emitió una factura para esa venta, no se pueden insertar más detalles. '

	IF(@error='')
	BEGIN
		INSERT dbVenta.DetalleDeVenta(cantidad,subtotal,precioUnitarioAlMomento,FKProducto, FKVenta)
		SELECT @cantidad,@cantidad*p.precioUnitario,p.precioUnitario,@FKProducto,@FKVenta
		FROM dbProducto.Producto p
		WHERE p.IDProducto = @FKProducto;
	END
	ELSE
		RAISERROR (@error, 16, 1);
END
------------------------------------------
GO
CREATE OR ALTER PROCEDURE dbFactura.EmitirFactura
	@IDVenta INT,
	@identificadorDePago VARCHAR(max),
	@numeroFactura INT,
	@tipoFactura CHAR(1),
	@puntoDeVenta INT,
	@FKCliente INT = NULL,
	@cui CHAR(11) = NULL,	--
	@nombre VARCHAR(30) = NULL,
	@apellido VARCHAR(30) = NULL,
	@direccion VARCHAR(70) = NULL,
	@email VARCHAR(70) = NULL,
	@fechaNac DATE = NULL,
	@tipoCliente CHAR(6) = NULL,
	@genero CHAR(1) = NULL

AS
BEGIN
	DECLARE @error varchar(max) = '';
	DECLARE @IVA DECIMAL(5,2);
	SELECT @IVA=PorcentajeIVA FROM dbSistema.Parametrizacion;
	DECLARE @CUIT CHAR(13);
	SELECT @CUIT=CUITAurora FROM dbSistema.Parametrizacion;

	DECLARE @minimo DECIMAL(10,2);
	SELECT @minimo=montoMinimoDatos FROM dbSistema.Parametrizacion;
	DECLARE @totalConIVA DECIMAL(10,2);

	--Validar factura.												
	IF (@numeroFactura=0 OR @numeroFactura IS NULL)
		SET @error = @error + 'Falta el numero de factura. ';
	ELSE IF(@numeroFactura < 100000000 OR @numeroFactura > 999999999)
		SET @error = @error + 'Numero de factura inválido, deben ser 9 digitos exactos del 0-9. ';
	ELSE IF EXISTS(SELECT numeroFactura FROM dbFactura.Factura WHERE numeroFactura=@numeroFactura )
		SET @error = @error + 'Numero de factura ya existente. ';

	--Validar identificador de pago
	IF (@identificadorDePago IS NOT NULL)	-- si es NULL es el caso de pago en efectivo, si no lo es entonces valido
	BEGIN
		IF (LEN(@identificadorDePago) = 22 AND @identificadorDePago LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
			SET @error = @error + 'El identificador de pago de 22 caracteres debe contener solo n�meros(0-9). ';
		ELSE IF (LEN(@identificadorDePago) = 19 AND @identificadorDePago NOT LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
			SET @error = @error + 'El identificador de pago de 19 caracteres debe tener el siguiente formato: ''XXXX-XXXX-XXXX-XXXX'', siendo X un n�mero del 0-9. ';
		ELSE IF (LEN(@identificadorDePago) <> 22 AND LEN(@identificadorDePago) <> 19)
			SET @error = @error + 'El identificador de pago debe tener 19 o 22 caracteres. ';
	END

	--Validar punto de venta.												
	IF (@puntoDeVenta=0 OR @puntoDeVenta IS NULL)
		SET @error = @error + 'Falta el punto de venta. ';
	ELSE IF(@puntoDeVenta < 1 OR @puntoDeVenta > 99999)
		SET @error = @error + 'Punto de venta inválido, debe encontrarse entre 1-99999. ';

	--Validar tipo de factura												
	IF (@tipoFactura IS NULL OR @tipoFactura not in('A', 'B', 'C'))
		SET @error = @error + 'Tipo de factura inválido(Tipos disponibles: A, B, C). ';

	--Validar que la venta exista y su factura no este emitida
	IF (@IDVenta IS NULL OR @IDVenta = 0)
        SET @error = @error + 'ID de venta vacio o nulo. ';
	ELSE IF NOT EXISTS (SELECT @IDVenta FROM dbVenta.Venta WHERE IDVenta = @IDVenta)
		SET @error = @error + 'El ID de venta ingresado no existe. ';
	ELSE IF EXISTS(
			SELECT 1 FROM dbFactura.Factura f
			JOIN dbVenta.Venta v ON v.FKFactura = f.IDFactura
			WHERE v.IDVenta = @IDVenta AND fechaHoraEmision IS NOT NULL
		)
		SET @error = @error + 'La factura ya fué emitida anteriormente. ';

	--Validar que tenga al menos un detalle
	IF NOT EXISTS (
		SELECT 1 FROM dbVenta.DetalleDeVenta d
		WHERE FKVenta = @IDVenta
	)
		SET @error = @error + 'La venta no tiene ningún detalle asociado. ';

	IF @error=''
	BEGIN
		SELECT @totalConIVA=SUM(subtotal)
		FROM dbVenta.DetalleDeVenta d
		WHERE d.FKVenta = @IDVenta
		IF(@tipoFactura='A' OR @totalConIVA>=@minimo)	--solo pido datos/los busco si es factura A o si me paso del total minimo establecido
		BEGIN
			IF @FKCliente IS NOT NULL
			BEGIN
				--Validar FK de Cliente
				IF NOT EXISTS (SELECT 1 FROM dbCliente.Cliente WHERE IDCliente = @FKCliente)
					SET @error = @error + 'El ID de cliente ingresado no existe. ';
			END
			ELSE	
			BEGIN
				EXEC dbCliente.InsertarCliente	--Este SP a su vez tira sus propios errores de validación,
					@FKCliente OUTPUT,			--lo importante es que si hubo algun error @FKCliente quedó en NULL
					@cui,
					@nombre,
					@apellido,
					@direccion,
					@email,
					@fechaNac,
					@tipoCliente,
					@genero
			END
			IF @FKCliente IS NOT NULL	--La ingresó a mano o se generó por el identity. En ambos casos NO  es NULO,
			BEGIN
				UPDATE dbVenta.Venta	--en ambos casos actualizo la FKcliente 
				SET FKCliente=@FKCliente
			END
			ELSE						--Si es NULL entonces tiro error y no puedo emitir la factura sin datos
				SET @error = @error + 'No es posible emitir la factura sin los datos del cliente. ';
		END
	END
	IF @error=''
	BEGIN
		UPDATE dbVenta.Venta
		SET
		identificadorDePago=@identificadorDePago
		WHERE IDVenta=@IDVenta;

		WITH total(total) AS(
			SELECT SUM(subtotal) as total
			FROM dbVenta.DetalleDeVenta d
			WHERE d.FKVenta = @IDVenta
			--WHERE d.FKVenta = 1
		)
		UPDATE dbFactura.Factura 
		SET 
		numeroFactura=@numeroFactura,
		estadoFactura='E',				--pongo estado en Emitida
		tipoFactura=@tipoFactura,
		fechaHoraEmision=GETDATE(),
		puntoDeVenta=@puntoDeVenta,
		total=(
			SELECT total FROM total
		),	
		totalConIva=(SELECT total+total*@IVA FROM total),
		CUITAur=@CUIT
		WHERE IDFactura=(SELECT FKFactura FROM dbVenta.Venta WHERE IDVenta=@IDVenta)
	END
	ELSE
		RAISERROR (@error, 16, 1);
END
------------------------------------------
GO


