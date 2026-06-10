# Enterprise Security Monitor

A real-time cybersecurity monitoring dashboard built with **Flutter** and **FastAPI**. This project simulates core Security Operations Center (SOC) functionalities such as log monitoring, alert detection, threat intelligence tracking, phishing URL analysis, and security analytics.

## Features

### Security Dashboard

* Real-time security overview
* Threat statistics
* Alert monitoring
* High-risk event tracking
* Auto-refresh every 5 seconds

### Live Log Monitoring

* Displays system logs from Kali Linux
* Real-time log collection
* Security event visibility

### Alert Management

* Detects suspicious events from logs
* Categorizes alerts by severity:

  * High
  * Medium
  * Low

### Threat Severity Analysis

* Severity breakdown cards
* Risk visualization
* Security analytics dashboard

### Threat Intelligence

* Displays known vulnerabilities and threats
* CVE information
* Severity scoring

### Phishing URL Scanner

* Scans URLs for phishing indicators
* Detects suspicious keywords
* Risk scoring engine
* Classifies URLs as:

  * Safe
  * Suspicious
  * Phishing

## Technology Stack

### Frontend

* Flutter
* Dart
* Material Design

### Backend

* FastAPI
* Python
* Uvicorn

### Security Components

* Journalctl Log Analysis
* Threat Detection Logic
* Phishing URL Heuristics
* Security Alert Engine

## Project Structure

```text
enterprise-security-monitor/
│
├── frontend/
│   ├── lib/
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── models/
│   │   ├── services/
│   │   └── main.dart
│   │
│   ├── android/
│   ├── ios/
│   └── web/
│
├── backend/
│   ├── main.py
│   ├── requirements.txt
│   └── venv/
│
└── README.md
```

## API Endpoints

### Health Check

```http
GET /
```

Response:

```json
{
  "status": "Kali Backend Running"
}
```

### Logs

```http
GET /logs
```

Returns recent system logs.

### Alerts

```http
GET /alerts
```

Returns detected security alerts.

### Statistics

```http
GET /stats
```

Returns dashboard statistics.

### Severity

```http
GET /severity
```

Returns threat severity distribution.

### Threat Intelligence

```http
GET /threats
```

Returns threat intelligence data.

### Phishing URL Scanner

```http
POST /scan-url
```

Request:

```json
{
  "url": "https://example.com"
}
```

Response:

```json
{
  "url": "https://example.com",
  "verdict": "SAFE",
  "risk": "LOW",
  "score": 0
}
```

## Installation

### Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/enterprise-security-monitor.git
cd enterprise-security-monitor
```

## Backend Setup

```bash
cd backend

python3 -m venv venv

source venv/bin/activate

pip install -r requirements.txt
```

Run Backend:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Backend URL:

```text
http://localhost:8000
```

## Frontend Setup

```bash
cd frontend

flutter pub get
```

Run Flutter Web:

```bash
flutter run -d chrome
```

## Screenshots

### Dashboard

* Threat Statistics
* Severity Analysis
* Security Analytics

### Live Logs

* Real-time Log Monitoring

### Alerts

* Security Event Detection

### Threat Intelligence

* CVE Monitoring

### Phishing Scanner

* URL Risk Assessment

## Future Enhancements

* SIEM Log Search
* PDF Security Reports
* JWT Authentication
* Threat Intelligence APIs
* Vulnerability Scanner Integration
* Wazuh Integration
* Security Event Correlation
* World Threat Map
* User Management
* Incident Response Module

## Learning Objectives

This project demonstrates:

* Cybersecurity Monitoring
* Security Event Detection
* Log Analysis
* REST API Development
* Flutter Application Development
* FastAPI Backend Development
* Threat Intelligence Concepts
* SOC Dashboard Design

## Author

Developed as a cybersecurity and enterprise security monitoring project using Flutter and FastAPI.
