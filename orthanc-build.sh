#!/bin/sh

# Prepare Google Cloud/ etc instance for whatisit (mostly just Docker and cloning repo)
sudo apt-get update > /dev/null
sudo apt-get install -y --force-yes git 
sudo apt-get install -y --force-yes nginx
sudo apt-get install -y --force-yes build-essential
sudo apt-get install -y --force-yes nginx
sudo apt-get install -y --force-yes python-dev
sudo apt-get install -y --force-yes python-pip

# Start nginx web server
sudo service nginx start

# Python updates, etc.
sudo pip2 install --upgrade pip
sudo pip2 install --upgrade google-api-python-client
sudo pip2 install --upgrade google
sudo pip2 install oauth2client==3.0.0
sudo pip2 install gitpython
sudo pip2 install ipaddress

# Add docker key server
#gcloud compute firewall-rules create orthancp --allow tcp:8042,icmp
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# Install Docker
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee --append /etc/apt/sources.list.d/docker.list
sudo apt-get update
apt-cache policy docker-engine
sudo apt-get update
sudo apt-get -y install linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get -y install docker-engine
sudo service docker start
#sudo docker run hello-world
sudo usermod -aG docker $USER

# Docker-compose
sudo apt -y install docker-compose

# Note that you will need to log in and out for changes to take effect

# Prepare Orthancp Docker
sudo mkdir /code
sudo chmod -R 777 /code
cd /code && git clone https://github.com/radinformatics/cirr-docker && cd cirr-docker/orthancp-docker
# Get the variables for the postgres and username from metadata here
export POSTGRES_USER=`curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/postgres_user" -H "Metadata-Flavor: Google"`
export POSTGRES_PASSWORD=curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/postgres_pass" -H "Metadata-Flavor: Google"`
export DB_USER=curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_user" -H "Metadata-Flavor: Google"`
export DB_PASSWORD=curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_pass" -H "Metadata-Flavor: Google"`
./bootstrap-orthanc.sh
docker-compose up -d
