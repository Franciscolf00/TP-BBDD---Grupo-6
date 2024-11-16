USE Com2900G06
/*-------------------------------- ENCRIPTACIÓN DE DATOS --------------------------------*/

-- Agregamos los 3 campos correspondientes a los datos cifrados a la tabla, validando la existencia
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE Name = N'dniCifrado' 
               AND Object_ID = Object_ID(N'dbSucursal.Empleado'))
BEGIN
    ALTER TABLE dbSucursal.Empleado   
    ADD dniCifrado VARBINARY(256);
END;

IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE Name = N'emailPersonalCifrado' 
               AND Object_ID = Object_ID(N'dbSucursal.Empleado'))
BEGIN
    ALTER TABLE dbSucursal.Empleado   
    ADD emailPersonalCifrado VARBINARY(256);
END;

IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE Name = N'direccionCifrada' 
               AND Object_ID = Object_ID(N'dbSucursal.Empleado'))
BEGIN
    ALTER TABLE dbSucursal.Empleado   
    ADD direccionCifrada VARBINARY(256);
END;

ALTER TABLE dbSucursal.Empleado
ALTER COLUMN direccion VARBINARY(MAX);

-- Obtenemos la clave de cifrado. Lo cargaríamos desde otra capa.
DECLARE @FraseClaveCargadaPorUsuario NVARCHAR(256);  
SET @FraseClaveCargadaPorUsuario = 'Grupo06'; 

-- Ciframos los campos dni, emailPersonal y dirección de todos los registros  
-- Agregamos un hash (Legajo del empleado)
UPDATE dbSucursal.Empleado
SET dniCifrado = EncryptByPassPhrase(@FraseClaveCargadaPorUsuario, CONVERT(VARCHAR, dni), 1, CONVERT(varbinary, Legajo)),
	emailPersonalCifrado = EncryptByPassPhrase(@FraseClaveCargadaPorUsuario, emailPersonal, 1, CONVERT(varbinary, Legajo)),
	direccionCifrada = EncryptByPassPhrase(@FraseClaveCargadaPorUsuario, direccion, 1, CONVERT(varbinary, Legajo))
GO

-- PRUEBA: Desciframos los datos y los mostramos en una tabla

DECLARE @FraseClaveCargadaPorUsuario NVARCHAR(256);  
SET @FraseClaveCargadaPorUsuario = 'Grupo06';

WITH CTE AS (
    SELECT 
        Legajo,
        CONVERT(VARCHAR(512), DecryptByPassPhrase(@FraseClaveCargadaPorUsuario, dniCifrado, 1, CONVERT(VARBINARY, Legajo))) AS dniDescifrado,
        CONVERT(VARCHAR(512), DecryptByPassPhrase(@FraseClaveCargadaPorUsuario, emailPersonalCifrado, 1, CONVERT(VARBINARY, Legajo))) AS emailPersonalDescifrado,
        CONVERT(VARCHAR(512), DecryptByPassPhrase(@FraseClaveCargadaPorUsuario, direccionCifrada, 1, CONVERT(VARBINARY, Legajo))) AS direccionDescifrada
    FROM 
        dbSucursal.Empleado
)
SELECT 
    e.Legajo, 
    e.dniCifrado,
    e.emailPersonalCifrado, 
    e.direccionCifrada, 
    c.dniDescifrado, 
    c.emailPersonalDescifrado, 
    c.direccionDescifrada
FROM 
    dbSucursal.Empleado e
JOIN 
    CTE c ON e.Legajo = c.Legajo;

