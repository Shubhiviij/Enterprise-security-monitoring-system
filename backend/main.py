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

@app.get("/logs")
def get_logs():
    result = subprocess.run(
        ["journalctl", "-n", "20", "--no-pager"],
        capture_output=True,
        text=True
    )

    return {
        "logs": result.stdout.splitlines()
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

    alerts = get_alerts()["alerts"]

    high = 0
    medium = 0
    low = 0

    for alert in alerts:
        if alert["severity"] == "HIGH":
            high += 1
        elif alert["severity"] == "MEDIUM":
            medium += 1
        elif alert["severity"] == "LOW":
            low += 1

    return {
        "threats": high + medium + low,
        "high_risk": high,
        "alerts": len(alerts),
        "users": 120
    }







