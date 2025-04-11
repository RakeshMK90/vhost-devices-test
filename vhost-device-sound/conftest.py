import subprocess
import time
import pytest

@pytest.fixture(scope="session", autouse=True)
def setup_vhost_device():
    subprocess.Popen(["bash", "./scripts/start_vhost_device.sh"])
    time.sleep(2)

@pytest.fixture(scope="session", autouse=True)
def setup_qemu():
    qemu_proc = subprocess.Popen(["bash", "./scripts/start_qemu.sh"])
    time.sleep(15)  # wait for VM to boot
    yield
    qemu_proc.terminate()
