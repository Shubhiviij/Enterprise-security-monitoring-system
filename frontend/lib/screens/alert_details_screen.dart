import 'package:flutter/material.dart';

class AlertDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> alert;

  const AlertDetailsScreen({
    super.key,
    required this.alert,
  });

  Color getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
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

  @override
  Widget build(BuildContext context) {
    final severity = alert["severity"] ?? "UNKNOWN";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Alert Details"),
        backgroundColor: Colors.blueGrey.shade900,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Card(
          color: const Color(0xFF1E293B),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: getSeverityColor(severity),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      alert["title"] ?? "Security Alert",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Chip(
                  label: Text(
                    severity,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor:
                  getSeverityColor(severity),
                ),

                const SizedBox(height: 20),

                detailRow(
                  "Alert Type",
                  alert["type"] ?? "Threat Detection",
                ),

                detailRow(
                  "Status",
                  alert["status"] ?? "OPEN",
                ),

                detailRow(
                  "Events",
                  "${alert["count"] ?? 0}",
                ),

                detailRow(
                  "Timestamp",
                  alert["timestamp"] ?? "N/A",
                ),

                const SizedBox(height: 20),

                const Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  alert["description"] ??
                      "Suspicious activity detected.",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Recommended Action",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  alert["recommendation"] ??
                      "Investigate logs and isolate affected system.",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}