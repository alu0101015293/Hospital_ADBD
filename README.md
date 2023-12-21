## Pasos a seguir para que la APIRest en Flask funcione:

### 1. Cargar nuestra base de datos y nuestro script de SQL:
```bash
sudo -u postgres psql -d my_base2 -a -f hospital.sql  # Carga nuestro database desde nuestro script
\i Parking_BBDD.sql  # Ejecutar el script
```

### 2. Crear el entorno virtual para Python:
```bash
python3 -m venv venv  # Crear el entorno virtual
source venv/bin/activate  # Activar el entorno virtual
pip install Flask psycopg2-binary  # Instalar las dependencias necesarias
```

### 3. Una vez esté configurado, seguir los siguientes pasos:
```bash
. venv/bin/activate  # Activar el entorno virtual (si no lo has hecho ya)
python3 app.py  # Ejecutar la aplicación Flask
flask --app app run --host 0.0.0.0 --port=8080  # Iniciar la API en el host y puerto especificados
```

### 4. Probar la API:
Una vez tengamos la API corriendo, abre tu navegador [Google Chrome](https://www.google.com/chrome/) y accede a [reqbin.com](https://reqbin.com/) para realizar las operaciones CRUD.
