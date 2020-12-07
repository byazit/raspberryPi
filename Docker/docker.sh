#!/bin/bash
<<COMMENT1 
remove comment if you don't have docker install in your pi
#downloading docker
curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
#docker add pi user so we can run docker as pi
sudo usermod -aG docker pi
sudo curl https://download.docker.com/linux/raspbian/gpg
sudo apt-get install apt-transport-https ca-certificates software-properties-common -y
sudo nano /etc/apt/sources.list -> deb https://download.docker.com/linux/raspbian/ stretch stable
#adding firewall rules
sudo ufw default deny incoming && sudo ufw default allow outgoing && sudo ufw enable
#opening port 22 and 8080
sudo ufw allow 22
sudo ufw allow 8080/tcp
sudo service ufw restart
COMMENT1
sudo apt install libffi-dev libssl-dev python3 python3-pip && sudo pip3 install docker-compose -y
rm -rf docker
mkdir docker
cd docker
echo -n 'version: "3.7"
services:
  db:
    build: ./db
    container_name: db
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: myrootpasswordisveryhard
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: myrootpasswordisveryhard
    networks:
      website_network:
        aliases:
          - wordpress          
  wordpress:
    build: .
    container_name: wordpress
    ports:
      - "8080:80"
    networks:
      website_network:
        aliases:
          - wordpress
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: myrootpasswordisveryhard
      WORDPRESS_DB_NAME: wordpress
networks:
  website_network:
    name: website_network
volumes: 
  db_data:
    driver: local
    name: db_data' > docker-compose.yaml
<<COMMENT2
add this before networks if you want to have nginx
  nginx:
    build: ./nginx
    container_name: nginx
    ports:
      - "8080:80"
      - "80"
    networks:
      website_network:
        aliases:
          - nginx-proxy
COMMENT2
mkdir db && cd db
echo -n 'FROM hypriot/rpi-mysql:latest'> Dockerfile
cd ..
echo -n 'FROM wordpress:latest'> Dockerfile
docker-compose down && docker-compose build && docker-compose up -d && docker ps -a
        
