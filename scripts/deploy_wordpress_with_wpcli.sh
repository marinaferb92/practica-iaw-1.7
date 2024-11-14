#!/bin/bash

# Para mostrar los comandos que se van ejecutando
set -ex

# Cargamos las variables
source .env

#Borramos descargas previas de WP-CLI
rm -rf /tmp/wp-cli.phar

#Descargamos el archivo wp-cli.phar
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp

#Asignamos permisos de ejecución al archivo 
chmod +x /tmp/wp-cli.phar

#Movemos el script WP-CLI al directorio /usr/local/bin
mv /tmp/wp-cli.phar /usr/local/bin/wp

#Borramos instalaciones previas en /var/www/html

rm -rf $WORDPRESS_DIRECTORY*

# Descargamos el codigo fuente de Wordpress 
wp core download \
  --locale=es_ES \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root

# Crear la base de datos y el usuario para Wordpress
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

wp config create \
  --dbname=$WORDPRESS_DB_NAME \
  --dbuser=$WORDPRESS_DB_USER \
  --dbpass=$WORDPRESS_DB_PASSWORD \
  --dbhost=$WORDPRESS_DB_HOST \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root

wp core install \
  --url=practica-wordpress.ddns.net \
  --title="IAW" \
  --admin_user=admin \
  --admin_password=admin_password \
  --admin_email=test@test.com \
  --path=/var/www/html \
  --allow-root 