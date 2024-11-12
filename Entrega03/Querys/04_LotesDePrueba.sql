USE Com2900G06
 --use master
 /*///////////////////////////////////////////////////////////////////////////////////////// */
 --Prueba INSERCIONES
 --METODO DE PAGO:	3 rows affected
 GO
-- Caso 1: Nombre válido
EXEC dbVenta.InsertarMetodoDePago @nombre = 'Cash'; --Debería insertarse correctamente.
GO
-- Caso 2: Nombre válido
EXEC dbVenta.InsertarMetodoDePago 'Credit card'; --Debería insertarse correctamente.
GO
-- Caso 3: Nombre vacío
EXEC dbVenta.InsertarMetodoDePago @nombre = ''; --'Falta nombre.'
GO
-- Caso 4: Nombre demasiado largo
EXEC dbVenta.InsertarMetodoDePago @nombre = 'Tarjeta de Crédito'; --'Nombre demasiado largo. Tamaño maximo de 11 caracteres.'
GO
-- Caso 5: Nombre que ya existe
EXEC dbVenta.InsertarMetodoDePago @nombre = 'Cash'; --'El nombre del metodo de pago ingresado ya existe.'
GO
-- Caso 6: Nombre demasiado largo
EXEC dbVenta.InsertarMetodoDePago @nombre = 'Transferencia'; --'Nombre demasiado largo. Tamaño maximo de 11 caracteres.'
GO
-- Caso 7: Nombre válido
EXEC dbVenta.InsertarMetodoDePago @nombre = 'Ewallet'; --Debería insertarse correctamente.
GO
----------------------------------------------------------------------------------------------
--SUCURSAL: 2 rows affected
-- Caso 1: Inserción válida
EXEC dbSucursal.InsertarSucursal 
    @direccion = 'Calle Falsa 123',
    @numTelefono = '123456789',
    @ciudad = 'Madrid',
    @sucursal = 'Sucursal Centro'; -- Debería insertarse correctamente.
GO
-- Caso 2: Inserción válida
EXEC dbSucursal.InsertarSucursal 
    @direccion = 'Avenida Siempre Viva 742',
    @numTelefono = '987654321',
    @ciudad = 'Barcelona',
    @sucursal = 'Sucursal Norte'; -- Debería insertarse correctamente.
GO
-- Caso 3: Inserción con varios errores
EXEC dbSucursal.InsertarSucursal 
    @direccion = '',				--Falta direccion
    @numTelefono = '12345',     
    @ciudad = 'MuyLargaCiudad',      -- Ciudad demasiado larga (más de 9 caracteres).
    @sucursal = 'Sucursal Centro';     --Repetida.
GO
----------------------------------------------------------------------------------------------
--EMPLEADO: 2 rows affected
EXEC dbVenta.InsertarEmpleado
	@Legajo = NULL,          -- Legajo vacío o nulo
	@dni = NULL,             -- DNI vacío o nulo
	@nombre = '',            -- Nombre vacío
	@apellido = 'EsteApellidoEsDemasiadoLargoParaElCampo',  -- Apellido demasiado largo
	@emailEmpresa = 'empleado@otroDominio.com',             -- Email de empresa no válido
	@emailPersonal = 'personal@correo',                     -- Email personal sin ".com"
	@direccion = NULL,                                       -- Dirección vacía
	@cargo = 'Mantenimiento',                                -- Cargo no válido
	@turno = 'Noche',                                        -- Turno no válido
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
    @apellido = 'Sánchez',
    @emailEmpresa = 'pedro.sanchez@superA.com',
    @emailPersonal = 'pedro.sanchez@gmail.com',
    @direccion = 'Calle Real 654',
    @cargo = 'Gerente de sucursal',
    @turno = 'Jornada Completa',
    @FKSucursal = 999; -- ID de sucursal no existente. Debería generar un error: 'El ID de sucursal ingresado no existe.'
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
    @nombreCategoria = '',            -- Nombre de categoría vacío
    @FKLineaDeProducto = NULL;        -- ID de línea de producto nulo
GO
EXEC dbProducto.InsertarCategoria
    @nombreCategoria = 'EstaCategoriaTieneUnNombreExcesivamenteLargoQueSuperaLos50Caracteres',
    @FKLineaDeProducto = 9999;  -- ID de línea de producto que no existe
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
--PRODUCTO: 2 rows affected
EXEC dbProducto.InsertarProducto
    @nombre = '',                 -- Nombre vacío
    @precioUnitario = 0,          -- Precio unitario menor o igual a 0
    @precioReferencia = -5,       -- Precio de referencia menor o igual a 0
    @unidadReferencia = '',       -- Unidad de referencia vacía
    @FKCategoria = NULL;          -- FK de categoría nulo
GO
EXEC dbProducto.InsertarProducto
    @nombre = 'ProductoConUnNombreExcesivamenteLargoQueSuperaLos50Caracteres',
    @precioUnitario = 12,
    @precioReferencia = NULL,
    @unidadReferencia = 'UnidadDeReferenciaDemasiadoLarga',
    @FKCategoria = 9999; -- ID de categoría que no existe
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
EXEC dbProducto.InsertarProducto
    @nombre = 'Producto 2',
    @precioUnitario = 30,
    @precioReferencia = 40,
    @unidadReferencia = 'unidad pro',
    @FKCategoria = 1;
GO
----------------------------------------------------------------------------------------------
--FACTURAS, DETALLES Y VENTA(3 rows affected)
CREATE OR ALTER PROCEDURE dbFactura.PruebaFacturasYVentas
AS
BEGIN
	DECLARE @IDFactura INT;
	--Creo la factura
	EXEC dbFactura.CrearFactura @IDFacturaGenerada=@IDFactura OUTPUT;

	--Inserto detalles
	EXEC dbFactura.InsertarDetalleDeFactura
		@cantidad=-10,				--Cantidad negativa
		@FKProducto=1000000,		--Producto no existente
		@FKFactura=1000;			--Factura no existente
	EXEC dbFactura.InsertarDetalleDeFactura
		@cantidad=5,
		@FKProducto=1,
		@FKFactura=@IDFactura;
	EXEC dbFactura.InsertarDetalleDeFactura
		@cantidad=2,
		@FKProducto=2,
		@FKFactura=@IDFactura;

	--Emito la factura
	EXEC dbFactura.EmitirFactura
		@IDFactura=7645,			--Factura no existente
		@numeroFactura=0,			--Invalido
		@tipoFactura='Z';			--Tipo Factura inválido
	EXEC dbFactura.EmitirFactura
		@IDFactura=@IDFactura,			
		@numeroFactura=546665237,		--SI QUIERO EMITIR OTRA CAMBIO ESTE NUMERO
		@tipoFactura='A';

	--Le asignó la factura a la venta
	EXEC dbVenta.InsertarVenta
		@tipoCliente = 'VIP',					-- Tipo de cliente inválido
		@genero = 'Z',							-- Género inválido
		@identificadorDePago = '12345678abcd',  -- Identificador de pago incorrecto
		@FKempleado = 9999,						-- Legajo no registrado
		@FKMetodoDePago = 9999,					-- ID de método de pago no existente
		@FKSucursal = 9999,						-- ID de sucursal no existente
		@FKFactura = 9999;						-- ID de factura no existente
	EXEC dbVenta.InsertarVenta
		@tipoCliente = 'Normal',       -- Tipo de cliente válido
		@genero = 'M',                 -- Género inválido
		@identificadorDePago = '1234-5678-90aa-5678', -- Identificador de pago mal formateado
		@FKempleado = NULL,            -- Legajo vacío
		@FKMetodoDePago = 0,           -- ID de método de pago nulo
		@FKSucursal = 0,               -- ID de sucursal nulo
		@FKFactura = 9999;			   -- ID de factura nulo
	EXEC dbVenta.InsertarVenta
		@tipoCliente = 'Normal',
		@genero = 'Male',
		@identificadorDePago = '1234-5678-9012-3456', 
		@FKempleado = 54321,              
		@FKMetodoDePago = 1,                       
		@FKSucursal = 1,
		@FKFactura = @IDFactura;
	EXEC dbVenta.InsertarVenta
		@tipoCliente = 'Member',
		@genero = 'Female',
		@identificadorDePago = NULL,   
		@FKempleado = 54321,               
		@FKMetodoDePago = 2,                         
		@FKSucursal = 2,
		@FKFactura = @IDFactura;			--La factura ya tiene una venta asociada
	------------------------------
	--Pruebo que no deje emitir si no agregue ningun detalle
	EXEC dbFactura.CrearFactura @IDFacturaGenerada=@IDFactura OUTPUT;

	EXEC dbFactura.EmitirFactura		--Falta al menos un detalle
		@IDFactura=@IDFactura,			
		@numeroFactura=867662468,	
		@tipoFactura='B';
	EXEC dbVenta.InsertarVenta			--Falta que se emita la factura
		@tipoCliente = 'Member',
		@genero = 'Female',
		@identificadorDePago = NULL,   
		@FKempleado = 54321,               
		@FKMetodoDePago = 2,                         
		@FKSucursal = 2,
		@FKFactura = @IDFactura;
END
GO
EXEC dbFactura.PruebaFacturasYVentas;
----------------------------------------------------------------------------------------------
/*///////////////////////////////////////////////////////////////////////////////////////// */
/*///////////////////////////////////////////////////////////////////////////////////////// */
/*///////////////////////////////////////////////////////////////////////////////////////// */
--Prueba ACTUALIZACIONES
GO
EXEC dbSucursal.ActualizarSucursal
    @IDSucursal = 1,  -- ID de la sucursal a actualizar
    @direccion = 'Calle Actualizada 123',  -- Nueva dirección
    @numTelefono = '987654321',  -- Nuevo número de teléfono
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
	@FKSucursal=100;
GO
EXEC dbProducto.ActualizarLineaDeProducto
	@lineaDeProductoAactualizar=2,
	@nombre='linea de producto actualizada';
GO
EXEC dbProducto.ActualizarCategoria
	@categoriaAactualizar=1,
	@nombre='categoria actualizada',
	@FKLineaDeProducto=2;
GO
EXEC dbProducto.ActualizarProducto
	@productoAactualizar=5,
	@nombre='producto actualizado',
	@precioUnitario=48.6,
	@precioReferencia=50.0,
	@unidadReferencia='1 unidad actu',
	@FKCategoria=2;
GO
EXEC dbVenta.ActualizarMetodoDePago
	 @metodoDePagoAactualizar=1,
	 @nombre='Chachos';
GO
EXEC dbFactura.RecibirPagoFactura
	@IDFactura = 1;
GO
/*///////////////////////////////////////////////////////////////////////////////////////// */
/*///////////////////////////////////////////////////////////////////////////////////////// */
/*///////////////////////////////////////////////////////////////////////////////////////// */
--Prueba BORRADOS(LÓGICOS)
EXEC dbSucursal.ModificarEstadoSucursal
	@IDSucursal=2,
	@estado=1;
GO
EXEC dbSucursal.ModificarEstadoEmpleado
	@Legajo=12345,
	@estado=0;
GO
EXEC dbProducto.ModificarEstadoLineaDeProducto
	@IDLineaDeProducto=1,
	@estado=1;
GO
EXEC dbProducto.ModificarEstadoCategoria
	@IDCategoria=1,
	@estado=0;
GO
EXEC dbProducto.ModificarEstadoProducto
	@IDProducto=2,
	@estado=0;
GO
EXEC dbVenta.ModificarEstadoMetodoDePago
	@IDMetodoDePago=1,
	@estado=1;
GO


--SELECT * FROM dbSucursal.Sucursal
--GO
--SELECT * FROM dbSucursal.Empleado
--GO
--SELECT * FROM dbProducto.LineaDeProducto
--GO
--SELECT * FROM dbProducto.Categoria
--GO
--SELECT * FROM dbProducto.Producto
--GO
--SELECT * FROM dbVenta.MetodoDePago
--GO
--SELECT * FROM dbVenta.Venta
--GO
--SELECT * FROM dbFactura.DetalleDeFactura
--GO
--SELECT * FROM dbFactura.Factura
--GO