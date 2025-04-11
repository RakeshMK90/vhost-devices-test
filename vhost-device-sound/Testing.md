#  Test Plan for `vhost-user-sound`

## Objective
To validate the functionality, stability, and integration of `vhost-user-sound` with supported audio backends (Pipewire/ALSA) using QEMU and virtio-sound.

---

## Test Environment

- **Host**: Fedora (or any Linux distro) with `vhost-device-sound` and QEMU ≥ 9.0.0
- **Guest**: Fedora Server 41 image
- **Backends**: Pipewire and ALSA
- **QEMU Version**: ≥ 9.0.0

---

## Components to Test

- `vhost-user-snd-pci` device in QEMU
- `virtio-snd` kernel module in guest
- `vhost-device-sound` with Pipewire backend
- `vhost-device-sound` with ALSA backend
- Audio playback using tools like `aplay` or `speaker-test`

---

---

##  Sample Test Cases

| Description | Steps | Expected Result |
|-------------|-------|------------------|
| Load `virtio_snd` module in guest | `modprobe virtio_snd` | `lsmod` output includes `virtio_snd` |
| Start `vhost-device-sound` with Pipewire | `vhost-device-sound --socket=/tmp/mysnd.sock --backend pipewire` | Daemon starts with no errors |
| Start QEMU with `vhost-user-snd-pci` | Launch QEMU with correct `-device` and `-chardev` arguments | VM boots successfully |
| Verify sound card in guest | Run `aplay -l` or `cat /proc/asound/cards` | Sound card is listed |
| Playback test in guest | `speaker-test -t sine -f 440 -c 2` | Tone plays via host's output speakers|
| Failback test with no socket | Start QEMU without `vhost-device-sound` running | QEMU throws a “socket not found” error |
| Load with ALSA backend | `vhost-device-sound --backend alsa` | Daemon runs using ALSA |
---

##  Notes

- Use `dnf install alsa-utils` in the guest for playback tools.
- Ensure the `virtio_snd` module is available using:  
  ```bash
  sudo modprobe virtio_snd
