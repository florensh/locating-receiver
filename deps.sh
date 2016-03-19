#!/bin/bash

set -o errexit
set -o pipefail

sudo apt-get update
echo "yes" | sudo debconf-set-selections
sudo apt-get install -y libssl-dev tshark aircrack-ng iw
sudo airmon-ng start wlan0
