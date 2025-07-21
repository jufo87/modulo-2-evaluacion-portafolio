
-- Crear base de datos CondoControl
DROP DATABASE IF EXISTS ControlAcceso;
CREATE DATABASE ControlAcceso;
USE ControlAcceso;

CREATE TABLE USUARIOS (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    tipo_usuario ENUM('residente', 'guardia') NOT NULL,
    numero_unidad VARCHAR(10), -- Solo para residentes
    telefono VARCHAR(15),
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE VISITANTES (
    id_visitante INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    documento VARCHAR(20) NOT NULL,
    telefono VARCHAR(15),
    email VARCHAR(100),
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE VEHICULOS (
    id_vehiculo INT PRIMARY KEY AUTO_INCREMENT,
    patente VARCHAR(10) UNIQUE NOT NULL,
    marca VARCHAR(50),
    modelo VARCHAR(50),
    color VARCHAR(30),
    id_propietario INT NOT NULL,
    tipo_propietario ENUM('usuario', 'visitante') NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ACCESOS (
    id_acceso INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT, -- NULL si es visitante
    id_visitante INT, -- NULL si es usuario
    id_vehiculo INT, -- Opcional
    tipo_acceso ENUM('entrada', 'salida') NOT NULL,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_guardia INT NOT NULL,
    motivo_visita TEXT, -- Solo para visitantes
    unidad_visitada VARCHAR(10), -- Solo para visitantes
    observaciones TEXT,
    FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario),
    FOREIGN KEY (id_visitante) REFERENCES VISITANTES(id_visitante),
    FOREIGN KEY (id_vehiculo) REFERENCES VEHICULOS(id_vehiculo),
    FOREIGN KEY (id_guardia) REFERENCES USUARIOS(id_usuario)
);

-- Ejemplos Insert Acceso Usuarios
INSERT INTO ACCESOS (id_usuario, id_vehiculo, tipo_acceso, fecha_hora, id_guardia) VALUES
(2, 1, 'entrada', '2025-01-20 08:30:00', 1),
(3, 2, 'entrada', '2025-01-20 09:15:00', 1),
(2, 1, 'salida', '2025-01-20 18:45:00', 5),
(4, 3, 'entrada', '2025-01-20 19:30:00', 5),
(3, 2, 'salida', '2025-01-21 07:20:00', 1);

-- Ejemplos Insert Accesos de visitantes
INSERT INTO ACCESOS (id_visitante, tipo_acceso, fecha_hora, id_guardia, motivo_visita, unidad_visitada) VALUES
(1, 'entrada', '2025-01-20 14:00:00', 1, 'Visita familiar', '101'),
(2, 'entrada', '2025-01-20 15:30:00', 1, 'Entrega de paquete', '202'),
(1, 'salida', '2025-01-20 17:00:00', 5, NULL, NULL),
(3, 'entrada', '2025-01-21 10:00:00', 1, 'Reunión de trabajo', '303'),
(2, 'salida', '2025-01-20 16:00:00', 1, NULL, NULL);

-- CONSULTA : Ver todos los accesos de un residente específico
SELECT 
    a.tipo_acceso,
    a.fecha_hora,
    u.nombre AS residente,
    u.numero_unidad,
    v.placa AS vehiculo
FROM ACCESOS a
INNER JOIN USUARIOS u ON a.id_usuario = u.id_usuario
LEFT JOIN VEHICULOS v ON a.id_vehiculo = v.id_vehiculo
WHERE u.email = 'julio.fonseca@email.com'
ORDER BY a.fecha_hora DESC;

-- CONSULTA : Reporte de movimientos por fecha
SELECT 
    DATE(fecha_hora) as fecha,
    COUNT(CASE WHEN tipo_acceso = 'entrada' THEN 1 END) as entradas,
    COUNT(CASE WHEN tipo_acceso = 'salida' THEN 1 END) as salidas,
    COUNT(*) as total_movimientos
FROM ACCESOS 
WHERE fecha_hora >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(fecha_hora)
ORDER BY fecha DESC;

-- CONSULTA : Vehículos registrados con sus propietarios
SELECT 
    v.patente,
    v.marca,
    v.modelo,
    v.color,
    CASE 
        WHEN v.tipo_propietario = 'usuario' THEN u.nombre
        ELSE vis.nombre
    END AS propietario,
    v.tipo_propietario
FROM VEHICULOS v
LEFT JOIN USUARIOS u ON v.id_propietario = u.id_usuario AND v.tipo_propietario = 'usuario'
LEFT JOIN VISITANTES vis ON v.id_propietario = vis.id_visitante AND v.tipo_propietario = 'visitante'
WHERE v.activo = TRUE
ORDER BY v.patente;

-- Actualizar teléfono de un residente
UPDATE USUARIOS 
SET telefono = '+56999888777' 
WHERE email = 'juan.perez@email.com';

-- Cambiar email de un residente
UPDATE USUARIOS 
SET email = 'juan.perez.nuevo@email.com' 
WHERE id_usuario = 2;

-- Marcar vehículo como inactivo
UPDATE VEHICULOS 
SET activo = FALSE 
WHERE patente = 'ABC123';

-- Actualizar información de visitante
UPDATE VISITANTES 
SET telefono = '+56888999000' 
WHERE documento = '12.345.678-9';

-- Eliminar accesos antiguos (más de 6 meses)
DELETE FROM ACCESOS 
WHERE fecha_hora < DATE_SUB(NOW(), INTERVAL 6 MONTH);

-- Eliminar vehículos inactivos sin accesos recientes
DELETE FROM VEHICULOS 
WHERE activo = FALSE 
AND id_vehiculo NOT IN (
    SELECT DISTINCT id_vehiculo 
    FROM ACCESOS 
    WHERE id_vehiculo IS NOT NULL 
    AND fecha_hora >= DATE_SUB(NOW(), INTERVAL 3 MONTH)
);

-- Reporte diario
CREATE VIEW vista_reporte_diario AS
SELECT 
    a.id_acceso,
    a.tipo_acceso,
    TIME(a.fecha_hora) AS hora,
    COALESCE(u.nombre, vis.nombre) AS persona,
    COALESCE(u.numero_unidad, a.unidad_visitada) AS unidad,
    CASE 
        WHEN u.id_usuario IS NOT NULL THEN 'Residente'
        ELSE 'Visitante'
    END AS tipo_persona,
    v.placa,
    g.nombre AS guardia
FROM ACCESOS a
LEFT JOIN USUARIOS u ON a.id_usuario = u.id_usuario
LEFT JOIN VISITANTES vis ON a.id_visitante = vis.id_visitante
LEFT JOIN VEHICULOS v ON a.id_vehiculo = v.id_vehiculo
LEFT JOIN USUARIOS g ON a.id_guardia = g.id_usuario
WHERE DATE(a.fecha_hora) = CURDATE()
ORDER BY a.fecha_hora DESC;

-- Registrar visita
CREATE PROCEDURE RegistrarVisita(
    IN p_nombre_visitante VARCHAR(100),
    IN p_documento VARCHAR(20),
    IN p_telefono VARCHAR(15),
    IN p_unidad_visitada VARCHAR(10),
    IN p_motivo TEXT,
    IN p_id_guardia INT
)
BEGIN
    DECLARE v_id_visitante INT;
    
    -- Verificar si el visitante ya existe
    SELECT id_visitante INTO v_id_visitante 
    FROM VISITANTES 
    WHERE documento = p_documento;
    
    -- Si no existe, crearlo
    IF v_id_visitante IS NULL THEN
        INSERT INTO VISITANTES (nombre, documento, telefono) 
        VALUES (p_nombre_visitante, p_documento, p_telefono);
        SET v_id_visitante = LAST_INSERT_ID();
    END IF;
    
    -- Registrar el acceso
    INSERT INTO ACCESOS (id_visitante, tipo_acceso, id_guardia, motivo_visita, unidad_visitada)
    VALUES (v_id_visitante, 'entrada', p_id_guardia, p_motivo, p_unidad_visitada);
    
    -- Retornar el ID del acceso creado
    SELECT LAST_INSERT_ID() as id_acceso_creado;
    
END //


-- Ver todos los usuarios
SELECT * FROM USUARIOS;

-- Ver todos los visitantes
SELECT * FROM VISITANTES;

-- Ver todos los vehículos
SELECT * FROM VEHICULOS;

-- Ver todos los accesos del día
SELECT * FROM vista_reporte_diario;

-- Contar registros en cada tabla
SELECT 'USUARIOS' as tabla, COUNT(*) as total FROM USUARIOS
UNION ALL
SELECT 'VISITANTES', COUNT(*) FROM VISITANTES
UNION ALL
SELECT 'VEHICULOS', COUNT(*) FROM VEHICULOS
UNION ALL
SELECT 'ACCESOS', COUNT(*) FROM ACCESOS;


