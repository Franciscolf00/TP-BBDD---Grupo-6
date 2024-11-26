USE Com2900G06;
GO

-- Eliminamos roles si existen
--EXEC sp_droprolemember 'Empleado', 'Cajero';
--EXEC sp_droprolemember 'Administrador', 'Supervisor';
--EXEC sp_droprolemember 'Administrador', 'GerenteDeSucursal';

DROP ROLE IF EXISTS Empleado;
DROP ROLE IF EXISTS Administrador;

-- Eliminamos usuarios si existen
DROP USER IF EXISTS Cajero;
DROP USER IF EXISTS Supervisor;
DROP USER IF EXISTS Gerente;

-- Eliminamos logins si existen
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Empleado')
    DROP LOGIN Empleado;

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Supervisor')
    DROP LOGIN Supervisor;

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'GerenteDeSucursal')
    DROP LOGIN Gerente;



-- Creamos login para empleado y user para cajero
EXEC dbSeguridad.CrearLogin 'Empleado', '12345678';
EXEC dbSeguridad.CrearUser 'Cajero', 'Empleado'
GO

-- Creamos login para supervisor y user para supervisor
EXEC dbSeguridad.CrearLogin 'Supervisor', '12345678';
EXEC dbSeguridad.CrearUser 'Supervisor', 'Supervisor'
GO

-- Creamos login para gerente y user para gerente de sucursal
EXEC dbSeguridad.CrearLogin 'Gerente', '12345678';
EXEC dbSeguridad.CrearUser 'GerenteDeSucursal', 'Gerente'
GO

-- Creamos roles para empleado (agregando al cajero) y para administrador (agregando al supervisor y al gerente)
EXEC dbSeguridad.CrearRol 'Empleado'
GO
EXEC dbSeguridad.AsignarRolAUsuario 'Empleado', 'Cajero'
GO
EXEC dbSeguridad.CrearRol 'Administrador'
GO
EXEC dbSeguridad.AsignarRolAUsuario 'Administrador', 'Supervisor'
GO
EXEC dbSeguridad.AsignarRolAUsuario 'Administrador', 'GerenteDeSucursal'
GO

-- Asignamos permisos de ejecución a roles
EXEC dbSeguridad.AsignarPermisosEjecucionARol 'dbVenta.InsertarVenta', 'Empleado';
GO
EXEC dbSeguridad.AsignarPermisosEjecucionARol 'dbFactura.GenerarNotaDeCredito', 'Supervisor';
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


	-- Ver roles y sus miembros
SELECT r.name AS RoleName, m.name AS MemberName
FROM sys.database_principals r
LEFT JOIN sys.database_role_members rm ON r.principal_id = rm.role_principal_id
LEFT JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id;

-- Ver permisos asignados
SELECT perms.state_desc AS State,
       permission_name AS Permission,
       obj.name AS ObjectName,
       dp.name AS Grantee
FROM sys.database_permissions perms
JOIN sys.database_principals dp ON perms.grantee_principal_id = dp.principal_id
JOIN sys.objects obj ON perms.major_id = obj.object_id;

