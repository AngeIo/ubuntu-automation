#!/bin/bash

# Ajout d'un "Message Of The Day"
sudo tee -a /etc/motd > /dev/null <<EOF
  ____       _ _   _______    _     _
 |  _ \     | | | |__   __|  | |   | |
 | |_) | ___| | | ___| | __ _| |__ | | ___
 |  _ < / _ \ | |/ _ \ |/ _\` | '_ \| |/ _ \\
 | |_) |  __/ | |  __/ | (_| | |_) | |  __/
 |____/ \___|_|_|\___|_|\__,_|_.__/|_|\___|

Ce serveur est géré par Terraform.
Vos modifications en local peuvent être écrasées.

En cas d'incident, merci de contacter : support@infra.blt
---

EOF

# Prendre tout l'espace disque
sudo growpart /dev/sda 2
sudo resize2fs /dev/sda2

# Ajout de la VM à l'inventaire FreeIPA
sudo ipa-client-install --unattended --principal admin --password '@Password1234' --domain infra.blt --ntp-server 0.fr.pool.ntp.org,1.fr.pool.ntp.org,2.fr.pool.ntp.org,3.fr.pool.ntp.org --ntp-pool pool.ntp.org --mkhomedir --enable-dns-updates

# Installation de l'agent Zabbix
sudo mkdir /tmp/zabbix
sudo cd /tmp/zabbix
sudo wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-3+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.0-3+ubuntu22.04_all.deb
sudo apt update
sudo apt install zabbix-agent -y
sudo sed -i 's/^Server=127.0.0.1/Server=192.168.100.14/g' /etc/zabbix/zabbix_agentd.conf
sudo sed -i 's/^ServerActive=127.0.0.1/ServerActive=192.168.100.14/g' /etc/zabbix/zabbix_agentd.conf
sudo systemctl restart zabbix-agent
sudo systemctl enable zabbix-agent

# Package permettant d'ajouter un certificat à Firefox
sudo apt update && sudo apt install libnss3-tools xvfb -y

# Télécharger le certificat de FreeIPA
sudo mkdir -p /opt/ssl
sudo wget https://srv-par-ipa-01.infra.blt/ipa/config/ca.crt -O /opt/ssl/ca.crt

# Installer Firefox
sudo add-apt-repository ppa:mozillateam/ppa -y

echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | sudo tee /etc/apt/preferences.d/mozilla-firefox

echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

sudo apt install firefox -y

# Créer un profil Firefox pour l'utilisateur
sudo su belletable-user -c "xvfb-run -a firefox" &
sleep 60
pkill -f firefox 

# Ajouter le certificat à Firefox
for certDB in $(sudo find /home/belletable-user/.mozilla* -name "cert9.db")
do
  cert_dir=$(dirname ${certDB});
  echo "Mozilla Firefox certificate" "install 'INFRA.BLT' in ${cert_dir}"
  sudo certutil -A -n "INFRA.BLT" -t "TCu,Cuw,Tuw" -i "/opt/ssl/ca.crt" -d sql:"${cert_dir}"
done

