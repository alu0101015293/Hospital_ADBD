-- Administración y Diseño de Bases de Datos
--
-- Proyecto de Hospital
--
-- Realizado por:
--  Marcelo Daniel Choque Mamani
--  Arturo Pestana Ortiz
-- 

--
-- Creacion de la base de datos
--
\c postgres

-- Elimina la base de datos si existe
DROP DATABASE IF EXISTS bbdd_hospital;

-- Crea la base de datos
CREATE DATABASE bbdd_hospital WITH TEMPLATE = template0 ENCODING = 'UTF8';

-- Conéctate a la nueva base de datos
\c bbdd_hospital

-- Establece algunas configuraciones
SET default_tablespace = '';
SET default_table_access_method = heap;

--------------------------------------------
-------- TABLAS DE LA BASE DE DATOS --------
--------------------------------------------

-- Concede privilegios
GRANT ALL PRIVILEGES ON DATABASE bbdd_hospital TO postgres;

-- Crea la tabla cliente
CREATE TABLE  cliente (
  id_cliente INTEGER PRIMARY KEY,
  nombre VARCHAR(100),
  direccion VARCHAR(100),
  telefono INTEGER NOT NULL,
  email VARCHAR(50)
);

CREATE TABLE telefonos (
  id_cliente INTEGER NOT NULL, 
  telefono INTEGER NOT NULL,

  PRIMARY KEY(id_cliente, telefono),
  FOREIGN KEY(id_cliente) 
  REFERENCES cliente(id_cliente)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);

-- Definimos tipo de dato
CREATE TYPE genero_t AS ENUM ('Masculino', 'Femenino');

CREATE OR REPLACE FUNCTION calcular_edad(fecha_nacimiento DATE)
RETURNS INTEGER AS $$
BEGIN
  RETURN EXTRACT(YEAR FROM AGE(NOW(), fecha_nacimiento));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE TABLE paciente (
  id_paciente SERIAL NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  edad INTEGER GENERATED ALWAYS AS (calcular_edad(fecha_nacimiento)) STORED,
  genero genero_t,
  id_cliente INTEGER NOT NULL,

  PRIMARY KEY (id_paciente),
  CONSTRAINT fk_id_cliente
  FOREIGN KEY(id_cliente)
  REFERENCES cliente(id_cliente)
  ON UPDATE CASCADE  --si id_cliente en cliente se modif, las de paciente tmb
  ON DELETE CASCADE
);

CREATE TABLE familiar (
  dni VARCHAR(9) NOT NULL,
  nombre VARCHAR (150) NOT NULL,
  telefono INTEGER,
  id_paciente INTEGER,

  PRIMARY KEY(dni, id_paciente),
  CONSTRAINT fk_id_paciente
  FOREIGN KEY(id_paciente)
  REFERENCES paciente(id_paciente)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);

CREATE TABLE departamento (
  id_dpto INTEGER NOT NULL,
  nombre_dpto VARCHAR(100) NOT NULL,

  PRIMARY KEY(id_dpto)
);

CREATE TABLE material (
  id_material INTEGER NOT NULL,
  nombre_material VARCHAR(50) NOT NULL,
  tipo VARCHAR,

  PRIMARY KEY(id_material)
);

CREATE TABLE proveedores (
  id_proveedor INTEGER NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  direccion VARCHAR (200),
  telefono INTEGER NOT NULL,

  PRIMARY KEY(id_proveedor)
);

CREATE TABLE aprovisionamiento (
  id_dpto INTEGER NOT NULL,
  id_material INTEGER NOT NULL,
  id_proveedor INTEGER NOT NULL,
  cantidad INTEGER,

  PRIMARY KEY(id_dpto, id_material, id_proveedor),
  CONSTRAINT fk_id_dpto
  FOREIGN KEY(id_dpto)
  REFERENCES departamento(id_dpto)
  ON UPDATE CASCADE
  ON DELETE CASCADE,

  CONSTRAINT fk_id_material
  FOREIGN KEY(id_material)
  REFERENCES material(id_material)
  ON UPDATE CASCADE
  ON DELETE CASCADE,

  CONSTRAINT fk_id_proveedor
  FOREIGN KEY(id_proveedor)
  REFERENCES proveedores(id_proveedor)
  ON UPDATE CASCADE
  ON DELETE CASCADE
);

CREATE TABLE grupo_practicas (
  id_grupoPracticas INTEGER NOT NULL,

  PRIMARY KEY(id_grupoPracticas)
);


CREATE TABLE empleado (
  codigo_p INTEGER NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  dni CHAR(9) NOT NULL,
  id_dpto INTEGER,
  id_grupoPracticas INTEGER,

  PRIMARY KEY (codigo_p),
  CONSTRAINT fk_id_dpto
  FOREIGN KEY(id_dpto)
  REFERENCES departamento(id_dpto)
  ON UPDATE CASCADE
  ON DELETE CASCADE,

  CONSTRAINT fk_id_grupoPracticas
  FOREIGN KEY(id_grupoPracticas)
  REFERENCES grupo_practicas(id_grupoPracticas)
  ON UPDATE CASCADE
  ON DELETE CASCADE
);

CREATE TABLE medico (
  codigo_p INTEGER NOT NULL,
  especialidad VARCHAR(100) NOT NULL,
  
  PRIMARY KEY (codigo_p),
  CONSTRAINT fk_codigo_p
  FOREIGN KEY(codigo_p)
  REFERENCES empleado(codigo_p)
  ON UPDATE CASCADE
  ON DELETE CASCADE
);

CREATE TABLE auxiliar (
  codigo_p INTEGER NOT NULL, 

  PRIMARY KEY (codigo_p),
  CONSTRAINT fk_codigo_p
  FOREIGN KEY(codigo_p)
  REFERENCES empleado(codigo_p)
  ON UPDATE CASCADE
  ON DELETE CASCADE
);

CREATE TABLE pasa_consulta (
  codigo INTEGER NOT NULL,
  fecha DATE,
  diagnostico VARCHAR(150),
  codigo_p INTEGER NOT NULL,
  id_paciente INTEGER NOT NULL,

  PRIMARY KEY (codigo, fecha, codigo_p),
  CONSTRAINT fk_codigo_p
  FOREIGN KEY(codigo_p)
  REFERENCES empleado(codigo_p)
  ON UPDATE CASCADE
  ON DELETE CASCADE,

  CONSTRAINT fk_id_paciente
  FOREIGN KEY(id_paciente)
  REFERENCES paciente(id_paciente)
  ON UPDATE CASCADE
  ON DELETE CASCADE
);

CREATE TABLE pago (
  id_pago INTEGER NOT NULL,
  importe FLOAT NOT NULL,
  tipo VARCHAR NOT NULL,
  id_cliente INTEGER,

  PRIMARY KEY (id_pago),
  CONSTRAINT fk_id_cliente
  FOREIGN KEY(id_cliente)
  REFERENCES cliente(id_cliente)
  ON UPDATE CASCADE
  ON DELETE CASCADE 
);

CREATE TABLE tarjeta (
  num_card VARCHAR NOT NULL,
  fecha_caduca DATE NOT NULL,
  id_pago INTEGER NOT NULL,

  PRIMARY KEY(num_card),
  CONSTRAINT fk_id_pago
  FOREIGN KEY(id_pago)
  REFERENCES pago(id_pago)
  ON UPDATE CASCADE
  ON DELETE CASCADE
);

CREATE TABLE efectivo (
  id_pago INTEGER NOT NULL,
  divisa VARCHAR NOT NULL,

  PRIMARY KEY(id_pago),
  CONSTRAINT fk_id_pago
  FOREIGN KEY(id_pago)
  REFERENCES pago(id_pago)
  ON UPDATE CASCADE
  ON DELETE CASCADE
);

--------------------------------------------
---------- CREACION DE LOS CHECKS ----------
--------------------------------------------

ALTER TABLE cliente
ADD CONSTRAINT check_email_unique
UNIQUE (email);

ALTER TABLE cliente
ADD CONSTRAINT check_telefono_cliente_range
CHECK (telefono >= 100000000 AND telefono <= 999999999);

ALTER TABLE cliente
ADD CONSTRAINT check_telefono_cliente_unique
UNIQUE (telefono);

ALTER TABLE familiar
ADD CONSTRAINT check_telefono_familiar_range
CHECK (telefono >= 100000000 AND telefono <= 999999999);

ALTER TABLE familiar
ADD CONSTRAINT check_telefono_familiar_unique
UNIQUE (telefono);

ALTER TABLE telefonos
ADD CONSTRAINT check_telefono_telefonos_unique
UNIQUE(telefono);

ALTER TABLE telefonos
ADD CONSTRAINT check_telefono_telefonos_range
CHECK (telefono >= 100000000 AND telefono <= 999999999);

ALTER TABLE paciente
ADD CONSTRAINT check_edad_no_negative
CHECK (edad > 1);

ALTER TABLE paciente
ADD CONSTRAINT check_fecha_nacimiento
CHECK (fecha_nacimiento >= '1900-01-01');

ALTER TABLE paciente
ADD CONSTRAINT check_genero_M_or_F
CHECK (genero IN ('Masculino', 'Femenino'));

ALTER TABLE departamento
ADD CONSTRAINT check_nom_dpto_departamento_unique
UNIQUE (nombre_dpto);

ALTER TABLE familiar
ADD CONSTRAINT check_dni_familiar_unique
UNIQUE(dni);

ALTER TABLE empleado
ADD CONSTRAINT check_dni_pesonal_unique
UNIQUE(dni);

ALTER TABLE pago
ADD CONSTRAINT check_importe_noZero
CHECK (importe > 0.0);

ALTER TABLE pago
ADD CONSTRAINT check_tipo
CHECK (tipo IN ('efectivo', 'tarjeta'));

ALTER TABLE proveedores
ADD CONSTRAINT check_telefono_proveedores
CHECK (telefono >= 100000000 AND telefono <= 999999999),
ADD CONSTRAINT unique_telefono_proveedores
UNIQUE (telefono);

ALTER TABLE aprovisionamiento
ADD CONSTRAINT check_cantidad
CHECK (cantidad > 0);

--------------------------------------------
----------- CREACION DE TRIGGERS -----------
--------------------------------------------

-- activa automátic antes que se haga una operación de inserción o update en la tabla

-- Comprobar al ingresar una tarjeda de debito si no ha expirado
CREATE OR REPLACE FUNCTION check_card_expiration()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.fecha_caduca < CURRENT_DATE THEN
    RAISE EXCEPTION 'La tarjeta ha caducado ! ! !';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tarjeta_check_expiration
BEFORE INSERT OR UPDATE ON tarjeta
FOR EACH ROW
EXECUTE FUNCTION check_card_expiration();

-- Comprobamos que el numero de tarjeta no este repetido
CREATE OR REPLACE FUNCTION check_unique_account_number_tarjeta()
RETURNS TRIGGER AS $$
DECLARE
  duplicate INT;
BEGIN
  SELECT 1 INTO duplicate
  FROM tarjeta
  WHERE num_card = NEW.num_card
  AND id_pago != NEW.id_pago;
  
  IF duplicate = 1 THEN
    RAISE EXCEPTION 'El número de tarjeta debe ser único ! ! !';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tarjeta_check_unique_account_number
BEFORE INSERT OR UPDATE ON tarjeta
FOR EACH ROW
EXECUTE FUNCTION check_unique_account_number_tarjeta();

-- Creamos una funcion para actualizar la fecha caducidad de una tarjeta
CREATE OR REPLACE FUNCTION actualizar_fecha_caducidad(num_tarjeta VARCHAR, nueva_fecha DATE)
RETURNS VOID AS $$
BEGIN
  UPDATE tarjeta
  SET fecha_caduca = nueva_fecha
  WHERE num_card = num_tarjeta;
END;
$$ LANGUAGE plpgsql;

-- Creamos trigger para poner la fecha actual si el campo esta vacio
CREATE OR REPLACE FUNCTION actualizar_fecha_actual()
RETURNS TRIGGER AS $$
BEGIN
  -- Actualizar la fecha solo si no se proporciona una fecha específica en la inserción
  IF NEW.fecha IS NULL THEN
    NEW.fecha := CURRENT_DATE;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_fecha_actual
BEFORE INSERT ON pasa_consulta
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_actual();

-- Creamos trigger para verificar que empleado pertenece a dpto o grupo practicas 
CREATE OR REPLACE FUNCTION validar_pertenencia()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.id_dpto IS NOT NULL AND NEW.id_grupoPracticas IS NOT NULL) OR
     (NEW.id_dpto IS NULL AND NEW.id_grupoPracticas IS NULL) THEN
    RAISE EXCEPTION 'Un empleado debe pertenecer a un departamento o a un grupo de prácticas.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creamos el trigger
CREATE TRIGGER trigger_validar_pertenencia
BEFORE INSERT OR UPDATE ON empleado
FOR EACH ROW
EXECUTE FUNCTION validar_pertenencia();

--------------------------------------------
------ INSERTANDO DATOS EN LAS TABLAS ------
--------------------------------------------

INSERT INTO cliente (id_cliente, nombre, direccion, telefono, email) VALUES
  (1, 'Carlos Tevez', 'Salón de la Fama 1', 611111111, 'carlosTevez@email.com'),
  (2, 'Brad Pitt', 'Miami, Número 2', 623456789, 'bradPitt@email.com'),
  (3, 'Tom Hanks', 'Beverly Hills, Calle Principal', 655511122, 'tomHanks@email.com'),
  (4, 'Leonardo DiCaprio', 'Malibu, Frente al Mar', 677788899, 'leoDiCaprio@email.com'),
  (5, 'Dwayne Johnson', 'Hollywood Blvd, Casa 5', 633344455, 'dwayneJohnson@email.com'),
  (6, 'Chris Hemsworth', 'Sydney, Australia', 699988877, 'chrisHemsworth@email.com'),
  (7, 'Robert Downey Jr.', 'Los Angeles, Rodeo Drive', 666777888, 'robertDowney@email.com'),
  (8, 'Keanu Reeves', 'New York City, Times Square', 611122233, 'keanuReeves@email.com');

INSERT INTO telefonos (id_cliente, telefono) VALUES
  (1, 922222221),
  (1, 922222222),
  (2, 922222223),
  (3, 922222224),
  (3, 922222225),
  (4, 922222226)
  ;
  
INSERT INTO paciente (nombre, fecha_nacimiento, genero, id_cliente) VALUES 
  ('LeBron James', '1984-12-30', 'Masculino', 1),
  ('Kevin Durant', '1988-09-29', 'Masculino', 2),
  ('Stephen Curry', '1988-03-14', 'Masculino', 3),
  ('Giannis Antetokounmpo', '1994-12-06', 'Masculino', 4),
  ('Luka Dončić', '1999-02-28', 'Masculino', 5),
  ('Kawhi Leonard', '1991-06-29', 'Masculino', 6),
  ('Anthony Davis', '1993-03-11', 'Masculino', 7),
  ('Damian Lillard', '1990-07-15', 'Masculino', 8),
  ('Marta Vieira da Silva', '1986-02-19', 'Femenino', 3),
  ('Alejandra Morgan', '1989-07-02', 'Femenino', 3),
  ('Ada Hegerberg', '1995-07-10', 'Femenino', 2),
  ('Samanta Kerr', '1993-09-10', 'Femenino', 1),
  ('Wendie Renard', '1990-07-20', 'Femenino', 1),
  ('Vivianne Miedema', '1996-07-15', 'Femenino', 1)
  ;

INSERT INTO familiar (dni, nombre, telefono, id_paciente) VALUES
  ('12345678A', 'Susana Gimenez', 922549111, 1),
  ('98765432B', 'Marcelo Tinelli', 922111333, 1),
  ('11111111X', 'Lionel Messi', 922111444, 1),
  ('22222222Y', 'Diego Maradona Jr.', 922111555, 1),
  ('33333333Z', 'Pampita Veron', 922111666, 5),
  ('44444444W', 'Juan Martín Del Potro', 922111777, 6),
  ('55555555U', 'Lali Espósito', 922111888, 7),
  ('66666666T', 'Javier Gerardo Milei', 922111999, 8)
  ;

-- Inserción en la tabla DEPARTAMENTO
INSERT INTO departamento (id_dpto, nombre_dpto)
VALUES
  (1, 'Cardiología'),
  (2, 'Neurología'),
  (3, 'Oncología'),
  (4, 'Cirugía'),
  (5, 'Pediatría');

-- Inserción en la tabla MATERIAL
INSERT INTO material (id_material, nombre_material, tipo)
VALUES
  (1, 'Jeringas', 'Suministros médicos'),
  (2, 'Monitor cardíaco', 'Equipos médicos'),
  (3, 'Quimioterapia', 'Medicamentos'),
  (4, 'Bisturí', 'Instrumentos quirúrgicos'),
  (5, 'Vacunas', 'Medicamentos');

-- Inserción en la tabla PROVEEDORES
INSERT INTO proveedores (id_proveedor, nombre, direccion, telefono)
VALUES
  (1, 'Suministros Médicos S.A.', 'Calle Principal 123', 923456789),
  (2, 'Equipos Médicos SL', 'Avenida Secundaria 456', 987654321),
  (3, 'Farmacia ABC', 'Plaza Central 789', 954321987),
  (4, 'Instrumentos Quirúrgicos Inc.', 'Calle Secundaria 321', 911222333),
  (5, 'Vacunas Pro SLU', 'Calle de la Salud 555', 944555666);

-- Inserción en la tabla APROVISIONAMIENTO
INSERT INTO aprovisionamiento (id_dpto, id_material, id_proveedor, cantidad)
VALUES
  (1, 1, 1, 100),
  (2, 2, 2, 50),
  (3, 3, 3, 200),
  (4, 4, 4, 30),
  (5, 5, 5, 150),
  (1, 2, 3, 75),
  (2, 3, 4, 120),
  (3, 4, 5, 40),
  (4, 5, 1, 90),
  (5, 1, 2, 60)
  ;

INSERT INTO grupo_practicas (id_grupoPracticas) VALUES
  (1),
  (2),
  (3);

INSERT INTO empleado (codigo_p, nombre, dni, id_grupoPracticas) VALUES
  (1, 'Madonna', '111222333', 1),
  (2, 'Michael Jackson', '444555666', 2),
  (3, 'Prince Royce', '777888999', 1),
  (4, 'Chuck Berry', '11111111A', 3),
  (5, 'Elvis Presley', '11111111B', 2);

INSERT INTO empleado (codigo_p, nombre, dni, id_dpto) VALUES
  (6, 'Madonna', '111222444', 1),
  (7, 'Michael Jackson', '444555777', 2),
  (8, 'Prince Royce', '777888000', 1),
  (9, 'Chuck Berry', '11111111Z', 3),
  (10, 'Elvis Presley', '11111111C', 2);

-- Insertar en PASA_CONSULTA
INSERT INTO pasa_consulta (codigo, fecha, diagnostico, codigo_p, id_paciente)
VALUES
  (1, '2023-01-15', 'Consulta de rutina', 1, 1),
  (2, '2023-02-20', 'Dolor abdominal', 2, 2),
  (3, '2023-03-25', 'Examen de sangre', 3, 3),
  (4, '2023-04-30', 'Control de presión', 4, 4),
  (5, '2023-05-05', 'Vacunación anual', 5, 5),
  (6, '2023-06-10', 'Consulta dermatológica', 1, 6),
  (7, '2023-07-15', 'Exámenes cardiológicos', 2, 7),
  (8, '2023-08-20', 'Seguimiento postoperatorio', 3, 8),
  (9, '2023-03-20', 'Consulta de rutina', 2, 2),
  (10, '2023-11-15', 'Consulta de rutina', 1, 1),
  (11, '2023-09-10', 'Consulta dermatológica', 1, 6)
  ;

-- Insertar en PAGO
INSERT INTO pago (id_pago, importe, tipo, id_cliente)
VALUES
  (1, 500.00, 'efectivo', 1),
  (2, 200.00, 'tarjeta', 2),
  (3, 350.00, 'efectivo', 3),
  (4, 150.00, 'tarjeta', 4),
  (5, 800.50, 'tarjeta', 5),
  (6, 700.90, 'tarjeta', 6),
  (7, 150.40, 'tarjeta', 7),
  (8, 250.00, 'tarjeta', 8),
  (9, 290.00, 'efectivo', 1),
  (10, 80.00, 'efectivo', 1)
  ;

-- Insertar en tabla TARJETA
INSERT INTO tarjeta (num_card, fecha_caduca, id_pago)
VALUES 
   (1234567890123456, '2024-12-31', 1),
   (9876543210987654, '2023-06-30', 2);

INSERT INTO efectivo (id_pago, divisa)
VALUES (1, 'euro');

-- FORZAMOS ERROR Y EL TRIGGER LO PILLA.
--INSERT INTO EMPLEADO (codigo_p, nombre, dni, id_dpto, id_grupoPracticas) VALUES
--  (99, 'Madoddnna', '119222333', 1, 1);