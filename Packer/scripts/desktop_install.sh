#!/bin/sh

# Passer l'installation en mode non interactif 
export DEBIAN_FRONTEND=noninteractive

# Installer l'interface graphique sur Ubuntu Server
echo '> Install UI on Ubuntu Server.'
sudo -E apt install ubuntu-desktop -y

### All done. ### 
echo '> Done.'

