USE Com2900G06
GO
exec dbReporte.mostrarTotalDias 1,2019
GO
exec dbReporte.mostrarTotalTrimestre 1,2019
GO
exec dbReporte.mostrarCantidadPorFecha '2019-01-15', '2019-03-15'
GO
exec dbReporte.mostrarCantidadSucursalPorFecha '2019-01-15', '2019-03-15'
GO
EXEC dbReporte.mostrarTop5ProductosPorSemana 1, 2019;
GO
EXEC dbReporte.mostrarTopMenos5ProductosPorMes 1, 2019;
GO
EXEC dbReporte.mostrarAcumuladoSucursal '2019-03-01', 1;
GO