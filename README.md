# practica-iaw-1.7
#Administración de Wordpress con la utilidad WP-CLI

##  1. Introducción
En esta práctica vamos a instalar y cofigurar la utilidad WP-CLI desde terminal, que es la interfaz de comandos de Wordpress.

Con ella podemos administrar muchas de las tareas de Wordpress sin usar un navegador web como: actualizar e instalar pluggings, cambiar los temas de la pagina, configurar instalaciones multisitios, etc.

En la web oficial de Wordpress estan disponibles tanto el manual de uso, como el de comandos de WP-CLI.

[MANUAL DE USO](https://make.wordpress.org/cli/handbook/)

[GUÍA DE COMANDOS](https://developer.wordpress.org/cli/commands/)

- Para ello el primer paso sera el de instalar la pila LAMP y configurar el Certificado SSL/TLS con Let’s Encrypt en la maquina donde vayamos a instalar WP-CLI.

## 2.Creacion de una instancia EC2 en AWS e instalacion de Pila LAMP
Para la realizacion de este apartado seguiremos los pasos detallados en la practica-iaw-1.1 y utilizaremos el script ``` install_lamp.sh ```.

**Esta vez tenemos la siguiente IP elastica para nuestra maquina**

  ![bNabA1Ww5l](https://github.com/user-attachments/assets/ec67113e-343c-4890-8086-6d0cb5e3d4e9)

[Practica-iaw-1.1](https://github.com/marinaferb92/practica-iaw-1.1/tree/main)

[Script Install LAMP](https://github.com/marinaferb92/practica-iaw-1.1/blob/main/scripts/install_lamp.sh)



Una vez hecho esto nos aseguraremos de que la Pila LAMP esta funcionando correctamente.

- Verificaremos el estado de apache.

  ![MMA4oyDdYV](https://github.com/user-attachments/assets/ef998254-f5f8-4bc1-b702-0e41621b0844)


- Entramos en mysql desde la terminal para ver que esta corriendo.

  ![jYkXAri0jN](https://github.com/user-attachments/assets/c919d2a4-aaa8-4241-838d-698ef3685a2e)



## 3. Registrar un Nombre de Dominio

Usamos un proveedor gratuito de nombres de dominio como son Freenom o No-IP.
En nuestro caso lo hemos hecho a traves de No-IP, nos hemos registrado en la página web y hemos registrado un nombre de dominio con la IP pública del servidor.


   ![TwkcTIoiNE](https://github.com/user-attachments/assets/f66b4d80-4c6e-4251-a12c-26303bfdcc00)


## 4. Instalar Certbot y Configurar el Certificado SSL/TLS con Let’s Encrypt
Para la realizacion de este apartado seguiremos los pasos detallados en la practica-iaw-1.5 y utilizaremos el script ``` setup_letsencrypt_certificate.sh ```.

[Practica-iaw-1.5](https://github.com/marinaferb92/practica-iaw-1.5)

[Script setup_letsencrypt_certificate.sh](scripts/setup_letsencrypt_certificate.sh)



# Instalación de WP-CLI en el servidor LAMP
Tras los pasos anteriores y que se hayan ejecutado exitosamente los scripts ``` install_lamp.sh ``` y ``` setup_letsencrypt_certificate.sh ```, comenzaremos a desarrollar del script para la instalación y configuración de WP-CLI. A continuación explicamos todos los comandos que se utilizan en el script:

### 1. Cargamos el archivo de variables
   
El primer paso de nuestro script sera crear un archivo de variable ``` . env ``` donde iremos definiendo las diferentes variables que necesitemos, y cargarlo en el entorno del script.

``` source.env ```


### 2. Configuramos el script
   
Configuraremos el script para que en caso de que haya errores en algun comando este se detenga ```-e```, ademas de que para que nos muestre los comando antes de ejecutarlos ```-x```.

``` set -ex ```


### 3. Borramos descargas previas de WP-CLI

Con este comando nos aseguramos de que se borre cualquier descarga anterior de Cli, por si tenemos que ejecutar el script varias veces que no haya mas paquetes de los necesarios ocupando espacio.

````
rm -rf /tmp/wp-cli.phar
````


### 4. Descargamos el archivo wp-cli.phar

Descargamos el ejecutable WP-CLI desde su repositorio oficial. 

````
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp
````


### 5. Asignamos permisos de ejecución al archivo

Le asignamos a archivo permisos de ejecución para que pueda ejecutarse como un programa.

````
chmod +x /tmp/wp-cli.phar
````


### 6. Movemos el script WP-CLI al directorio /usr/local/bin

Movemos desde */tmp/wp-cli.phar* a  */usr/local/bin* renombradolo como **wp**, colocandolo en un directorio global. Esto nos permitira utilizar ````wp```` como si fuera un comando sin tener que usar la ruta completa */tmp/wp-cli.phar* cada vez que queramos usar WP-CLI. 


````
mv /tmp/wp-cli.phar /usr/local/bin/wp
````


### 7. Borramos instalaciones previas en /var/www/html

A continuación borraremos todos los archivos en el directorio donde se instalará Wordpress, asegurando que no queden archivos ni instalaciones anteriores que interfieran con la nueva instalación.

- *$WORDPRESS_DIRECTORY* estará definida en el archivo .env como ````/var/www/html```` que será el directorio donde tiene que descargarse Wordpress.

````
rm -rf $WORDPRESS_DIRECTORY*
````

### 8. Descargamos el codigo fuente de Wordpress

Utilizamos el comando wp para realizar la descargas los archivos prncipales de Wordpress.
- *--locale=es_ES* indicamos que queremos descargar la versión en Español.

  - Si quisieramos descagarlo en otro idioma, podemos usar otros códigos como:

      - <ins>Inglés: --locale=en_US<ins>

      - <ins>Francés: --locale=fr_FR<ins>

      - <ins>Alemán: --locale=de_DE<ins>

- path=$WORDPRESS_DIRECTORY indicamos que queremos descargar Wordpress en la ruta $WORDPRESS_DIRECTORY, variable que estará definida en el archivo .env.
- *allow-root* indicamos que permitimos ejecutar Wordpress con el usuario root.

````
wp core download \
  --locale=es_ES \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root
````


### 9. Crear la base de datos y el usuario para Wordpress

**Configuramos la base de datos en MySQL usando comandos SQL enviados directamente a mysql. Cada línea tiene una función específica**:
-Eliminar la base de datos existente.
-Crear una nueva base de datos.
-Eliminar el usuario existente.
-Crear un nuevo usuario.
-Otorgar permisos al usuario.

Para esto deberemos configurar en el archivo ```` .env ```` las variables ```` WORDPRESS_DB_NAME, 
 WORDPRESS_DB_USER, WORDPRESS_DB_PASSWORD, IP_CLIENTE_MYSQL, WORDPRESS_DB_HOST````

````
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
````

### 10. Configuración de WordPress

A continuación, generaremos el archivo de configuración principal ``wp-config.php``, necesario para que Wordpress pueda conectarse a la base de datos.
El archivo contendrá las configuraciones y credenciales básicas para que Wordpress interactue con MySQL.
- <ins>dbname=$WORDPRESS_DB_NAME</ins>: Definimos el nombre de la base de datos 
- <ins>dbuser=$WORDPRESS_DB_USER</ins>: Especificamos el usuario con permisos para la base de datos.
- <ins>dbpass=$WORDPRESS_DB_PASSWORD</ins>: Definimos la contraseña de usuario de la base de datos.
- <ins>dbhost=$WORDPRESS_DB_HOST</ins>: Define la ubicación del servidor de la base de datos.
    - Localhost si MySQL esta en el mismo servidor Wordpress.
    - Otra dirección IP si esta en un servidor remoto.
- <ins>path=$WORDPRESS_DIRECTORY</ins>:Especifica el directorio donde se creará el archivo *wp-config.php*

````
wp config create \

  --dbname=$WORDPRESS_DB_NAME \
  
  --dbuser=$WORDPRESS_DB_USER \
  
  --dbpass=$WORDPRESS_DB_PASSWORD \
  
  --dbhost=$WORDPRESS_DB_HOST \
  
  --path=$WORDPRESS_DIRECTORY \
  
  --allow-root
````
  

 - Todas estas variables deberán estar definidas en nuestro archivo ``.env``.
   
### 11. Instalar WordPress

A continuación, completaremos la instalación de Wordpress con las tablas necesarias y las configuraciones de nombre del sitio, URL y las credenciales para el administrador.

- <ins>url=$LE_DOMAIN</ins>: ponemos la dirección del dominio que hemos reservado, define la URL  principal del sitio.
- <ins>title="$WORDPRESS_TITLE"</ins>: Definimos el nombre principal del sitio web.
- <ins>admin_user=$WORDPRESS_ADMIN_USER</ins>: crea al usuario administrador de Wordpress.
- <ins>admin_password=$WORDPRESS_ADMIN_PASS</ins>: definimos la contraseña del usuario administrador.
- <ins>admin_email=$WORDPRESS_ADMIN_EMAIL</ins>: especificamos el correo del administrador.
- <ins>path=$WORDPRESS_DIRECTORY</ins>: indicamos el directorio donde se instalará Wordpress.

  -Estas variables estarán definidas dentro del archivo *.env*.
  
````
wp core install \

  --url=$LE_DOMAIN \

  --title="$WORDPRESS_TITLE" \
  
  --admin_user=$WORDPRESS_ADMIN_USER \
  
  --admin_password=$WORDPRESS_ADMIN_PASS \
  
  --admin_email=$WORDPRESS_ADMIN_EMAIL \
  
  --path=$WORDPRESS_DIRECTORY \
  
  --allow-root
````

### 12. Instalamos un tema 

Ddesde la linea de comandos, ejecutamos ``wp theme list`` para ver los temas disponibles para Wordpress.

Hay una lista con los temas que tenemos disponibles. 

![ehil3cGFEa](https://github.com/user-attachments/assets/1b5d9269-cc58-4bad-b042-f8622d1fa786)


Una vez que hemos elegido uno ejecutamos el siguiente comando teniendo en cuenta el nombre (name) del tema que hemos elegido.
````
wp theme install twentytwentytwo --activate --path=$WORDPRESS_DIRECTORY --allow-root
````

El tema ha cambiado al entrar a Wordpress

![3KexUxe7WX](https://github.com/user-attachments/assets/ebb9324c-dbe4-4295-a227-9dcfe8695a84)

Tambien se puede comprbar desde las configuraciones.

![iat0ghqa9a](https://github.com/user-attachments/assets/a3141ffb-0550-4260-a79f-989221163ac2)


### 13. Instalamos y configuramos el plugging wps-hide-login 

Este plugging nos permite mejorar la seguridad de nuestro sitio web al cambiar la URL de inico de sesión predeterminado por Wordpress, por defecto cualquier usuario podria acceder a la pagina de inicio de sesión de Wordpress añadiendo ``/wp-login.php `` o ``/wp-admin``. Con el siguiente comando instalaremos el plugging y lo activaremos:

``
wp plugin install wps-hide-login --activate --path=$WORDPRESS_DIRECTORY --allow-root
``


A continuación tendremos que configurarlo para ponerle la URL que queremos para reemplazar la predeterminada, esto lo haremos definiendo una nueva variable en `.env` a la que llamaremos ``WORDPRESS_HIDE_LOGIN_URL``, donde pondremos el valor que queremos.

``
wp option update whl_page "$WORDPRESS_HIDE_LOGIN_URL" --path=$WORDPRESS_DIRECTORY --allow-root
``

Al entrar en la ruta que hemos definido comprobamos que ha cambiado correcctamente

![zves5XmWO9](https://github.com/user-attachments/assets/9a51125d-e821-4101-8eee-3d8c74902196)

### 13. Instalar y activamos el plugging Wordfence

Wordfence es una herramienta de seguridad que incuye un firewall, proteccion contra ataques de fuerza bruta, escaneo de malware, etc. Podemos Instalarla y activarla con el siguiente comando:

``
wp plugin install wordfence --activate --path=$WORDPRESS_DIRECTORY --allow-root
``

![ViHaYFwIDr](https://github.com/user-attachments/assets/feda1933-3e34-465f-9c1d-72fe34c165ac)


### 14. Configurar los enlaces permanentes con el nombre de las entradas

Configuramos la estructura de los enlaces permanentes (URLs) de Wordpress para que usen el nombre de las entradas (*postname*). Para que el sitio en vez de tener URLs tipo:

``https://ejemplo.com/?p=123``

Utilice URLs más legibles como:

``https://ejemplo.com/nombre-de-la-entrada``

*Esta estructura además es más facil de entender tambien para los motores de busqueda y mejora la posición en los resultados de busqueda en estos, al incluir palabras claves en URL.*

``
wp rewrite structure '/%postname%/'  --path=$WORDPRESS_DIRECTORY --allow-root
``


Desde Wordpress entrando en ajustes podemos ver que efectivamente se ha cambiado a %postname%

![9JLjsEVI1q](https://github.com/user-attachments/assets/a44a73e0-9707-4dee-9b5d-a57b42768b74)

Entrando en una de las entradas del blog vemos como ahora aparece el encabezado de esta como parte de la URL

![YE4WpgBtt3](https://github.com/user-attachments/assets/957b444d-4c66-4285-aad5-11a5e31341bc)



### 15. Copiamos el archivo .htaccess

Creamos un directory *htacces* y dentro de este creamos un archivo de configuración *.htaccess* con la siguiente estructura:

````
# BEGIN WordPress

<IfModule mod_rewrite.c>

RewriteEngine On

RewriteBase /

RewriteRule ^index\.php$ - [L]

RewriteCond %{REQUEST_FILENAME} !-f

RewriteCond %{REQUEST_FILENAME} !-d

RewriteRule . /index.php [L]

</IfModule>

# END WordPress

````

En el script escribiremos el siguiente comando, que copiara el archivo desde `/htaccess/.htaccess` al directorio especificado en la variable *$WORDPRESS_DIRECTORY* donde esta instalado Wordpress:

````
cp ../htaccess/.htaccess $WORDPRESS_DIRECTORY
````

### 16. Damos permisos a www-data

Con este comando cambiamos el propietario y el grupo de todos los archivos y directorios dentro de /var/www/html al usuario *www-data*. Este usuario es el que utiliza el servidor web Apache para poder leer, escribir y ejecutar los archivos del sitio web.

Además asegura que solo el servidor web tenga acceso directo.

````
chown -R www-data:www-data $WORDPRESS_DIRECTORY
````















