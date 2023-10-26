#!/bin/bash
exec > >(tee -a /var/log/user-data.log) 2>&1

echo "Script started at: $(date)"

sudo apt update && sudo apt install -y fontconfig openjdk-17-jre

curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update && sudo apt install -y jenkins

sudo systemctl start jenkins
sudo systemctl enable jenkins

sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update

sudo apt-get install -y python3.7
sudo apt-get install -y python3.7-venv

sudo usermod -aG sudo jenkins

sudo su - jenkins

ssh-keygen -t rsa -N "" -f /var/lib/jenkins/.ssh/id_rsa

chmod 700 /var/lib/jenkins/.ssh/id_rsa
chmod 600 /var/lib/jenkins/.ssh/id_rsa

echo "Script completed at: $(date)"