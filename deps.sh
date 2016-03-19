#!/bin/bash

set -o errexit
set -o pipefail

sudo apt-get update
sudo apt-get install -y libssl-dev tshark
wget http://download.aircrack-ng.org/aircrack-ng-1.2-beta1.tar.gz
tar -zxvf aircrack-ng-1.2-beta1.tar.gz
cd aircrack-ng-1.2-beta1
make
make install
apt-get -y install iw
sudo airmon-ng start wlan0
