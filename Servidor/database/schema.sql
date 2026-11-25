-- ============================================================================
-- Esquema de Base de Datos: Sistema Inteligente de Gestión de Asistencias (SIGA)
-- Compatible 100% con TiDB Cloud y MySQL (AUTO_ID_CACHE = 1 para IDs de 1 en 1)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS siga_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE siga_db;

-- ----------------------------------------------------------------------------
-- 1. Tabla: alumnos
-- El alumno se registra únicamente con numero_control y nombre_completo.
-- id_alumno se asigna automáticamente de uno en uno (1, 2, 3...).
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS alumnos (
    id_alumno INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único asignado automáticamente de uno en uno',
    numero_control VARCHAR(10) NOT NULL UNIQUE COMMENT 'Número de control oficial del estudiante utilizado para generar el QR',
    nombre_completo VARCHAR(100) NOT NULL COMMENT 'Nombre y apellidos del estudiante',
    chat_id_telegram VARCHAR(50) DEFAULT NULL COMMENT 'ID numérico del chat de Telegram (se llena cuando el alumno vincula su cuenta)',
    qr_enviado TINYINT(1) NOT NULL DEFAULT 0 COMMENT '0 = Pendiente de generar/enviar QR, 1 = QR enviado',
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de alta en el servidor'
) ENGINE=InnoDB AUTO_ID_CACHE = 1;

-- ----------------------------------------------------------------------------
-- 2. Tabla: asistencias
-- Registra cada pase de lista validado tras decodificar el QR de la cámara
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS asistencias (
    id_asistencia INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del registro de asistencia',
    id_alumno INT NOT NULL COMMENT 'Referencia al id_alumno de la tabla alumnos',
    numero_control VARCHAR(10) NOT NULL COMMENT 'Número de control (token del QR) para consultas rápidas',
    fecha DATE NOT NULL COMMENT 'Fecha del pase de asistencia (YYYY-MM-DD)',
    hora TIME NOT NULL COMMENT 'Hora exacta del registro (HH:MM:SS)',
    fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp completo del registro',
    estado ENUM('presente', 'retardo', 'falta', 'justificado') NOT NULL DEFAULT 'presente' COMMENT 'Estatus de la asistencia',
    dispositivo_origen VARCHAR(30) NOT NULL DEFAULT 'arduino_qr' COMMENT 'Origen del registro (arduino_qr, escritorio, android)',
    observaciones VARCHAR(255) DEFAULT NULL COMMENT 'Notas opcionales del registro',
    CONSTRAINT fk_asistencia_alumno
        FOREIGN KEY (id_alumno) REFERENCES alumnos(id_alumno)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    INDEX idx_asistencias_fecha (fecha),
    INDEX idx_asistencias_alumno_fecha (id_alumno, fecha),
    INDEX idx_asistencias_num_control (numero_control)
) ENGINE=InnoDB AUTO_ID_CACHE = 1;
