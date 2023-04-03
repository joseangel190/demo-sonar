#!/bin/bash

sudo apt update -y && sudo apt upgrade -y
sudo apt install curl -y
sudo apt install wget -y
sudo apt install nano -y
sudo apt install unzip -y

# Install OpenJDK - Java
sudo apt install openjdk-11-jdk -y

# Install PostgreSQL
curl https://www.postgresql.org/media/keys/ACCC5CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt update -y
sudo apt install postgresql postgresql-contrib -y
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Configure PostgreSQL
#sudo -u postgres createuser sonar
sudo -u postgres sh -c "cd / && createuser sonar"
sudo -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED password 'sonar';"
sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;"

# Install sonarqube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.8.0.63668.zip
sudo unzip -q sonarqube-9.8.0.63668.zip
sudo mv sonarqube-9.8.0.63668 /opt/sonarqube
sudo rm sonarqube-9.8.0.63668.zip

# Configure sonarqube
sudo groupadd sonar
sudo useradd -d /opt/sonarqube -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube -R
sudo sed -i -e 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/g' /opt/sonarqube/conf/sonar.properties
sudo sed -i -e 's/#sonar.jdbc.password=/sonar.jdbc.password=sonar/g' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's/^#sonar.jdbc.url=jdbc:postgresql:\/\/localhost\/sonarqube?currentSchema=my_schema/sonar.jdbc.url=jdbc:postgresql:\/\/localhost:5432\/sonarqube/' /opt/sonarqube/conf/sonar.properties
sudo sed -i '/APP_NAME="SonarQube"/a RUN_AS_USER=sonar' /opt/sonarqube/bin/linux-x86-64/sonar.sh

echo "[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65537
LimitNPROC=4097

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/sonar.service
sudo systemctl enable sonar
sudo systemctl start sonar


sudo sed -i '$a\vm.max_map_count=262145\nfs.file-max=65536\nulimit -n 65536\nulimit -u 4096' /etc/sysctl.conf
sudo sysctl -p
