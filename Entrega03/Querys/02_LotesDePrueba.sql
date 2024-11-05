 USE Com2900G06
 --use master
 /*///////////////////////////////////////////////////////////////////////////////////////// */
 --Prueba INSERCIONES
 --METODO DE PAGO:	3 rows affected
 GO
-- Caso 1: Nombre v�lido
EXEC dbVenta.InsertarMetodoDePago @nombre = 'Cash'; --Deber�a insertarse correctamente.
GO
-- Caso 2: Nombre v�lido
EXEC dbVenta.InsertarMetodoDePago @nombre = 'Credit card'; --Deber�a insertarse correctamente.
GO
-- Caso 3: Nombre vac�o
EXEC dbVenta.InsertarMetodoDePago @nombre = ''; --'Falta nombre.'
GO
-- Caso 4: Nombre demasiado largo
EXEC dbVenta.InsertarMetodoDePago @nombre = 'Tarjeta de Cr�dito'; --'Nombre demasiado largo. Tama�o maximo de 11 caracteres.'
GO
-- Caso 5: Nombre que ya existe
EXEC dbVenta.InsertarMetodoDePago @nombre = 'Cash'; --'El nombre del metodo de pago ingresado ya existe.'
GO
-- Caso 6: Nombre demasiado largo
EXEC dbVenta.InsertarMetodoDePago @nombre = 'Transferencia'; --'Nombre demasiado largo. Tama�o maximo de 11 caracteres.'
GO
-- Caso 7: Nombre v�lido
EXEC dbVenta.InsertarMetodoDePago @nombre = 'Ewallet'; --Deber�a insertarse correctamente.
GO
----------------------------------------------------------------------------------------------
--SUCURSAL: 2 rows affected
-- Caso 1: Inserci�n v�lida
EXEC dbSucursal.InsertarSucursal 
    @direccion = 'Calle Falsa 123',
    @numTelefono = '123456789',
    @ciudad = 'Madrid',
    @sucursal = 'Sucursal Centro'; -- Deber�a insertarse correctamente.
GO
-- Caso 2: Inserci�n v�lida
EXEC dbSucursal.InsertarSucursal 
    @direccion = 'Avenida Siempre Viva 742',
    @numTelefono = '987654321',
    @ciudad = 'Barcelona',
    @sucursal = 'Sucursal Norte'; -- Deber�a insertarse correctamente.
GO
-- Caso 3: Inserci�n con varios errores
EXEC dbSucursal.InsertarSucursal 
    @direccion = '',				--Falta direccion
    @numTelefono = '12345',     
    @ciudad = 'MuyLargaCiudad',      -- Ciudad demasiado larga (m�s de 9 caracteres).
    @sucursal = 'Sucursal Centro';     --Repetida.
GO
----------------------------------------------------------------------------------------------
--EMPLEADO: 2 rows affected
EXEC dbVenta.InsertarEmpleado
	@Legajo = NULL,          -- Legajo vac�o o nulo
	@dni = NULL,             -- DNI vac�o o nulo
	@nombre = '',            -- Nombre vac�o
	@apellido = 'EsteApellidoEsDemasiadoLargoParaElCampo',  -- Apellido demasiado largo
	@emailEmpresa = 'empleado@otroDominio.com',             -- Email de empresa no v�lido
	@emailPersonal = 'personal@correo',                     -- Email personal sin ".com"
	@direccion = NULL,                                       -- Direcci�n vac�a
	@cargo = 'Mantenimiento',                                -- Cargo no v�lido
	@turno = 'Noche',                                        -- Turno no v�lido
	@FKSucursal = 99999;                                     -- ID de sucursal que no existe
GO
EXEC dbVenta.InsertarEmpleado
    @Legajo = 12345,
    @dni = 45678901,
    @nombre = 'Carlos',
    @apellido = 'Gomez',
    @emailEmpresa = 'carlos.gomez@superA.com',
    @emailPersonal = 'carlos.gomez@gmail.com',
    @direccion = 'Calle Falsa 123',
    @cargo = 'Cajero',
    @turno = 'TM',
    @FKSucursal = 1; 
GO
EXEC dbVenta.InsertarEmpleado
    @Legajo = 54321,
    @dni = 98765432,
    @nombre = 'Lucia',
    @apellido = 'Perez',
    @emailEmpresa = 'lucia.perez@superA.com',
    @emailPersonal = 'lucia.perez@yahoo.com',
    @direccion = 'Avenida Principal 456',
    @cargo = 'Supervisor',
    @turno = 'Jornada Completa',
    @FKSucursal = 2; 
GO
EXEC dbVenta.InsertarEmpleado 
    @Legajo = 12345,
    @dni = 66778899,
    @nombre = 'Pedro',
    @apellido = 'S�nchez',
    @emailEmpresa = 'pedro.sanchez@superA.com',
    @emailPersonal = 'pedro.sanchez@gmail.com',
    @direccion = 'Calle Real 654',
    @cargo = 'Gerente de sucursal',
    @turno = 'Jornada Completa',
    @FKSucursal = 999; -- ID de sucursal no existente. Deber�a generar un error: 'El ID de sucursal ingresado no existe.'
GO
----------------------------------------------------------------------------------------------
--LINEA DE PRODUCTO: 2 rows affected
EXEC dbProducto.InsertarLineaDeProducto
    @nombreLineaDeProducto = 'Lacteos';
GO
EXEC dbProducto.InsertarLineaDeProducto
    @nombreLineaDeProducto = 'Bebidas';
GO
EXEC dbProducto.InsertarLineaDeProducto
    @nombreLineaDeProducto = 'Bebidas';
GO
EXEC dbProducto.InsertarLineaDeProducto
    @nombreLineaDeProducto = '';  
GO
EXEC dbProducto.InsertarLineaDeProducto
    @nombreLineaDeProducto = 'EstaEsUnaLineaDeProductoQueSuperaElLimiteDe30Caracteres';
GO
----------------------------------------------------------------------------------------------
--CATEGORIA: 2 rows affected
EXEC dbProducto.InsertarCategoria
    @nombreCategoria = '',            -- Nombre de categor�a vac�o
    @FKLineaDeProducto = NULL;        -- ID de l�nea de producto nulo
GO
EXEC dbProducto.InsertarCategoria
    @nombreCategoria = 'EstaCategoriaTieneUnNombreExcesivamenteLargoQueSuperaLos50Caracteres',
    @FKLineaDeProducto = 9999;  -- ID de l�nea de producto que no existe
GO
EXEC dbProducto.InsertarCategoria
    @nombreCategoria = 'Quesos',
    @FKLineaDeProducto = 1; 
GO
EXEC dbProducto.InsertarCategoria
    @nombreCategoria = 'Jugos',
    @FKLineaDeProducto = 2; 
GO
EXEC dbProducto.InsertarCategoria
    @nombreCategoria = 'Jugos',
    @FKLineaDeProducto = 2;  
GO
----------------------------------------------------------------------------------------------
--PRODUCTO: 1 rows affected
EXEC dbProducto.InsertarProducto
    @nombre = '',                 -- Nombre vac�o
    @precioUnitario = 0,          -- Precio unitario menor o igual a 0
    @precioReferencia = -5,       -- Precio de referencia menor o igual a 0
    @unidadReferencia = '',       -- Unidad de referencia vac�a
    @FKCategoria = NULL;          -- FK de categor�a nulo
GO
EXEC dbProducto.InsertarProducto
    @nombre = 'ProductoConUnNombreExcesivamenteLargoQueSuperaLos50Caracteres',
    @precioUnitario = 12,
    @precioReferencia = NULL,
    @unidadReferencia = 'UnidadDeReferenciaDemasiadoLarga',
    @FKCategoria = 9999; -- ID de categor�a que no existe
GO
EXEC dbProducto.InsertarProducto
    @nombre = 'Leche LaSerenisima',
    @precioUnitario = 20,
    @precioReferencia = 18,
    @unidadReferencia = 'Litro',
    @FKCategoria = 1;
GO
EXEC dbProducto.InsertarProducto
    @nombre = 'Leche LaSerenisima',  -- Nombre de producto ya existente
    @precioUnitario = 20,
    @precioReferencia = 18,
    @unidadReferencia = 'Litro',
    @FKCategoria = 1;
GO
----------------------------------------------------------------------------------------------
--VENTA: 3 rows affected
EXEC dbVenta.InsertarVenta
    @Factura = NULL,               -- Falta el n�mero de factura
    @tipoFactura = 'X',            -- Tipo de factura inv�lido
    @tipoCliente = 'VIP',          -- Tipo de cliente inv�lido
    @genero = 'Z',                 -- G�nero inv�lido
    @cantidad = -5,                -- Cantidad menor a 0
    @identificadorDePago = '12345678abcd', -- Identificador de pago incorrecto
    @FKempleado = 9999,            -- Legajo no registrado
    @FKMetodoDePago = 9999,        -- ID de m�todo de pago no existente
    @FKproducto = 9999,            -- ID de producto no registrado
    @FKSucursal = 9999;            -- ID de sucursal no existente
GO
EXEC dbVenta.InsertarVenta
    @Factura = 123456789,          -- Factura v�lida
    @tipoFactura = 'A',            -- Tipo de factura v�lido
    @tipoCliente = 'Normal',       -- Tipo de cliente v�lido
    @genero = 'M',                 -- G�nero inv�lido
    @cantidad = 10,                -- Cantidad v�lida
    @identificadorDePago = '1234-5678-90aa-5678', -- Identificador de pago mal formateado
    @FKempleado = NULL,            -- Legajo vac�o
    @FKMetodoDePago = 0,           -- ID de m�todo de pago nulo
    @FKproducto = 0,               -- ID de producto nulo
    @FKSucursal = 0;               -- ID de sucursal nulo
GO
EXEC dbVenta.InsertarVenta
    @Factura = 234567891,
    @tipoFactura = 'A',
    @tipoCliente = 'Normal',
    @genero = 'Male',
    @cantidad = 20,
    @identificadorDePago = '1234-5678-9012-3456', -- Pago con tarjeta formateado correctamente
    @FKempleado = 54321,               -- Legajo existente
    @FKMetodoDePago = 1,           -- M�todo de pago v�lido
    @FKproducto = 1,               -- Producto v�lido
    @FKSucursal = 1;               -- Sucursal v�lida
GO
EXEC dbVenta.InsertarVenta
    @Factura = 123456789,
    @tipoFactura = 'B',
    @tipoCliente = 'Member',
    @genero = 'Female',
    @cantidad = 15,
    @identificadorDePago = NULL,   -- Pago en efectivo
    @FKempleado = 54321,               -- Legajo existente
    @FKMetodoDePago = 2,           -- M�todo de pago v�lido
    @FKproducto = 2,               -- Producto v�lido
    @FKSucursal = 2;               -- Sucursal v�lida
GO
EXEC dbVenta.InsertarVenta
    @Factura = 345678912,
    @tipoFactura = 'C',
    @tipoCliente = 'Member',
    @genero = NULL,                -- G�nero no especificado
    @cantidad = 5,
    @identificadorDePago = NULL,   -- Pago en efectivo
    @FKempleado = 12345,               -- Legajo existente
    @FKMetodoDePago = 2,           -- M�todo de pago v�lido
    @FKproducto = 1,               -- Producto v�lido
    @FKSucursal = 2;               -- Sucursal v�lida
/*///////////////////////////////////////////////////////////////////////////////////////// */
/*///////////////////////////////////////////////////////////////////////////////////////// */
/*///////////////////////////////////////////////////////////////////////////////////////// */
--Prueba ACTUALIZACIONES
GO
EXEC dbSucursal.ActualizarSucursal
    @IDSucursal = 1,  -- ID de la sucursal a actualizar
    @direccion = 'Calle Actualizada 123',  -- Nueva direcci�n
    @numTelefono = '987654321',  -- Nuevo n�mero de tel�fono
    @ciudad = 'Ciudad Actualizada',  -- Nueva ciudad
    @sucursal = 'Sucursal Actu';  -- Nuevo nombre de la sucursal
GO
EXEC dbSucursal.ActualizarEmpleado
	@empleadoAactualizar=54321,
	@dni=1111111,
	@nombre='Empleado Actu',
	@apellido='Alizado',
	@emailEmpresa='emailempresaactu@superA.com',
	@emailPersonal='emailpersonalactu@unlam.com',
	@direccion='direccion actualizada 5421',
	@cargo='Supervisor',
	@turno='TM',
	@FKSucursal=100
GO
EXEC dbProducto.ActualizarLineaDeProducto
	@lineaDeProductoAactualizar=2,
	@nombre='linea de producto actualizada'
GO
EXEC dbProducto.ActualizarCategoria
	@categoriaAactualizar=1,
	@nombre='categoria actualizada',
	@FKLineaDeProducto=2
GO
EXEC dbProducto.ActualizarProducto
	@productoAactualizar=5,
	@nombre='producto actualizado',
	@precioUnitario=48.6,
	@precioReferencia=50.0,
	@unidadReferencia='1 unidad actu',
	@FKCategoria=2
GO
EXEC dbVenta.ActualizarMetodoDePago
	 @metodoDePagoAactualizar=1,
	 @nombre='Chachos'
GO
/*///////////////////////////////////////////////////////////////////////////////////////// */
/*///////////////////////////////////////////////////////////////////////////////////////// */
/*///////////////////////////////////////////////////////////////////////////////////////// */
--Prueba BORRADOS(L�GICOS)
EXEC dbSucursal.ModificarEstadoSucursal
	@IDSucursal=2,
	@estado=1
GO
EXEC dbSucursal.ModificarEstadoEmpleado
	@Legajo=12345,
	@estado=0
GO
EXEC dbProducto.ModificarEstadoLineaDeProducto
	@IDLineaDeProducto=3,
	@estado=1
GO
EXEC dbProducto.ModificarEstadoCategoria
	@IDCategoria=1,
	@estado=0
GO
EXEC dbProducto.ModificarEstadoProducto
	@IDProducto=2,
	@estado=0
GO
EXEC dbVenta.ModificarEstadoMetodoDePago
	@IDMetodoDePago=1,
	@estado=1
GO

SELECT * FROM dbSucursal.Sucursal
GO
SELECT * FROM dbSucursal.Empleado
GO
SELECT * FROM dbProducto.LineaDeProducto
GO
SELECT * FROM dbProducto.Categoria
GO
SELECT * FROM dbProducto.Producto
GO
SELECT * FROM dbVenta.MetodoDePago
GO
SELECT * FROM dbVenta.Venta

