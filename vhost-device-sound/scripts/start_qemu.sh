#!/bin/bash

# Start QEMU with sound passthrough and port forwarding for SSH
qemu-system-x86_64 \
  -snapshot -m 4G -smp 4 -enable-kvm \
  -object memory-backend-memfd,id=mem0,size=4G,share=on \
  -machine q35,memory-backend=mem0,accel=kvm \
  -chardev socket,id=vsnd,path=/tmp/mysnd.sock \
  -device vhost-user-snd-pci,chardev=vsnd \
  -drive file=./Fedora.qcow2,format=qcow2 \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 -device e1000,netdev=net0 \
  -nographic
