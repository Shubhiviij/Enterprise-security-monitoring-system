import subprocess
import sqlite3
from database.db import DB_NAME, hash_password
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

class UserCreate(BaseModel):
    username: str
    password: str
    role: str

class RoleUpdate(BaseModel):
    role: str
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

from datetime import datetime

@app.get("/alerts")
def get_alerts():
    docker_count = 0
    network_count = 0
    failed_count = 0

    logs = read_logs()
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M")

    for log in logs:
        log_lower = log.lower()
        if "failed" in log_lower:
            failed_count += 1
        if "docker" in log_lower:
            docker_count += 1
        if "network" in log_lower:
            network_count += 1

    alerts = []

    # ── 1. AUTHENTICATION FAILURE ALERT METADATA ──
    if failed_count > 0:
        alerts.append({
            "id": "ALT-4011",
            "title": "Brute-Force Authentication Attempt",
            "severity": "HIGH",
            "type": "Access Control / Identity",
            "status": ALERT_STATUS_DB.get("ALT-4011", "OPEN"),
            "count": failed_count,
            "timestamp": current_time,
            "description": f"Detected {failed_count} explicit subsystem login failures within the current journalctl buffer window. This indicates an active credential-stuffing or automated dictionary attack against local access entry points.",
            "recommendation": "Identify the structural source IP origin from live access logs, immediately terminate conflicting sessions, and enforce host-level firewall drop rules via iptables/ufw.",
            "message": f"{failed_count} failed authentication events" # Legacy backup key to protect dashboard stability
        })

    # ── 2. DOCKER SUBSYSTEM ALERT METADATA ──
    if docker_count > 0:
        alerts.append({
            "id": "ALT-9082",
            "title": "Container Daemon Event Spike",
            "severity": "MEDIUM",
            "type": "Container Runtime Security",
            "status": ALERT_STATUS_DB.get("ALT-9082", "INVESTIGATING"),
            "count": docker_count,
            "timestamp": current_time,
            "description": f"The local Linux engine reported {docker_count} rapid docker container microservice events. Spikes in container transitions or namespace modifications could point to privilege escalation attempts or unauthorized image execution configurations.",
            "recommendation": "Execute 'docker ps -a' via target system terminal to investigate unexpected instances and check running docker container statistics for abnormal resource consumption patterns.",
            "message": f"{docker_count} docker-related events" # Legacy backup key
        })

    # ── 3. NETWORK SUBSYSTEM ALERT METADATA ──
    if network_count > 0:
        alerts.append({
            "id": "ALT-2043",
            "title": "Abnormal Interface Traffic",
            "severity": "LOW",
            "type": "Network Surveillance Feed",
            "status": ALERT_STATUS_DB.get("ALT-2043", "RESOLVED"),
            "count": network_count,
            "timestamp": current_time,
            "description": f"Logged {network_count} distinct core socket system interface connectivity reports. This activity baseline represents routine tracking metrics but should be monitored for sudden internal pivoting markers.",
            "recommendation": "Cross-reference mapped target ports with internal service architecture sheets to confirm valid system configurations.",
            "message": f"{network_count} network-related events" # Legacy backup key
        })

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

        # Parse out the top 20 actionable intelligence threats
        for vuln in data["vulnerabilities"][:20]:
            # Clean up raw notes or use fallback references
            cve_id = vuln.get("cveID", "Unknown CVE")
            
            threats.append({
                "cve": cve_id,
                "title": vuln.get("vulnerabilityName", "N/A"),
                "vendor": vuln.get("vendorProject", "N/A"),
                "product": vuln.get("product", "N/A"),
                "dateAdded": vuln.get("dateAdded", "N/A"),
                # ── ENRICHED SOC THREAT INTEL FIELDS ──
                "severity": "CRITICAL" if "remote code execution" in vuln.get("shortDescription", "").lower() else "HIGH",
                "summary": vuln.get("shortDescription", "No abstract summary available in source feed."),
                "requiredAction": vuln.get("requiredAction", "Apply vendor updates immediately or isolate the system asset."),
                "dueDate": vuln.get("dueDate", "Immediate mitigation recommended"),
                "referenceUrl": f"https://nvd.nist.gov/vuln/detail/{cve_id}"
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
ALERT_STATUS_DB = {
    "ALT-4011": "OPEN",
    "ALT-9082": "INVESTIGATING",
    "ALT-2043": "RESOLVED"
}

class StatusUpdateRequest(BaseModel):
    alert_id: str
    status: str

@app.post("/alerts/update-status")
def update_alert_status(data: StatusUpdateRequest):
    aid = data.alert_id.upper()
    status_upper = data.status.upper()
    
    if status_upper not in ["OPEN", "INVESTIGATING", "RESOLVED"]:
        raise HTTPException(status_code=400, detail="Invalid operational status assignment")
        
    # Update our runtime status database tracker
    ALERT_STATUS_DB[aid] = status_upper
    print(f"[+] Operational Alert {aid} migration shifted to state: {status_upper}")
    return {"status": "success", "alert_id": aid, "new_status": status_upper}

@app.get("/users")
def get_users():
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute("SELECT id, username, role FROM users ORDER BY id ASC")
    rows = cursor.fetchall()
    conn.close()
    
    return [
        {"id": row[0], "username": row[1], "role": row[2]}
        for row in rows
    ]

@app.post("/users")
def create_user(user: UserCreate):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    try:
        # Enforce password hashing protections
        encrypted_password = hash_password(user.password)
        cursor.execute("""
            INSERT INTO users (username, password_hash, role)
            VALUES (?, ?, ?)
        """, (user.username.lower().strip(), encrypted_password, user.role))
        conn.commit()
        return {"message": "User created successfully"}
    except sqlite3.IntegrityError:
        raise HTTPException(status_code=400, detail="Operator profile already registered")
    finally:
        conn.close()

@app.delete("/users/{user_id}")
def delete_user(user_id: int):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    
    # Prevent the active admin account from deleting itself by accident
    cursor.execute("SELECT username FROM users WHERE id = ?", (user_id,))
    target = cursor.fetchone()
    if target and target[0] == "admin":
        conn.close()
        raise HTTPException(status_code=403, detail="Cannot delete master root administrator")
        
    cursor.execute("DELETE FROM users WHERE id = ?", (user_id,))
    conn.commit()
    conn.close()
    return {"message": "User deleted successfully"}

@app.put("/users/{user_id}/role")
def update_role(user_id: int, data: RoleUpdate):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute("UPDATE users SET role = ? WHERE id = ?", (data.role, user_id))
    conn.commit()
    conn.close()
    return {"message": "Role metrics updated successfully"}
