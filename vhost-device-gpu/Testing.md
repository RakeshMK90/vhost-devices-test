# vhost-user-gpu Test Cases

This document outlines detailed and structured test cases to validate the functionality, stability, and integration of the `vhost-user-gpu` daemon and its use within virtualized environments like QEMU.

---

## 🔹 Host-Side Validation

| Step Description | Command(s) | Expected Result |
|------------------|------------|------------------|
| Start daemon with virglrenderer | `/path/to/vhost-device-gpu --socket-path /tmp/gpu.socket --gpu-mode virglrenderer &` | Daemon starts, socket file appears at `/tmp/gpu.socket` |
| Verify socket file exists | `ls -l /tmp/gpu.socket` | Socket file is present |
| Check daemon process | `ps aux | grep vhost-device-gpu` | Daemon process is running |
| Check system logs | `journalctl -xe | grep vhost` | No critical errors related to GPU backend |


---

## 🔹 Backend Capabilities

| Step Description | Command(s) | Expected Result |
|------------------|------------|------------------|
| Use virglrenderer and check EGL vendor | `eglinfo -B` inside guest | Output includes `virgl` |
| Use gfxstream and run EGL app | `kmscube` inside guest | App runs, but only display output (no accel) |
| Attempt Vulkan rendering (virgl) | `vkcube` or `vulkaninfo` | Should fail if Vulkan unsupported |

---

## 🔹 QEMU Integration

| Step Description | Command(s) | Expected Result |
|------------------|------------|------------------|
| Use `vhost-user-gpu-pci` device | Standard QEMU launch with socket | Guest boots, `glxinfo` shows virgl support |
| Use `vhost-user-vga` device | Add `-device vhost-user-vga,chardev=char0` | Boot messages visible, GNOME starts |
| Launch without `-vga none` | Omit `-vga none` in QEMU | Guest sees multiple VGA outputs, possible GPU fallback |
| Guest detects GPU via lspci | `lspci | grep -i virtio` | Shows `Virtio 1.0 GPU` device |
| Check virtio_gpu module | `lsmod | grep virtio_gpu` | Kernel module is loaded |
| Check for /dev/dri/ nodes | `ls -l /dev/dri/` | `card0` and `renderD128` should exist |

---

## 🔹 Guest GPU Rendering

| Step Description | Command(s) | Expected Result |
|------------------|------------|------------------|
| Launch GNOME session | `systemctl start graphical.target` | GNOME loads successfully with acceleration |
| Run `glxgears` and check vendor | `glxgears -info` | `GL_VENDOR` is `virgl` or virtualized GPU vendor |
| Check OpenGL renderer | `glxinfo | grep "OpenGL renderer"` | Should report `virgl` or similar virtual driver |
| Run glxgears rendering test | `glxgears` | Smooth 3D spinning gears appear |
| Run glmark2 benchmark | `glmark2` | Benchmark completes without crashing |
| Run stress test (multiple OpenGL) | Multiple `glxgears`, `glxinfo`, etc. | Stable rendering, no crash or slowdown |
| Check kernel logs for init | `dmesg | grep virtio` | No GPU init errors |

---

## 🔹 Display Output Validation

| Step Description | Command(s) | Expected Result |
|------------------|------------|------------------|
| GTK display enabled | `-display gtk,gl=on` | QEMU window shows graphical guest |
| DBus display with Snowglobe | `-display dbus,gl=on`, `flatpak run com.belmoussaoui.snowglobe` | Output appears in Snowglobe viewer |
| Guest display resolution | `xrandr` | Reports expected resolution (e.g., 1280x720) |

---

## 🔹 Fault Injection & Error Recovery

| Step Description | Command(s) | Expected Result |
|------------------|------------|------------------|
| Kill daemon mid-session | `kill -9 $(pidof vhost-device-gpu)` | Guest logs GPU disconnection |
| Restart daemon with reconnect | Restart daemon, set `reconnect=1` in QEMU | Guest reconnects successfully or shows partial recovery |
| Inject garbage into socket | `echo 'garbage' > /tmp/gpu.socket` | Daemon handles it gracefully, logs error |

---

## 🔹 Long-Running Stability

| Step Description | Command(s) | Expected Result |
|------------------|------------|------------------|
| Run guest with glxgears for 24 hours | `glxgears &` with monitoring | Stable frame rate, no daemon crash |
| Run VM restart loop | Script: loop 10x start/stop VM | No GPU state corruption or socket leak |
| Monitor memory usage | `top`, `ps`, `smem` | No memory growth in daemon process |

---


