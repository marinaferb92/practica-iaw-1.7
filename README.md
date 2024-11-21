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

1. Cargamos el archivo de variables
   
El primer paso de nuestro script sera crear un archivo de variable ``` . env ``` donde iremos definiendo las diferentes variables que necesitemos, y cargarlo en el entorno del script.

``` source.env ```


2. Configuramos el script
   
Configuraremos el script para que en caso de que haya errores en algun comando este se detenga ```-e```, ademas de que para que nos muestre los comando antes de ejecutarlos ```-x```.

``` set -ex ```


3. Borramos descargas previas de WP-CLI

Con este comando nos aseguramos de que se borre cualquier descarga anterior de Cli, por si tenemos que ejecutar el script varias veces que no haya mas paquetes de los necesarios ocupando espacio.

````
rm -rf /tmp/wp-cli.phar
````
4. Descargamos el archivo wp-cli.phar

Descargamos el ejecutable WP-CLI desde su repositorio oficial. 

````
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp
````

5. Asignamos permisos de ejecución al archivo

Le asignamos a archivo permisos de ejecución para que pueda ejecutarse como un programa.

````
chmod +x /tmp/wp-cli.phar
````


6. Movemos el script WP-CLI al directorio /usr/local/bin

Movemos desde */tmp/wp-cli.phar* a  */usr/local/bin* renombradolo como **wp**, colocandolo en un directorio global. Esto nos permitira utilizar ````wp```` como si fuera un comando sin tener que usar la ruta completa */tmp/wp-cli.phar* cada vez que queramos usar WP-CLI. 


````
mv /tmp/wp-cli.phar /usr/local/bin/wp
````


7. Borramos instalaciones previas en /var/www/html

A continuación borraremos todos los archivos en el directorio donde se instalará Wordpress, asegurando que no queden archivos ni instalaciones anteriores que interfieran con la nueva instalación.

- *$WORDPRESS_DIRECTORY* estará definida en el archivo .env como ````/var/www/html```` que será el directorio donde tiene que descargarse Wordpress.

````
rm -rf $WORDPRESS_DIRECTORY*
````

8. Descargamos el codigo fuente de Wordpress

Utilizamos el comando wp para realizar la descargas los archivos prncipales de Wordpress.
- *--locale=es_ES* indicamos que queremos descargar la versión en Español.

  - Si quisieramos otro idioma, podemos usar otros códigos:

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


9. Crear la base de datos y el usuario para Wordpress

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
wp config create \
  --dbname=$WORDPRESS_DB_NAME \
  --dbuser=$WORDPRESS_DB_USER \
  --dbpass=$WORDPRESS_DB_PASSWORD \
  --dbhost=$WORDPRESS_DB_HOST \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root

wp core install \
  --url=$LE_DOMAIN \
  --title="$WORDPRESS_TITLE" \
  --admin_user=$WORDPRESS_ADMIN_USER \
  --admin_password=$WORDPRESS_ADMIN_PASS \
  --admin_email=$WORDPRESS_ADMIN_EMAIL \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root

#intalamos un tema 
wp theme install mindscape --activate --path=$WORDPRESS_DIRECTORY --allow-root

#instalamos un plugging
wp plugin install wps-hide-login --activate --path=$WORDPRESS_DIRECTORY --allow-root

#configuramos el plugging
wp option update whl_page "$WORDPRESS_HIDE_LOGIN_URL" --path=$WORDPRESS_DIRECTORY --allow-root

#configurar los enlaces permanentes con el nombre de las entradas
wp rewrite structure '/%postname%/'  --path=$WORDPRESS_DIRECTORY --allow-root

#Copiamos el archivo .htaccess
cp ../htaccess/.htaccess $WORDPRESS_DIRECTORY

#damos permisos a www-data
chown -R www-data:www-data /var/www/html
















