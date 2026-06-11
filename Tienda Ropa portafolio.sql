
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'TiendaRopaBD')
BEGIN
    DROP DATABASE TiendaRopaBD;
END
GO
--Creación de la base de datos TiendaRopaBD--
CREATE DATABASE TiendaRopaBD;
GO

USE TiendaRopaBD;
GO

CREATE TABLE Clientes (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    dni VARCHAR(15) NOT NULL UNIQUE,
    telefono VARCHAR(20) NULL,
    email VARCHAR(150) NULL
);
GO


CREATE TABLE Productos (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    nombre_producto VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio_base DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(50) NOT NULL
);
GO

CREATE TABLE Detalle_Variaciones (
    id_variacion INT IDENTITY(1,1) PRIMARY KEY,
    id_producto INT NOT NULL,
    talla VARCHAR(10) NOT NULL,
    color VARCHAR(30) NOT NULL,
    stock_actual INT NOT NULL CHECK (stock_actual >= 0),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);
GO

CREATE TABLE Ventas (
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_venta DATETIME DEFAULT GETDATE(),
    metodo_pago VARCHAR(30) NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);
GO

CREATE TABLE Detalle_Ventas (
    id_detalle INT IDENTITY(1,1) PRIMARY KEY,
    id_venta INT NOT NULL,
    id_variacion INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario_historico DECIMAL(10,2) NOT NULL, 
    FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta),
    FOREIGN KEY (id_variacion) REFERENCES Detalle_Variaciones(id_variacion)
);
GO

INSERT INTO Clientes (nombre, apellido, dni, telefono, email)
VALUES ('Lucía', 'Fernández', '77665544', '987654321', 'lucia.f@email.com');

INSERT INTO Productos (nombre_producto, descripcion, precio_base, categoria)
VALUES ('Camisola Summer Vibes', 'Camisola de playa ligera y fresca de lino', 45.00, 'Prendas Superiores');

INSERT INTO Detalle_Variaciones (id_producto, talla, color, stock_actual)
VALUES 
(1, 'M', 'Blanco', 15), 
(1, 'L', 'Negro', 20); 

INSERT INTO Ventas (id_cliente, metodo_pago, monto_total)
VALUES (1, 'Tarjeta', 135.00); 

INSERT INTO Detalle_Ventas (id_venta, id_variacion, cantidad, precio_unitario_historico)
VALUES 
(1, 1, 2, 45.00), 
(1, 2, 1, 45.00); 
GO
--INSERTANTO MÁS REGISTROS--

INSERT INTO Clientes (nombre, apellido, dni, telefono, email) VALUES 
('Carlos', 'Mendoza', '44332211', '912345678', 'carlos.m@email.com'),
('Ana', 'Gomez', '11223344', '934567890', 'ana.g@email.com'),
('Luis', 'Pineda', '55667788', '956789012', 'luis.p@email.com'),
('Elena', 'Vega', '99887766', '978901234', 'elena.v@email.com'),
('Mario', 'Castro', '12345678', '990123456', 'mario.c@email.com');

INSERT INTO Productos (nombre_producto, descripcion, precio_base, categoria) VALUES 
('Pantalon Denim Classic', 'Pantalon jean clásico de corte recto', 89.90, 'Prendas Inferiores'),
('Casaca Cortaviento Eco', 'Casaca impermeable hecha de material reciclado', 120.00, 'Prendas Superiores'),
('Vestido Flores Primavera', 'Vestido corto casual con estampado floral', 75.00, 'Vestidos'),
('Polera Oversize Basic', 'Polera de algodón franela sin capucha', 65.00, 'Prendas Superiores'),
('Short Sport Active', 'Short ligero para entrenamiento deportivo', 39.90, 'Prendas Inferiores');

INSERT INTO Detalle_Variaciones (id_producto, talla, color, stock_actual) VALUES 
(2, '30', 'Azul Oscuro', 10), -- Pantalon Denim
(2, '32', 'Negro', 12),       -- Pantalon Denim
(3, 'L', 'Verde Oliva', 8),   -- Casaca Cortaviento
(4, 'S', 'Rojo', 15),         -- Vestido Flores
(5, 'M', 'Gris Jaspe', 25),    -- Polera Oversize
(6, 'L', 'Negro', 30);        -- Short Sport

INSERT INTO Ventas (id_cliente, metodo_pago, monto_total) VALUES 
(2, 'Efectivo', 89.90),   -- Carlos Mendoza compra un jean
(3, 'Tarjeta', 185.00),  -- Ana Gomez compra casaca + vestido
(4, 'Yape', 65.00),      -- Luis Pineda compra una polera
(5, 'Tarjeta', 79.80),   -- Elena Vega compra dos shorts
(6, 'Efectivo', 244.90);

INSERT INTO Detalle_Ventas (id_venta, id_variacion, cantidad, precio_unitario_historico) VALUES 
-- Venta 2: Carlos compra Pantalon Azul (id_variacion 3)
(2, 3, 1, 89.90),

-- Venta 3: Ana compra Casaca Verde (id_variacion 5) y Vestido Rojo (id_variacion 6)
(3, 5, 1, 120.00),
(3, 6, 1, 75.00),

-- Venta 4: Luis compra Polera Gris (id_variacion 7)
(4, 7, 1, 65.00),

-- Venta 5: Elena compra 2 Shorts Negros (id_variacion 8)
(5, 8, 2, 39.90),

-- Venta 6: Mario compra Pantalon Negro (id_variacion 4), Polera Gris (id_variacion 7) y Short Negro (id_variacion 8)
(6, 4, 1, 89.90),
(6, 7, 1, 65.00),
(6, 8, 2, 39.90);
GO

/*CONSULTAS AVANZADAS*/

--Historial detallado de renglones de venta--
SELECT
v.id_venta AS [Número de boleta],
cl.nombre+' '+cl.apellido AS [Nombre completo],
p.nombre_producto AS Producto,
dv.color AS Color,
dv.talla AS Talla,
dve.cantidad AS Cantidad,
(dve.cantidad*dve.precio_unitario_historico) AS Subtotal
FROM Detalle_Ventas dve
INNER JOIN  Ventas v on dve.id_venta=v.id_venta
INNER JOIN Detalle_Variaciones dv on dve.id_variacion=dv.id_variacion
INNER JOIN Clientes cl on v.id_cliente=cl.id_cliente
INNER JOIN Productos p on dv.id_producto=p.id_producto;
GO
--Ranking de clientes vip y segmentación de alto valor--
SELECT
cl.id_cliente AS [Código del cliente],
cl.nombre+' '+cl.apellido AS Cliente,
SUM(dve.cantidad) AS [Total prendas compradas],
SUM(dve.cantidad*dve.precio_unitario_historico) AS [Dinero total gastado]
FROM Ventas v
INNER JOIN Detalle_Ventas dve on v.id_venta=dve.id_venta
INNER JOIN Clientes cl on v.id_cliente=cl.id_cliente
GROUP BY cl.id_cliente ,cl.nombre,cl.apellido
HAVING SUM(dve.cantidad)>=1 AND SUM(dve.cantidad*dve.precio_unitario_historico)>=45
ORDER BY [Dinero total gastado] DESC;
GO
--Alerta de producto con bajo inventario global (Stock <=5)--
SELECT
p.nombre_producto AS Prenda,
SUM(dv.stock_actual)AS [Stock total disponible]
FROM Productos p
INNER JOIN Detalle_Variaciones dv on p.id_producto=dv.id_producto
GROUP BY p.nombre_producto
HAVING SUM(dv.stock_actual)<=5
ORDER BY [Stock total disponible] ASC;
GO
--Reporte de auditoría de boletas--
SELECT
v.id_venta AS [Número de boleta],
CONCAT(cl.nombre,' ',cl.apellido) AS Cliente,
p.nombre_producto AS Producto,
dva.talla AS Talla,
dva.color AS Color,
dve.cantidad AS [Cantidad vendida]
FROM Detalle_Ventas dve
INNER JOIN Ventas v on dve.id_venta=v.id_venta
INNER JOIN Detalle_Variaciones dva on dve.id_variacion=dva.id_variacion
INNER JOIN Clientes cl on v.id_cliente=cl.id_cliente
INNER JOIN Productos p on dva.id_producto=p.id_producto;
GO
--Raking de variaciones más vendidas--
SELECT
p.nombre_producto AS Producto,
dva.talla AS Talla,
dva.color AS Color,
SUM(dve.cantidad) AS [Total unidades vendidas]
FROM Productos p
INNER JOIN Detalle_Variaciones dva on p.id_producto=dva.id_producto
INNER JOIN Detalle_Ventas dve on dva.id_variacion=dve.id_variacion
GROUP BY p.nombre_producto,dva.talla,dva.color
HAVING SUM(dve.cantidad)>=1
ORDER BY [Total unidades vendidas] DESC;
GO

--Login y usuario con permisos--
CREATE LOGIN LoginCajero
WITH PASSWORD = 'Cajero12026'
GO
USE TiendaRopaBD;
GO
CREATE USER UsuarioCajero FOR LOGIN LoginCajero;
GO
GRANT SELECT ON Clientes TO UsuarioCajero;
GRANT SELECT ON Productos TO UsuarioCajero;
GRANT SELECT ON Detalle_Ventas TO UsuarioCajero;
GO
GRANT INSERT,SELECT ON Ventas TO UsuarioCajero;
GRANT INSERT,SELECT ON Detalle_Ventas TO UsuarioCajero;
GO
DENY UPDATE,DELETE ON Productos TO UsuarioCajero;
DENY DELETE ON Ventas TO UsuarioCajero;
DENY DELETE ON Detalle_Ventas TO UsuarioCajero;
GO
--Prueba(Cambiamos el de administrador a Usuario cajero)
EXECUTE AS USER ='UsuarioCajero'

UPDATE Productos
SET precio_base=5.00
WHERE id_producto=1;

REVERT; --Revertimos los cambios  - volver a ser Administrador
GO


