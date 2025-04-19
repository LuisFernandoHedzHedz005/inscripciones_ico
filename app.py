from flask import Flask, render_template, request, redirect, flash, session, url_for
import mysql.connector
from mysql.connector import Error
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'mensajes'

# Conexión a la base de datos
def get_db_connection():
    try:
        conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password='Dracohunter#190603',
            database='ico_ins'
        )
        return conn
    except Error as e:
        print(f"Error al conectar a MySQL: {e}")
        return None

@app.route('/', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        num_cta = request.form['num_cta']
        contrasena = request.form['contrasena']
        
        # Validar credenciales
        conn = get_db_connection()
        if conn:
            try:
                cursor = conn.cursor(dictionary=True)
                query = "SELECT * FROM alumno WHERE num_cta = %s AND contrasena = %s"
                cursor.execute(query, (num_cta, contrasena))
                alumno = cursor.fetchone()
                
                if alumno:
                    # Credenciales correctas
                    session['logged_in'] = True
                    session['user_id'] = alumno['id_alumno']
                    session['num_cta'] = alumno['num_cta']
                    session['nombre'] = alumno['nombre']
                    session['semestre'] = alumno['semestre']
                    flash('Has iniciado sesión correctamente', 'success')
                    return redirect(url_for('inscripciones'))
                else:
                    # Credenciales incorrectas
                    flash('Número de cuenta o contraseña incorrectos', 'danger')
            except Error as e:
                flash(f'Error en la base de datos: {e}', 'danger')
            finally:
                cursor.close()
                conn.close()
        else:
            flash('Error de conexión a la base de datos', 'danger')
    
    return render_template('login.html')

@app.route('/inscripciones')
def inscripciones():
    # Verificar si el usuario ha iniciado sesión
    if not session.get('logged_in'):
        flash('Debes iniciar sesión para acceder', 'warning')
        return redirect(url_for('login'))
    
    # Obtener materias inscritas por el alumno
    materias_inscritas = obtener_materias_inscritas(session['user_id'])
    
    # Obtener materias disponibles para su semestre
    materias_disponibles = obtener_materias_disponibles(session['user_id'], session['semestre'])
    
    return render_template('inscripciones.html', 
                          materias_inscritas=materias_inscritas,
                          materias_disponibles=materias_disponibles)

@app.route('/mi_horario')
def mi_horario():
    # Verificar si el usuario ha iniciado sesión
    if not session.get('logged_in'):
        flash('Debes iniciar sesión para acceder', 'warning')
        return redirect(url_for('login'))
    
    # Obtener el horario completo del alumno
    horario = obtener_horario_alumno(session['user_id'])
    
    return render_template('mi_horario.html', horario=horario)

def obtener_horario_alumno(id_alumno):
    conn = get_db_connection()
    if not conn:
        return []
    
    try:
        cursor = conn.cursor(dictionary=True)
        
        # Primero obtenemos las materias inscritas con sus datos básicos
        query_materias = """
        SELECT 
            asig.id_asignatura,
            asig.nombre,
            g.clave,
            ag.id_asignatura_grupo,
            CONCAT(p.nombre, ' ', p.paterno) AS profesor
        FROM 
            inscripciones i
        JOIN 
            asignatura_grupo ag ON i.id_asignatura_grupo = ag.id_asignatura_grupo
        JOIN 
            asignatura asig ON ag.id_asignatura = asig.id_asignatura
        JOIN 
            grupo g ON ag.id_grupo = g.id_grupo
        JOIN 
            profesor p ON ag.id_profesor = p.id_prof
        WHERE 
            i.id_alumno = %s
        ORDER BY 
            asig.nombre
        """
        cursor.execute(query_materias, (id_alumno,))
        materias = cursor.fetchall()
        
        # Ahora para cada materia, obtenemos sus horarios
        for materia in materias:
            # Inicializamos los días vacíos
            materia['lunes'] = ''
            materia['martes'] = ''
            materia['miercoles'] = ''
            materia['jueves'] = ''
            materia['viernes'] = ''
            materia['sabado'] = ''
            materia['domingo'] = ''
            
            # Consultamos los horarios de la materia
            query_horario = """
            SELECT 
                ds.nombre AS dia,
                h.hora_inicio,
                h.hora_fin,
                s.nombre_salon
            FROM 
                horario h
            JOIN 
                dia_semana ds ON h.id_dia = ds.id_dia
            JOIN 
                salon s ON h.id_salon = s.id_salon
            WHERE 
                h.id_asignatura_grupo = %s
            ORDER BY 
                ds.id_dia, h.hora_inicio
            """
            cursor.execute(query_horario, (materia['id_asignatura_grupo'],))
            horarios = cursor.fetchall()
            
            # Organizamos los horarios por día
            for horario in horarios:
                dia = horario['dia'].lower()
                hora_inicio = str(horario['hora_inicio']).split(':')[:2]
                hora_inicio = ':'.join(hora_inicio)
                hora_fin = str(horario['hora_fin']).split(':')[:2]
                hora_fin = ':'.join(hora_fin)
                salon = horario['nombre_salon']
                
                info_horario = f"{hora_inicio}-{hora_fin} {salon}"
                
                if dia == 'lunes':
                    materia['lunes'] = info_horario
                elif dia == 'martes':
                    materia['martes'] = info_horario
                elif dia == 'miércoles' or dia == 'miercoles':
                    materia['miercoles'] = info_horario
                elif dia == 'jueves':
                    materia['jueves'] = info_horario
                elif dia == 'viernes':
                    materia['viernes'] = info_horario
                elif dia == 'sábado' or dia == 'sabado':
                    materia['sabado'] = info_horario
                elif dia == 'domingo':
                    materia['domingo'] = info_horario
        
        return materias
    except Error as e:
        print(f"Error al obtener horario: {e}")
        return []
    finally:
        cursor.close()
        conn.close()

def obtener_materias_inscritas(id_alumno):
    conn = get_db_connection()
    if not conn:
        return []
    
    try:
        cursor = conn.cursor(dictionary=True)
        query = """
        SELECT 
            i.id_inscripcion,
            asig.id_asignatura,
            asig.nombre,
            g.clave,
            CONCAT(p.nombre, ' ', p.paterno) AS profesor
        FROM 
            inscripciones i
        JOIN 
            asignatura_grupo ag ON i.id_asignatura_grupo = ag.id_asignatura_grupo
        JOIN 
            asignatura asig ON ag.id_asignatura = asig.id_asignatura
        JOIN 
            grupo g ON ag.id_grupo = g.id_grupo
        JOIN 
            profesor p ON ag.id_profesor = p.id_prof
        WHERE 
            i.id_alumno = %s
        ORDER BY 
            asig.nombre
        """
        cursor.execute(query, (id_alumno,))
        return cursor.fetchall()
    except Error as e:
        print(f"Error: {e}")
        return []
    finally:
        cursor.close()
        conn.close()

def obtener_materias_disponibles(id_alumno, semestre):
    conn = get_db_connection()
    if not conn:
        return []
    
    try:
        cursor = conn.cursor(dictionary=True)
        query = """
        SELECT 
            ag.id_asignatura_grupo,
            asig.id_asignatura,
            asig.nombre,
            g.clave,
            CONCAT(p.nombre, ' ', p.paterno) AS profesor,
            g.cupo
        FROM 
            asignatura_grupo ag
        JOIN 
            asignatura asig ON ag.id_asignatura = asig.id_asignatura
        JOIN 
            grupo g ON ag.id_grupo = g.id_grupo
        JOIN 
            profesor p ON ag.id_profesor = p.id_prof
        WHERE 
            asig.semestre = %s
            AND ag.id_asignatura_grupo NOT IN (
                SELECT id_asignatura_grupo FROM inscripciones WHERE id_alumno = %s
            )
        ORDER BY 
            asig.nombre, g.clave
        """
        cursor.execute(query, (semestre, id_alumno))
        return cursor.fetchall()
    except Error as e:
        print(f"Error: {e}")
        return []
    finally:
        cursor.close()
        conn.close()

@app.route('/inscribir', methods=['POST'])
def inscribir():
    if not session.get('logged_in'):
        flash('Debes iniciar sesión para realizar esta acción', 'warning')
        return redirect(url_for('login'))
    
    id_asignatura_grupo = request.form['id_asignatura_grupo']
    id_alumno = session['user_id']
    
    conn = get_db_connection()
    if not conn:
        flash('Error de conexión a la base de datos', 'danger')
        return redirect(url_for('inscripciones'))
    
    try:
        cursor = conn.cursor(dictionary=True)
        
        # Verificar el cupo disponible
        query_cupo = """
        SELECT g.cupo FROM asignatura_grupo ag
        JOIN grupo g ON ag.id_grupo = g.id_grupo
        WHERE ag.id_asignatura_grupo = %s
        """
        cursor.execute(query_cupo, (id_asignatura_grupo,))
        resultado = cursor.fetchone()
        
        if not resultado or resultado['cupo'] <= 0:
            flash('No hay cupo disponible para esta materia', 'danger')
            return redirect(url_for('inscripciones'))
        
        # Verificar si el alumno ya tiene 5 materias inscritas
        query_count = "SELECT COUNT(*) as total FROM inscripciones WHERE id_alumno = %s"
        cursor.execute(query_count, (id_alumno,))
        resultado = cursor.fetchone()
        
        if resultado['total'] >= 5:
            flash('Ya tienes el máximo de 5 materias inscritas', 'warning')
            return redirect(url_for('inscripciones'))
        
        # Verificar traslapes de horario
        query_traslape = """
        SELECT COUNT(*) as traslapes FROM horario h1
        JOIN asignatura_grupo ag1 ON h1.id_asignatura_grupo = ag1.id_asignatura_grupo
        JOIN inscripciones i ON ag1.id_asignatura_grupo = i.id_asignatura_grupo
        JOIN horario h2 ON h2.id_dia = h1.id_dia
        WHERE i.id_alumno = %s 
        AND h2.id_asignatura_grupo = %s
        AND ((h1.hora_inicio < h2.hora_fin) AND (h1.hora_fin > h2.hora_inicio))
        """
        cursor.execute(query_traslape, (id_alumno, id_asignatura_grupo))
        resultado = cursor.fetchone()
        
        if resultado['traslapes'] > 0:
            flash('Hay un traslape de horario con otra materia inscrita', 'danger')
            return redirect(url_for('inscripciones'))
        
        # Realizar la inscripción
        query_insert = """
        INSERT INTO inscripciones (id_alumno, id_asignatura_grupo, fecha_inscripcion)
        VALUES (%s, %s, %s)
        """
        fecha_actual = datetime.now()
        cursor.execute(query_insert, (id_alumno, id_asignatura_grupo, fecha_actual))
        
        conn.commit()
        flash('Te has inscrito correctamente a la materia', 'success')
    except Error as e:
        conn.rollback()
        flash(f'Error al inscribir: {e}', 'danger')
    finally:
        cursor.close()
        conn.close()
    
    return redirect(url_for('inscripciones'))

@app.route('/dar_baja', methods=['POST'])
def dar_baja():
    if not session.get('logged_in'):
        flash('Debes iniciar sesión para realizar esta acción', 'warning')
        return redirect(url_for('login'))
    
    id_inscripcion = request.form['id_inscripcion']
    id_alumno = session['user_id']
    
    conn = get_db_connection()
    if not conn:
        flash('Error de conexión a la base de datos', 'danger')
        return redirect(url_for('inscripciones'))
    
    try:
        cursor = conn.cursor()
        
        # Verificar que la inscripción pertenezca al alumno
        query_check = """
        SELECT id_inscripcion FROM inscripciones 
        WHERE id_inscripcion = %s AND id_alumno = %s
        """
        cursor.execute(query_check, (id_inscripcion, id_alumno))
        resultado = cursor.fetchone()
        
        if not resultado:
            flash('No tienes permiso para dar de baja esta materia', 'danger')
            return redirect(url_for('inscripciones'))
        
        # Dar de baja la materia
        query_delete = "DELETE FROM inscripciones WHERE id_inscripcion = %s"
        cursor.execute(query_delete, (id_inscripcion,))
        
        conn.commit()
        flash('Has dado de baja la materia correctamente', 'success')
    except Error as e:
        conn.rollback()
        flash(f'Error al dar de baja: {e}', 'danger')
    finally:
        cursor.close()
        conn.close()
    
    return redirect(url_for('inscripciones'))

@app.route('/horarios')
def horarios():
    # Verificar si el usuario ha iniciado sesión
    if not session.get('logged_in'):
        flash('Debes iniciar sesión para acceder', 'warning')
        return redirect(url_for('login'))
    
    # Obtener horarios para todos los semestres (del 1 al 9)
    horarios_por_semestre = {}
    for semestre in range(1, 10):
        horarios_por_semestre[str(semestre)] = obtener_horarios_por_semestre(str(semestre))
    
    return render_template('horarios.html', horarios_por_semestre=horarios_por_semestre)

def obtener_horarios_por_semestre(semestre):
    conn = get_db_connection()
    if not conn:
        return []
    
    try:
        cursor = conn.cursor(dictionary=True)
        
        # Consulta para obtener todas las asignaturas con su información completa
        query = """
        SELECT 
            asig.id_asignatura AS clave,
            asig.nombre AS materia,
            CONCAT(p.nombre, ' ', p.paterno) AS profesor,
            g.clave AS grupo,
            g.cupo,
            ag.id_asignatura_grupo
        FROM 
            asignatura_grupo ag
        JOIN 
            asignatura asig ON ag.id_asignatura = asig.id_asignatura
        JOIN 
            grupo g ON ag.id_grupo = g.id_grupo
        JOIN 
            profesor p ON ag.id_profesor = p.id_prof
        WHERE 
            asig.semestre = %s
        ORDER BY 
            asig.nombre, g.clave
        """
        cursor.execute(query, (semestre,))
        materias = cursor.fetchall()
        
        # Para cada materia, obtenemos sus horarios y salon
        for materia in materias:
            # Inicializamos los días vacíos
            materia['lunes'] = ''
            materia['martes'] = ''
            materia['miercoles'] = ''
            materia['jueves'] = ''
            materia['viernes'] = ''
            materia['sabado'] = ''
            materia['salon'] = ''
            
            # Consultamos los horarios de la materia
            query_horario = """
            SELECT 
                ds.nombre AS dia,
                h.hora_inicio,
                h.hora_fin,
                s.nombre_salon
            FROM 
                horario h
            JOIN 
                dia_semana ds ON h.id_dia = ds.id_dia
            JOIN 
                salon s ON h.id_salon = s.id_salon
            WHERE 
                h.id_asignatura_grupo = %s
            ORDER BY 
                ds.id_dia, h.hora_inicio
            """
            cursor.execute(query_horario, (materia['id_asignatura_grupo'],))
            horarios = cursor.fetchall()
            
            # Organizamos los horarios por día
            for horario in horarios:
                dia = horario['dia'].lower()
                hora_inicio = str(horario['hora_inicio']).split(':')[:2]
                hora_inicio = ':'.join(hora_inicio)
                hora_fin = str(horario['hora_fin']).split(':')[:2]
                hora_fin = ':'.join(hora_fin)
                salon = horario['nombre_salon']
                
                # Si no hay salón asignado, lo guardamos
                if not materia['salon']:
                    materia['salon'] = salon
                
                info_horario = f"{hora_inicio}-{hora_fin}"
                
                if dia == 'lunes':
                    materia['lunes'] = info_horario
                elif dia == 'martes':
                    materia['martes'] = info_horario
                elif dia == 'miércoles' or dia == 'miercoles':
                    materia['miercoles'] = info_horario
                elif dia == 'jueves':
                    materia['jueves'] = info_horario
                elif dia == 'viernes':
                    materia['viernes'] = info_horario
                elif dia == 'sábado' or dia == 'sabado':
                    materia['sabado'] = info_horario
        
        return materias
    except Error as e:
        print(f"Error al obtener horarios: {e}")
        return []
    finally:
        cursor.close()
        conn.close()

@app.route('/logout')
def logout():
    session.clear()
    flash('Has cerrado sesión correctamente', 'info')
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(debug=True)