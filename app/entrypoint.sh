#!/bin/sh

if [ "$DEBUG" = "False" ]; then

  echo "Waiting for MariaDB ...."
  while ! nc -z $MARIADB_HOST $MARIADB_PORT; do
    sleep 0.1
  done
  echo "MariaDB started"

  echo "Apply database migrations ...."
  python manage.py migrate --no-input
  
fi

echo "Collect static files ...."
python manage.py collectstatic --noinput

exec uwsgi --ini uwsgi.ini