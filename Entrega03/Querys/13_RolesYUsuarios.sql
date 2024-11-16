USE Com2900G06
GO
/*-------------------------------- LOGIN Y USUARIOS --------------------------------*/

-- Creamos el login y user de cajero
CREATE LOGIN Cajero
WITH PASSWORD = 'abc123',
DEFAULT_DATABASE=Com2900G06, -- Default Database en la que se está trabajando.
CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF; -- Asignamos credenciales sin vencimiento y sin restricciones de password.
GO

CREATE USER Cajero
FOR LOGIN Cajero;
GO

-- Creamos el login y user de supervisor
CREATE LOGIN Supervisor
WITH PASSWORD = '123abc',
DEFAULT_DATABASE=Com2900G06, 
CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
GO
CREATE USER Supervisor
FOR LOGIN Supervisor;
GO

-- Creamos el login y user de GerenteDeSucursal
CREATE LOGIN GerenteDeSucursal
WITH PASSWORD = 'abcd1234',
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

/*
REVOKE EXECUTE ON dbVenta.insertarVenta 
TO Cajero;
GO
*/

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
