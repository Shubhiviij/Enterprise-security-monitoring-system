import requests
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import subprocess
from pydantic import BaseModel

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
class URLRequest(BaseModel):
    url: str

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

    url = "https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json"

    try:

        response = requests.get(url, timeout=10)

        data = response.json()

        threats = []

        for vuln in data["vulnerabilities"][:20]:

            threats.append({
                "cve": vuln["cveID"],
                "title": vuln["vulnerabilityName"],
                "vendor": vuln["vendorProject"],
                "product": vuln["product"],
                "severity": "HIGH",
                "dateAdded": vuln["dateAdded"]
            })

        return {
            "threats": threats
        }

    except Exception as e:

        return {
            "error": str(e),
            "threats": []
        }

@app.post("/scan-url")
def scan_url(data: URLRequest):
    url = data.url.lower()
    reasons = []
    score = 0

    suspicious_keywords = [
        "login", "verify", "update", "secure",
        "banking", "account", "password"
    ]

    for keyword in suspicious_keywords:
        if keyword in url:
            score += 1
            reasons.append({
                "type": "keyword",
                "description": f"Suspicious keyword detected: '{keyword}'"
            })

    if "@" in url:
        score += 2
        reasons.append({
            "type": "symbol",
            "description": "URL contains '@' symbol — common in phishing links"
        })

    if url.count("-") > 2:
        score += 2
        reasons.append({
            "type": "structure",
            "description": f"Excessive hyphens ({url.count('-')}) — typical of spoofed domains"
        })

    # NEW: Check for IP address instead of domain
    import re
    if re.search(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', url):
        score += 3
        reasons.append({
            "type": "ip",
            "description": "URL uses raw IP address instead of domain name"
        })

    # NEW: Check for excessive subdomains
    domain_part = url.split("/")[2] if "/" in url else url
    if domain_part.count(".") > 3:
        score += 1
        reasons.append({
            "type": "structure",
            "description": "Too many subdomains — suspicious domain structure"
        })

    # NEW: Check for misleading HTTPS
    if "https" in url and any(k in url for k in ["login", "secure", "verify"]):
        reasons.append({
            "type": "info",
            "description": "HTTPS does not guarantee safety — phishing sites use it too"
        })

    max_score = 9
    normalized = round((score / max_score) * 100)
    normalized = min(normalized, 100)

    if score >= 4:
        verdict = "PHISHING"
        risk = "HIGH"
    elif score >= 2:
        verdict = "SUSPICIOUS"
        risk = "MEDIUM"
    else:
        verdict = "SAFE"
        risk = "LOW"

    return {
        "url": data.url,
        "verdict": verdict,
        "risk": risk,
        "score": score,
        "normalized_score": normalized,
        "reasons": reasons
    }
        