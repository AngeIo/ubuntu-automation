#!/bin/sh

# Cleans the machine-id and cleans shell history.
sudo truncate -s 0 /etc/machine-id
sudo rm /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id
sudo echo > ~/.bash_history
sudo rm -rf /root/.bash_history