#!/bin/bash

# Bootstrap example script

# - The parameter for the Bootstrap Script is the POS Directory.
USER=`whoami`
DJANGO_USER=${1:-admin}
DJANGO_PASS=${2:-admin}
DJANGO_EMAIL=${3:-admin@exaple.co}
DIRECTORY=${4:-pos}
DB_DATA=${5:-docker-datas}

SERVERIP=`ip a | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1`

if [ "$DJANGO_USER" == "" ] || [ "$DJANGO_PASS" == "" ] ; then
    echo -e "parameter must not be empty"
    echo -e "there are times that the bootstrap will ask for the os password since it's needed."
    echo -e 'usage: ./install_pos.sh "$DJANGO_USER" "$DJANGO_PASS" "$DIRECTORY" "$DB_DATA"'
    echo -e '$DJANGO_USER will be the superuser on pos-api admin.'
    echo -e '$DJANGO_PASS will be the password of superuser on pos-api admin.'
    echo -e '$DIRECTORY (optional)will be the name of the main dir, example pos as default or client name for custom name.'
    echo -e '$DB_DATA (optional)will be the name of the db data dir, example docker-datas as default or client name for db data custom name.'
    echo -e '$DIRECTORY -> (optional)pos or laundry_1'
    echo -e '$DB_DATA -> (optional)db_data or laundry_1_db_data'
    exit 1
fi
----------------------------------------------------------------------------

# Start the Bootstrap Process
echo "bootstrap process running ..."
echo "...install necessary tools and apps"
sudo apt-get install -y git curl wget ca-certificates

# Base Directory: All Directories will be below this point
BASE_DIRECTORY=/opt

# User Directory: That's the private directory for the user to be created, if none exists
POS_DIRECTORY=$BASE_DIRECTORY/$DIRECTORY
DB_DIRECTORY=$BASE_DIRECTORY/$DIRECTORY/$DB_DATA/pos-db

# Update distro
sudo apt-get update -y

if [ -d "$POS_DIRECTORY" ]; then
    echo "$POS_DIRECTORY directory already exists. skipped"
else
    echo "...creating a directory: $POS_DIRECTORY"
    sudo mkdir -p $POS_DIRECTORY
fi

if [ -d "$DB_DIRECTORY" ]; then
    echo "$DB_DIRECTORY directory already exists. skipped"
else
    echo "...creating a directory: $DB_DIRECTORY"
    sudo mkdir -p $DB_DIRECTORY
fi

echo "...changing permission of the directory"
sudo chmod 777 -R $POS_DIRECTORY $DB_DIRECTORY

echo "...adding docker repository"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc


echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "...running update"
sudo apt-get update -y

echo "...installing docker and docker compose"
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

echo "...post install setup"
echo "...adding current user $USER to docker group in order to run it without sudo"
sudo usermod -aG docker $USER
echo "... please restart the terminal in order for it to work"

echo "...login to docker registry"
echo "..this will ask for username and password, check your password manager for the username and password"
docker login

echo "...copy the docker-compose-linux.yaml to $POS_DIRECTORY"
cp ../docker-compose-linux.yaml $POS_DIRECTORY

echo "...setup .env"
cd $POS_DIRECTORY
touch .env
cat <<EOF > .env
EMAIL_USE_TLS=True
EMAIL_HOST=smtp-relay.brevo.com
EMAIL_HOST_USER=imrmendez@oceanhiveph.com
EMAIL_HOST_PASSWORD=xsmtpsib-14b46701c99c4012040c80a19c95e886ab9cedcad9ed8a9b7ec3fa268e63284c-MvkpfRVxjZy713b8
EMAIL_PORT=587
DJANGO_SECRET_KEY=django-insecure-o6y%+=3ib=ic&u3(krj%x8zn8-ma=@3_q^sib=_!tb3y4l8@i@
DJANGO_DATABASE_HOST=pos-db
DJANGO_DATABASE_PORT=5432
DJANGO_DATABASE_NAME=postgres
DJANGO_DATABASE_USER=postgres
DJANGO_DATABASE_PASSWORD=postgres
PORT=80
GENERATE_SOURCEMAP=false
REACT_APP_API_BASE_URL=http://pos-api.raspberry.pi:8000/api
EOF

echo "...checking if the file is on the $POS_DIRECTORY"
ls -laht $POS_DIRECTORY

echo "...pulling docker images on the private repository"
cd $POS_DIRECTORY
docker compose -f docker-compose-linux.yaml pull

echo "...starting the pos server"
cd $POS_DIRECTORY
docker compose -f docker-compose-linux.yaml up -d

echo "...waiting to initialize properly"
sleep 15

echo "...running migration"
docker exec pos-api python manage.py migrate

echo "...create superuser"
docker exec pos-api python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser(username='${DJANGO_USER}',email='${DJANGO_EMAIL}', password='${DJANGO_PASS}')"

echo "...waiting for the system to come online"
sleep 15

echo "...initializing data"
curl localhost:8000/api/initialize/data

echo "................................"
echo "You update the hosts file and add this ${SERVERIP} pos-api.local.co"

exit 0