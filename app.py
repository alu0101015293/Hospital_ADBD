import os
import psycopg2 
from flask import Flask, render_template, request, url_for, redirect
from flask import jsonify

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        host='localhost',
        database="my_base2",
        user="postgres",
        password="hola123"
    )
    return conn

@app.route('/')
def index():
    return jsonify({'miembros': ['Marcelo Daniel Choque Mamani alu', 'Arturo Pestana Ortiz']})

### MOSTRAR TABLAS A UTILIZAR EN LA API ###
@app.route('/cliente/')
def cliente():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM cliente;')
    cliente = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify({'cliente': cliente})

@app.route('/paciente/')
def paciente():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM paciente;')
    paciente = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify({'paciente': paciente})

@app.route('/departamento/')
def departamento():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM departamento;')
    departamento = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify({'departamento': departamento})

@app.route('/empleado/')
def empleado():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM cliente;')
    empleado = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify({'empleado': empleado})

@app.route('/medico/')
def medico():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM medico;')
    medico = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify({'medico': medico})

@app.route('/auxiliar/')
def auxiliar():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM auxiliar;')
    auxiliar = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify({'auxiliar': auxiliar})

### DELETE POST PUT for cliente ###
@app.route('/cliente/<int:id_cliente>/<string:nombre>/<string:direccion>/<int:telefono>/<string:email>/', methods=["POST"])
def cliente_add(id_cliente, nombre, direccion, telefono, email):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute('INSERT INTO cliente (id_cliente, nombre, direccion, telefono, email)'
                    'VALUES (%s, %s, %s, %s, %s)',
                    (id_cliente, nombre, direccion, telefono, email))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"message": "Cliente agregado correctamente."}), 201
    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

@app.route('/cliente/<int:id_cliente>/', methods=["DELETE"])
def cliente_delete(id_cliente):
    conn = get_db_connection()
    try:
        cur = conn.cursor()
        cur.execute('DELETE FROM cliente WHERE id_cliente = %s', (id_cliente,))
        conn.commit()
        cur.close()
        conn.close()
        if cur.rowcount > 0:
            return jsonify({"message": "Cliente eliminado correctamente."})
        else:
            return jsonify({"message": "No se encontró el cliente asociado al id_cliente proporcionado."}), 404
    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

@app.route('/cliente/<int:id_cliente>/<string:nombre>/<string:direccion>/<int:telefono>/<string:email>/', methods=["PUT"])
def cliente_update(id_cliente, nombre, direccion, telefono, email):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        # Comprobar si se proporcionan datos para actualizar
        if not nombre or not direccion or not telefono or not email:
            return jsonify({"error": "Se requieren todos los campos para la actualización"}), 400  # 400 significa Bad Request
        
        # Actualizar el cliente en la base de datos
        cur.execute('UPDATE cliente SET nombre = %s, direccion = %s, telefono = %s, email = %s WHERE id_cliente = %s',
                    (nombre, direccion, telefono, email, id_cliente))
        
        conn.commit()
        cur.close()
        conn.close()
        
        if cur.rowcount > 0:
            return jsonify({"message": "Cliente actualizado correctamente."})
        else:
            return jsonify({"message": "No se encontró el cliente asociado al id_cliente proporcionado."}), 404

    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

### DELETE POST PUT for paciente ###
@app.route('/paciente/<int:id_paciente>/<string:nombre>/<string:fecha_nacimiento>/<string:genero>/<int:id_cliente>/', methods=["POST"])
def paciente_add(id_paciente, nombre, fecha_nacimiento, genero, id_cliente):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute('INSERT INTO paciente (id_paciente, nombre, fecha_nacimiento, genero, id_cliente)'
                    'VALUES (%s, %s, %s, %s, %s)',
                    (id_paciente, nombre, fecha_nacimiento, genero, id_cliente))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"message": "Paciente agregado correctamente."}), 201
    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

@app.route('/paciente/<int:id_paciente>/', methods=["DELETE"])
def paciente_delete(id_paciente):
    conn = get_db_connection()
    try:
        cur = conn.cursor()
        cur.execute('DELETE FROM paciente WHERE id_paciente = %s', (id_paciente,))
        conn.commit()
        cur.close()
        conn.close()
        if cur.rowcount > 0:
            return jsonify({"message": "Paciente eliminado correctamente."})
        else:
            return jsonify({"message": "No se encontró el paciente asociado al id_paciente proporcionado."}), 404
    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

@app.route('/paciente/<int:id_paciente>/<string:nombre>/<string:fecha_nacimiento>/<string:genero>/<int:id_cliente>/', methods=["PUT"])
def paciente_update(id_paciente, nombre, fecha_nacimiento, genero, id_cliente):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        # Comprobar si se proporcionan datos para actualizar
        if not nombre or not fecha_nacimiento or not genero or not id_cliente:
            return jsonify({"error": "Se requieren todos los campos para la actualización"}), 400  # 400 significa Bad Request
        
        # Actualizar el paciente en la base de datos
        cur.execute('UPDATE paciente SET nombre = %s, fecha_nacimiento = %s, genero = %s, id_cliente = %s WHERE id_paciente = %s',
                    (nombre, fecha_nacimiento, genero, id_cliente, id_paciente))
        
        conn.commit()
        cur.close()
        conn.close()
        
        if cur.rowcount > 0:
            return jsonify({"message": "Paciente actualizado correctamente."})
        else:
            return jsonify({"message": "No se encontró el paciente asociado al id_paciente proporcionado."}), 404

    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

### DELETE POST PUT for departamento ###
@app.route('/departamento/<int:id_dpto>/<string:nombre_dpto>/', methods=["POST"])
def departamento_add(id_dpto, nombre_dpto):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute('INSERT INTO departamento (id_dpto, nombre_dpto) VALUES (%s, %s)',
                    (id_dpto, nombre_dpto))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"message": "Departamento agregado correctamente."}), 201
    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

@app.route('/departamento/<int:id_dpto>/', methods=["DELETE"])
def departamento_delete(id_dpto):
    conn = get_db_connection()
    try:
        cur = conn.cursor()
        cur.execute('DELETE FROM departamento WHERE id_dpto = %s', (id_dpto,))
        conn.commit()
        cur.close()
        conn.close()
        if cur.rowcount > 0:
            return jsonify({"message": "Departamento eliminado correctamente."})
        else:
            return jsonify({"message": "No se encontró el departamento asociado al id_dpto proporcionado."}), 404
    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

@app.route('/departamento/<int:id_dpto>/<string:nombre_dpto>/', methods=["PUT"])
def departamento_update(id_dpto, nombre_dpto):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        # Comprobar si se proporcionan datos para actualizar
        if not nombre_dpto:
            return jsonify({"error": "Se requiere el campo 'nombre_dpto' para la actualización"}), 400  # 400 significa Bad Request
        
        # Actualizar el departamento en la base de datos
        cur.execute('UPDATE departamento SET nombre_dpto = %s WHERE id_dpto = %s',
                    (nombre_dpto, id_dpto))
        
        conn.commit()
        cur.close()
        conn.close()
        
        if cur.rowcount > 0:
            return jsonify({"message": "Departamento actualizado correctamente."})
        else:
            return jsonify({"message": "No se encontró el departamento asociado al id_dpto proporcionado."}), 404

    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

### DELETE POST PUT for empleado ###
@app.route('/empleado/<int:codigo_p>/<string:nombre>/<string:dni>/<int:id_dpto>/<int:id_grupoPracticas>/', methods=["POST"])
def empleado_add(codigo_p, nombre, dni, id_dpto, id_grupoPracticas):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute('INSERT INTO empleado (codigo_p, nombre, dni, id_dpto, id_grupoPracticas) VALUES (%s, %s, %s, %s, %s)',
                    (codigo_p, nombre, dni, id_dpto, id_grupoPracticas))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"message": "Empleado agregado correctamente."}), 201
    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

@app.route('/empleado/<int:codigo_p>/', methods=["DELETE"])
def empleado_delete(codigo_p):
    conn = get_db_connection()
    try:
        cur = conn.cursor()
        cur.execute('DELETE FROM empleado WHERE codigo_p = %s', (codigo_p,))
        conn.commit()
        cur.close()
        conn.close()
        if cur.rowcount > 0:
            return jsonify({"message": "Empleado eliminado correctamente."})
        else:
            return jsonify({"message": "No se encontró el empleado asociado al código proporcionado."}), 404
    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

@app.route('/empleado/<int:codigo_p>/<string:nombre>/<string:dni>/<int:id_dpto>/<int:id_grupoPracticas>/', methods=["PUT"])
def empleado_update(codigo_p, nombre, dni, id_dpto, id_grupoPracticas):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        # Comprobar si se proporcionan datos para actualizar
        if not nombre or not dni or not id_dpto or not id_grupoPracticas:
            return jsonify({"error": "Se requieren todos los campos para la actualización"}), 400  # 400 significa Bad Request
        
        # Actualizar el empleado en la base de datos
        cur.execute('UPDATE empleado SET nombre = %s, dni = %s, id_dpto = %s, id_grupoPracticas = %s WHERE codigo_p = %s',
                    (nombre, dni, id_dpto, id_grupoPracticas, codigo_p))
        
        conn.commit()
        cur.close()
        conn.close()
        
        if cur.rowcount > 0:
            return jsonify({"message": "Empleado actualizado correctamente."})
        else:
            return jsonify({"message": "No se encontró el empleado asociado al código proporcionado."}), 404

    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

### DELETE POST PUT for medico ###
@app.route('/medico/<int:codigo_p>/<string:especialidad>/', methods=["POST"])
def medico_add(codigo_p, especialidad):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute('INSERT INTO medico (codigo_p, especialidad) VALUES (%s, %s)',
                    (codigo_p, especialidad))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"message": "Médico agregado correctamente."}), 201
    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

@app.route('/medico/<int:codigo_p>/', methods=["DELETE"])
def medico_delete(codigo_p):
    conn = get_db_connection()
    try:
        cur = conn.cursor()
        cur.execute('DELETE FROM medico WHERE codigo_p = %s', (codigo_p,))
        conn.commit()
        cur.close()
        conn.close()
        if cur.rowcount > 0:
            return jsonify({"message": "Médico eliminado correctamente."})
        else:
            return jsonify({"message": "No se encontró el médico asociado al código proporcionado."}), 404
    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

@app.route('/medico/<int:codigo_p>/<string:especialidad>/', methods=["PUT"])
def medico_update(codigo_p, especialidad):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        # Comprobar si se proporcionan datos para actualizar
        if not especialidad:
            return jsonify({"error": "Se requiere la especialidad para la actualización"}), 400  # 400 significa Bad Request
        
        # Actualizar el médico en la base de datos
        cur.execute('UPDATE medico SET especialidad = %s WHERE codigo_p = %s',
                    (especialidad, codigo_p))
        
        conn.commit()
        cur.close()
        conn.close()
        
        if cur.rowcount > 0:
            return jsonify({"message": "Médico actualizado correctamente."})
        else:
            return jsonify({"message": "No se encontró el médico asociado al código proporcionado."}), 404

    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

### DELETE POST PUT for auxiliar ###
@app.route('/auxiliar/<int:codigo_p>/', methods=["POST"])
def auxiliar_add(codigo_p):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute('INSERT INTO auxiliar (codigo_p) VALUES (%s)', (codigo_p,))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"message": "Auxiliar agregado correctamente."}), 201
    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

@app.route('/auxiliar/<int:codigo_p>/', methods=["DELETE"])
def auxiliar_delete(codigo_p):
    conn = get_db_connection()
    try:
        cur = conn.cursor()
        cur.execute('DELETE FROM auxiliar WHERE codigo_p = %s', (codigo_p,))
        conn.commit()
        cur.close()
        conn.close()
        if cur.rowcount > 0:
            return jsonify({"message": "Auxiliar eliminado correctamente."})
        else:
            return jsonify({"message": "No se encontró el auxiliar asociado al código proporcionado."}), 404
    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500

@app.route('/auxiliar/<int:codigo_p>/', methods=["PUT"])
def auxiliar_update(codigo_p):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        # No hay datos para actualizar, simplemente confirmamos que el registro existe
        cur.execute('SELECT * FROM auxiliar WHERE codigo_p = %s', (codigo_p,))
        result = cur.fetchone()
        
        if result:
            return jsonify({"message": "Auxiliar actualizado correctamente."})
        else:
            return jsonify({"message": "No se encontró el auxiliar asociado al código proporcionado."}), 404

    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": str(e)}), 500