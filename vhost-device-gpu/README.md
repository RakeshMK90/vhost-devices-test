# vhost-user-gpu

> A virtio-gpu device implementation using vhost-user from rust-vmm

[![Fedora](https://img.shields.io/badge/platform-Fedora-blue)](https://getfedora.org/)
[![License](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](./LICENSE)

## Table of Contents
- [Overview](#-overview)
- [GPU Backends and Capability Sets](#-gpu-backends-and-capability-sets-capsets)
- [Installation](#-installation)
- [Setting Up a Fedora VM](#️-setting-up-a-fedora-vm)
- [Running vhost-user-gpu with QEMU](#-running-vhost-user-gpu-with-qemu)
- [Testing Inside the VM](#-testing-inside-the-vm)
- [Troubleshooting](#️-troubleshooting-optional-addition)
- [Quickstart](#-tldr-quickstart)

## Overview
`vhost-device-gpu` from [rust-vmm](https://github.com/rust-vmm/vhost-device) is an implementation of the `virtio-gpu` device (as defined in the [virtio specification](https://docs.oasis-open.org/virtio/virtio/v1.2/virtio-v1.2.html)) using the `vhost-user` protocol. This device is typically used with virtual machine monitors (VMMs) that support the `vhost-user` protocol—most notably, **QEMU**.

## GPU Backends and Capability Sets (Capsets)
The GPU device supports two main backends, each implementing their own capability sets (capsets). These capsets define the rendering protocols available to the guest.

### 1. `virglrenderer`
- Implements the `virgl` and `virgl2` capsets for **OpenGL acceleration**.
- The `virglrenderer` library also supports other capsets (e.g., `venus` for Vulkan), but these are **not currently enabled** in `vhost-device-gpu`.

### 2. `gfxstream`
- Implements `gfxstream-vulkan` and `gfxstream-gles` capsets.
- Currently, **only display output** is supported—OpenGL/Vulkan acceleration is not yet available for guests using this backend.

More information: [crates.io/crates/vhost-device-gpu](https://crates.io/crates/vhost-device-gpu)

---

##  Installation

### 1. Install QEMU and display backends
```bash
sudo dnf install qemu-system-x86-core qemu-ui-gtk qemu-ui-dbus \
                 qemu-ui-opengl qemu-device-display-virtio-gpu-pci-gl
```

### 2. Install `vhost-device-gpu` (on Fedora 42/43 and ELN)
```bash
sudo dnf install vhost-device-gpu
```

### 3. (Optional) Development Packages
```bash
sudo dnf install rust-vhost-device-gpu*
```

### 4. (Optional) Snowglobe Display Viewer
```bash
# Enable Flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Snowglobe
flatpak install com.belmoussaoui.snowglobe
```

---

## Setting Up a Fedora VM

### 1. Download Image
Download a **persistent Fedora Server image** from: https://fedoraproject.org/server/download

### 2. Launch the Image
```bash
qemu-system-x86_64 -smp 4 -m 4G -enable-kvm -nographic \
  -drive file=Fedora-Server-KVM-41-1.4.x86_64.qcow2,format=qcow2
```

### 3. Create a User in Fedora Installer
- Choose option 5 for user creation
- Follow prompts to set username and password
- Press `c` to continue
- At login, use your created username/password

### 4. Install GPU-related Tools
```bash
sudo dnf install eglinfo     # See GPU driver info
sudo dnf install kmscube     # Simple OpenGL test
sudo dnf install gdm gnome-shell gnome-terminal  # GNOME desktop
```

Shutdown the VM before launching with GPU passthrough.

---

## Running vhost-user-gpu with QEMU

### 1. Start the GPU Device Daemon
```bash
vhost-device-gpu --socket-path=/tmp/gpu.socket --gpu-mode virglrenderer
```

### 2. Launch QEMU with vhost-user-gpu
```bash
qemu-system-x86_64 -snapshot \
  -object memory-backend-memfd,share=on,id=mem0,size=4G \
  -machine q35,memory-backend=mem0,accel=kvm \
  -display gtk,gl=on \
  -vga none \
  -chardev socket,id=char0,reconnect=0,path=/tmp/gpu.socket \
  -device vhost-user-gpu-pci,chardev=char0 \
  -drive file=Fedora-Server-KVM-41-1.4.x86_64.qcow2,format=qcow2
```

### Alternative Configurations
- To use the **Snowglobe** DBus display:
```bash
  -display dbus,gl=on
```
Run Snowglobe:
```bash
flatpak run com.belmoussaoui.snowglobe
```

- To use VGA front-end:
```bash
  -device vhost-user-vga,chardev=char0  # VGA + GPU passthrough
  -vga none
```

---

## Testing Inside the VM

### 1. Confirm virgl is active
```bash
eglinfo -B | less
```
Look for:
```
OpenGL core profile vendor: virgl
```
If you only see `llvmpipe`, then only software rendering is being used. Seeing both is okay as long as `virgl` takes priority.

### 2. Run Graphical Demo
```bash
kmscube
```

### 3. Start GNOME Desktop
```bash
systemctl start graphical.target
```
Inside GNOME, run:
```bash
glxgears -info
```
Look for:
```
GL_VENDOR = "VMware, Inc." or "virgl"
```

---


##  TL;DR (Quickstart)
```bash
sudo dnf install qemu-system-x86-core qemu-ui-gtk vhost-device-gpu

vhost-device-gpu --socket-path=/tmp/gpu.socket --gpu-mode virglrenderer

qemu-system-x86_64 -snapshot -display gtk,gl=on -vga none \
  -chardev socket,id=char0,path=/tmp/gpu.socket \
  -device vhost-user-gpu-pci,chardev=char0 \
  -drive file=Fedora-Server-KVM-41-1.4.x86_64.qcow2,format=qcow2
```
