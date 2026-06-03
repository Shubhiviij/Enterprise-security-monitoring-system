import subprocess

def get_logs():
    result = subprocess.run(
        ["journalctl", "-n", "20", "--no-pager"],
        capture_output=True,
        text=True
    )

    logs = result.stdout.split("\n")

    return [
        {"event": log}
        for log in logs
        if log.strip()
    ]