#!/bin/bash

# Start vhost-device-sound with Pipewire
vhost-device-sound --socket=/tmp/mysnd.sock --backend pipewire &
echo "Started vhost-device-sound on /tmp/mysnd.sock"
