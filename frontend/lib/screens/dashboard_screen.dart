import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Models & Services
import '../models/behavior_analysis.dart';
import '../services/api_service.dart';
import '../services/auth_session.dart';
import '../services/report_service.dart';

// Widgets
import '../widgets/alert_tile.dart';
import '../widgets/behavior_analysis_card.dart';
import '../widgets/severity_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/threat_trend_chart.dart';
import '../widgets/behavior_history_chart.dart';

// Screens
import 'alert_details_screen.dart';
import 'alert_screen.dart';
import 'behaviour_analysis_screen.dart';
import 'live_logs_screen.dart';
import 'login_screen.dart';
import 'phishing_scanner_screen.dart';
import 'threat_intel_screen.dart';
import 'user_management_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // State Data Collections
  Map<String, dynamic>? _statsData;
  Map<String, dynamic>? _severityData;
  List<dynamic> _alerts = [];
  List<dynamic> _threats = [];
  BehaviorAnalysis? _behaviorAnalysis;
  List<Map<String, dynamic>> _behaviorHistory = [];
  bool _behaviorHistoryLoading = true;

  // Operational State Flags
  bool _isLoading = true;
  bool _behaviorLoading = true;
  String? _errorMessage;
  Timer? _timer;

  // Track precise data sync time
  String _lastUpdated = "--:--:--";

  @override
  void initState() {
    super.initState();
    // Consolidated single initialization pass
    _fetchData(isInitialLoad: true);
    _loadBehaviorHistory();

    // Polls background data smoothly every 5 seconds
    _timer = Timer.periodic(
      const Duration(seconds: 5),
          (_) => _fetchData(isInitialLoad: false),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── UNIFIED TELEMETRY SYNC PIPELINE ──
  Future<void> _fetchData({required bool isInitialLoad}) async {
    if (isInitialLoad) {
      setState(() {
        _isLoading = true;
        _behaviorLoading = true;
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
        ApiService.getBehaviorAnalysis(),
      ]);

      if (!mounted) return;

      setState(() {
        _statsData = results[0] as Map<String, dynamic>?;
        _severityData = results[1] as Map<String, dynamic>?;
        _alerts = (results[2] as List<dynamic>?) ?? [];
        _threats = (results[3] as List<dynamic>?) ?? [];

        // Parse Behavior Analysis Object safely
        if (results[4] != null) {
          _behaviorAnalysis = BehaviorAnalysis.fromJson(results[4] as Map<String, dynamic>);
        }

        _errorMessage = null;
        _isLoading = false;
        _behaviorLoading = false;

        // Timestamp captures precisely when the engine pushes fresh data mutations
        _lastUpdated = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        if (_statsData == null || _severityData == null) {
          _errorMessage = "Failed to sync security data: $e";
        }
        _isLoading = false;
        _behaviorLoading = false;
      });
    }
  }

  // Helper KPI Widget Generator
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
  Future<void> _loadBehaviorHistory() async {
    try {
      final history = await ApiService.getBehaviorHistory();

      if (!mounted) return;

      setState(() {
        _behaviorHistory = history;
        _behaviorHistoryLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _behaviorHistory = [];
        _behaviorHistoryLoading = false;
      });

      print('Failed to load behavior history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _statsData ?? {"threats": 0, "alerts": 0, "users": 0, "high_risk": 0};
    final severity = _severityData ?? {"high": 0, "medium": 0, "low": 0};
    final hasCriticalThreats = (severity["high"] ?? 0) > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Security Dashboard"),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Dashboard Data",
            onPressed: _isLoading ? null : () => _fetchData(isInitialLoad: false),
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
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.blueGrey),
              currentAccountPicture: CircleAvatar(
                backgroundColor: const Color(0xFF0F172A),
                child: Icon(
                  AuthSession().isAdmin ? Icons.admin_panel_settings : Icons.security,
                  size: 36,
                  color: AuthSession().isAdmin ? Colors.red.shade400 : Colors.blue.shade400,
                ),
              ),
              accountName: Text(
                AuthSession().username?.toUpperCase() ?? "UNKNOWN OPERATOR",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  AuthSession().role ?? "Security Analyst",
                  style: TextStyle(
                    color: AuthSession().isAdmin ? Colors.red.shade300 : Colors.green.shade300,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text("Live Logs"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveLogsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text("Alerts"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text("Phishing Scanner"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PhishingScannerScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text("Threat Intelligence"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ThreatIntelScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.psychology),
              title: const Text("Behavior Analysis"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BehaviorAnalysisScreen()),
                );
              },
            ),
            const Divider(),
            if (AuthSession().isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.supervised_user_circle_outlined, color: Colors.lightBlueAccent),
                title: const Text("User Management", style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text("Manage operator clearance levels", style: TextStyle(fontSize: 10, color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserManagementScreen()),
                  );
                },
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              trailing: AuthSession().isAdmin ? null : const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
              subtitle: AuthSession().isAdmin ? null : const Text("Requires Administrator rights", style: TextStyle(fontSize: 10)),
              onTap: AuthSession().isAdmin ? () => Navigator.pop(context) : null,
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                AuthSession().clearSession();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
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
                  const Text("Real-time monitoring of security events", style: TextStyle(color: Colors.grey)),
                  Text("Last Updated: $_lastUpdated", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),

              // ── SECURITY STATUS BANNER ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: hasCriticalThreats ? Colors.red.withOpacity(0.08) : Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasCriticalThreats ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasCriticalThreats ? Icons.gpp_bad_outlined : Icons.verified_user_outlined,
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

              // ── BEHAVIOR ANOMALY DIAGNOSTIC CARD ──
              if (_behaviorLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_behaviorAnalysis != null) ...[
                BehaviorAnalysisCard(
                  status: _behaviorAnalysis!.status,
                  riskScore: _behaviorAnalysis!.riskScore,
                  anomalies: _behaviorAnalysis!.anomalies,
                  metrics: _behaviorAnalysis!.trackedMetrics,
                ),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 24),

              _behaviorHistoryLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : BehaviorHistoryChart(
                history: _behaviorHistory,
              ),

              const SizedBox(height: 24),

              // ── STATS GRID ──
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

              // ── THREAT SEVERITY SECTION ──
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

              // ── ANALYTICS SECTION ──
              const Text(
                "Analytics & Recent Activity",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

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

              // ── RECENT ALERTS ──
              const Text(
                "Recent Alerts",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_alerts.isEmpty) const Text("No alerts detected"),

              ..._alerts.map(
                    (alert) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AlertDetailsScreen(alert: alert),
                      ),
                    );
                  },
                  child: AlertTile(
                    title: alert["title"] ?? alert["message"],
                    risk: alert["severity"],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}