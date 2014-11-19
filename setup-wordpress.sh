#!/bin/bash

if [[ -z "$DB_PORT_3306_TCP_ADDR" ]] ; then
  echo '$DB_PORT_3306_TCP_ADDR environmental variable not set'
  echo 'Is this container linked with the database container as "db"?'
  exit 1
fi

DBYAML='/root/.secret/dbdata.yaml'

DB_NAME="$(grep name dbdata.yaml |awk '{print $2}')"
DB_USER='root'
DB_PASS="$(grep mysql dbdata.yaml |awk '{print $2}')"
DB_HOST=$DB_PORT_3306_TCP_ADDR

if [[ "$(/bin/ls -A /var/www/html)" ]] ; then
  /bin/echo "SOMETHING ALREADY INSTALLED IN '/var/www/html'"
  exit 1
else
  cd /
  /bin/tar -xz -C /var/www/html --strip-components=1 -f /latest.tar.gz

  /bin/sed -e "s/database_name_here/$DB_NAME/
  s/username_here/$DB_USER/
  s/password_here/$DB_PASS/
  s/localhost/$DB_HOST/
  /'AUTH_KEY'/s/put your unique phrase here/$(pwgen -c -n -1 65)/
  /'SECURE_AUTH_KEY'/s/put your unique phrase here/$(pwgen -c -n -1 65)/
  /'LOGGED_IN_KEY'/s/put your unique phrase here/$(pwgen -c -n -1 65)/
  /'NONCE_KEY'/s/put your unique phrase here/$(pwgen -c -n -1 65)/
  /'AUTH_SALT'/s/put your unique phrase here/$(pwgen -c -n -1 65)/
  /'SECURE_AUTH_SALT'/s/put your unique phrase here/$(pwgen -c -n -1 65)/
  /'LOGGED_IN_SALT'/s/put your unique phrase here/$(pwgen -c -n -1 65)/
  /'NONCE_SALT'/s/put your unique phrase here/$(pwgen -c -n -1 65)/" \
  /var/www/html/wp-config-sample.php > /var/www/html/wp-config.php

  # UID 48 is Apache on RHEL-based servers
  # We can set UID 48 even if the user doesn't exist
  /bin/chown -R 48 /var/www/html
fi
