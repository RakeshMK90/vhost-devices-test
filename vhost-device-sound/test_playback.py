from utils.ssh_client import ssh_command

def test_speaker_test_runs():
    out, err = ssh_command(
        host="localhost",
        port=2222,
        username="fedora",
        password="fedora_password",
        command="speaker-test -t sine -f 440 -c 2 -l 1"
    )
    assert "Rate" in out or "Playback" in out, f"Failed output: {out}, Error: {err}"