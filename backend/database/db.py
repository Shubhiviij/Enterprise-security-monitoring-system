import os
from dotenv import load_dotenv

load_dotenv()
import sqlite3
from datetime import datetime
import bcrypt

# ── DYNAMIC ABSOLUTE PATH BINDING ──
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_NAME = os.path.join(BASE_DIR, "threat_history.db")
ALLOWED_ROLES = {"Administrator", "Analyst", "User"}

# ── NATIVE HASHING FUNCTIONS ──
def hash_password(password: str) -> str:
    """Converts plain text to bytes, generates salt, and hashes using bcrypt."""
    pwd_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(pwd_bytes, salt).decode('utf-8')


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifies a plain text password against a bcrypt hash."""
    try:
        return bcrypt.checkpw(
            plain_password.encode('utf-8'),
            hashed_password.encode('utf-8')
        )
    except Exception:
        return False


# ── DATABASE INITIALIZATION ──
def init_db():
    """Initializes all relational tables and default master account."""
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
            username TEXT UNIQUE,
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
        default_password = os.getenv("DEFAULT_ADMIN_PASSWORD")

        if not default_password:
            raise RuntimeError("DEFAULT_ADMIN_PASSWORD is not configured")

        default_hash = hash_password(default_password)

        cursor.execute(
            "INSERT INTO users (username, password_hash, role) VALUES (?, ?, ?)",
            ("admin", default_hash, "Administrator")
        )

        print(f"[+] Default admin account initialized in {DB_NAME}.")

    conn.commit()
    conn.close()


# ── USER MANAGEMENT FUNCTIONS ──
def create_user(username: str, plain_password: str, role: str = "Analyst") -> bool:
    """Creates a new operator with hashed credentials."""

    username = username.strip().lower()
    role = role.strip()

    if not username or not plain_password:
        return False

    if role not in ALLOWED_ROLES:
        return False

    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    try:
        password_hash = hash_password(plain_password)

        cursor.execute(
            "INSERT INTO users (username, password_hash, role) VALUES (?, ?, ?)",
            (username, password_hash, role)
        )

        conn.commit()
        return True

    except sqlite3.IntegrityError:
        return False

    finally:
        conn.close()

def verify_user_credentials(username: str, plain_password: str):
    """Validates operator login credentials."""
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute(
        "SELECT password_hash, role FROM users WHERE username = ?",
        (username.lower().strip(),)
    )
    row = cursor.fetchone()
    conn.close()

    if row and verify_password(plain_password, row[0]):
        return {"username": username, "role": row[1]}
    return None


# ── TELEMETRY & HISTORY FUNCTIONS ──
def save_stats(threats: int, alerts: int, high_risk: int):
    """Persists aggregated threat metrics into historical tracking records."""
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO threat_history (timestamp, threats, alerts, high_risk)
        VALUES (?, ?, ?, ?)
    """, (datetime.now().isoformat(), threats, alerts, high_risk))

    conn.commit()
    conn.close()


def get_history():
    """Retrieves the last 20 threat history snapshots."""
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT timestamp, threats, alerts, high_risk
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
def save_behavior_snapshot(
    failed_logins: int,
    docker_events: int,
    network_events: int,
    cpu: float,
    memory: float
):
    """Saves a telemetry snapshot into the behavior baseline table."""
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO behavior_baseline (
            timestamp, failed_logins, docker_events, network_events, cpu, memory
        ) VALUES (?, ?, ?, ?, ?, ?)
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


def get_behavior_baseline() -> dict:
    """Calculates mathematical averages across historical behavior telemetry."""
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

    if not row or row[0] is None:
        return {
            "failed_logins": 0,
            "docker_events": 0,
            "network_events": 0,
            "cpu": 0.0,
            "memory": 0.0,
        }

    return {
        "failed_logins": row[0] or 0,
        "docker_events": row[1] or 0,
        "network_events": row[2] or 0,
        "cpu": row[3] or 0.0,
        "memory": row[4] or 0.0,
    }


def get_behavior_history(limit: int = 20) -> list:
    """Retrieves historical behavior telemetry records sorted chronologically."""
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT
            timestamp, failed_logins, docker_events, network_events, cpu, memory
        FROM behavior_baseline
        ORDER BY id DESC
        LIMIT ?
    """, (limit,))

    rows = cursor.fetchall()
    conn.close()

    history = []
    for row in rows:
        history.append({
            "timestamp": row[0],
            "failed_logins": row[1],
            "docker_events": row[2],
            "network_events": row[3],
            "cpu": row[4],
            "memory": row[5],
        })

    return list(reversed(history))


# ── BEHAVIOR ANOMALY EVALUATION MATRIX ──
def analyze_behavior(current: dict, baseline: dict) -> dict:
    """Compares real-time metrics against calculated baseline norms to calculate risk scores."""
    anomalies = []
    risk_score = 0

    # 1. Critical Authentication Failures Check (3x Multiplier Spike)
    if baseline.get("failed_logins", 0) > 0:
        if current.get("failed_logins", 0) > baseline["failed_logins"] * 3:
            anomalies.append("Login failures significantly above normal")
            risk_score += 30

    # 2. Critical Container Runtime Check (3x Multiplier Spike)
    if baseline.get("docker_events", 0) > 0:
        if current.get("docker_events", 0) > baseline["docker_events"] * 3:
            anomalies.append("Unusual Docker activity")
            risk_score += 20

    # 3. Network Interface Event Check (2.5x Multiplier Spike)
    if baseline.get("network_events", 0) > 0:
        if current.get("network_events", 0) > baseline["network_events"] * 2.5:
            anomalies.append("High volume network interface activity")
            risk_score += 20

    # 4. Host System Hardware Infrastructure Checks (2x Multiplier Spike)
    if baseline.get("cpu", 0) > 0:
        if current.get("cpu", 0) > baseline["cpu"] * 2:
            anomalies.append("CPU utilization anomaly")
            risk_score += 25

    if baseline.get("memory", 0) > 0:
        if current.get("memory", 0) > baseline["memory"] * 2:
            anomalies.append("Memory utilization anomaly")
            risk_score += 25

    # 5. Cumulative Risk Categorization Matrix
    status = "NORMAL"
    if risk_score >= 50:
        status = "HIGH"
    elif risk_score >= 20:
        status = "MEDIUM"

    return {
        "status": status,
        "risk_score": min(risk_score, 100),
        "anomalies": anomalies,
    }
