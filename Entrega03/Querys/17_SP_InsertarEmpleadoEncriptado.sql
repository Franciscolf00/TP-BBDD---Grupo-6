USE Com2900G06;
GO

ALTER PROCEDURE dbVenta.InsertarEmpleado
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
	DECLARE @FraseClaveCargadaPorUsuario NVARCHAR(256)
	SET @FraseClaveCargadaPorUsuario = 'Grupo06'; 
    DECLARE @error varchar(max) = '';
	DECLARE @nombreCifrado VARBINARY(MAX);
	DECLARE @apellidoCifrado VARBINARY(MAX);
	DECLARE @direccionCifrada VARBINARY(MAX);
	DECLARE @emailPersonalCifrado VARBINARY(MAX);

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
		
		SET @nombreCifrado = EncryptByPassPhrase(@FraseClaveCargadaPorUsuario, @nombre, 1, CONVERT(VARBINARY, @Legajo));
		SET @apellidoCifrado = EncryptByPassPhrase(@FraseClaveCargadaPorUsuario, @apellido, 1, CONVERT(VARBINARY, @Legajo));
		SET @direccionCifrada = EncryptByPassPhrase(@FraseClaveCargadaPorUsuario, @direccion, 1, CONVERT(VARBINARY, @Legajo));
		SET @emailPersonalCifrado = EncryptByPassPhrase(@FraseClaveCargadaPorUsuario, @emailPersonal, 1, CONVERT(VARBINARY, @Legajo));
        INSERT INTO dbSucursal.Empleado(Legajo,dni,nombre,apellido,emailEmpresa,emailPersonal,direccion,cargo,turno,FKSucursal,estado)
        VALUES (@Legajo,@dni,@nombreCifrado,@apellidoCifrado,@emailEmpresa,@emailPersonalCifrado,@direccionCifrada,@cargo,@turno,@FKSucursal,1);
    END
    ELSE
    BEGIN
        RAISERROR (@error, 16, 1);
    END
END
GO

EXEC dbVenta.InsertarEmpleado
    @Legajo = 542321,
    @dni = 87654637,
    @nombre = 'Lucia',
    @apellido = 'Perez',
    @emailEmpresa = 'lucia.perez@superA.com',
    @emailPersonal = 'lucia.perez@yahoo.com',
    @direccion = 'Avenida Principal 456',
    @cargo = 'Supervisor',
    @turno = 'Jornada Completa',
    @FKSucursal = 2; 
GO