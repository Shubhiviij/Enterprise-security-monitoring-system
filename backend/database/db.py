 
import sqlite3
from datetime import datetime
import bcrypt  # <-- Change this import

DB_NAME = "threat_history.db"

# ── NEW NATIVE HASHING FUNCTIONS ──
def hash_password(password: str) -> str:
    # Converts plain text to bytes, generates salt, and hashes
    pwd_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(pwd_bytes, salt).decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        return bcrypt.checkpw(
            plain_password.encode('utf-8'), 
            hashed_password.encode('utf-8')
        )
    except Exception:
        return False

def init_db():
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS threat_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            threats INTEGER,
            alerts INTEGER,
            high_risk INTEGER
        )
    """)
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT PRIMARY KEY,
            password_hash TEXT,
            role TEXT
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS behavior_baseline (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp TEXT,
          failed_logins INTEGER,
          docker_events INTEGER,
          network_events INTEGER,
          cpu REAL,
          memory REAL
        )
    """)
    cursor.execute("SELECT * FROM users WHERE username = ?", ("admin",))
    if not cursor.fetchone():
        # FIXED: Using the new direct hashing function
        default_hash = hash_password("admin123")
        cursor.execute(
            "INSERT INTO users (username, password_hash, role) VALUES (?, ?, ?)",
            ("admin", default_hash, "Administrator")
        )
        print("[+] Default admin account initialized (admin/admin123).")

    conn.commit()
    conn.close()

def create_user(username, plain_password, role="Analyst"):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    try:
        password_hash = hash_password(plain_password) # FIXED
        cursor.execute(
            "INSERT INTO users (username, password_hash, role) VALUES (?, ?, ?)",
            (username.lower(), password_hash, role)
        )
        conn.commit()
        return True
    except sqlite3.IntegrityError:
        return False
    finally:
        conn.close()

def verify_user_credentials(username, plain_password):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute("SELECT password_hash, role FROM users WHERE username = ?", (username.lower(),))
    row = cursor.fetchone()
    conn.close()
    
    # FIXED: Using the native verify check
    if row and verify_password(plain_password, row[0]):
        return {"username": username, "role": row[1]}
    return None

def save_stats(threats, alerts, high_risk):
    conn = sqlite3.connect(DB_NAME)

    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO threat_history
        (timestamp, threats, alerts, high_risk)
        VALUES (?, ?, ?, ?)
    """, (
        datetime.now().isoformat(),
        threats,
        alerts,
        high_risk
    ))

    conn.commit()
    conn.close()

def get_history():

    conn = sqlite3.connect("threat_history.db")

    cursor = conn.cursor()

    cursor.execute("""
        SELECT timestamp,
               threats,
               alerts,
               high_risk
        FROM threat_history
        ORDER BY id DESC
        LIMIT 20
    """)

    rows = cursor.fetchall()

    conn.close()

    history = []

    for row in rows:

        history.append({
            "timestamp": row[0],
            "threats": row[1],
            "alerts": row[2],
            "high_risk": row[3],
        })

    return list(reversed(history))


# ── BEHAVIOR ANOMALY TRACKING STORAGE ──
def save_behavior_snapshot(failed_logins: int, docker_events: int, network_events: int, cpu: float, memory: float):
    """Saves a metrics snapshot into the baseline telemetry table using the global DB_NAME variable."""
    # FIXED: Replaced hardcoded DB_PATH with the centralized DB_NAME constant
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO behavior_baseline (
            timestamp,
            failed_logins,
            docker_events,
            network_events,
            cpu,
            memory
        )
        VALUES (?, ?, ?, ?, ?, ?)
    """, (
        datetime.now().isoformat(),
        failed_logins,
        docker_events,
        network_events,
        cpu,
        memory
    ))

    conn.commit()
    conn.close()
# ── BEHAVIOR ANOMALY TRACKING STORAGE ──

def get_behavior_baseline() -> dict:
    """
    Queries the behavior baseline table and calculates the mathematical average 
    for all key performance indicators and security flags.
    """
    # FIXED: Replaced hardcoded DB_PATH with the centralized DB_NAME constant
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT
            AVG(failed_logins),
            AVG(docker_events),
            AVG(network_events),
            AVG(cpu),
            AVG(memory)
        FROM behavior_baseline
    """)

    row = cursor.fetchone()
    conn.close()

    # The 'or 0' fallbacks protect your statistics engine from throwing NoneType 
    # exceptions if the application executes an evaluation check on an empty table.
    return {
        "failed_logins": row[0] or 0,
        "docker_events": row[1] or 0,
        "network_events": row[2] or 0,
        "cpu": row[3] or 0,
        "memory": row[4] or 0,
    }
# ── BEHAVIOR ANOMALY EVALUATION MATRIX ──

def analyze_behavior(current: dict, baseline: dict) -> dict:
    """
    Compares real-time metrics against calculated baseline norms.
    Generates deterministic security risks if standard deviations are exceeded.
    """
    anomalies = []
    risk_score = 0

    # 1. Critical Authentication Failures Check (3x Multiplier Spike)
    if baseline["failed_logins"] > 0:
        if current["failed_logins"] > baseline["failed_logins"] * 3:
            anomalies.append("Login failures significantly above normal")
            risk_score += 30

    # 2. Critical Container Runtime Check (3x Multiplier Spike)
    if baseline["docker_events"] > 0:
        if current["docker_events"] > baseline["docker_events"] * 3:
            anomalies.append("Unusual Docker activity")
            risk_score += 20

    # 3. Host System Hardware Infrastructure Checks (2x Multiplier Spike)
    if baseline["cpu"] > 0:
        if current["cpu"] > baseline["cpu"] * 2:
            anomalies.append("CPU utilization anomaly")
            risk_score += 25

    if baseline["memory"] > 0:
        if current["memory"] > baseline["memory"] * 2:
            anomalies.append("Memory utilization anomaly")
            risk_score += 25

    # 4. Determine Cumulative Risk Categorization Matrix
    status = "NORMAL"
    if risk_score >= 50:
        status = "HIGH"
    elif risk_score >= 20:
        status = "MEDIUM"

    return {
        "status": status,
        "risk_score": risk_score,
        "anomalies": anomalies
    }
