#!/bin/bash

sudo apt-get update

#JAVA SETUP
sudo apt install openjdk-11-jdk-headless -y
#Export java home
echo "export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))" | sudo tee -a /etc/profile
#import profile
source /etc/profile
#export path
echo "export PATH=$PATH:$JAVA_HOME/bin" | sudo tee -a /etc/profile
echo "export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar" | sudo tee -a /etc/profile
#import updated profile
source /etc/profile


#TOMCAT SETUP
#create user tomcat for secutity purposes
sudo groupadd tomcat
sudo mkdir /opt/tomcat
sudo useradd -s /bin/nologin -g tomcat -d /opt/tomcat tomcat

#go to temp to download binaries
cd /tmp
curl -O http://apache.spinellicreations.com/tomcat/tomcat-9/v9.0.31/bin/apache-tomcat-9.0.31.tar.gz

## unzip
sudo tar xzvf apache-tomcat-9.0.31.tar.gz -C /opt/tomcat --strip-components=1

#go to tomcat folder
cd /opt/tomcat/
#configure tomcat users permissions and update permissions for conf
sudo chgrp -R tomcat conf
sudo chmod g+rwx conf
sudo chmod -R g+r conf
sudo chown -R tomcat logs/ temp/ webapps/ work/
sudo rm -rf /opt/tomcat/webapps/*
sudo rm -rf /opt/tomcat/work/*

#same for bin,lib and bin
sudo chgrp -R tomcat bin
sudo chgrp -R tomcat lib
sudo chmod g+rwx bin
sudo chmod -R g+r binS

echo"before touch"
## Writing a tomcat service to make it start on boot
echo "affter touch"
echo "[Unit]
Description=Apache Tomcat Web Application Container
After=network.target
[Service]
Type=oneshot
Environment=JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'
WorkingDirectory=/opt/tomcat
ExecStart=/opt/tomcat/bin/startup.sh
RemainAfterExit=true
ExecStop=/opt/tomcat/bin/shutdown.sh
User=tomcat
Group=tomcat
UMask=0007
[Install]
WantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/tomcat.service
echo "after file write"

#Installing codedeploy
sudo apt-get install ruby -y
sudo apt-get install wget
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

sudo service codedeploy-agent start
#Reload  and run tomcat service

sudo systemctl daemon-reload
sudo systemctl unmask tomcat.service
sudo systemctl enable tomcat.service
sudo systemctl start tomcat.service

# Installing cloud-watch  
cat cloudwatch-config.json
    

echo 'Downloading cloud watch'
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb


echo 'cloud watch downloaded successfully'
chmod +x ./amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
sudo cp amazon-cloudwatch-agent.service /etc/systemd/system/

echo 'Listing all services'
systemctl list-unit-files --type=service

echo 'Enabling cloudwatch service'
sudo systemctl enable amazon-cloudwatch-agent.service

echo 'Starting cloudwatch service'
sudo systemctl start amazon-cloudwatch-agent.service