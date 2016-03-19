#!/bin/bash

set -o errexit
set -o pipefail

sudo apt-get update
echo "yes" | sudo debconf-set-selections
sudo apt-get install -y libssl-dev aircrack-ng iw
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q install tshark
sudo airmon-ng start wlan0
