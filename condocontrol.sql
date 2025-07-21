
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
