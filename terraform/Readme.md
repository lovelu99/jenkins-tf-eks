Script 1 for Terraform,kubectl,Aws cli

vi script1.sh

#!/bin/bash
#install terraform
sudo apt install wget -y
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

#install Kubectl on Jenkins
sudo apt update
sudo apt install curl -y
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

#install Aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt-get install unzip -y
unzip awscliv2.zip
sudo ./aws/install


Step 2 — Install Jenkins, Docker and Trivy
-------------------------------------------

Script2 for Java,Jenkins,Docker

vi script2.sh

#!/bin/bash

set -e

echo "=============================="
echo " Jenkins WAR Auto Setup Script"
echo "=============================="

# Update system
sudo apt update -y

# Install Java 21, wget, curl
sudo apt install -y openjdk-21-jdk wget curl

# Verify Java
java -version

# Create Jenkins directory
sudo mkdir -p /opt/jenkins
cd /opt/jenkins

# Download Jenkins WAR
if [ ! -f jenkins.war ]; then
  echo "Downloading Jenkins WAR..."
  wget https://get.jenkins.io/war/2.552/jenkins.war
else
  echo "Jenkins WAR already exists"
fi

# Permissions
sudo chmod 755 jenkins.war

# Run Jenkins in background
echo "Starting Jenkins in background..."
nohup java -Djava.net.preferIPv4Stack=true -jar /opt/jenkins/jenkins.war \
> /opt/jenkins/jenkins.log 2>&1 &

sleep 5

# Show status
echo "Jenkins process:"
ps -ef | grep jenkins.war | grep -v grep

echo "=============================="
echo " Jenkins started successfully "
echo " URL: http://<SERVER-IP>:8080"
echo " Log: /opt/jenkins/jenkins.log"
echo "=============================="

#install docker
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -aG docker ubuntu
newgrp docker

===========================================

http://ip:8080

vi trivy.sh

sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y
apt install -y libatomic1


http://IP:8080


Now Run sonarqube container
=============================

sudo chmod 777 /var/run/docker.sock
systemctl daemon-reload
systemctl restart docker.service

docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

http://IP:9000