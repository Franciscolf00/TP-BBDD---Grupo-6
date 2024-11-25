USE Com2900G06
GO
/*-------------------------------- LOGIN Y USUARIOS --------------------------------*/

-- Creamos el SP para crear logins.
-- Default Database en la que se está trabajando.
-- Asignamos credenciales sin vencimiento y sin restricciones de password.
CREATE OR ALTER PROCEDURE dbSeguridad.CrearLogin
	@login VARCHAR(MAX),
	@password VARCHAR(MAX)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'CREATE LOGIN ' + @login
		+ ' WITH PASSWORD = ''' + @password + ''',
		DEFAULT_DATABASE=Com2900G06,
		CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF'
	EXEC sp_executesql @sql;
END
GO

-- Creamos el SP para crear users.
CREATE OR ALTER PROCEDURE dbSeguridad.CrearUser
	@user VARCHAR(MAX),
	@login VARCHAR(MAX)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'CREATE USER ' + @user +
		' FOR LOGIN ' + @login
	EXEC sp_executesql @sql;
END
GO

-- Creamos el SP para crear roles.
CREATE OR ALTER PROCEDURE dbSeguridad.CrearRol
	@rol VARCHAR(MAX)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'CREATE ROLE ' + @rol
	EXEC sp_executesql @sql;
END
GO

CREATE OR ALTER PROCEDURE dbSeguridad.AsignarRolAUsuario
	@rol VARCHAR(MAX),
	@user VARCHAR(MAX)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'ALTER ROLE ' + @rol + ' 
		ADD MEMBER ' + @user
	EXEC sp_executesql @sql;
END
GO

CREATE OR ALTER PROCEDURE dbSeguridad.AsignarPermisosEjecucionARol
	@objeto VARCHAR(MAX),
	@rol VARCHAR(MAX)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'GRANT EXECUTE ON ' + @objeto + '
		TO ' + @rol
	EXEC sp_executesql @sql;
END
GO

CREATE OR ALTER PROCEDURE dbSeguridad.QuitarPermisosEjecucionARol
	@objeto VARCHAR(MAX),
	@rol VARCHAR(MAX)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'REVOKE EXECUTE ON ' + @objeto + '
		TO ' + @rol
	EXEC sp_executesql @sql;
END
GO

CREATE OR ALTER PROCEDURE dbSeguridad.AsignarPermisosSchemaARol
	@objeto VARCHAR(MAX),
	@rol VARCHAR(MAX)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'GRANT CONTROL ON ' + @objeto + '
		TO ' + @rol
	EXEC sp_executesql @sql;
END
GO

CREATE OR ALTER PROCEDURE dbSeguridad.QuitarPermisosSchemaARol
	@objeto VARCHAR(MAX),
	@rol VARCHAR(MAX)
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'REVOKE CONTROL ON ' + @objeto + '
		TO ' + @rol
	EXEC sp_executesql @sql;
END
GO