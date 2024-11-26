USE Com2900G06
GO
exec dbSucursal.CargaInformacionComplementariaSucursal 'C:\Users\Tomas_Arce\Documents\GitHub\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO
exec dbSucursal.CargaInformacionComplementariaEmpleados 'C:\Users\Tomas_Arce\Documents\GitHub\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO
exec dbProducto.CargaInformacionComplementariaClasificacionProductos 'C:\Users\Tomas_Arce\Documents\GitHub\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO
exec dbVenta.CargaInformacionComplementariaMetodosDePago 'C:\Users\Tomas_Arce\Documents\GitHub\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO
exec dbProducto.CargaMasivaProductosImportados 'C:\Users\Tomas_Arce\Documents\GitHub\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO
exec dbProducto.cargaAccesoriosElectronicos 'C:\Users\Tomas_Arce\Documents\GitHub\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO
exec dbProducto.CargaMasivaCatalogo 'C:\Users\Tomas_Arce\Documents\GitHub\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO
exec dbVenta.CargaMasivaVentas 'C:\Users\Tomas_Arce\Documents\GitHub\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO

--EXEC dbVenta.MostrarVentas