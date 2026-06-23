import sqlite3from datetime import datetime
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
