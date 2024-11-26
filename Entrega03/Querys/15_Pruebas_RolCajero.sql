-- Un cajero no tiene el rol asignado para poder generar NC:

EXECUTE AS LOGIN = 'Empleado';
GO
EXEC dbFactura.GenerarNotaDeCredito 11, 'Nota de crédito por fondos insuficientes', 1234, 123;
GO