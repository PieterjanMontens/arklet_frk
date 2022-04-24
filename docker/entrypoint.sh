#!/usr/bin/env bash
# Getting static files for Admin panel hosting!
set -e

# Wait a bit while DB is spinning up
echo "pg_isready -h $ARKLET_POSTGRES_HOST -p $ARKLET_POSTGRES_PORT"
while ! pg_isready -h $ARKLET_POSTGRES_HOST -p $ARKLET_POSTGRES_PORT; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 1
done

# Following rules depend on what you expect from django dev docker
# ./manage.py collectstatic --noinput
# ./manage.py compress --force

./manage.py migrate

case "$ENV" in
    "dev")
        # Run the Django development server
        ./manage.py runserver 0.0.0.0:$ARKLET_PORT
        ;;
    "prod")
        # Run the Gunicorn production server
        ./manage.py collectstatic --noinput
        gunicorn arklet.wsgi:application -w 2 -b :$ARKLET_PORT --reload
        ;;
    *)
        echo "Wrong environment defined, check ENV value (prod|dev)"
        exit 1
        ;;
esac
