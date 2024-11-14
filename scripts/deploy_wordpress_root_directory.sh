#!/bin/bash
source .env

# Para mostrar los comandos que se van ejecutando.
set -ex

# Descargar la URL de WordPress, después de comprobar su funcionamiento.
# Descargamos el código fuente de WordPress.
wget http://wordpress.org/latest.tar.gz -P /tmp

# Borramos instalaciones previas de WordPress en el directorio de destino.
rm -rf /var/www/html/*

# Extraemos el archivo descargado.
tar -xzvf /tmp/latest.tar.gz -C /tmp

# Movemos el contenido de WordPress al directorio de destino.
mv -f /tmp/wordpress/* /var/www/html

# Eliminamos los archivos temporales.
rm -rf /tmp/latest.tar.gz /tmp/wordpress


cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

#Creamos una base de datos.
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"


#Configuramos el archivo de configuración de Wordpress

sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php

#Cambiar propietario y grupo del directorio.

chown -R www-data:www-data /var/www/html/

# Habilitar el módulo mod_rewrite de Apache
a2enmod rewrite

# Reiniciar Apache para aplicar los cambios
systemctl restart apache2