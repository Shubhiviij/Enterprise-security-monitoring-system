import 'package:flutter/material.dart';

// Assuming these services are imported from your project files:
// import 'package:your_app/services/api_service.dart';
// import 'package:your_app/services/report_service.dart';

class AlertDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> alert;

  const AlertDetailsScreen({
    super.key,
    required this.alert,
  });

  @override
  State<AlertDetailsScreen> createState() => _AlertDetailsScreenState();
}

class _AlertDetailsScreenState extends State<AlertDetailsScreen> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    // Initialize mutable status from the passed alert data
    _currentStatus = widget.alert["status"] ?? "OPEN";
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case "HIGH":
      case "CRITICAL":
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
    final severity = widget.alert["severity"] ?? "UNKNOWN";

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Tailored background for dark contrast
      appBar: AppBar(
        title: const Text("Alert Details"),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: const Color(0xFF1E293B),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.warning,
                        color: _getSeverityColor(severity),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.alert["title"] ?? "Security Alert",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Chip(
                  label: Text(
                    severity,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _getSeverityColor(severity),
                ),
                const SizedBox(height: 20),
                _buildDetailRow("Alert Type", widget.alert["type"] ?? "Threat Detection"),
                _buildDetailRow("Status", _currentStatus), // Tracks active changes dynamically
                _buildDetailRow("Events", "${widget.alert["count"] ?? 0}"),
                _buildDetailRow("Timestamp", widget.alert["timestamp"] ?? "N/A"),
                const SizedBox(height: 24),
                const Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.alert["description"] ?? "Suspicious activity detected.",
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Recommended Action",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.alert["recommendation"] ?? "Investigate logs and isolate affected system.",
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
                const Divider(height: 40, color: Colors.white10),
                const Text(
                  "INCIDENT RESPONSE MANAGEMENT",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // ── ACTIONS CONTROL INTERFACE PANEL ──
                Column(
                  children: [
                    Row(
                      children: [
                        // ── 1. INVESTIGATE ACTION BUTTON ──
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFF334155),
                              disabledBackgroundColor: const Color(0xFF1E293B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _currentStatus == "INVESTIGATING"
                                ? null
                                : () async {
                              // Placeholder ApiService check. Replace with your actual implementation code.
                              bool success = true;
                              // bool success = await ApiService.updateAlertStatus(widget.alert["id"] ?? "", "INVESTIGATING");
                              if (success) {
                                setState(() => _currentStatus = "INVESTIGATING");
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Triage initiated: Status updated to INVESTIGATING")),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.biotech, color: Colors.orangeAccent, size: 18),
                            label: const Text("Investigate", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // ── 2. MARK RESOLVED ACTION BUTTON ──
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.green.shade800,
                              disabledBackgroundColor: const Color(0xFF1E293B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _currentStatus == "RESOLVED"
                                ? null
                                : () async {
                              // Placeholder ApiService check. Replace with your actual implementation code.
                              bool success = true;
                              // bool success = await ApiService.updateAlertStatus(widget.alert["id"] ?? "", "RESOLVED");
                              if (success) {
                                setState(() => _currentStatus = "RESOLVED");
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Incident cleared: Status updated to RESOLVED")),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                            label: const Text("Mark Resolved", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── 3. EXPORT RAW ALERT MANIFEST BUTTON ──
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF475569)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          final currentAlertContext = Map<String, dynamic>.from(widget.alert);
                          currentAlertContext["status"] = _currentStatus;

                          // Call your external service layer worker
                          // await ReportService.exportSingleAlertRaw(currentAlertContext);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Diagnostic report triggered successfully")),
                            );
                          }
                        },
                        icon: const Icon(Icons.ios_share_outlined, color: Colors.blue, size: 18),
                        label: const Text("Export Alert Diagnostic", style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── RENDER HELPER METHOD ──
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
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