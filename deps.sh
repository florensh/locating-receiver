#!/bin/bash
modprobe bcm2835-v4l2 && python demo.py &
set -o errexit
set -o pipefail

sudo apt-get update
sudo apt-get install -y libssl-dev aircrack-ng iw
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q install tshark
