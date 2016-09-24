#!/bin/bash

set -o errexit
set -o pipefail

sudo apt-get update
sudo apt-get install -y libssl-dev aircrack-ng iw
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q install tshark

grep "start_x=1" /boot/config.txt
if grep "start_x=1" /boot/config.txt
then
        exit
else
        sed -i "s/start_x=0/start_x=1/g" /boot/config.txt
        reboot
fi
exit
