USE Com2900G06
GO
exec dbSucursal.CargaInformacionComplementariaSucursal 'D:\Thiago\UNLAM\1_EN_CURSO\BASES DE DATOS APLICADAS\Github\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO																		 
exec dbSucursal.CargaInformacionComplementariaEmpleados	'D:\Thiago\UNLAM\1_EN_CURSO\BASES DE DATOS APLICADAS\Github\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO																		
exec dbProducto.CargaInformacionComplementariaClasificacionProductos 'D:\Thiago\UNLAM\1_EN_CURSO\BASES DE DATOS APLICADAS\Github\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO																		
exec dbVenta.CargaInformacionComplementariaMetodosDePago 'D:\Thiago\UNLAM\1_EN_CURSO\BASES DE DATOS APLICADAS\Github\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO																		
exec dbProducto.CargaMasivaProductosImportados 'D:\Thiago\UNLAM\1_EN_CURSO\BASES DE DATOS APLICADAS\Github\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO																		
exec dbProducto.cargaAccesoriosElectronicos 'D:\Thiago\UNLAM\1_EN_CURSO\BASES DE DATOS APLICADAS\Github\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO																		 
exec dbProducto.CargaMasivaCatalogo	'D:\Thiago\UNLAM\1_EN_CURSO\BASES DE DATOS APLICADAS\Github\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO																		
exec dbVenta.CargaMasivaVentas 'D:\Thiago\UNLAM\1_EN_CURSO\BASES DE DATOS APLICADAS\Github\TP-BBDD---Grupo-6\TP_integrador_Archivos';
GO

--EXEC dbVenta.MostrarVentas