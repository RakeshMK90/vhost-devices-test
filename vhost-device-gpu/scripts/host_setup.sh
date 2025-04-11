#!/bin/bash
set -e

source ./config/guest-params.env
mkdir -p logs

echo "[HOST] Starting vhost-device-gpu..." | tee logs/test.log
pkill vhost-device-gpu || true
$VHOST_GPU_BIN --socket-path "$GPU_SOCKET" --gpu-mode virglrenderer &>> logs/test.log &

sleep 1
[[ -S "$GPU_SOCKET" ]] || { echo "[HOST] Socket not created!" | tee -a logs/test.log; exit 1; }

echo "[HOST] Launching QEMU guest..." | tee -a logs/test.log
qemu-system-x86_64 \
  -enable-kvm \
  -m 4096 \
  -cpu host \
  -smp 4 \
  -chardev socket,id=vgpu,path=$GPU_SOCKET \
  -device vhost-user-gpu-pci,chardev=vgpu,id=vgpu \
  -object memory-backend-memfd,share=on,id=mem0,size=4G \
  -machine q35,memory-backend=mem0,accel=kvm \
  -display gtk,gl=on,show-cursor=on \
  -vga none \
  -drive file=$QCOW2_IMG,format=qcow2,if=virtio \
  -net nic -net user,hostfwd=tcp::2222-:22 \
  -daemonize

echo "[HOST] QEMU started with GPU passthrough." | tee -a logs/test.log
sleep 30

