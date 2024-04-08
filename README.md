<details>
<summary>Español</summary>

# Formulario de Gestión de Libros

Este proyecto consiste en un formulario web desarrollado en Flask que permite a los usuarios registrar información sobre libros, como título, autor, género, año de publicación y editorial. Los datos ingresados en el formulario se almacenan en una base de datos DynamoDB de AWS.

Además, se implementa un flujo de datos automatizado utilizando los servicios de AWS. Un stream de DynamoDB alimenta un pipeline que envía los datos a una cola SQS. Desde allí, un Lambda es invocado para realizar transformaciones en los datos y luego almacenarlos en un bucket de Amazon S3.

Finalmente, los datos almacenados en S3 pueden ser consultados utilizando Amazon Athena para análisis y generación de informes.

Todo el sistema está desplegado y ejecutándose en una instancia EC2 de AWS, lo que proporciona una plataforma robusta y escalable para la gestión eficiente de libros y análisis de datos.

## Arquitectura en AWS

![Oppido Facundo-AWS](https://github.com/facuoppi/aws-event-project/assets/94979941/5d8dd275-d1d7-40d8-93df-7de378e856d6)

## Desplegando una Aplicación Flask en EC2 con Gunicorn y Nginx

Te llevaré paso a paso en la configuración de una aplicación Flask en una instancia de EC2, utilizando Gunicorn como el servidor WSGI y Nginx como un proxy inverso.

Vamos a profundizar un poco más en cada paso:

### Paso 1: Instalar Python Virtualenv

```bash
sudo apt-get update
sudo apt-get install python3-venv
```

Este paso se encarga de asegurarse de que tu instancia EC2 tenga todas las herramientas necesarias para crear y gestionar entornos virtuales para Python.

### Paso 2: Configurar el Entorno Virtual

```bash
mkdir project
cd project
python3 -m venv venv
source venv/bin/activate
```

Acá creamos un directorio para el proyecto y configuramos un entorno virtual dentro de él. Activar el entorno virtual aisla las dependencias del proyecto, evitando conflictos con otros proyectos de Python en la misma máquina.

### Paso 3: Instalar Flask

```bash
pip install flask
```

Esto instala el framework Flask dentro del entorno virtual, permitiéndote desarrollar aplicaciones web usando Python.

### Paso 4: Instalar Flask-WTF

```bash
pip install Flask-WTF
```
Extensión para Flask que proporciona integración con el paquete WTForms, una biblioteca de Python para la creación de formularios web. Flask-WTF simplifica la creación y validación de formularios HTML en aplicaciones Flask.

### Paso 5: Instalar boto3

```bash
pip install boto3
```
Interfaz de cliente de Python para interactuar con servicios en la nube de Amazon Web Services (AWS).

### Paso 6: Crear una API Simple con Flask (Clonar Repositorio de Github)

```bash
git clone https://github.com/facuoppi/aws-event-project.git
cd ..
mv project/aws-event-project/* project/
rm -r project/aws-event-project
```

Clonas el código de tu aplicación Flask desde un repositorio de GitHub.

```bash
cd project/
python app.py
```

Verificamos que la aplicación funcione asegura que tu API de Flask esté correctamente configurada.

### Paso 7: Instalar Gunicorn

```bash
pip install gunicorn
```

Gunicorn, o Green Unicorn, es un servidor WSGI para ejecutar aplicaciones Flask. Instalarlo es un paso crucial para desplegar una aplicación Flask lista para producción.

```bash
gunicorn -b 0.0.0.0:8000 app:app
```

Ejecutas Gunicorn, uniéndolo a la dirección 0.0.0.0:8000 y especificando el punto de entrada de tu aplicación Flask (app:app).

### Paso 8: Usar systemd para Administrar Gunicorn

Creas un archivo de unidad systemd para administrar el proceso de Gunicorn como un servicio.

```bash
sudo nano /etc/systemd/system/project.service
```

El archivo de unidad especifica el usuario, el directorio de trabajo y el comando para iniciar Gunicorn como un servicio.

```ini
[Unit]
Description=Gunicorn instance for a de-project
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/project
ExecStart=/home/ubuntu/project/venv/bin/gunicorn -b 0.0.0.0:8000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
```

De esta forma permitimos el trafico a nuestra aplicación.
Después de crear el archivo de unidad, habilitas e inicias el servicio de Gunicorn.

```bash
sudo systemctl daemon-reload
sudo systemctl start project
sudo systemctl enable project
```

### Paso 9: Ejecutar el Servidor Web Nginx

```bash
sudo apt-get install nginx
```

Nginx es un servidor web que actuará como un proxy inverso para tu aplicación Flask, reenviando las solicitudes a Gunicorn.

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

Iniciar y habilitar Nginx asegura que se ejecute automáticamente después de un reinicio del sistema.

```bash
sudo nano /etc/nginx/sites-available/default
```

Configuras Nginx editando su archivo de configuración predeterminado, especificando el servidor upstream (Gunicorn) y la ubicación para reenviar las solicitudes.

```nginx
upstream flask_project {
    server 127.0.0.1:5000;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        proxy_pass http://flask_project;
        try_files $uri $uri/ =404;
    }

    location /exito {
        alias /home/ubuntu/project/templates/;
        index exito.html;
        try_files $uri =404;
        allow all;
    }

    location /registrar_libro {
        proxy_pass http://flask_project;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Después de editar la configuración, reinicias Nginx para aplicar los cambios.

```bash
sudo systemctl restart nginx
```

Visitar la dirección IP pública de tu instancia EC2 en un navegador confirma que tu aplicación Flask ahora es accesible a través de Nginx, completando el proceso de implementación.

## Fin
¡Muchas gracias por tu visita! Espero que la información te haya sido útil. 😊
Puedes encontrarme en [LinkedIn](https://www.linkedin.com/in/facuoppi/).

## Licencia

Este proyecto está licenciado bajo la [Licencia MIT](LICENSE). Consulta el archivo `LICENSE` para obtener más detalles.

</details>

-----------------------

<details>
<summary>English with Español</summary>

# Book Management Form
This project (*Este proyecto*) consists of (*consiste en*) a web form (*un formulario web*) developed in (*desarrollado en*) Flask that (*que*) allows users (*permite a los usuarios*) to record information about books (*registrar información sobre libros*) like (*como*) title, author, genre, year of publication, and publisher (*título, autor, género, año de publicación y editorial*). The data (*Los datos*) entered (*ingresados*) in the form (*en el formulario*) is stored (*se almacenan*) in an AWS DynamoDB database (*base de datos*)


Additionally, an automated data flow is implemented using AWS services. A DynamoDB stream feeds a pipeline that sends data to an SQS queue. From there, a Lambda is invoked to perform transformations on the data and then store it in an Amazon S3 bucket.

Finally, data stored in S3 can be queried using Amazon Athena for analysis and reporting.

The entire system is deployed and running on an AWS EC2 instance, providing a robust and scalable platform for efficient ledger management and data analysis.


## Architecture in AWS
![Oppido Facundo-AWS](https://github.com/facuoppi/aws-event-project/assets/94979941/5d8dd275-d1d7-40d8-93df-7de378e856d6)

## Deploying a Flask Application on EC2 with Gunicorn and Nginx

I'll take you step by step through setting up a Flask application on an EC2 instance, using Gunicorn as the WSGI server and Nginx as a reverse proxy.

Let's go a little deeper into each step:

### Step 1: Install Python Virtualenv

```cmd
sudo apt-get update
sudo apt-get install python3-venv
```

This step is responsible for ensuring that your EC2 instance has all the necessary tools to create and manage virtual environments for Python.  


### Step 2: Configure the Virtual Environment
```cmd
mkdir project
cd project
python3 -m venv venv
source venv/bin/activate
```
Here we create a directory for the project and configure a virtual environment within it. Enabling the virtual environment isolates project dependencies, avoiding conflicts with other Python projects on the same machine.



### Step 3: Install Flask

```cmd
pip install flask
```
This installs the Flask framework within the virtual environment, allowing you to develop web applications using Python.

### Step 4: Install Flask-WTF

```cmd
pip install Flask-WTF
```

Extension for Flask that provides integration with the WTForms package, a Python library for creating web forms. Flask-WTF simplifies the creation and validation of HTML forms in Flask applications.


### Step 5: Install boto3

```cmd
pip install boto3 
```

Python client interface for interacting with Amazon Web Services (AWS) cloud services.

### Step 6: Create a Simple API with Flask (Clone Github Repository)

```cmd
git clone https://github.com/facuoppi/aws-event-project.git
cd ..
mv project/aws-event-project/* project/
rm -r project/aws-event-project
```

You clone your Flask application code from a GitHub repository.

```cmd
cd project/
python app.py
```

We verify that the application works ensures that your Flask API is correctly configured.

### Step 7: Install Gunicorn

```cmd
pip install gunicorn
```

Gunicorn, or Green Unicorn, is a WSGI server for running Flask applications. Installing it is a crucial step to deploy a production-ready Flask application.


```cmd
gunicorn -b 0.0.0.0:8000 app:app
```


Run Gunicorn, joining to the address 0.0.0.0:8000 and specifying the entry point of your Flask application (app:app).

### Step 8: Use systemd to Manage Gunicorn

Create a systemd unit file to manage the Gunicorn process as a service.

```bash
sudo nano /etc/systemd/system/project.service
```


The unit file specifies the user, working directory, and command to start Gunicorn as a service.

```ini
[Unit]
Description=Gunicorn instance for a de-project
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/project
ExecStart=/home/ubuntu/project/venv/bin/gunicorn -b 0.0.0.0:8000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
```


In this way we allow traffic to our application. After creating the unit file, you enable and start the Gunicorn service.

```bash 
sudo systemctl daemon-reload
sudo systemctl start project
sudo systemctl enable project
```

### Step 9: Execute Nginx Web Server

```bash
sudo apt-get install nginx
```

Nginx is a web server that will act as a reverse proxy for your Flask application, forwarding requests to Gunicorn.

```cmd
sudo systemctl start nginx
sudo systemctl enable nginx
```
Starting and enabling Nginx ensures that it runs automatically after a system reboot.
```bash
sudo nano /etc/nginx/sites-available/default
```

You configure Nginx by editing its default configuration file, specifying the upstream server (Gunicorn) and the location to forward requests.

```nginx
upstream flask_project {
    server 127.0.0.1:5000;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        proxy_pass http://flask_project;
        try_files $uri $uri/ =404;
    }

    location /exito {
        alias /home/ubuntu/project/templates/;
        index exito.html;
        try_files $uri =404;
        allow all;
    }

    location /registrar_libro {
        proxy_pass http://flask_project;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

After editing the configuration, restart Nginx to apply the changes.

```bash
sudo systemctl restart nginx
```

Visiting the public IP address of your EC2 instance in a browser confirms that your Flask application is now accessible through Nginx, completing the deployment process.

## Final

Thank you very much for your visit! I hope the information has been useful to you. 😊 

# License
Este proyecto está licenciado bajo la Licencia MIT. Consulta el archivo LICENSE para obtener más detalles.

</details>


