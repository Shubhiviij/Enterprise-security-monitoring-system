import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BehaviorAnalysisScreen extends StatefulWidget {
  const BehaviorAnalysisScreen({super.key});

  @override
  State<BehaviorAnalysisScreen> createState() => _BehaviorAnalysisScreenState();
}

class _BehaviorAnalysisScreenState extends State<BehaviorAnalysisScreen> {
  Map<String, dynamic>? data;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadBehavior();
  }

  Future<void> loadBehavior() async {
    try {
      final response = await ApiService.getBehaviorAnalysis();
      if (mounted) {
        setState(() {
          data = response;
          isLoading = false;
          errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "Failed to fetch behavioral metrics";
        });
      }
    }
  }


  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case "HIGH":
        return Colors.red;
      case "MEDIUM":
        return Colors.orange;
      case "LOW":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // 💡 FIX 1: Relocated helper layout utility inside the State class scope
  Widget buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Behavioral Analysis"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              loadBehavior();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
  Widget _buildAnomaliesSection() {
    final anomalies = data?["anomalies"];

    if (anomalies == null || anomalies.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "No behavioral anomalies detected",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Current system activity is within the established behavioral baseline.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: anomalies.map<Widget>((anomaly) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
              ),
            ),
            title: Text(
              anomaly.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              "Behavioral deviation detected",
            ),
          ),
        );
      }).toList(),
    );
  }
  Widget _buildRecommendations() {
    final anomalies = data?["anomalies"] ?? [];
    final status = (data?["status"] ?? "NORMAL").toString().toUpperCase();

    List<String> recommendations = [];

    if (anomalies.isEmpty) {
      recommendations = [
        "Continue monitoring system behavior.",
        "Review authentication activity periodically.",
        "Monitor Docker container activity for unexpected changes.",
        "Continue tracking CPU and memory utilization.",
      ];
    } else {
      recommendations.add(
          "Investigate the detected behavioral anomalies."
      );

      if (status == "HIGH") {
        recommendations.add(
            "Perform immediate investigation of affected system activity."
        );
      }

      recommendations.add(
          "Review recent authentication and system logs."
      );

      recommendations.add(
          "Verify active Docker containers and running processes."
      );

      recommendations.add(
          "Monitor network activity for unusual connections."
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: recommendations.map((recommendation) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.blueGrey,
                    size: 22,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      recommendation,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null || data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(errorMessage ?? "No data available"),
          ],
        ),
      );
    }

    final anomalies = data!["anomalies"] as List<dynamic>? ?? [];
    final riskScore = data!["risk_score"] ?? 0;
    final status = data!["status"] ?? "UNKNOWN";

    // Safety check parsing dynamic keys out of nested meta maps
    final metrics = data!["meta"]?["tracked_metrics"] ?? {};
    final failedLogins = metrics["failed_logins"] ?? 0;
    final dockerEvents = metrics["docker_events"] ?? 0;
    final networkEvents = metrics["network_events"] ?? 0;
    final cpuUsage = metrics["cpu"] ?? 0.0;
    final memoryUsage = metrics["memory"] ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          // Risk Indicator Dashboard Card
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const Text(
                    "Overall Risk Score",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "$riskScore",
                    style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Chip(
                    backgroundColor: _getStatusColor(status),
                    label: Text(
                      status,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            "Current System Metrics",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // 💡 FIX 2: Using Balanced Expanded Row structures for even grid pairs
          Row(
            children: [
              Expanded(child: buildMetricCard("Failed Logins", "$failedLogins", Icons.lock, Colors.red)),
              const SizedBox(width: 10),
              Expanded(child: buildMetricCard("Docker Events", "$dockerEvents", Icons.inventory, Colors.blue)),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(child: buildMetricCard("Network Events", "$networkEvents", Icons.wifi, Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: buildMetricCard("CPU Usage", "$cpuUsage%", Icons.memory, Colors.orange)),
            ],
          ),
          const SizedBox(height: 10),

          // 💡 FIX 3: Isolated single metric row uses half layout block instead of broken Spacer
          Row(
            children: [
              Expanded(child: buildMetricCard("Memory Usage", "$memoryUsage%", Icons.storage, Colors.purple)),
              const SizedBox(width: 10),
              const Expanded(child: SizedBox.shrink()), // Clean container block balance
            ],
          ),
          const SizedBox(height: 24),

          // Detected Threat Logs Title
          const Text(
            "Identified System Anomalies",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Detected Anomalies",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          _buildAnomaliesSection(),
          const SizedBox(height: 24),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Security Recommendations",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          _buildRecommendations(),
          const SizedBox(height: 12),

          // Anomalies Ingestion Directory Feed
          anomalies.isEmpty
              ? const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "No behavioral anomalies detected on the host system.",
                textAlign: TextAlign.center,
              ),
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: anomalies.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  title: Text(
                    anomalies[index].toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}