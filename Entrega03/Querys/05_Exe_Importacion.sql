USE Com2900G06
GO
exec dbVenta.CargaInformacionComplementariaSucursal 
GO
exec dbVenta.CargaInformacionComplementariaEmpleados
GO
exec dbVenta.CargaInformacionComplementariaClasificacionProductos
GO
exec dbVenta.CargaInformacionComplementariaMetodosDePago
GO
exec dbProducto.CargaMasivaProductosImportados
GO
exec dbProducto.cargaAccesoriosElectronicos
GO
exec dbVenta.CargaMasivaCatalogo
GO
exec dbVenta.CargaMasivaVentas
GO

--EXEC dbVenta.MostrarVentas