import subprocess
import requests
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from database.db import (
    init_db,
    save_stats,
    get_history,
    verify_user_credentials,
    create_user
)

app = FastAPI()
init_db()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class URLRequest(BaseModel):
    url: str

class LoginRequest(BaseModel):
    username: str
    password: str

class RegisterRequest(BaseModel):
    username: str
    password: str
    role: str = "Analyst"

@app.get("/")
def home():
    return {"status": "Kali Backend Running Securely"}

# ── AUTHENTICATION ROUTES ──
@app.post("/auth/login")
def login(data: LoginRequest):
    user = verify_user_credentials(data.username, data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, 
            detail="Invalid security credentials"
        )
    return {"status": "success", "username": user["username"], "role": user["role"]}

@app.post("/auth/register")
def register(data: RegisterRequest):
    success = create_user(data.username, data.password, data.role)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="Operator identifier already exists"
        )
    return {"status": "success", "message": "Operator registered successfully"}

def read_logs():
    result = subprocess.run(
        ["journalctl", "-n", "100", "--no-pager"],
        capture_output=True,
        text=True,
    )
    return result.stdout.splitlines()

@app.get("/logs")
def get_logs():
    return {"logs": read_logs()}

@app.get("/alerts")
def get_alerts():
    docker_count = 0
    network_count = 0
    failed_count = 0

    logs = read_logs()
    for log in logs:
        log_lower = log.lower()
        if "failed" in log_lower:
            failed_count += 1
        if "docker" in log_lower:
            docker_count += 1
        if "network" in log_lower:
            network_count += 1

    alerts = []
    if failed_count > 0:
        alerts.append({"severity": "HIGH", "message": f"{failed_count} failed authentication events"})
    if docker_count > 0:
        alerts.append({"severity": "MEDIUM", "message": f"{docker_count} docker-related events"})
    if network_count > 0:
        alerts.append({"severity": "LOW", "message": f"{network_count} network-related events"})

    return {"alerts": alerts}

@app.get("/stats")
def get_stats():
    logs = read_logs()
    threats = len(logs)
    alerts = 0
    high_risk = 0

    for log in logs:
        log_lower = log.lower()
        if "failed" in log_lower:
            high_risk += 1
        if "docker" in log_lower or "network" in log_lower:
            alerts += 1

    save_stats(threats, alerts, high_risk)

    return {
        "threats": threats,
        "alerts": alerts,
        "users": 120,
        "high_risk": high_risk,
    }

@app.get("/severity")
def get_severity():
    logs = read_logs()
    high = 0
    medium = 0
    low = 0

    for log in logs:
        log_lower = log.lower()
        if "failed" in log_lower:
            high += 1
        elif "docker" in log_lower:
            medium += 1
        elif "network" in log_lower:
            low += 1

    return {"high": high, "medium": medium, "low": low}

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
                "dateAdded": vuln["dateAdded"],
            })
        return {"threats": threats}
    except Exception as e:
        return {"error": str(e), "threats": []}

@app.get("/history")
def history():
    return {"history": get_history()}

@app.post("/scan-url")
def scan_url(data: URLRequest):
    url = data.url.lower()
    reasons = []
    score = 0

    suspicious_keywords = ["login", "verify", "update", "secure", "banking", "account", "password"]
    for keyword in suspicious_keywords:
        if keyword in url:
            score += 1
            reasons.append({"type": "keyword", "description": f"Suspicious keyword detected: '{keyword}'"})

    if "@" in url:
        score += 2
        reasons.append({"type": "symbol", "description": "URL contains '@' symbol — common in phishing links"})

    if url.count("-") > 2:
        score += 2
        reasons.append({"type": "structure", "description": f"Excessive hyphens ({url.count('-')}) — typical of spoofed domains"})

    if re.search(r"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}", url):
        score += 3
        reasons.append({"type": "ip", "description": "URL uses raw IP address instead of domain name"})

    domain_part = url.split("/")[2] if "/" in url else url
    if domain_part.count(".") > 3:
        score += 1
        reasons.append({"type": "structure", "description": "Too many subdomains — suspicious domain structure"})

    if "https" in url and any(k in url for k in ["login", "secure", "verify"]):
        reasons.append({"type": "info", "description": "HTTPS does not guarantee safety — phishing sites use it too"})

    max_score = 9
    normalized = min(round((score / max_score) * 100), 100)

    if score >= 4:
        verdict = "PHISHING"; risk = "HIGH"
    elif score >= 2:
        verdict = "SUSPICIOUS"; risk = "MEDIUM"
    else:
        verdict = "SAFE"; risk = "LOW"

    return {
        "url": data.url,
        "verdict": verdict,
        "risk": risk,
        "score": score,
        "normalized_score": normalized,
        "reasons": reasons,
    }
        