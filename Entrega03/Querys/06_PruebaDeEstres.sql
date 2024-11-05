USE Com2900G06
GO
CREATE OR ALTER PROCEDURE dbVenta.Insertar10000Ventas
AS
BEGIN
    DECLARE @contador INT = 1;
    DECLARE @Factura INT;
    DECLARE @tipoFactura CHAR(1);
    DECLARE @tipoCliente CHAR(6);
    DECLARE @genero CHAR(6);
    DECLARE @cantidad INT;
    DECLARE @identificadorDePago VARCHAR(MAX);
    DECLARE @FKempleado INT;
    DECLARE @FKMetodoDePago INT;
    DECLARE @FKproducto INT;
    DECLARE @FKSucursal INT;
    

    BEGIN TRY
        -- Ciclo para insertar ventas 10000 veces
        WHILE @contador <= 10000
        BEGIN
           
            SET @Factura = 100000000 + @contador; 
            SET @tipoFactura = 'A'; 
            SET @tipoCliente = 'Normal'; 
            SET @genero = 'Male';
            SET @cantidad = 1;
            SET @identificadorDePago = NULL;
            SET @FKempleado = 12345;
            SET @FKMetodoDePago = 1;
            SET @FKproducto = 1;
            SET @FKSucursal = 1;

            EXEC dbVenta.InsertarVenta 
                @Factura, 
                @tipoFactura, 
                @tipoCliente, 
                @genero, 
                @cantidad, 
                @identificadorDePago, 
                @FKempleado, 
                @FKMetodoDePago, 
                @FKproducto, 
                @FKSucursal;

            SET @contador = @contador + 1;
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbVenta.PruebaDeEstres
AS
BEGIN
	DECLARE @TraceID INT;
	DECLARE @MaxFileSize BIGINT = 10;

	EXEC sp_trace_create 
		@TraceID OUTPUT,
		@Options = 2,	--que pare cuando cierro el sv
		@TraceFile ='C:\TP_integrador_Archivos\Traza',	--donde guarda la traza
		@MaxFileSize = @MaxFileSize;	--100MB maximo

	EXEC sp_trace_setevent @TraceID, 10, 1, 1;  --RPC:Completed, TextData

    EXEC sp_trace_setevent @TraceID, 12, 1, 1;  -- SQL:BatchCompleted, TextData
    EXEC sp_trace_setevent @TraceID, 14, 1, 1;  -- SQL:StmtStarting, TextData
    EXEC sp_trace_setevent @TraceID, 13, 1, 1;  -- SQL:StmtCompleted, TextData
    EXEC sp_trace_setevent @TraceID, 19, 1, 1;  -- ErrorLog, TextData

	EXEC sp_trace_setstatus @TraceID, 1;	--inicio

	SET nocount on;
	exec dbVenta.Insertar10000Ventas;
	select * from dbVenta.Venta;
	SET nocount off;

	EXEC sp_trace_setstatus @TraceID, 0;	--paro
	EXEC sp_trace_setstatus @TraceID, 2;	--elimino

	SELECT * 
	FROM fn_trace_gettable('C:\TP_integrador_Archivos\Traza.trc', DEFAULT);

END
go
exec dbVenta.PruebaDeEstres
GO
