DROP DATABASE IF EXISTS ico_ins;
CREATE DATABASE ico_ins;
USE ico_ins;

CREATE TABLE alumno (
  id_alumno INT AUTO_INCREMENT PRIMARY KEY,
  num_cta VARCHAR(10) NOT NULL UNIQUE,
  nombre VARCHAR(50) NOT NULL,
  paterno VARCHAR(20),
  materno VARCHAR(20),
  correo VARCHAR(50) NOT NULL UNIQUE,
  contrasena VARCHAR(30) NOT NULL ,
  semestre VARCHAR(2) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE profesor (
  id_prof INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  paterno VARCHAR(50),
  materno VARCHAR(50),
  correo VARCHAR(50) NOT NULL UNIQUE,
  rfc VARCHAR(13) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE salon (
  id_salon INT AUTO_INCREMENT PRIMARY KEY,
  nombre_salon VARCHAR(6) NOT NULL UNIQUE,
  capacidad INT NOT NULL,
  edificio VARCHAR(10) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE grupo (
  id_grupo INT AUTO_INCREMENT PRIMARY KEY,
  clave VARCHAR(5) NOT NULL UNIQUE,
  cupo INT NOT NULL
) ENGINE=InnoDB;

CREATE TABLE asignatura (
  id_asignatura INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  semestre VARCHAR(2) NOT NULL,
  creditos VARCHAR(2) NOT NULL,
  laboratorio BOOLEAN NOT NULL DEFAULT FALSE,
  optativa BOOLEAN NOT NULL DEFAULT FALSE
) ENGINE=InnoDB;

CREATE TABLE dia_semana (
  id_dia INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(10) NOT NULL UNIQUE
) ENGINE=InnoDB;

INSERT INTO dia_semana (nombre) VALUES 
('Lunes'), ('Martes'), ('Miércoles'), ('Jueves'), ('Viernes'), ('Sábado'), ('Domingo');

CREATE TABLE asignatura_grupo (
  id_asignatura_grupo INT AUTO_INCREMENT PRIMARY KEY,
  id_asignatura INT NOT NULL,
  id_grupo INT NOT NULL,
  id_profesor INT NOT NULL,
  FOREIGN KEY (id_asignatura) REFERENCES asignatura(id_asignatura) ON UPDATE CASCADE,
  FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON UPDATE CASCADE,
  FOREIGN KEY (id_profesor) REFERENCES profesor(id_prof) ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE horario (
  id_horario INT AUTO_INCREMENT PRIMARY KEY,
  id_asignatura_grupo INT NOT NULL,
  id_dia INT NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin TIME NOT NULL,
  id_salon INT NOT NULL,
  FOREIGN KEY (id_asignatura_grupo) REFERENCES asignatura_grupo(id_asignatura_grupo) ON UPDATE CASCADE,
  FOREIGN KEY (id_dia) REFERENCES dia_semana(id_dia) ON UPDATE CASCADE,
  FOREIGN KEY (id_salon) REFERENCES salon(id_salon) ON UPDATE CASCADE,
  CONSTRAINT chk_hora CHECK (hora_fin > hora_inicio)
) ENGINE=InnoDB;

CREATE TABLE inscripciones (
  id_inscripcion INT AUTO_INCREMENT PRIMARY KEY,
  id_alumno INT NOT NULL,
  id_asignatura_grupo INT NOT NULL,
  fecha_inscripcion DATETIME NOT NULL,
  FOREIGN KEY (id_alumno) REFERENCES alumno(id_alumno) ON UPDATE CASCADE,
  FOREIGN KEY (id_asignatura_grupo) REFERENCES asignatura_grupo(id_asignatura_grupo) ON UPDATE CASCADE
) ENGINE=InnoDB;

INSERT INTO alumno (num_cta, nombre, paterno, materno, correo, contrasena, semestre) VALUES
('317001245', 'Ana', 'Rodríguez', 'López', 'ana.rodriguez@alumno.ico.edu', 'Pass123A', '3'),
('317002367', 'Carlos', 'Martínez', 'García', 'carlos.martinez@alumno.ico.edu', 'Pass123C', '5'),
('317003489', 'Sofía', 'Hernández', 'Pérez', 'sofia.hernandez@alumno.ico.edu', 'Pass123S', '7'),
('317004590', 'Miguel', 'González', 'Sánchez', 'miguel.gonzalez@alumno.ico.edu', 'Pass123M', '3'),
('317005612', 'Laura', 'Ramírez', 'Torres', 'laura.ramirez@alumno.ico.edu', 'Pass123L', '5');

INSERT INTO profesor (nombre, paterno, materno, correo, rfc) VALUES
('Ricardo', 'Méndez', 'Valenzuela', 'ricardo.mendez@profesor.ico.edu', 'MEVR750612ABC'),
('Patricia', 'Flores', 'Morales', 'patricia.flores@profesor.ico.edu', 'FOMP680824DEF'),
('Javier', 'Castro', 'Ruiz', 'javier.castro@profesor.ico.edu', 'CARJ701130GHI'),
('Mónica', 'Vargas', 'Luna', 'monica.vargas@profesor.ico.edu', 'VALM630417JKL'),
('Eduardo', 'López', 'Gutiérrez', 'eduardo.lopez@profesor.ico.edu', 'LOGE720305MNO'),
('Silvia', 'Ortiz', 'Vega', 'silvia.ortiz@profesor.ico.edu', 'ORVS6509121PQ'),
('Daniel', 'Torres', 'Mendoza', 'daniel.torres@profesor.ico.edu', 'TOMD701223RST');

INSERT INTO salon (nombre_salon, capacidad, edificio) VALUES
('A101', 30, 'Edificio A'),
('A102', 25, 'Edificio A'),
('B201', 35, 'Edificio B'),
('B202', 30, 'Edificio B'),
('C301', 40, 'Edificio C'),
('C302', 35, 'Edificio C'),
('D401', 30, 'Edificio D');

INSERT INTO grupo (clave, cupo) VALUES
('1A', 30),
('1B', 30),
('2A', 35),
('2B', 35),
('3A', 30),
('3B', 30),
('4A', 35);

INSERT INTO asignatura (nombre, semestre, creditos, laboratorio, optativa) VALUES
('Matemáticas Discretas', '3', '8', FALSE, FALSE),
('Programación Orientada a Objetos', '3', '10', TRUE, FALSE),
('Estructura de Datos', '5', '10', TRUE, FALSE),
('Bases de Datos', '5', '8', TRUE, FALSE),
('Inteligencia Artificial', '7', '8', TRUE, FALSE),
('Redes de Computadoras', '5', '8', TRUE, FALSE),
('Sistemas Operativos', '5', '10', TRUE, FALSE);

INSERT INTO asignatura_grupo (id_asignatura, id_grupo, id_profesor) VALUES
(1, 1, 1), -- Matemáticas Discretas, Grupo 1A, Profesor Ricardo
(1, 2, 2), -- Matemáticas Discretas, Grupo 1B, Profesor Patricia
(2, 3, 3), -- POO, Grupo 2A, Profesor Javier
(2, 4, 4), -- POO, Grupo 2B, Profesor Mónica
(3, 5, 5), -- Estructura de Datos, Grupo 3A, Profesor Eduardo
(3, 6, 6), -- Estructura de Datos, Grupo 3B, Profesor Silvia
(4, 7, 7), -- Bases de Datos, Grupo 4A, Profesor Daniel
(4, 1, 1), -- Bases de Datos, Grupo 1A, Profesor Ricardo
(5, 2, 2), -- Inteligencia Artificial, Grupo 1B, Profesor Patricia
(5, 3, 3), -- Inteligencia Artificial, Grupo 2A, Profesor Javier
(6, 4, 4), -- Redes de Computadoras, Grupo 2B, Profesor Mónica
(6, 5, 5), -- Redes de Computadoras, Grupo 3A, Profesor Eduardo
(7, 6, 6), -- Sistemas Operativos, Grupo 3B, Profesor Silvia
(7, 7, 7); -- Sistemas Operativos, Grupo 4A, Profesor Daniel

INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
-- Matemáticas Discretas, Grupo 1A
(1, 2, '09:00:00', '11:00:00', 1), -- Martes 9-11, Salón A101
(1, 4, '09:00:00', '11:00:00', 1), -- Jueves 9-11, Salón A101

-- Matemáticas Discretas, Grupo 1B
(2, 3, '11:00:00', '13:00:00', 2), -- Miércoles 11-13, Salón A102
(2, 5, '11:00:00', '13:00:00', 2), -- Viernes 11-13, Salón A102

-- POO, Grupo 2A
(3, 1, '13:00:00', '15:00:00', 3), -- Lunes 13-15, Salón B201
(3, 3, '13:00:00', '15:00:00', 3), -- Miércoles 13-15, Salón B201

-- POO, Grupo 2B
(4, 2, '15:00:00', '17:00:00', 4), -- Martes 15-17, Salón B202
(4, 4, '15:00:00', '17:00:00', 4), -- Jueves 15-17, Salón B202

-- Estructura de Datos, Grupo 3A
(5, 1, '07:00:00', '09:00:00', 5), -- Lunes 7-9, Salón C301
(5, 5, '07:00:00', '09:00:00', 5), -- Viernes 7-9, Salón C301

-- Estructura de Datos, Grupo 3B
(6, 2, '13:00:00', '15:00:00', 6), -- Martes 13-15, Salón C302
(6, 4, '13:00:00', '15:00:00', 6), -- Jueves 13-15, Salón C302

-- Bases de Datos, Grupo 4A
(7, 1, '09:00:00', '11:00:00', 7), -- Lunes 9-11, Salón D401
(7, 3, '09:00:00', '11:00:00', 7), -- Miércoles 9-11, Salón D401

-- Bases de Datos, Grupo 1A
(8, 2, '11:00:00', '13:00:00', 1), -- Martes 11-13, Salón A101
(8, 4, '11:00:00', '13:00:00', 1), -- Jueves 11-13, Salón A101

-- Inteligencia Artificial, Grupo 1B
(9, 1, '15:00:00', '17:00:00', 2), -- Lunes 15-17, Salón A102
(9, 3, '15:00:00', '17:00:00', 2), -- Miércoles 15-17, Salón A102

-- Inteligencia Artificial, Grupo 2A
(10, 2, '07:00:00', '09:00:00', 3), -- Martes 7-9, Salón B201
(10, 4, '07:00:00', '09:00:00', 3), -- Jueves 7-9, Salón B201

-- Redes de Computadoras, Grupo 2B
(11, 1, '11:00:00', '13:00:00', 4), -- Lunes 11-13, Salón B202
(11, 5, '11:00:00', '13:00:00', 4), -- Viernes 11-13, Salón B202

-- Redes de Computadoras, Grupo 3A
(12, 3, '07:00:00', '09:00:00', 5), -- Miércoles 7-9, Salón C301
(12, 5, '09:00:00', '11:00:00', 5), -- Viernes 9-11, Salón C301

-- Sistemas Operativos, Grupo 3B
(13, 1, '17:00:00', '19:00:00', 6), -- Lunes 17-19, Salón C302
(13, 3, '17:00:00', '19:00:00', 6), -- Miércoles 17-19, Salón C302

-- Sistemas Operativos, Grupo 4A
(14, 2, '17:00:00', '19:00:00', 7), -- Martes 17-19, Salón D401
(14, 4, '17:00:00', '19:00:00', 7); -- Jueves 17-19, Salón D401



INSERT INTO inscripciones (id_alumno, id_asignatura_grupo, fecha_inscripcion) VALUES
-- Alumno 1 (Ana Rodríguez)
(1, 1, '2024-08-10 09:15:00'), -- Matemáticas Discretas, Grupo 1A
(1, 3, '2024-08-10 09:20:00'), -- POO, Grupo 2A
(1, 5, '2024-08-10 09:25:00'), -- Estructura de Datos, Grupo 3A
(1, 7, '2024-08-10 09:30:00'), -- Bases de Datos, Grupo 4A
(1, 9, '2024-08-10 09:35:00'), -- Inteligencia Artificial, Grupo 1B

-- Alumno 2 (Carlos Martínez)
(2, 2, '2024-08-10 10:15:00'), -- Matemáticas Discretas, Grupo 1B
(2, 4, '2024-08-10 10:20:00'), -- POO, Grupo 2B
(2, 6, '2024-08-10 10:25:00'), -- Estructura de Datos, Grupo 3B
(2, 8, '2024-08-10 10:30:00'), -- Bases de Datos, Grupo 1A
(2, 10, '2024-08-10 10:35:00'), -- Inteligencia Artificial, Grupo 2A

-- Alumno 3 (Sofía Hernández)
(3, 1, '2024-08-10 11:15:00'), -- Matemáticas Discretas, Grupo 1A
(3, 4, '2024-08-10 11:20:00'), -- POO, Grupo 2B
(3, 5, '2024-08-10 11:25:00'), -- Estructura de Datos, Grupo 3A
(3, 11, '2024-08-10 11:30:00'), -- Redes de Computadoras, Grupo 2B
(3, 13, '2024-08-10 11:35:00'), -- Sistemas Operativos, Grupo 3B

-- Alumno 4 (Miguel González)
(4, 2, '2024-08-10 12:15:00'), -- Matemáticas Discretas, Grupo 1B
(4, 3, '2024-08-10 12:20:00'), -- POO, Grupo 2A
(4, 6, '2024-08-10 12:25:00'), -- Estructura de Datos, Grupo 3B
(4, 12, '2024-08-10 12:30:00'), -- Redes de Computadoras, Grupo 3A
(4, 14, '2024-08-10 12:35:00'), -- Sistemas Operativos, Grupo 4A

-- Alumno 5 (Laura Ramírez)
(5, 1, '2024-08-10 13:15:00'), -- Matemáticas Discretas, Grupo 1A
(5, 4, '2024-08-10 13:20:00'), -- POO, Grupo 2B
(5, 6, '2024-08-10 13:25:00'), -- Estructura de Datos, Grupo 3B
(5, 9, '2024-08-10 13:30:00'), -- Inteligencia Artificial, Grupo 1B
(5, 14, '2024-08-10 13:35:00'); -- Sistemas Operativos, Grupo 4A

DELIMITER //
CREATE TRIGGER decrementar_cupo_after_insert
AFTER INSERT ON inscripciones
FOR EACH ROW
BEGIN
    DECLARE grupo_id INT;
    
    -- Obtener el id_grupo asociado a la asignatura_grupo
    SELECT id_grupo INTO grupo_id
    FROM asignatura_grupo
    WHERE id_asignatura_grupo = NEW.id_asignatura_grupo;
    
    -- Decrementar el cupo del grupo
    UPDATE grupo
    SET cupo = cupo - 1
    WHERE id_grupo = grupo_id;
END //
DELIMITER ;

-- Trigger para incrementar cupo cuando se da de baja un alumno
DELIMITER //
CREATE TRIGGER incrementar_cupo_after_delete
AFTER DELETE ON inscripciones
FOR EACH ROW
BEGIN
    DECLARE grupo_id INT;
    
    -- Obtener el id_grupo asociado a la asignatura_grupo
    SELECT id_grupo INTO grupo_id
    FROM asignatura_grupo
    WHERE id_asignatura_grupo = OLD.id_asignatura_grupo;
    
    -- Incrementar el cupo del grupo
    UPDATE grupo
    SET cupo = cupo + 1
    WHERE id_grupo = grupo_id;
END //
DELIMITER ;

/*
-- 1. Query para verificar que cada alumno inscribió exactamente 5 materias
SELECT 
    a.id_alumno,
    CONCAT(a.nombre, ' ', a.paterno, ' ', a.materno) AS nombre_completo,
    COUNT(i.id_inscripcion) AS materias_inscritas
FROM 
    alumno a
LEFT JOIN 
    inscripciones i ON a.id_alumno = i.id_alumno
GROUP BY 
    a.id_alumno, nombre_completo
ORDER BY 
    a.id_alumno;

-- 2. Query para mostrar las materias y grupos en los que está inscrito cada alumno
SELECT 
    a.id_alumno,
    CONCAT(a.nombre, ' ', a.paterno, ' ', a.materno) AS nombre_alumno,
    asig.nombre AS nombre_materia,
    g.clave AS grupo,
    CONCAT(p.nombre, ' ', p.paterno) AS nombre_profesor
FROM 
    alumno a
JOIN 
    inscripciones i ON a.id_alumno = i.id_alumno
JOIN 
    asignatura_grupo ag ON i.id_asignatura_grupo = ag.id_asignatura_grupo
JOIN 
    asignatura asig ON ag.id_asignatura = asig.id_asignatura
JOIN 
    grupo g ON ag.id_grupo = g.id_grupo
JOIN 
    profesor p ON ag.id_profesor = p.id_prof
ORDER BY 
    a.id_alumno, asig.nombre;

-- 3. Query para verificar que cada materia inscrita tiene al menos 2 horarios
SELECT 
    a.id_alumno,
    CONCAT(a.nombre, ' ', a.paterno) AS nombre_alumno,
    asig.nombre AS materia,
    g.clave AS grupo,
    COUNT(h.id_horario) AS cantidad_sesiones
FROM 
    alumno a
JOIN 
    inscripciones i ON a.id_alumno = i.id_alumno
JOIN 
    asignatura_grupo ag ON i.id_asignatura_grupo = ag.id_asignatura_grupo
JOIN 
    asignatura asig ON ag.id_asignatura = asig.id_asignatura
JOIN 
    grupo g ON ag.id_grupo = g.id_grupo
JOIN 
    horario h ON ag.id_asignatura_grupo = h.id_asignatura_grupo
GROUP BY 
    a.id_alumno, nombre_alumno, asig.nombre, g.clave
ORDER BY 
    a.id_alumno, asig.nombre;

-- 4. Query para mostrar detalle completo de horarios de cada alumno
SELECT 
    a.id_alumno,
    CONCAT(a.nombre, ' ', a.paterno, ' ', a.materno) AS nombre_alumno,
    asig.nombre AS materia,
    g.clave AS grupo,
    ds.nombre AS dia,
    TIME_FORMAT(h.hora_inicio, '%H:%i') AS hora_inicio,
    TIME_FORMAT(h.hora_fin, '%H:%i') AS hora_fin,
    s.nombre_salon AS salon,
    s.edificio
FROM 
    alumno a
JOIN 
    inscripciones i ON a.id_alumno = i.id_alumno
JOIN 
    asignatura_grupo ag ON i.id_asignatura_grupo = ag.id_asignatura_grupo
JOIN 
    asignatura asig ON ag.id_asignatura = asig.id_asignatura
JOIN 
    grupo g ON ag.id_grupo = g.id_grupo
JOIN 
    horario h ON ag.id_asignatura_grupo = h.id_asignatura_grupo
JOIN 
    dia_semana ds ON h.id_dia = ds.id_dia
JOIN 
    salon s ON h.id_salon = s.id_salon
ORDER BY 
    a.id_alumno, asig.nombre, ds.id_dia, h.hora_inicio;

-- 5. Query para verificar si hay posibles traslapes de horarios para cada alumno
SELECT 
    a.id_alumno,
    CONCAT(a.nombre, ' ', a.paterno) AS nombre_alumno,
    ds.nombre AS dia,
    h1.hora_inicio AS inicio1,
    h1.hora_fin AS fin1,
    asig1.nombre AS materia1,
    h2.hora_inicio AS inicio2,
    h2.hora_fin AS fin2,
    asig2.nombre AS materia2
FROM 
    alumno a
JOIN 
    inscripciones i1 ON a.id_alumno = i1.id_alumno
JOIN 
    asignatura_grupo ag1 ON i1.id_asignatura_grupo = ag1.id_asignatura_grupo
JOIN 
    horario h1 ON ag1.id_asignatura_grupo = h1.id_asignatura_grupo
JOIN 
    dia_semana ds ON h1.id_dia = ds.id_dia
JOIN 
    asignatura asig1 ON ag1.id_asignatura = asig1.id_asignatura
JOIN 
    inscripciones i2 ON a.id_alumno = i2.id_alumno AND i1.id_inscripcion != i2.id_inscripcion
JOIN 
    asignatura_grupo ag2 ON i2.id_asignatura_grupo = ag2.id_asignatura_grupo
JOIN 
    horario h2 ON ag2.id_asignatura_grupo = h2.id_asignatura_grupo AND h1.id_dia = h2.id_dia
JOIN 
    asignatura asig2 ON ag2.id_asignatura = asig2.id_asignatura
WHERE 
    -- Condición para detectar traslapes
    ((h1.hora_inicio < h2.hora_fin) AND (h1.hora_fin > h2.hora_inicio))
ORDER BY 
    a.id_alumno, ds.id_dia, h1.hora_inicio;

-- 6. Query para ver cuántos salones diferentes visita cada alumno
SELECT 
    a.id_alumno,
    CONCAT(a.nombre, ' ', a.paterno, ' ', a.materno) AS nombre_alumno,
    COUNT(DISTINCT s.id_salon) AS cantidad_salones_diferentes,
    GROUP_CONCAT(DISTINCT s.nombre_salon ORDER BY s.nombre_salon) AS salones
FROM 
    alumno a
JOIN 
    inscripciones i ON a.id_alumno = i.id_alumno
JOIN 
    asignatura_grupo ag ON i.id_asignatura_grupo = ag.id_asignatura_grupo
JOIN 
    horario h ON ag.id_asignatura_grupo = h.id_asignatura_grupo
JOIN 
    salon s ON h.id_salon = s.id_salon
GROUP BY 
    a.id_alumno, nombre_alumno
ORDER BY 
    a.id_alumno;

-- 7. Query para ver el horario semanal completo de un alumno específico (ejemplo: alumno con id 1)
SELECT 
    ds.nombre AS dia,
    TIME_FORMAT(h.hora_inicio, '%H:%i') AS hora_inicio,
    TIME_FORMAT(h.hora_fin, '%H:%i') AS hora_fin,
    asig.nombre AS materia,
    g.clave AS grupo,
    s.nombre_salon AS salon,
    CONCAT(p.nombre, ' ', p.paterno) AS profesor
FROM 
    dia_semana ds
LEFT JOIN 
    horario h ON ds.id_dia = h.id_dia
LEFT JOIN 
    asignatura_grupo ag ON h.id_asignatura_grupo = ag.id_asignatura_grupo
LEFT JOIN 
    inscripciones i ON ag.id_asignatura_grupo = i.id_asignatura_grupo AND i.id_alumno = 1
LEFT JOIN 
    asignatura asig ON ag.id_asignatura = asig.id_asignatura
LEFT JOIN 
    grupo g ON ag.id_grupo = g.id_grupo
LEFT JOIN 
    salon s ON h.id_salon = s.id_salon
LEFT JOIN 
    profesor p ON ag.id_profesor = p.id_prof
WHERE 
    i.id_inscripcion IS NOT NULL
ORDER BY 
    ds.id_dia, h.hora_inicio;
    */