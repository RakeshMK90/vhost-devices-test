import paramiko
import time

def ssh_command(host, port, username, password, command):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    ssh.connect(host, port=port, username=username, password=password)
    stdin, stdout, stderr = ssh.exec_command(command)
    time.sleep(2)
    out = stdout.read().decode()
    err = stderr.read().decode()
    ssh.close()

    return out, err
