from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import subprocess

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {"status": "Kali Backend Running"}

def read_logs():
    result = subprocess.run(
        ["journalctl", "-n", "100", "--no-pager"],
        capture_output=True,
        text=True
    )

    return result.stdout.splitlines()

@app.get("/logs")
def get_logs():
    return {
        "logs": read_logs()
    }

@app.get("/alerts")
def get_alerts():

    docker_count = 0
    network_count = 0
    failed_count = 0

    result = subprocess.run(
        ["journalctl", "-n", "100", "--no-pager"],
        capture_output=True,
        text=True
    )

    logs = result.stdout.splitlines()

    for log in logs:

        log = log.lower()

        if "failed" in log:
            failed_count += 1

        if "docker" in log:
            docker_count += 1

        if "network" in log:
            network_count += 1

    alerts = []

    if failed_count > 0:
        alerts.append({
            "severity": "HIGH",
            "message": f"{failed_count} failed authentication events"
        })

    if docker_count > 0:
        alerts.append({
            "severity": "MEDIUM",
            "message": f"{docker_count} docker-related events"
        })

    if network_count > 0:
        alerts.append({
            "severity": "LOW",
            "message": f"{network_count} network-related events"
        })

    return {"alerts": alerts}

@app.get("/stats")
def get_stats():

    logs = read_logs()

    threats = len(logs)

    alerts = 0
    high_risk = 0

    for log in logs:

        if "docker" in log.lower():
            alerts += 1

        if "failed" in log.lower():
            high_risk += 1

    return {
        "threats": threats,
        "alerts": alerts,
        "users": 120,
        "high_risk": high_risk
    }
@app.get("/severity")
def get_severity():

    logs = read_logs()

    high = 0
    medium = 0
    low = 0

    for log in logs:

        log = log.lower()

        if "failed" in log:
            high += 1

        elif "docker" in log:
            medium += 1

        elif "network" in log:
            low += 1

    return {
        "high": high,
        "medium": medium,
        "low": low
    }
@app.get("/threats")
def get_threats():

    return {
        "threats": [
            {
                "cve": "CVE-2025-1234",
                "title": "Apache HTTP Server RCE",
                "cvss": 9.8,
                "severity": "CRITICAL"
            },
            {
                "cve": "CVE-2025-5678",
                "title": "Linux Kernel Privilege Escalation",
                "cvss": 8.4,
                "severity": "HIGH"
            },
            {
                "cve": "CVE-2025-7890",
                "title": "Docker Container Escape",
                "cvss": 6.7,
                "severity": "MEDIUM"
            }
        ]
    }
