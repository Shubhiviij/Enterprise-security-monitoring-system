import 'dart:async';
import 'package:enterprise_security_monitor/screens/threat_intel_screen.dart';
import 'package:flutter/material.dart';
import 'package:enterprise_security_monitor/screens/alert_screen.dart';
import 'package:enterprise_security_monitor/services/api_service.dart';
import '../widgets/severity_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/alert_tile.dart';
import 'live_logs_screen.dart';
import 'package:intl/intl.dart';
import 'phishing_scanner_screen.dart';
import '../services/report_service.dart';
import '../widgets/threat_trend_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Widget _kpiTile(IconData icon, String label, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
              Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
  Map<String, dynamic>? _statsData;
  Map<String, dynamic>? _severityData;
  List<dynamic> _alerts = [];
  List<dynamic> _threats = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _timer;

  // Track precise data sync time
  String _lastUpdated = "--:--:--";

  @override
  void initState() {
    super.initState();
    _fetchData(isInitialLoad: true);

    // Polls background data smoothly every 5 seconds
    _timer = Timer.periodic(
      const Duration(seconds: 5),
          (_) => _fetchData(isInitialLoad: false),
    );
  }

  Future<void> _fetchData({required bool isInitialLoad}) async {
    if (isInitialLoad) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Parallel API executions for improved speed
      final results = await Future.wait([
        ApiService.getStats(),
        ApiService.getSeverity(),
        ApiService.getAlerts(),
        ApiService.getThreats(),
      ]);

      if (mounted) {
        setState(() {
          _statsData = results[0] as Map<String, dynamic>;
          _severityData = results[1] as Map<String, dynamic>;
          _alerts = results[2] as List<dynamic>;
          _threats = results[3] as List<dynamic>;
          _errorMessage = null; // Clear any existing historical errors if it recovers
          _isLoading = false;

          // Timestamp captures precisely when the engine pushes fresh data mutations
          _lastUpdated =
              DateFormat('HH:mm:ss').format(DateTime.now());
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Optimized UX: Only show full-screen error if initial load completely fails
          if (_statsData == null || _severityData == null) {
            _errorMessage = "Failed to sync security data: $e";
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fallback default states to keep UI rendering safe
    final stats = _statsData ?? {"threats": 0, "alerts": 0, "users": 0, "high_risk": 0};
    final severity = _severityData ?? {"high": 0, "medium": 0, "low": 0};

    // Dynamic state computation for the top banner
    final hasCriticalThreats = (severity["high"] ?? 0) > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Security Dashboard"),
        backgroundColor: Colors.blueGrey,
        actions: [
          // Anti-spam configuration built into manual sync interaction triggers
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Dashboard Data",
            onPressed: _isLoading
                ? null
                : () {
              _fetchData(isInitialLoad: false);
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Generate Security Report",
            onPressed: _isLoading
                ? null
                : () {
              ReportService.generateReport(
                stats: stats,
                severity: severity,
                threats: _threats,
                alerts: _alerts,
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.security, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Enterprise Security",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const ListTile(
              leading: Icon(Icons.dashboard),
              title: Text("Dashboard"),
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text("Live Logs"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LiveLogsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text("Alerts"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlertsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text("Phishing Scanner"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PhishingScannerScreen()),
                );
              },
            ),
            const ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text("Reports"),
            ),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text("Threat Intelligence"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ThreatIntelScreen()),
                );
              },
            ),
            const ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Security Overview",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Real-time monitoring of security events",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "Last Updated: $_lastUpdated",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── SECURITY STATUS BANNER (DYNAMIC) ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: hasCriticalThreats
                      ? Colors.red.withOpacity(0.08)
                      : Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasCriticalThreats
                        ? Colors.red.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasCriticalThreats
                          ? Icons.gpp_bad_outlined
                          : Icons.verified_user_outlined,
                      color: hasCriticalThreats ? Colors.red : Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        hasCriticalThreats
                            ? "Critical threats detected — Immediate isolation required"
                            : "All systems operational — No critical threats detected",
                        style: TextStyle(
                          color: hasCriticalThreats ? Colors.red : Colors.green,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      hasCriticalThreats ? "CRITICAL" : "SECURE",
                      style: TextStyle(
                        color: hasCriticalThreats ? Colors.red : Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── KPI ROW ──
              Row(
                children: [
                  Expanded(child: _kpiTile(Icons.speed, "API", "Online", Colors.green)),
                  const SizedBox(width: 8),
                  Expanded(child: _kpiTile(Icons.cloud_done_outlined, "Backend", "Connected", Colors.blue)),
                  const SizedBox(width: 8),
                  Expanded(child: _kpiTile(Icons.rss_feed, "Threat Feed", "Active", Colors.orange)),
                ],
              ),
              const SizedBox(height: 20),

              // --- STATS GRID ---
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  StatCard(
                    title: "Threats",
                    value: stats["threats"].toString(),
                    color: Colors.red,
                    icon: Icons.bug_report_outlined,
                  ),
                  StatCard(
                    title: "Alerts",
                    value: stats["alerts"].toString(),
                    color: Colors.orange,
                    icon: Icons.notifications_active_outlined,
                  ),
                  StatCard(
                    title: "Users",
                    value: stats["users"].toString(),
                    color: Colors.blue,
                    icon: Icons.people_outline,
                  ),
                  StatCard(
                    title: "High Risk",
                    value: stats["high_risk"].toString(),
                    color: Colors.purple,
                    icon: Icons.local_fire_department_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- THREAT SEVERITY SECTION ---
              const Text(
                "Threat Severity",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SeverityCard(
                      title: "High",
                      value: severity["high"].toString(),
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SeverityCard(
                      title: "Medium",
                      value: severity["medium"].toString(),
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SeverityCard(
                      title: "Low",
                      value: severity["low"].toString(),
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- ANALYTICS SECTION ---
              const Text(
                "Analytics & Recent Activity",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // --- ENTERPRISE THREAT TREND CARD CONTAINER ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Threat Trend Analysis",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ThreatTrendChart(
                      high: severity["high"],
                      medium: severity["medium"],
                      low: severity["low"],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // --- RECENT ALERTS ---
              const Text(
                "Recent Alerts",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (_alerts.isEmpty)
                const Text("No alerts detected"),
              ..._alerts.map(
                    (alert) => AlertTile(
                  title: alert["message"],
                  risk: alert["severity"],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}