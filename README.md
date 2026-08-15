# Enterprise Security Monitor

A real-time **Enterprise Security Monitoring System** designed to provide centralized visibility into Linux system activity, security alerts, threat intelligence, phishing indicators, behavioral anomalies, and system health.

The system combines a **Flutter-based security dashboard** with a **FastAPI backend** and **SQLite database**. Linux telemetry is collected from `journalctl`, analyzed using rule-based detection and behavioral baselines, and exposed through REST APIs to the monitoring dashboard.

> **Project Context:** Developed as part of the DA-IICT Summer Research Internship (SRI) work on cybersecurity for enterprise systems.

---

## Table of Contents

* [Overview](#overview)
* [Objectives](#objectives)
* [Key Features](#key-features)
* [System Architecture](#system-architecture)
* [Technology Stack](#technology-stack)
* [Project Structure](#project-structure)
* [System Workflow](#system-workflow)
* [Security Mechanisms](#security-mechanisms)
* [Behavioral Analysis](#behavioral-analysis)
* [Threat Intelligence](#threat-intelligence)
* [Phishing Scanner](#phishing-scanner)
* [API Reference](#api-reference)
* [Installation](#installation)
* [Configuration](#configuration)
* [Running the System](#running-the-system)
* [Frontend Configuration](#frontend-configuration)
* [PDF Reporting](#pdf-reporting)
* [Limitations](#limitations)
* [Future AI Integration](#future-ai-integration)
* [Learning Outcomes](#learning-outcomes)
* [Project Status](#project-status)

---

# Overview

Enterprise environments continuously generate system events, authentication failures, network activity, container events, and other operational telemetry.

Monitoring these events manually can make it difficult to identify suspicious activity quickly.

The **Enterprise Security Monitor** addresses this problem by providing a centralized security dashboard capable of:

* Monitoring Linux system logs
* Detecting suspicious log activity
* Generating security alerts
* Tracking alert status
* Visualizing threat statistics
* Displaying threat intelligence
* Performing heuristic phishing URL analysis
* Maintaining historical threat data
* Performing behavioral baseline analysis
* Monitoring CPU, memory, disk, and backend health
* Managing users through role-based access control
* Generating security reports in PDF format

The current implementation focuses on **rule-based security monitoring and behavioral analysis**, while providing a foundation for future AI/ML-based detection.

---

# Objectives

The primary objectives of the project are:

1. Develop a centralized enterprise security monitoring dashboard.
2. Collect and analyze Linux system telemetry.
3. Detect common suspicious activities from system logs.
4. Provide role-based access to security operations.
5. Maintain historical security and behavioral information.
6. Integrate external threat intelligence.
7. Provide heuristic phishing URL detection.
8. Detect deviations from normal system behavior.
9. Provide system health visibility.
10. Establish a foundation for future AI-assisted cybersecurity analysis.

---

# Key Features

## Authentication

The system provides username/password authentication through the FastAPI backend.

Passwords are not stored as plaintext. Password credentials are processed using **bcrypt hashing** before being stored in the SQLite database.

---

## Role-Based Access Control

The system supports three roles:

* **Administrator**
* **Analyst**
* **User**

The Flutter application maintains the authenticated user's role and uses it to control access to administrative functionality.

Administrator functionality includes user management operations such as:

* Creating users
* Updating user roles
* Removing users

The master administrator account cannot be deleted through the user-management interface.

---

## Security Dashboard

The main dashboard provides a centralized view of:

* Threat statistics
* Alert counts
* High-risk events
* Severity distribution
* Threat trends
* Security analytics
* System status

The dashboard is designed to provide a SOC-style overview of the monitored environment.

---

## Live Log Monitoring

Linux telemetry is collected using:

```bash
journalctl
```

The backend retrieves recent system journal entries and exposes them through the `/logs` API.

The Flutter interface displays these events for security monitoring.

---

## Security Alert Detection

The current detection engine identifies suspicious activity using log signatures.

Examples include:

### Authentication failures

Repeated occurrences of:

```text
failed
```

are treated as potential authentication attacks.

### Docker activity

Log entries containing:

```text
docker
```

are monitored as container-related security events.

### Network activity

Entries containing:

```text
network
```

are monitored as network-related events.

Detected events are categorized into:

* High
* Medium
* Low

---

## Alert Management

Security alerts contain information such as:

* Alert ID
* Title
* Severity
* Event type
* Current status
* Event count
* Timestamp
* Description
* Recommended mitigation

Alert statuses include:

* `OPEN`
* `INVESTIGATING`
* `RESOLVED`

The status can be updated through the backend API.

---

## Threat Intelligence

The system retrieves vulnerability information from the **CISA Known Exploited Vulnerabilities catalog**.

Threat intelligence records include:

* CVE ID
* Vulnerability title
* Vendor/project
* Product
* Date added
* Severity
* Description
* Required action
* Due date
* NVD reference

The application presents this information through a dedicated threat intelligence interface.

---

## Threat History

Aggregated security metrics are stored in SQLite for historical analysis.

The system maintains historical records containing:

* Timestamp
* Threat count
* Alert count
* High-risk event count

The most recent historical records can be visualized through the dashboard.

---

## Behavioral Analysis

The project includes a behavioral monitoring subsystem that establishes a baseline from historical system telemetry.

The following metrics are tracked:

* Failed login events
* Docker events
* Network events
* CPU utilization
* Memory utilization

The backend automatically captures behavioral snapshots approximately every **60 seconds**.

Historical averages are calculated and used as baseline values.

### Anomaly Detection

Current activity is compared against baseline behavior.

Examples:

| Metric             | Detection Threshold |
| ------------------ | ------------------- |
| Failed logins      | > 3× baseline       |
| Docker activity    | > 3× baseline       |
| Network activity   | > 2.5× baseline     |
| CPU utilization    | > 2× baseline       |
| Memory utilization | > 2× baseline       |

The resulting risk score is categorized as:

* **NORMAL**
* **MEDIUM**
* **HIGH**

This provides a lightweight behavioral anomaly detection mechanism without requiring a machine-learning model.

---

# System Architecture

```text
                         ┌──────────────────────────┐
                         │      Linux System        │
                         │                          │
                         │  journalctl / telemetry  │
                         │  CPU / Memory / Network  │
                         └────────────┬─────────────┘
                                      │
                                      ▼
                         ┌──────────────────────────┐
                         │      FastAPI Backend     │
                         │                          │
                         │ Authentication           │
                         │ RBAC                     │
                         │ Log Analysis             │
                         │ Alert Detection          │
                         │ Behavioral Analysis      │
                         │ Phishing Scanner         │
                         │ Threat Intelligence      │
                         │ System Health            │
                         └────────────┬─────────────┘
                                      │
                     ┌────────────────┴────────────────┐
                     │                                 │
                     ▼                                 ▼
          ┌─────────────────────┐           ┌─────────────────────┐
          │   SQLite Database   │           │ External Threat     │
          │                     │           │ Intelligence        │
          │ Users               │           │                     │
          │ Threat History      │           │ CISA KEV Feed       │
          │ Behavior Baselines  │           │ NVD References      │
          └─────────────────────┘           └─────────────────────┘
                     │
                     │ REST API
                     ▼
          ┌──────────────────────────────┐
          │       Flutter Frontend       │
          │                              │
          │ Login                        │
          │ Dashboard                    │
          │ Live Logs                    │
          │ Alerts                       │
          │ Threat Intelligence          │
          │ Threat History               │
          │ Behavioral Analysis          │
          │ Phishing Scanner             │
          │ User Management              │
          │ System Health                │
          │ PDF Reports                  │
          └──────────────────────────────┘
```

---

# Technology Stack

## Frontend

| Technology      | Purpose                              |
| --------------- | ------------------------------------ |
| Flutter         | Cross-platform application framework |
| Dart            | Application programming language     |
| Material Design | User interface                       |
| FL Chart        | Security analytics and visualization |
| PDF             | Report generation                    |
| Printing        | PDF preview/export                   |
| Google Fonts    | UI/report typography                 |
| HTTP            | REST API communication               |
| Intl            | Date/time formatting                 |
| URL Launcher    | URL-related functionality            |

## Backend

| Technology    | Purpose                                |
| ------------- | -------------------------------------- |
| Python        | Backend programming                    |
| FastAPI       | REST API framework                     |
| Uvicorn       | ASGI server                            |
| Pydantic      | API request validation                 |
| SQLite        | Persistent local database              |
| bcrypt        | Password hashing                       |
| psutil        | System health monitoring               |
| Requests      | External threat intelligence retrieval |
| python-dotenv | Environment configuration              |

## Linux Telemetry

```text
journalctl
```

is used as the primary Linux system telemetry source.

---

# Project Structure

```text
Enterprise-Security-Monitoring-System/
│
├── backend/
│   ├── database/
│   │   └── db.py
│   │
│   ├── main.py
│   ├── log_reader.py
│   ├── requirements.txt
│   └── .gitignore
│
├── frontend/
│   ├── lib/
│   │   ├── models/
│   │   │   ├── alert_model.dart
│   │   │   ├── behavior_analysis.dart
│   │   │   ├── history_model.dart
│   │   │   └── stats_model.dart
│   │   │
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── live_logs_screen.dart
│   │   │   ├── logs_screen.dart
│   │   │   ├── alert_screen.dart
│   │   │   ├── alert_details_screen.dart
│   │   │   ├── threat_intel_screen.dart
│   │   │   ├── threat_details_screen.dart
│   │   │   ├── behaviour_analysis_screen.dart
│   │   │   ├── phishing_scanner_screen.dart
│   │   │   └── user_management_screen.dart
│   │   │
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   ├── auth_session.dart
│   │   │   └── report_service.dart
│   │   │
│   │   ├── widgets/
│   │   │   ├── alert_tile.dart
│   │   │   ├── behavior_analysis_card.dart
│   │   │   ├── behavior_history_chart.dart
│   │   │   ├── chart_card.dart
│   │   │   ├── severity_card.dart
│   │   │   ├── stat_card.dart
│   │   │   └── threat_trend_chart.dart
│   │   │
│   │   └── main.dart
│   │
│   ├── pubspec.yaml
│   ├── android/
│   ├── ios/
│   ├── linux/
│   ├── macos/
│   ├── web/
│   └── windows/
│
├── docs/
├── .env.example
├── .gitignore
└── README.md
```

---

# System Workflow

The monitoring pipeline follows these stages:

### 1. Telemetry Collection

Linux system events are collected through:

```bash
journalctl -n 100 --no-pager
```

### 2. Log Analysis

The backend searches recent events for security-relevant signatures.

### 3. Alert Generation

Matching events are converted into structured security alerts.

### 4. Statistical Analysis

Threat and severity statistics are calculated for dashboard visualization.

### 5. Behavioral Monitoring

System telemetry is periodically stored in the behavioral baseline table.

### 6. Anomaly Detection

Current telemetry is compared against historical averages.

### 7. Dashboard Visualization

FastAPI exposes the processed information through REST APIs and Flutter presents the information through security dashboards.

---

# Security Mechanisms

The system currently implements several security controls.

## Password Protection

User passwords are processed using bcrypt before database storage.

```text
Plain Password
      │
      ▼
   bcrypt
      │
      ▼
Password Hash
      │
      ▼
SQLite
```

---

## Environment-Based Secret Configuration

The default administrator password is supplied through an environment variable:

```text
DEFAULT_ADMIN_PASSWORD
```

The `.env` file is excluded from version control.

A template is provided through:

```text
.env.example
```

---

## Role Separation

Three roles are defined:

```text
Administrator
Analyst
User
```

This provides a foundation for least-privilege access.

---

## Input Validation

FastAPI/Pydantic models are used to validate structured API requests such as:

* Login requests
* User creation
* Role updates
* URL scanning
* Alert status updates

---

## CORS Configuration

The backend uses FastAPI CORS middleware and permits local development origins such as:

```text
localhost
127.0.0.1
```

This allows the Flutter development environment to communicate with the API.

---

# Phishing Scanner

The phishing scanner uses heuristic URL analysis.

Indicators include:

* Suspicious keywords
* `@` symbols
* Excessive hyphens
* Raw IP addresses

Suspicious keywords include:

```text
login
verify
update
secure
banking
account
password
```

The scanner produces:

* Numerical score
* Normalized score
* Verdict
* Risk level
* Explanation of detected indicators

Possible verdicts:

```text
SAFE
SUSPICIOUS
PHISHING
```

Possible risk levels:

```text
LOW
MEDIUM
HIGH
```

---

# API Reference

## Authentication

### Login

```http
POST /auth/login
```

Request:

```json
{
  "username": "admin",
  "password": "your-password"
}
```

### Registration

```http
POST /auth/register
```

---

## Monitoring

### Health

```http
GET /
```

### Live Logs

```http
GET /logs
```

### Alerts

```http
GET /alerts
```

### Dashboard Statistics

```http
GET /stats
```

### Severity Distribution

```http
GET /severity
```

### Threat History

```http
GET /history
```

### System Health

```http
GET /system-health
```

---

## Alert Management

### Update Alert Status

```http
POST /alerts/update-status
```

Request:

```json
{
  "alert_id": "ALT-4011",
  "status": "INVESTIGATING"
}
```

---

## Threat Intelligence

```http
GET /threats
```

---

## Phishing Scanner

```http
POST /scan-url
```

Request:

```json
{
  "url": "https://example.com"
}
```

---

## User Management

### Get Users

```http
GET /users
```

### Create User

```http
POST /users
```

### Update Role

```http
PUT /users/{user_id}/role
```

### Delete User

```http
DELETE /users/{user_id}
```

---

## Behavioral Analysis

### Baseline

```http
GET /api/dashboard/baseline
```

### Current Behavioral Analysis

```http
GET /api/behavior-analysis
```

### Behavioral History

```http
GET /api/behavior-history
```

---

# Installation

## Prerequisites

Install the following:

* Python 3.x
* Flutter SDK
* Git
* Linux environment for live `journalctl` telemetry

The backend is designed to monitor Linux system telemetry.

---

# Backend Setup

Navigate to the backend:

```bash
cd backend
```

Create a virtual environment:

```bash
python3 -m venv venv
```

Activate it on Linux/Kali:

```bash
source venv/bin/activate
```

On Windows:

```powershell
venv\Scripts\activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

---

# Configuration

Create the environment file:

```bash
cp .env.example .env
```

Configure:

```env
DEFAULT_ADMIN_PASSWORD=your_secure_password
```

Do not commit the `.env` file to Git.

The application creates the SQLite database automatically during backend initialization.

Database location:

```text
backend/database/threat_history.db
```

---

# Running the Backend

From the `backend` directory:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

For development with automatic reload:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at:

```text
http://localhost:8000
```

FastAPI documentation is available at:

```text
http://localhost:8000/docs
```

---

# Frontend Setup

Navigate to:

```bash
cd frontend
```

Install Flutter dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

For Flutter Web:

```bash
flutter run -d chrome
```

---

# Frontend API Configuration

The Flutter application communicates with the FastAPI backend through the API base URL configured in:

```text
frontend/lib/services/api_service.dart
```

The value should point to the machine running the FastAPI server.

For example:

```dart
static const String baseUrl = "http://YOUR_SERVER_IP:8000";
```

When the frontend and backend run on different machines on the same network, use the backend machine's LAN IP address.

---

# PDF Security Reports

The application can generate security reports containing:

* Total threats
* Total alerts
* High-risk events
* User count
* Severity distribution
* Threat intelligence
* Recent alerts
* Generation timestamp

Reports are generated using Flutter's PDF and printing libraries.

Individual alert information can also be exported as an incident report.

---

# Limitations

The current system is a research/prototype implementation and has several limitations.

### Rule-Based Detection

The current log detection mechanism primarily relies on predefined textual signatures such as:

```text
failed
docker
network
```

This can result in false positives or false negatives.

### Behavioral Baseline

The behavioral system currently uses statistical averages and manually defined deviation thresholds rather than machine-learning models.

### Authentication Session

The current frontend maintains authentication state locally and does not yet implement a production-grade JWT/session-token architecture.

### Alert State

Some alert operational states are currently maintained in backend memory rather than persisted as a dedicated database entity.

### Threat Intelligence

Threat intelligence currently depends on external availability of the CISA vulnerability feed.

### Phishing Detection

The phishing scanner is heuristic-based and should not be considered a replacement for commercial URL reputation or sandboxing systems.

---

# Future AI Integration

The current architecture provides a foundation for integrating AI/ML-based cybersecurity capabilities.

Potential future enhancements include:

## Machine Learning Threat Detection

Historical telemetry could be used to train models for:

* Intrusion detection
* DDoS detection
* Malware behavior classification
* Anomaly detection
* Network traffic classification

Datasets such as **CIC-DDoS2019** can be explored for supervised security classification experiments.

---

## Advanced Behavioral Analytics

Future versions could replace manually defined thresholds with:

* Isolation Forest
* Autoencoders
* LSTM/RNN models
* Temporal anomaly detection
* Clustering
* Transformer-based sequence analysis

---

## Intelligent Alert Correlation

AI could correlate multiple low-level events into a single security incident.

For example:

```text
Failed Login
      +
Unusual Network Activity
      +
CPU Spike
      +
Process Anomaly
      ↓
Potential Compromise
```

---

## AI-Assisted SOC

A future version could provide:

* Alert prioritization
* Automated incident summaries
* Recommended mitigation
* Threat correlation
* Natural-language security queries
* Predictive risk analysis

The AI layer should be added on top of the existing monitoring architecture rather than replacing the core telemetry and security controls.

---

# Learning Outcomes

This project demonstrates practical experience with:

* Enterprise cybersecurity architecture
* Linux system monitoring
* Security event analysis
* REST API development
* FastAPI
* Flutter application development
* SQLite database design
* Authentication
* RBAC
* Password hashing
* Threat intelligence
* Phishing detection
* Behavioral anomaly detection
* Security visualization
* PDF report generation
* Git/GitHub-based development

---

# Project Status

### Implemented

* [x] Authentication
* [x] Role-Based Access Control
* [x] User Management
* [x] Live Linux Logs
* [x] Security Alerts
* [x] Alert Details
* [x] Alert Status Management
* [x] Threat Intelligence
* [x] Threat History
* [x] Threat Analytics
* [x] Phishing Scanner
* [x] Behavioral Analysis
* [x] Behavioral History
* [x] System Health Monitoring
* [x] PDF Security Reports
* [x] Password Hashing
* [x] SQLite Persistence

### Planned

* [ ] JWT-based authentication
* [ ] Persistent alert database
* [ ] Advanced SIEM integration
* [ ] Wazuh integration
* [ ] ML-based anomaly detection
* [ ] AI-assisted alert correlation
* [ ] Automated incident response
* [ ] Advanced threat prediction

---

# Conclusion

The Enterprise Security Monitor provides a modular foundation for centralized enterprise security monitoring.

By combining Linux telemetry, rule-based event detection, behavioral baseline analysis, threat intelligence, phishing analysis, RBAC, system-health monitoring, and a Flutter security dashboard, the system demonstrates the core workflow of a lightweight Security Operations Center monitoring platform.

The architecture is intentionally designed to support future integration of machine-learning and AI-based cybersecurity capabilities while retaining transparent and interpretable security controls.

---

## Author

**Shubhi Vijayvergiya**

B.Tech — Computer Science and Engineering

Developed as part of cybersecurity research and development work focused on **Cybersecurity for Enterprise Systems**.
