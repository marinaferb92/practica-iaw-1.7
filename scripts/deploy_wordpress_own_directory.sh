#!/bin/bash

# Cargamos las variables
source .env

# Para mostrar los comandos que se van ejecutando
set -ex

# Descargar la URL de WordPress
wget http://wordpress.org/latest.tar.gz -P /tmp

# Extraer el archivo descargado
tar -xzvf /tmp/latest.tar.gz -C /tmp

# Borrar instalaciones previas de WordPress
rm -rf /var/www/html/*

# Crear el directorio para la instalación de WordPress en el subdirectorio
mkdir -p /var/www/html/$WORDPRESS_DIRECTORY

# Mover el contenido de WordPress al directorio de destino
mv -f /tmp/wordpress/* /var/www/html/$WORDPRESS_DIRECTORY

# Copiar el archivo wp-config-sample.php y renombrarlo
cp /var/www/html/$WORDPRESS_DIRECTORY/wp-config-sample.php /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

# Crear la base de datos
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

# Configurar el archivo wp-config.php
sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

# Configurar WP_SITEURL y WP_HOME para el subdirectorio
sed -i "/DB_COLLATE/a define('WP_SITEURL', 'https://$CERTIFICATE_DOMAIN/$WORDPRESS_DIRECTORY');" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "/WP_SITEURL/a define('WP_HOME', 'https://$CERTIFICATE_DOMAIN/$WORDPRESS_DIRECTORY');" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

# Copiar el archivo index.php al directorio principal
cp /var/www/html/$WORDPRESS_DIRECTORY/index.php /var/www/html

# Configurar el archivo index.php
sed -i "s#wp-blog-header.php#$WORDPRESS_DIRECTORY/wp-blog-header.php#" /var/www/html/index.php

# Configurar las claves de seguridad
SECURITY_KEYS=$(curl https://api.wordpress.org/secret-key/1.1/salt/)
SECURITY_KEYS=$(echo $SECURITY_KEYS | tr / _)
sed -i "/@-/a $SECURITY_KEYS" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

# Configurar permisos
chown -R www-data:www-data /var/www/html/
chown -R www-data:www-data /var/www/html/$WORDPRESS_DIRECTORY/wp-content
chmod -R 755 /var/www/html/$WORDPRESS_DIRECTORY

# Habilitar el módulo mod_rewrite de Apache
a2enmod rewrite

# Reiniciar Apache
systemctl restart apache2

