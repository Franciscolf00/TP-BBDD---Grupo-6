USE Com2900G06
GO

-- Creamos el login y user de cajero
CREATE LOGIN Cajero
WITH PASSWORD = 'a1b2c3d4'.
DEFAULT_DATABASE=Com2900G06, -- Default Database en la que se está trabajando.
CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF; -- Asignamos credenciales sin vencimiento y sin restricciones de password.
GO

CREATE USER Cajero
FOR LOGIN Cajero;
GO

-- Creamos el login y user de supervisor
CREATE LOGIN Supervisor
WITH PASSWORD = '5z6x7y8w',
DEFAULT_DATABASE=Com2900G06, 
CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
GO
CREATE USER Supervisor
FOR LOGIN Supervisor;
GO

-- Creamos el login y user de GerenteDeSucursal
CREATE LOGIN GerenteDeSucursal
WITH PASSWORD = '19283746',
DEFAULT_DATABASE=Com2900G06, 
CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
GO
CREATE USER GerenteDeSucursal
FOR LOGIN GerenteDeSucursal;
GO

-- Creamos el rol de empleado, el cual le asignamos al cajero
CREATE ROLE Empleado
AUTHORIZATION Cajero;
GO

-- Creamos el rol de Administrador, el cual le asignamos al Supervisor y al Gerente de sucursal.
CREATE ROLE Administrador
AUTHORIZATION Supervisor;
GO

ALTER SERVER ROLE Administrador 
ADD MEMBER GerenteDeSucursal;
GO

--Le damos permisos de registrar ventas al Cajero
GRANT EXECUTE ON dbVenta.insertarVenta 
TO Cajero;
GO

REVOKE EXECUTE ON SCHEMA::dbVenta 
TO Cajero;
GO

--Le damos permisos de registrar Notas de crédito al supervisor y al Gerente
GRANT EXECUTE ON dbFactura.GenerarNotaDeCredito 
TO Administrador;
GO

-- Visualizar permisos asignados de manera explícita
SELECT
    perms.state_desc AS State,
    permission_name AS [Permission],
    obj.name AS [on Object],
    dp.name AS [to User Name]
FROM sys.database_permissions AS perms
JOIN sys.database_principals AS dp
    ON perms.grantee_principal_id = dp.principal_id
JOIN sys.objects AS obj
    ON perms.major_id = obj.object_id;

-- Visualizar roles de la DB y usuarios asignados
SELECT    roles.principal_id                            AS RolePrincipalID
    ,    roles.name                                    AS RolePrincipalName
    ,    database_role_members.member_principal_id    AS MemberPrincipalID
    ,    members.name                                AS MemberPrincipalName
FROM sys.database_role_members AS database_role_members  
JOIN sys.database_principals AS roles  
    ON database_role_members.role_principal_id = roles.principal_id  
JOIN sys.database_principals AS members  
    ON database_role_members.member_principal_id = members.principal_id;  
GO

/*-------------------------------- ENCRIPTACIÓN --------------------------------*/
-- Ejemplo práctico con nuestra frase
DECLARE @FraseClaveCargadaPorUsuario NVARCHAR(128);  
SET @FraseClaveCargadaPorUsuario = 'HolaSeñorThomson'; 

DECLARE @DatoCifrado VARBINARY(256);
SET @DatoCifrado = EncryptByPassPhrase(@FraseClaveCargadaPorUsuario  
, '1234', 1, CONVERT(varbinary, 1234))  

SELECT @DatoCifrado AS TextoCifrado;
