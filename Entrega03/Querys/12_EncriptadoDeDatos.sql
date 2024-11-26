USE Com2900G06
go
/*-------------------------------- ENCRIPTACIÓN DE DATOS --------------------------------*/

-- Agregamos los 4 campos correspondientes a los datos cifrados a la tabla, validando la existencia
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE Name = N'nombreCifrado' 
               AND Object_ID = Object_ID(N'dbSucursal.Empleado'))
BEGIN
    ALTER TABLE dbSucursal.Empleado
    ADD nombreCifrado VARBINARY(MAX);
END;
GO

IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE Name = N'apellidoCifrado' 
               AND Object_ID = Object_ID(N'dbSucursal.Empleado'))
BEGIN
    ALTER TABLE dbSucursal.Empleado
    ADD apellidoCifrado VARBINARY(MAX);
END;
GO

IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE Name = N'emailPersonalCifrado' 
               AND Object_ID = Object_ID(N'dbSucursal.Empleado'))
BEGIN
    ALTER TABLE dbSucursal.Empleado
    ADD emailPersonalCifrado VARBINARY(MAX);
END;
GO

IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE Name = N'direccionCifrado' 
               AND Object_ID = Object_ID(N'dbSucursal.Empleado'))
BEGIN
    ALTER TABLE dbSucursal.Empleado
    ADD direccionCifrado VARBINARY(MAX);
END;
GO

-- Obtenemos la clave de cifrado. Lo cargaríamos desde otra capa.
DECLARE @FraseClaveCargadaPorUsuario NVARCHAR(256)
SET @FraseClaveCargadaPorUsuario = 'Grupo06'; 

-- Ciframos los campos dni, emailPersonal y dirección de todos los registros  
-- Agregamos un hash (Legajo del empleado)

UPDATE dbSucursal.Empleado
SET nombreCifrado = EncryptByPassPhrase(@FraseClaveCargadaPorUsuario, nombre, 1, CONVERT(VARBINARY, Legajo)),
    apellidoCifrado = EncryptByPassPhrase(@FraseClaveCargadaPorUsuario, apellido, 1, CONVERT(VARBINARY, Legajo)),
    emailPersonalCifrado = EncryptByPassPhrase(@FraseClaveCargadaPorUsuario, emailPersonal, 1, CONVERT(VARBINARY, Legajo)),
    direccionCifrado = EncryptByPassPhrase(@FraseClaveCargadaPorUsuario, direccion, 1, CONVERT(VARBINARY, Legajo));
GO

-- Eliminamos las columnas originales
ALTER TABLE dbSucursal.Empleado
DROP COLUMN nombre,
    apellido,
    emailPersonal,
    direccion;
GO

--Renombramos nuevas columnas
EXEC sp_rename 'dbSucursal.Empleado.nombreCifrado', 'nombre', 'COLUMN';
EXEC sp_rename 'dbSucursal.Empleado.apellidoCifrado', 'apellido', 'COLUMN';
EXEC sp_rename 'dbSucursal.Empleado.emailPersonalCifrado', 'emailPersonal', 'COLUMN';
EXEC sp_rename 'dbSucursal.Empleado.direccionCifrado', 'direccion', 'COLUMN';
GO

-- PRUEBA: Desciframos los datos y los mostramos en una tabla

DECLARE @FraseClaveCargadaPorUsuario NVARCHAR(256);
SET @FraseClaveCargadaPorUsuario = 'Grupo06';

WITH CTE AS (
    SELECT 
        Legajo,
        CONVERT(VARCHAR(512), DecryptByPassPhrase(@FraseClaveCargadaPorUsuario, nombre, 1, CONVERT(VARBINARY, Legajo))) AS nombreDescifrado,
        CONVERT(VARCHAR(512), DecryptByPassPhrase(@FraseClaveCargadaPorUsuario, apellido, 1, CONVERT(VARBINARY, Legajo))) AS apellidoDescifrado,
        CONVERT(VARCHAR(512), DecryptByPassPhrase(@FraseClaveCargadaPorUsuario, emailPersonal, 1, CONVERT(VARBINARY, Legajo))) AS emailPersonalDescifrado,
        CONVERT(VARCHAR(512), DecryptByPassPhrase(@FraseClaveCargadaPorUsuario, direccion, 1, CONVERT(VARBINARY, Legajo))) AS direccionDescifrada
    FROM 
        dbSucursal.Empleado
)
SELECT 
    e.Legajo, 
    e.nombre,
    e.apellido,
    e.emailPersonal, 
    e.direccion, 
    c.nombreDescifrado, 
    c.apellidoDescifrado, 
    c.emailPersonalDescifrado, 
    c.direccionDescifrada
FROM 
    dbSucursal.Empleado e
JOIN 
    CTE c ON e.Legajo = c.Legajo;
GO

-- Mostramos toda la tabla encriptada
SELECT legajo, dni, nombre, apellido, emailPersonal, direccion , emailEmpresa
FROM dbSucursal.Empleado;
go