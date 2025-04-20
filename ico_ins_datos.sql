DROP DATABASE IF EXISTS ico_ins;
CREATE DATABASE ico_ins;
USE ico_ins;

CREATE TABLE alumno (
  id_alumno      INT AUTO_INCREMENT PRIMARY KEY,
  num_cta        VARCHAR(10) NOT NULL UNIQUE,
  nombre         VARCHAR(50) NOT NULL,
  paterno        VARCHAR(20),
  materno        VARCHAR(20),
  correo         VARCHAR(50) NOT NULL UNIQUE,
  contrasena     VARCHAR(30) NOT NULL,
  semestre       VARCHAR(2) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE profesor (
  id_prof        INT AUTO_INCREMENT PRIMARY KEY,
  nombre         VARCHAR(50) NOT NULL,
  paterno        VARCHAR(50),
  materno        VARCHAR(50),
  correo         VARCHAR(50) NOT NULL UNIQUE,
  rfc            VARCHAR(13) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE salon (
  id_salon       INT AUTO_INCREMENT PRIMARY KEY,
  nombre_salon   VARCHAR(6) NOT NULL UNIQUE,
  capacidad      INT NOT NULL,
  edificio       VARCHAR(10) NOT NULL
) ENGINE=InnoDB;

-- Se elimina la columna 'clave' de grupo
CREATE TABLE grupo (
  id_grupo       INT AUTO_INCREMENT PRIMARY KEY,
  cupo           INT NOT NULL
) ENGINE=InnoDB;

-- Ahora cada asignatura tiene su propia 'clave'
CREATE TABLE asignatura (
  id_asignatura  INT AUTO_INCREMENT PRIMARY KEY,
  clave          VARCHAR(5) NOT NULL UNIQUE,
  nombre         VARCHAR(50) NOT NULL,
  semestre       VARCHAR(2) NOT NULL,
  creditos       VARCHAR(2) NOT NULL,
  laboratorio    BOOLEAN NOT NULL DEFAULT FALSE,
  optativa       BOOLEAN NOT NULL DEFAULT FALSE
) ENGINE=InnoDB;

CREATE TABLE dia_semana (
  id_dia         INT AUTO_INCREMENT PRIMARY KEY,
  nombre         VARCHAR(10) NOT NULL UNIQUE
) ENGINE=InnoDB;

INSERT INTO dia_semana (nombre) VALUES 
  ('Lunes'), ('Martes'), ('Miércoles'), ('Jueves'), ('Viernes'), ('Sábado'), ('Domingo');

CREATE TABLE asignatura_grupo (
  id_asignatura_grupo INT AUTO_INCREMENT PRIMARY KEY,
  id_asignatura       INT NOT NULL,
  id_grupo            INT NOT NULL,
  id_profesor         INT NOT NULL,
  FOREIGN KEY (id_asignatura) REFERENCES asignatura(id_asignatura) ON UPDATE CASCADE,
  FOREIGN KEY (id_grupo)      REFERENCES grupo(id_grupo)       ON UPDATE CASCADE,
  FOREIGN KEY (id_profesor)   REFERENCES profesor(id_prof)     ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE horario (
  id_horario      INT AUTO_INCREMENT PRIMARY KEY,
  id_asignatura_grupo INT NOT NULL,
  id_dia          INT NOT NULL,
  hora_inicio     TIME NOT NULL,
  hora_fin        TIME NOT NULL,
  id_salon        INT NOT NULL,
  FOREIGN KEY (id_asignatura_grupo) REFERENCES asignatura_grupo(id_asignatura_grupo) ON UPDATE CASCADE,
  FOREIGN KEY (id_dia)            REFERENCES dia_semana(id_dia) ON UPDATE CASCADE,
  FOREIGN KEY (id_salon)          REFERENCES salon(id_salon)   ON UPDATE CASCADE,
  CONSTRAINT chk_hora CHECK (hora_fin > hora_inicio)
) ENGINE=InnoDB;

CREATE TABLE inscripciones (
  id_inscripcion INT AUTO_INCREMENT PRIMARY KEY,
  id_alumno      INT NOT NULL,
  id_asignatura_grupo INT NOT NULL,
  fecha_inscripcion   DATETIME NOT NULL,
  FOREIGN KEY (id_alumno)            REFERENCES alumno(id_alumno)            ON UPDATE CASCADE,
  FOREIGN KEY (id_asignatura_grupo)  REFERENCES asignatura_grupo(id_asignatura_grupo) ON UPDATE CASCADE
) ENGINE=InnoDB;

DELIMITER //
CREATE TRIGGER decrementar_cupo_after_insert
AFTER INSERT ON inscripciones
FOR EACH ROW
BEGIN
    DECLARE g INT;
    SELECT id_grupo INTO g
      FROM asignatura_grupo
     WHERE id_asignatura_grupo = NEW.id_asignatura_grupo;
    UPDATE grupo
       SET cupo = cupo - 1
     WHERE id_grupo = g;
END;
//
CREATE TRIGGER incrementar_cupo_after_delete
AFTER DELETE ON inscripciones
FOR EACH ROW
BEGIN
    DECLARE g INT;
    SELECT id_grupo INTO g
      FROM asignatura_grupo
     WHERE id_asignatura_grupo = OLD.id_asignatura_grupo;
    UPDATE grupo
       SET cupo = cupo + 1
     WHERE id_grupo = g;
END;
//
DELIMITER ;


-- 10 ALUMNOS
INSERT INTO alumno (num_cta, nombre, paterno, materno, correo, contrasena, semestre) VALUES
('317001001','Luis',   'Pérez',   'García',   'luis.perez@aragon.unam.mx',    'Pwd1234', '1'),
('317001002','María',  'López',   'Hernández','maria.lopez@aragon.unam.mx',   'Pass234', '2'),
('317001003','Juan',   'González','Martínez', 'juan.gonzalez@aragon.unam.mx', 'ABC123',  '3'),
('317001004','Ana',    'Ramírez', 'Torres',   'ana.ramirez@aragon.unam.mx',   'xyz789',  '4'),
('317001005','Carlos', 'Flores',  'Vega',     'carlos.flores@aragon.unam.mx', 'Stu456',  '5'),
('317001006','Sofía',  'Morales', 'Reyes',    'sofia.morales@aragon.unam.mx', 'Data321', '6'),
('317001007','Miguel', 'Sánchez', 'Díaz',     'miguel.sanchez@aragon.unam.mx','Key999',  '7'),
('317001008','Laura',  'Ortiz',   'Ramos',    'laura.ortiz@aragon.unam.mx',   'Qwe567',  '8'),
('317001009','Daniel', 'Vargas',  'Castro',   'daniel.vargas@aragon.unam.mx', 'Zxc234',  '9'),
('317001010','Lucía',  'Torres',  'Pérez',    'lucia.torres@aragon.unam.mx',  'Abc987',  '9');

-- 10 PROFESORES
INSERT INTO profesor (nombre, paterno, materno, correo, rfc) VALUES
('Luis',    'Méndez',    'Gómez',   'luis.mendez@aragon.unam.mx',    'MEML850101ABC'),
('Ana',     'Ramírez',   'Sánchez', 'ana.ramirez@aragon.unam.mx',    'RASA900203DEF'),
('Carlos',  'Torres',    'Morales', 'carlos.torres@aragon.unam.mx',  'TOMA820305GHI'),
('Isabel',  'López',     'Vega',    'isabel.lopez@aragon.unam.mx',   'LOVI780612JKL'),
('Javier',  'Hernández', 'Pérez',   'javier.hernandez@aragon.unam.mx','HEPJ750730MNO'),
('María',   'Ortiz',     'Ruiz',    'maria.ortiz@aragon.unam.mx',     'ORUM690101PQR'),
('Ricardo', 'Castro',    'Díaz',    'ricardo.castro@aragon.unam.mx',  'CADR880815STU'),
('Mónica',  'González',  'Torres',  'monica.gonzalez@aragon.unam.mx','GIMO770920VWX'),
('Patricia','Flores',    'Morales', 'patricia.flores@aragon.unam.mx','FOMP860430YZA'),
('Eduardo', 'Sánchez',   'Ramírez', 'eduardo.sanchez@aragon.unam.mx','SARJ810515BCD');

-- 20 SALONES
INSERT INTO salon (nombre_salon, capacidad, edificio) VALUES
('A101',40,'Edificio A'),('A102',35,'Edificio A'),('A103',50,'Edificio A'),
('A104',45,'Edificio A'),('A105',60,'Edificio A'),('A106',30,'Edificio A'),
('A107',55,'Edificio A'),('A108',38,'Edificio A'),('A109',42,'Edificio A'),
('A110',47,'Edificio A'),('A111',36,'Edificio A'),('A201',50,'Edificio A'),
('A202',32,'Edificio A'),('A203',58,'Edificio A'),('A204',29,'Edificio A'),
('A205',40,'Edificio A'),('A206',33,'Edificio A'),('A207',56,'Edificio A'),
('A208',39,'Edificio A'),('A209',44,'Edificio A');

-- 9 GRUPOS (sólo cupo)
INSERT INTO grupo (cupo) VALUES
(50),(45),(60),(30),(55),(35),(40),(60),(50);

-- 54 ASIGNATURAS con clave en lugar de grupo
INSERT INTO asignatura (clave, nombre, semestre, creditos, laboratorio, optativa) VALUES
-- Semestre 1
('1001','Cálculo I','1','8',FALSE,FALSE),
('1002','Álgebra Lineal','1','8',FALSE,FALSE),
('1003','Química General','1','7',TRUE,FALSE),
('1004','Introducción a la Programación','1','10',TRUE,FALSE),
('1005','Comunicación Oral y Escrita','1','6',FALSE,FALSE),
('1006','Ética y Sociedad','1','6',FALSE,FALSE),
-- Semestre 2
('1007','Cálculo II','2','8',FALSE,FALSE),
('1008','Física I','2','7',TRUE,FALSE),
('1009','Programación Avanzada','2','10',TRUE,FALSE),
('1010','Estructuras de Datos Básicas','2','8',TRUE,FALSE),
('1011','Matemáticas Discretas','2','8',FALSE,FALSE),
('1012','Historia de la Ciencia y Tecnología','2','6',FALSE,FALSE),
-- Semestre 3
('1013','Estructura de Datos','3','10',TRUE,FALSE),
('1014','Física II','3','7',TRUE,FALSE),
('1015','Fundamentos de Base de Datos','3','8',TRUE,FALSE),
('1016','Circuitos Eléctricos','3','8',TRUE,FALSE),
('1017','Probabilidad y Estadística','3','8',FALSE,FALSE),
('1018','Sistemas Digitales','3','8',TRUE,FALSE),
-- Semestre 4
('1019','Programación Orientada a Objetos','4','10',TRUE,FALSE),
('1020','Electrónica Analógica','4','8',TRUE,FALSE),
('1021','Análisis de Algoritmos','4','8',FALSE,FALSE),
('1022','Teoría de la Computación','4','8',FALSE,FALSE),
('1023','Administración de Proyectos','4','6',FALSE,FALSE),
('1024','Señales y Sistemas','4','8',TRUE,FALSE),
-- Semestre 5
('1025','Bases de Datos Avanzadas','5','8',TRUE,FALSE),
('1026','Redes de Computadoras','5','8',TRUE,FALSE),
('1027','Sistemas Operativos','5','10',TRUE,FALSE),
('1028','Compiladores','5','8',FALSE,FALSE),
('1029','Inteligencia Artificial','5','8',TRUE,FALSE),
('1030','Lenguajes de Programación','5','8',FALSE,FALSE),
-- Semestre 6
('1031','Ingeniería de Software','6','8',FALSE,FALSE),
('1032','Arquitectura de Computadoras','6','8',FALSE,FALSE),
('1033','Seguridad Informática','6','8',TRUE,FALSE),
('1034','Interacción Humano-Computadora','6','6',FALSE,FALSE),
('1035','Gestión de Datos Masivos','6','8',FALSE,FALSE),
('1036','Sistemas Distribuidos','6','8',TRUE,FALSE),
-- Semestre 7
('1037','Inteligencia de Negocios','7','6',FALSE,FALSE),
('1038','Aprendizaje Automático','7','8',TRUE,FALSE),
('1039','Computación en la Nube','7','6',FALSE,FALSE),
('1040','Robótica','7','8',TRUE,FALSE),
('1041','Modelado y Simulación','7','6',FALSE,FALSE),
('1042','Minería de Datos','7','8',TRUE,FALSE),
-- Semestre 8
('1043','Sistemas Embebidos','8','8',TRUE,FALSE),
('1044','Visión por Computadora','8','8',TRUE,FALSE),
('1045','Procesamiento de Lenguaje Natural','8','8',TRUE,FALSE),
('1046','Topología de Redes','8','6',FALSE,FALSE),
('1047','Gestión de Proyectos de TI','8','6',FALSE,FALSE),
('1048','Ética Profesional','8','6',FALSE,FALSE),
-- Semestre 9
('1049','Seminario de Titulación','9','6',FALSE,FALSE),
('1050','Práctica Profesional','9','8',FALSE,FALSE),
('1051','Proyecto de Ingeniería de Computación','9','10',FALSE,FALSE),
('1052','Emprendimiento Tecnológico','9','6',FALSE,FALSE),
('1053','Tecnologías Emergentes','9','6',FALSE,FALSE),
('1054','Administración de Calidad','9','6',FALSE,FALSE);

-- 54 ASIGNATURAS → GRUPOS → PROFESORES (uno por semestre)
INSERT INTO asignatura_grupo (id_asignatura, id_grupo, id_profesor) VALUES
-- Grupo 1 (semestre 1)
( 1,  1,  1),( 2,  1,  2),( 3,  1,  3),( 4,  1,  4),( 5,  1,  5),( 6,  1,  6),
-- Grupo 2 (semestre 2)
( 7,  2,  7),( 8,  2,  8),( 9,  2,  9),(10,  2, 10),(11,  2,  1),(12,  2,  2),
-- Grupo 3 (semestre 3)
(13,  3,  3),(14,  3,  4),(15,  3,  5),(16,  3,  6),(17,  3,  7),(18,  3,  8),
-- Grupo 4 (semestre 4)
(19,  4,  9),(20,  4, 10),(21,  4,  1),(22,  4,  2),(23,  4,  3),(24,  4,  4),
-- Grupo 5 (semestre 5)
(25,  5,  5),(26,  5,  6),(27,  5,  7),(28,  5,  8),(29,  5,  9),(30,  5, 10),
-- Grupo 6 (semestre 6)
(31,  6,  1),(32,  6,  2),(33,  6,  3),(34,  6,  4),(35,  6,  5),(36,  6,  6),
-- Grupo 7 (semestre 7)
(37,  7,  7),(38,  7,  8),(39,  7,  9),(40,  7, 10),(41,  7,  1),(42,  7,  2),
-- Grupo 8 (semestre 8)
(43,  8,  3),(44,  8,  4),(45,  8,  5),(46,  8,  6),(47,  8,  7),(48,  8,  8),
-- Grupo 9 (semestre 9)
(49,  9,  9),(50,  9, 10),(51,  9,  1),(52,  9,  2),(53,  9,  3),(54,  9,  4);

-- HORARIOS (combinando materias de 2 y 3 días, sin choques de salón)
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
-- Grupo 1 (IDs 1–6)
( 1, 1, '08:00:00', '10:00:00',  1),( 1, 3, '08:00:00', '10:00:00',  1),
( 2, 2, '08:00:00', '10:00:00',  2),( 2, 4, '08:00:00', '10:00:00',  2),
( 3, 3, '08:00:00', '10:00:00',  3),( 3, 5, '08:00:00', '10:00:00',  3),
( 4, 1, '10:00:00', '11:30:00',  4),( 4, 3, '10:00:00', '11:30:00',  4),( 4, 5, '10:00:00', '11:30:00',  4),
( 5, 2, '10:00:00', '11:30:00',  5),( 5, 4, '10:00:00', '11:30:00',  5),( 5, 5, '10:00:00', '11:30:00',  5),
( 6, 1, '12:00:00', '13:30:00',  6),( 6, 3, '12:00:00', '13:30:00',  6),( 6, 5, '12:00:00', '13:30:00',  6),

-- Grupo 2 (IDs 7–12)
( 7, 1, '10:00:00', '12:00:00',  7),( 7, 3, '10:00:00', '12:00:00',  7),
( 8, 2, '10:00:00', '12:00:00',  8),( 8, 4, '10:00:00', '12:00:00',  8),
( 9, 3, '10:00:00', '12:00:00',  9),( 9, 5, '10:00:00', '12:00:00',  9),
(10, 1, '12:00:00', '13:30:00', 10),(10, 3, '12:00:00', '13:30:00', 10),(10, 5, '12:00:00', '13:30:00', 10),
(11, 2, '12:00:00', '13:30:00', 11),(11, 4, '12:00:00', '13:30:00', 11),(11, 5, '12:00:00', '13:30:00', 11),
(12, 1, '14:00:00', '15:30:00', 12),(12, 3, '14:00:00', '15:30:00', 12),(12, 5, '14:00:00', '15:30:00', 12),

-- Grupo 3 (IDs 13–18)
(13, 1, '08:00:00', '10:00:00', 13),(13, 3, '08:00:00', '10:00:00', 13),
(14, 2, '08:00:00', '10:00:00', 14),(14, 4, '08:00:00', '10:00:00', 14),
(15, 3, '08:00:00', '10:00:00', 15),(15, 5, '08:00:00', '10:00:00', 15),
(16, 1, '10:00:00', '11:30:00', 16),(16, 3, '10:00:00', '11:30:00', 16),(16, 5, '10:00:00', '11:30:00', 16),
(17, 2, '10:00:00', '11:30:00', 17),(17, 4, '10:00:00', '11:30:00', 17),(17, 5, '10:00:00', '11:30:00', 17),
(18, 1, '12:00:00', '13:30:00', 18),(18, 3, '12:00:00', '13:30:00', 18),(18, 5, '12:00:00', '13:30:00', 18),

-- Grupo 4 (IDs 19–24)
(19, 1, '12:00:00', '14:00:00', 19),(19, 3, '12:00:00', '14:00:00', 19),
(20, 2, '12:00:00', '14:00:00', 20),(20, 4, '12:00:00', '14:00:00', 20),
(21, 3, '12:00:00', '14:00:00',  1),(21, 5, '12:00:00', '14:00:00',  1),
(22, 1, '14:00:00', '16:00:00',  2),(22, 3, '14:00:00', '16:00:00',  2),
(23, 2, '14:00:00', '16:00:00',  3),(23, 4, '14:00:00', '16:00:00',  3),
(24, 1, '16:00:00', '17:30:00',  4),(24, 3, '16:00:00', '17:30:00',  4),(24, 5, '16:00:00', '17:30:00',  4),

-- Grupo 5 (IDs 25–30)
(25, 1, '16:00:00', '18:00:00',  5),(25, 3, '16:00:00', '18:00:00',  5),
(26, 2, '16:00:00', '18:00:00',  6),(26, 4, '16:00:00', '18:00:00',  6),
(27, 3, '16:00:00', '18:00:00',  7),(27, 5, '16:00:00', '18:00:00',  7),
(28, 1, '18:00:00', '20:00:00',  8),(28, 3, '18:00:00', '20:00:00',  8),
(29, 2, '18:00:00', '20:00:00',  9),(29, 4, '18:00:00', '20:00:00',  9),
(30, 1, '08:00:00', '09:30:00', 10),(30, 3, '08:00:00', '09:30:00', 10),(30, 5, '08:00:00', '09:30:00', 10),

-- Grupo 6 (IDs 31–36)
(31, 1, '08:00:00', '10:00:00', 11),(31, 3, '08:00:00', '10:00:00', 11),
(32, 2, '08:00:00', '10:00:00', 12),(32, 4, '08:00:00', '10:00:00', 12),
(33, 3, '08:00:00', '10:00:00', 13),(33, 5, '08:00:00', '10:00:00', 13),
(34, 1, '10:00:00', '12:00:00', 14),(34, 3, '10:00:00', '12:00:00', 14),
(35, 2, '10:00:00', '12:00:00', 15),(35, 4, '10:00:00', '12:00:00', 15),
(36, 1, '12:00:00', '13:30:00', 16),(36, 3, '12:00:00', '13:30:00', 16),(36, 5, '12:00:00', '13:30:00', 16),

-- Grupo 7 (IDs 37–42)
(37, 1, '12:00:00', '14:00:00', 17),(37, 3, '12:00:00', '14:00:00', 17),
(38, 2, '12:00:00', '14:00:00', 18),(38, 4, '12:00:00', '14:00:00', 18),
(39, 3, '12:00:00', '14:00:00', 19),(39, 5, '12:00:00', '14:00:00', 19),
(40, 1, '14:00:00', '16:00:00', 20),(40, 3, '14:00:00', '16:00:00', 20),
(41, 2, '14:00:00', '16:00:00',  1),(41, 4, '14:00:00', '16:00:00',  1),
(42, 1, '16:00:00', '17:30:00',  2),(42, 3, '16:00:00', '17:30:00',  2),(42, 5, '16:00:00', '17:30:00',  2),

-- Grupo 8 (IDs 43–48)
(43, 1, '16:00:00', '18:00:00',  3),(43, 3, '16:00:00', '18:00:00',  3),
(44, 2, '16:00:00', '18:00:00',  4),(44, 4, '16:00:00', '18:00:00',  4),
(45, 3, '16:00:00', '18:00:00',  5),(45, 5, '16:00:00', '18:00:00',  5),
(46, 1, '18:00:00', '20:00:00',  6),(46, 3, '18:00:00', '20:00:00',  6),
(47, 2, '18:00:00', '20:00:00',  7),(47, 4, '18:00:00', '20:00:00',  7),
(48, 1, '08:00:00', '09:30:00',  8),(48, 3, '08:00:00', '09:30:00',  8),(48, 5, '08:00:00', '09:30:00',  8),

-- Grupo 9 (IDs 49–54)
(49, 1, '08:00:00', '10:00:00',  9),(49, 3, '08:00:00', '10:00:00',  9),
(50, 2, '08:00:00', '10:00:00', 10),(50, 4, '08:00:00', '10:00:00', 10),
(51, 3, '08:00:00', '10:00:00', 11),(51, 5, '08:00:00', '10:00:00', 11),
(52, 1, '10:00:00', '11:30:00', 12),(52, 3, '10:00:00', '11:30:00', 12),(52, 5, '10:00:00', '11:30:00', 12),
(53, 2, '10:00:00', '11:30:00', 13),(53, 4, '10:00:00', '11:30:00', 13),(53, 5, '10:00:00', '11:30:00', 13),
(54, 1, '12:00:00', '13:30:00', 14),(54, 3, '12:00:00', '13:30:00', 14),(54, 5, '12:00:00', '13:30:00', 14);

-- INSCRIPCIONES
INSERT INTO inscripciones (id_alumno, id_asignatura_grupo, fecha_inscripcion) VALUES
-- Los primeros 5 alumnos sólo 1 materia
( 1,  1, '2024-08-15 08:00:00'),
( 2,  7, '2024-08-15 08:05:00'),
( 3, 13, '2024-08-15 08:10:00'),
( 4, 19, '2024-08-15 08:15:00'),
( 5, 25, '2024-08-15 08:20:00'),
-- Los siguientes 5 con todas las materias de su semestre
-- Alumno 6 (semestre 6 → IDs 31–36)
( 6, 31, '2024-08-15 09:00:00'),( 6, 32, '2024-08-15 09:05:00'),
( 6, 33, '2024-08-15 09:10:00'),( 6, 34, '2024-08-15 09:15:00'),
( 6, 35, '2024-08-15 09:20:00'),( 6, 36, '2024-08-15 09:25:00'),
-- Alumno 7 (semestre 7 → IDs 37–42)
( 7, 37, '2024-08-15 10:00:00'),( 7, 38, '2024-08-15 10:05:00'),
( 7, 39, '2024-08-15 10:10:00'),( 7, 40, '2024-08-15 10:15:00'),
( 7, 41, '2024-08-15 10:20:00'),( 7, 42, '2024-08-15 10:25:00'),
-- Alumno 8 (semestre 8 → IDs 43–48)
( 8, 43, '2024-08-15 11:00:00'),( 8, 44, '2024-08-15 11:05:00'),
( 8, 45, '2024-08-15 11:10:00'),( 8, 46, '2024-08-15 11:15:00'),
( 8, 47, '2024-08-15 11:20:00'),( 8, 48, '2024-08-15 11:25:00'),
-- Alumno 9 (semestre 9 → IDs 49–54)
( 9, 49, '2024-08-15 12:00:00'),( 9, 50, '2024-08-15 12:05:00'),
( 9, 51, '2024-08-15 12:10:00'),( 9, 52, '2024-08-15 12:15:00'),
( 9, 53, '2024-08-15 12:20:00'),( 9, 54, '2024-08-15 12:25:00'),
-- Alumno 10 (también semestre 9 → IDs 49–54)
(10, 49, '2024-08-15 13:00:00'),(10, 50, '2024-08-15 13:05:00'),
(10, 51, '2024-08-15 13:10:00'),(10, 52, '2024-08-15 13:15:00'),
(10, 53, '2024-08-15 13:20:00'),(10, 54, '2024-08-15 13:25:00');

-- Hasta aqui los datos necesarios

-- 10 PROFESORES ADICIONALES
INSERT INTO profesor (nombre, paterno, materno, correo, rfc) VALUES
('Alejandra', 'Martínez', 'López',   'alejandra.martinez@aragon.unam.mx', 'MALA790212EFG'),
('Roberto',   'Gómez',    'Vázquez', 'roberto.gomez@aragon.unam.mx',     'GOVR820315HIJ'),
('Carmen',    'Luna',     'Juárez',  'carmen.luna@aragon.unam.mx',       'LUJC760418KLM'),
('Gabriel',   'Navarro',  'Rojas',   'gabriel.navarro@aragon.unam.mx',   'NARG831021NOP'),
('Diana',     'Durán',    'Mendoza', 'diana.duran@aragon.unam.mx',       'DUMD790624QRS'),
('Jorge',     'Fuentes',  'Campos',  'jorge.fuentes@aragon.unam.mx',     'FUCJ840727TUV'),
('Fernanda',  'Pacheco',  'Ríos',    'fernanda.pacheco@aragon.unam.mx',  'PARF791130WXY'),
('Octavio',   'Silva',    'Méndez',  'octavio.silva@aragon.unam.mx',     'SIMO800203ZAB'),
('Verónica',  'Jiménez',  'Estrada', 'veronica.jimenez@aragon.unam.mx',  'JIEV850306CDE'),
('Miguel',    'Velasco',  'Castro',  'miguel.velasco@aragon.unam.mx',    'VECM870409FGH');

-- 10 SALONES ADICIONALES
INSERT INTO salon (nombre_salon, capacidad, edificio) VALUES
('B101', 45, 'Edificio B'),
('B102', 38, 'Edificio B'),
('B103', 52, 'Edificio B'),
('B104', 40, 'Edificio B'),
('B105', 55, 'Edificio B'),
('B201', 48, 'Edificio B'),
('B202', 35, 'Edificio B'),
('B203', 60, 'Edificio B'),
('B204', 42, 'Edificio B'),
('B205', 50, 'Edificio B');

-- AGREGAR 2 GRUPOS MÁS PARA CADA SEMESTRE (actualmente hay 9 grupos, uno por semestre)
-- Necesitamos 18 grupos adicionales (2 adicionales por cada semestre)
INSERT INTO grupo (cupo) VALUES
-- Semestre 1: Grupos adicionales
(50), (50),
-- Semestre 2: Grupos adicionales
(45), (45),
-- Semestre 3: Grupos adicionales
(60), (60),
-- Semestre 4: Grupos adicionales
(30), (30),
-- Semestre 5: Grupos adicionales
(55), (55),
-- Semestre 6: Grupos adicionales
(35), (35),
-- Semestre 7: Grupos adicionales
(40), (40),
-- Semestre 8: Grupos adicionales
(60), (60),
-- Semestre 9: Grupos adicionales
(50), (50);

-- ASIGNAR MATERIAS A LOS NUEVOS GRUPOS
-- Semestre 1: Grupos 10 y 11 (IDs 10 y 11) - Materias 1-6
INSERT INTO asignatura_grupo (id_asignatura, id_grupo, id_profesor) VALUES
-- Grupo 10 (semestre 1, segundo grupo)
( 1, 10, 11),( 2, 10, 12),( 3, 10, 13),( 4, 10, 14),( 5, 10, 15),( 6, 10, 16),
-- Grupo 11 (semestre 1, tercer grupo)
( 1, 11, 17),( 2, 11, 18),( 3, 11, 19),( 4, 11, 20),( 5, 11, 11),( 6, 11, 12);

-- Semestre 2: Grupos 12 y 13 (IDs 12 y 13) - Materias 7-12
INSERT INTO asignatura_grupo (id_asignatura, id_grupo, id_profesor) VALUES
-- Grupo 12 (semestre 2, segundo grupo)
( 7, 12, 13),( 8, 12, 14),( 9, 12, 15),(10, 12, 16),(11, 12, 17),(12, 12, 18),
-- Grupo 13 (semestre 2, tercer grupo)
( 7, 13, 19),( 8, 13, 20),( 9, 13, 11),(10, 13, 12),(11, 13, 13),(12, 13, 14);

-- Semestre 3: Grupos 14 y 15 (IDs 14 y 15) - Materias 13-18
INSERT INTO asignatura_grupo (id_asignatura, id_grupo, id_profesor) VALUES
-- Grupo 14 (semestre 3, segundo grupo)
(13, 14, 15),(14, 14, 16),(15, 14, 17),(16, 14, 18),(17, 14, 19),(18, 14, 20),
-- Grupo 15 (semestre 3, tercer grupo)
(13, 15, 11),(14, 15, 12),(15, 15, 13),(16, 15, 14),(17, 15, 15),(18, 15, 16);

-- Semestre 4: Grupos 16 y 17 (IDs 16 y 17) - Materias 19-24
INSERT INTO asignatura_grupo (id_asignatura, id_grupo, id_profesor) VALUES
-- Grupo 16 (semestre 4, segundo grupo)
(19, 16, 17),(20, 16, 18),(21, 16, 19),(22, 16, 20),(23, 16, 11),(24, 16, 12),
-- Grupo 17 (semestre 4, tercer grupo)
(19, 17, 13),(20, 17, 14),(21, 17, 15),(22, 17, 16),(23, 17, 17),(24, 17, 18);

-- Semestre 5: Grupos 18 y 19 (IDs 18 y 19) - Materias 25-30
INSERT INTO asignatura_grupo (id_asignatura, id_grupo, id_profesor) VALUES
-- Grupo 18 (semestre 5, segundo grupo)
(25, 18, 19),(26, 18, 20),(27, 18, 11),(28, 18, 12),(29, 18, 13),(30, 18, 14),
-- Grupo 19 (semestre 5, tercer grupo)
(25, 19, 15),(26, 19, 16),(27, 19, 17),(28, 19, 18),(29, 19, 19),(30, 19, 20);

-- Semestre 6: Grupos 20 y 21 (IDs 20 y 21) - Materias 31-36
INSERT INTO asignatura_grupo (id_asignatura, id_grupo, id_profesor) VALUES
-- Grupo 20 (semestre 6, segundo grupo)
(31, 20, 11),(32, 20, 12),(33, 20, 13),(34, 20, 14),(35, 20, 15),(36, 20, 16),
-- Grupo 21 (semestre 6, tercer grupo)
(31, 21, 17),(32, 21, 18),(33, 21, 19),(34, 21, 20),(35, 21, 11),(36, 21, 12);

-- Semestre 7: Grupos 22 y 23 (IDs 22 y 23) - Materias 37-42
INSERT INTO asignatura_grupo (id_asignatura, id_grupo, id_profesor) VALUES
-- Grupo 22 (semestre 7, segundo grupo)
(37, 22, 13),(38, 22, 14),(39, 22, 15),(40, 22, 16),(41, 22, 17),(42, 22, 18),
-- Grupo 23 (semestre 7, tercer grupo)
(37, 23, 19),(38, 23, 20),(39, 23, 11),(40, 23, 12),(41, 23, 13),(42, 23, 14);

-- Semestre 8: Grupos 24 y 25 (IDs 24 y 25) - Materias 43-48
INSERT INTO asignatura_grupo (id_asignatura, id_grupo, id_profesor) VALUES
-- Grupo 24 (semestre 8, segundo grupo)
(43, 24, 15),(44, 24, 16),(45, 24, 17),(46, 24, 18),(47, 24, 19),(48, 24, 20),
-- Grupo 25 (semestre 8, tercer grupo)
(43, 25, 11),(44, 25, 12),(45, 25, 13),(46, 25, 14),(47, 25, 15),(48, 25, 16);

-- Semestre 9: Grupos 26 y 27 (IDs 26 y 27) - Materias 49-54
INSERT INTO asignatura_grupo (id_asignatura, id_grupo, id_profesor) VALUES
-- Grupo 26 (semestre 9, segundo grupo)
(49, 26, 17),(50, 26, 18),(51, 26, 19),(52, 26, 20),(53, 26, 11),(54, 26, 12),
-- Grupo 27 (semestre 9, tercer grupo)
(49, 27, 13),(50, 27, 14),(51, 27, 15),(52, 27, 16),(53, 27, 17),(54, 27, 18);

-- HORARIOS PARA LOS NUEVOS GRUPOS (asegurando que no haya solapamientos dentro del mismo grupo)

-- HORARIOS PARA SEMESTRE 1: GRUPOS 10 Y 11
-- Grupo 10 (semestre 1, segundo grupo) - turno intermedio
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
-- Asignaturas IDs 55-60 (segundo grupo de semestre 1)
(55, 1, '10:00:00', '12:00:00', 21),(55, 3, '10:00:00', '12:00:00', 21),
(56, 2, '10:00:00', '12:00:00', 22),(56, 4, '10:00:00', '12:00:00', 22),
(57, 3, '12:00:00', '14:00:00', 23),(57, 5, '12:00:00', '14:00:00', 23),
(58, 1, '12:00:00', '13:30:00', 24),(58, 3, '12:00:00', '13:30:00', 24),(58, 5, '12:00:00', '13:30:00', 24),
(59, 2, '12:00:00', '13:30:00', 25),(59, 4, '12:00:00', '13:30:00', 25),(59, 5, '14:00:00', '15:30:00', 25),
(60, 1, '14:00:00', '15:30:00', 26),(60, 3, '14:00:00', '15:30:00', 26),(60, 5, '16:00:00', '17:30:00', 26);

-- Grupo 11 (semestre 1, tercer grupo) - turno vespertino
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
-- Asignaturas IDs 61-66 (tercer grupo de semestre 1)
(61, 1, '16:00:00', '18:00:00', 27),(61, 3, '16:00:00', '18:00:00', 27),
(62, 2, '16:00:00', '18:00:00', 28),(62, 4, '16:00:00', '18:00:00', 28),
(63, 3, '18:00:00', '20:00:00', 29),(63, 5, '18:00:00', '20:00:00', 29),
(64, 1, '18:00:00', '19:30:00', 30),(64, 3, '18:00:00', '19:30:00', 30),(64, 5, '18:00:00', '19:30:00', 30),
(65, 2, '18:00:00', '19:30:00', 21),(65, 4, '18:00:00', '19:30:00', 21),(65, 5, '16:00:00', '17:30:00', 21),
(66, 1, '19:30:00', '21:00:00', 22),(66, 3, '19:30:00', '21:00:00', 22),(66, 5, '19:30:00', '21:00:00', 22);

-- HORARIOS PARA SEMESTRE 2: GRUPOS 12 Y 13
-- Grupo 12 (semestre 2, segundo grupo) - turno intermedio
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
-- Asignaturas IDs 67-72 (segundo grupo de semestre 2)
(67, 1, '12:00:00', '14:00:00', 23),(67, 3, '12:00:00', '14:00:00', 23),
(68, 2, '12:00:00', '14:00:00', 24),(68, 4, '12:00:00', '14:00:00', 24),
(69, 3, '14:00:00', '16:00:00', 25),(69, 5, '14:00:00', '16:00:00', 25),
(70, 1, '14:00:00', '15:30:00', 26),(70, 3, '14:00:00', '15:30:00', 26),(70, 5, '14:00:00', '15:30:00', 26),
(71, 2, '14:00:00', '15:30:00', 27),(71, 4, '14:00:00', '15:30:00', 27),(71, 5, '16:00:00', '17:30:00', 27),
(72, 1, '16:00:00', '17:30:00', 28),(72, 3, '16:00:00', '17:30:00', 28),(72, 5, '18:00:00', '19:30:00', 28);

-- Grupo 13 (semestre 2, tercer grupo) - turno vespertino
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
-- Asignaturas IDs 73-78 (tercer grupo de semestre 2)
(73, 1, '18:00:00', '20:00:00', 29),(73, 3, '18:00:00', '20:00:00', 29),
(74, 2, '18:00:00', '20:00:00', 30),(74, 4, '18:00:00', '20:00:00', 30),
(75, 3, '16:00:00', '18:00:00', 21),(75, 5, '16:00:00', '18:00:00', 21),
(76, 1, '16:00:00', '17:30:00', 22),(76, 3, '16:00:00', '17:30:00', 22),(76, 5, '16:00:00', '17:30:00', 22),
(77, 2, '16:00:00', '17:30:00', 23),(77, 4, '16:00:00', '17:30:00', 23),(77, 5, '18:00:00', '19:30:00', 23),
(78, 1, '20:00:00', '21:30:00', 24),(78, 3, '20:00:00', '21:30:00', 24),(78, 5, '20:00:00', '21:30:00', 24);

-- HORARIOS PARA SEMESTRE 3: GRUPOS 14 Y 15
-- Grupo 14 (semestre 3, segundo grupo) - turno intermedio
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
-- Asignaturas IDs 79-84 (segundo grupo de semestre 3)
(79, 1, '10:00:00', '12:00:00', 25),(79, 3, '10:00:00', '12:00:00', 25),
(80, 2, '10:00:00', '12:00:00', 26),(80, 4, '10:00:00', '12:00:00', 26),
(81, 3, '12:00:00', '14:00:00', 27),(81, 5, '12:00:00', '14:00:00', 27),
(82, 1, '12:00:00', '13:30:00', 28),(82, 3, '12:00:00', '13:30:00', 28),(82, 5, '12:00:00', '13:30:00', 28),
(83, 2, '12:00:00', '13:30:00', 29),(83, 4, '12:00:00', '13:30:00', 29),(83, 5, '14:00:00', '15:30:00', 29),
(84, 1, '14:00:00', '15:30:00', 30),(84, 3, '14:00:00', '15:30:00', 30),(84, 5, '16:00:00', '17:30:00', 30);

-- Grupo 15 (semestre 3, tercer grupo) - turno vespertino
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
-- Asignaturas IDs 85-90 (tercer grupo de semestre 3)
(85, 1, '16:00:00', '18:00:00', 21),(85, 3, '16:00:00', '18:00:00', 21),
(86, 2, '16:00:00', '18:00:00', 22),(86, 4, '16:00:00', '18:00:00', 22),
(87, 3, '18:00:00', '20:00:00', 23),(87, 5, '18:00:00', '20:00:00', 23),
(88, 1, '18:00:00', '19:30:00', 24),(88, 3, '18:00:00', '19:30:00', 24),(88, 5, '18:00:00', '19:30:00', 24),
(89, 2, '18:00:00', '19:30:00', 25),(89, 4, '18:00:00', '19:30:00', 25),(89, 5, '16:00:00', '17:30:00', 25),
(90, 1, '19:30:00', '21:00:00', 26),(90, 3, '19:30:00', '21:00:00', 26),(90, 5, '19:30:00', '21:00:00', 26);

-- HORARIOS PARA SEMESTRE 4: GRUPOS 16 Y 17
-- Grupo 16 (semestre 4, segundo grupo) - turno intermedio
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
-- Asignaturas IDs 91-96 (segundo grupo de semestre 4)
(91, 1, '14:00:00', '16:00:00', 27),(91, 3, '14:00:00', '16:00:00', 27),
(92, 2, '14:00:00', '16:00:00', 28),(92, 4, '14:00:00', '16:00:00', 28),
(93, 3, '16:00:00', '18:00:00', 29),(93, 5, '16:00:00', '18:00:00', 29),
(94, 1, '16:00:00', '18:00:00', 30),(94, 3, '16:00:00', '18:00:00', 30),
(95, 2, '16:00:00', '18:00:00', 21),(95, 4, '16:00:00', '18:00:00', 21),
(96, 1, '18:00:00', '19:30:00', 22),(96, 3, '18:00:00', '19:30:00', 22),(96, 5, '18:00:00', '19:30:00', 22);

-- Grupo 17 (semestre 4, tercer grupo) - turno vespertino
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
-- Asignaturas IDs 97-102 (tercer grupo de semestre 4)
(97, 1, '18:00:00', '20:00:00', 23),(97, 3, '18:00:00', '20:00:00', 23),
(98, 2, '18:00:00', '20:00:00', 24),(98, 4, '18:00:00', '20:00:00', 24),
(99, 3, '14:00:00', '16:00:00', 25),(99, 5, '14:00:00', '16:00:00', 25),
(100, 1, '16:00:00', '18:00:00', 26),(100, 3, '16:00:00', '18:00:00', 26),
(101, 2, '16:00:00', '18:00:00', 27),(101, 4, '16:00:00', '18:00:00', 27),
(102, 1, '20:00:00', '21:30:00', 28),(102, 3, '20:00:00', '21:30:00', 28),(102, 5, '20:00:00', '21:30:00', 28);

-- HORARIOS PARA SEMESTRE 5: GRUPOS 18 Y 19 
-- Grupo 18 (semestre 5, segundo grupo) - turno intermedio
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
-- Asignaturas IDs 103-108 (segundo grupo de semestre 5)
(103, 1, '12:00:00', '14:00:00', 29),(103, 3, '12:00:00', '14:00:00', 29),
(104, 2, '12:00:00', '14:00:00', 30),(104, 4, '12:00:00', '14:00:00', 30),
(105, 3, '14:00:00', '16:00:00', 21),(105, 5, '14:00:00', '16:00:00', 21),
(106, 1, '14:00:00', '16:00:00', 22),(106, 3, '14:00:00', '16:00:00', 22),
(107, 2, '14:00:00', '16:00:00', 23),(107, 4, '14:00:00', '16:00:00', 23),
(108, 1, '10:00:00', '11:30:00', 24),(108, 3, '10:00:00', '11:30:00', 24),(108, 5, '10:00:00', '11:30:00', 24);

-- Grupo 19 (semestre 5, tercer grupo) - turno vespertino
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
-- Asignaturas IDs 109-114 (tercer grupo de semestre 5)
(109, 1, '18:00:00', '20:00:00', 25),(109, 3, '18:00:00', '20:00:00', 25),
(110, 2, '18:00:00', '20:00:00', 26),(110, 4, '18:00:00', '20:00:00', 26),
(111, 3, '20:00:00', '22:00:00', 27),(111, 5, '20:00:00', '22:00:00', 27),
(112, 1, '20:00:00', '22:00:00', 28),(112, 3, '20:00:00', '22:00:00', 28),
(113, 2, '20:00:00', '22:00:00', 29),(113, 4, '20:00:00', '22:00:00', 29),
(114, 1, '16:00:00', '17:30:00', 30),(114, 3, '16:00:00', '17:30:00', 30),(114, 5, '16:00:00', '17:30:00', 30);

-- Los horarios para los semestres 6-9 siguen la misma estructura...
-- HORARIOS PARA SEMESTRE 6: GRUPOS 20 Y 21
-- Grupo 20 (semestre 6, segundo grupo) - turno intermedio
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
-- Asignaturas IDs 115-120 (segundo grupo de semestre 6)
(115, 1, '10:00:00', '12:00:00', 21),(115, 3, '10:00:00', '12:00:00', 21),
(116, 2, '10:00:00', '12:00:00', 22),(116, 4, '10:00:00', '12:00:00', 22),
(117, 3, '12:00:00', '14:00:00', 23),(117, 5, '12:00:00', '14:00:00', 23),
(118, 1, '12:00:00', '14:00:00', 24),(118, 3, '12:00:00', '14:00:00', 24),
(119, 2, '12:00:00', '14:00:00', 25),(119, 4, '12:00:00', '14:00:00', 25),
(120, 1, '14:00:00', '15:30:00', 26),(120, 3, '14:00:00', '15:30:00', 26),(120, 5, '14:00:00', '15:30:00', 26);

-- Grupo 21 (semestre 6, tercer grupo) - turno vespertino
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
-- Asignaturas IDs 121-126 (tercer grupo de semestre 6)
(121, 1, '16:00:00', '18:00:00', 27),(121, 3, '16:00:00', '18:00:00', 27),
(122, 2, '16:00:00', '18:00:00', 28),(122, 4, '16:00:00', '18:00:00', 28),
(123, 3, '18:00:00', '20:00:00', 29),(123, 5, '18:00:00', '20:00:00', 29),
(124, 1, '18:00:00', '20:00:00', 30),(124, 3, '18:00:00', '20:00:00', 30),
(125, 2, '18:00:00', '20:00:00', 21),(125, 4, '18:00:00', '20:00:00', 21),
(126, 1, '20:00:00', '21:30:00', 22),(126, 3, '20:00:00', '21:30:00', 22),(126, 5, '20:00:00', '21:30:00', 22);

-- HORARIOS PARA SEMESTRE 7: GRUPOS 22 Y 23
-- Grupo 22 (semestre 7, segundo grupo) - turno intermedio
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
-- Asignaturas IDs 127-132 (segundo grupo de semestre 7)
(127, 1, '14:00:00', '16:00:00', 23),(127, 3, '14:00:00', '16:00:00', 23),
(128, 2, '14:00:00', '16:00:00', 24),(128, 4, '14:00:00', '16:00:00', 24),
(129, 3, '16:00:00', '18:00:00', 25),(129, 5, '16:00:00', '18:00:00', 25),
(130, 1, '16:00:00', '18:00:00', 26),(130, 3, '16:00:00', '18:00:00', 26),
(131, 2, '16:00:00', '18:00:00', 27),(131, 4, '16:00:00', '18:00:00', 27),
(132, 1, '18:00:00', '19:30:00', 28),(132, 3, '18:00:00', '19:30:00', 28),(132, 5, '18:00:00', '19:30:00', 28);

-- Grupo 23 (semestre 7, tercer grupo) - turno vespertino
-- HORARIOS PARA SEMESTRE 7: GRUPOS 22 Y 23

-- Grupo 22 (semestre 7, segundo grupo) – ya definidos: IDs 127–132

-- Grupo 23 (semestre 7, tercer grupo) – IDs 133–138
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
  -- Asignatura 37 (Minería de Datos)
  (133, 2, '18:00:00', '20:00:00', 29),
  (133, 4, '18:00:00', '20:00:00', 29),
  -- Asignatura 38 (no. 38)
  (134, 1, '18:00:00', '20:00:00', 30),
  (134, 3, '18:00:00', '20:00:00', 30),
  -- Asignatura 39
  (135, 2, '16:00:00', '18:00:00', 21),
  (135, 4, '16:00:00', '18:00:00', 21),
  -- Asignatura 40
  (136, 3, '16:00:00', '18:00:00', 22),
  (136, 5, '16:00:00', '18:00:00', 22),
  -- Asignatura 41
  (137, 1, '20:00:00', '22:00:00', 23),
  (137, 3, '20:00:00', '22:00:00', 23),
  -- Asignatura 42 (3 días, 1.5 h)
  (138, 2, '18:00:00', '19:30:00', 24),
  (138, 4, '18:00:00', '19:30:00', 24),
  (138, 5, '18:00:00', '19:30:00', 24);


-- HORARIOS PARA SEMESTRE 8: GRUPOS 24 Y 25

-- Grupo 24 (semestre 8, segundo grupo) – IDs 139–144
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
  (139, 1, '16:00:00', '18:00:00', 25),
  (139, 3, '16:00:00', '18:00:00', 25),
  (140, 2, '16:00:00', '18:00:00', 26),
  (140, 4, '16:00:00', '18:00:00', 26),
  (141, 3, '18:00:00', '20:00:00', 27),
  (141, 5, '18:00:00', '20:00:00', 27),
  (142, 1, '18:00:00', '20:00:00', 28),
  (142, 3, '18:00:00', '20:00:00', 28),
  (143, 2, '20:00:00', '22:00:00', 29),
  (143, 4, '20:00:00', '22:00:00', 29),
  (144, 1, '14:00:00', '15:30:00', 30),
  (144, 3, '14:00:00', '15:30:00', 30),
  (144, 5, '14:00:00', '15:30:00', 30);

-- Grupo 25 (semestre 8, tercer grupo) – IDs 145–150
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
  (145, 1, '08:00:00', '10:00:00', 21),
  (145, 3, '08:00:00', '10:00:00', 21),
  (146, 2, '08:00:00', '10:00:00', 22),
  (146, 4, '08:00:00', '10:00:00', 22),
  (147, 3, '10:00:00', '12:00:00', 23),
  (147, 5, '10:00:00', '12:00:00', 23),
  (148, 1, '10:00:00', '12:00:00', 24),
  (148, 3, '10:00:00', '12:00:00', 24),
  (149, 2, '12:00:00', '14:00:00', 25),
  (149, 4, '12:00:00', '14:00:00', 25),
  (150, 1, '14:00:00', '15:30:00', 26),
  (150, 3, '14:00:00', '15:30:00', 26),
  (150, 5, '14:00:00', '15:30:00', 26);


-- HORARIOS PARA SEMESTRE 9: GRUPOS 26 Y 27

-- Grupo 26 (semestre 9, segundo grupo) – IDs 151–156
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
  (151, 1, '12:00:00', '14:00:00', 27),
  (151, 3, '12:00:00', '14:00:00', 27),
  (152, 2, '12:00:00', '14:00:00', 28),
  (152, 4, '12:00:00', '14:00:00', 28),
  (153, 3, '14:00:00', '16:00:00', 29),
  (153, 5, '14:00:00', '16:00:00', 29),
  (154, 1, '14:00:00', '16:00:00', 30),
  (154, 3, '14:00:00', '16:00:00', 30),
  (155, 2, '16:00:00', '18:00:00', 21),
  (155, 4, '16:00:00', '18:00:00', 21),
  (156, 1, '16:00:00', '17:30:00', 22),
  (156, 3, '16:00:00', '17:30:00', 22),
  (156, 5, '16:00:00', '17:30:00', 22);

-- Grupo 27 (semestre 9, tercer grupo) – IDs 157–162
INSERT INTO horario (id_asignatura_grupo, id_dia, hora_inicio, hora_fin, id_salon) VALUES
  (157, 1, '18:00:00', '20:00:00', 23),
  (157, 3, '18:00:00', '20:00:00', 23),
  (158, 2, '18:00:00', '20:00:00', 24),
  (158, 4, '18:00:00', '20:00:00', 24),
  (159, 3, '20:00:00', '22:00:00', 25),
  (159, 5, '20:00:00', '22:00:00', 25),
  (160, 1, '20:00:00', '22:00:00', 26),
  (160, 3, '20:00:00', '22:00:00', 26),
  (161, 2, '20:00:00', '21:30:00', 27),
  (161, 4, '20:00:00', '21:30:00', 27),
  (161, 5, '20:00:00', '21:30:00', 27),
  (162, 1, '08:00:00', '09:30:00', 28),
  (162, 3, '08:00:00', '09:30:00', 28),
  (162, 5, '08:00:00', '09:30:00', 28);

