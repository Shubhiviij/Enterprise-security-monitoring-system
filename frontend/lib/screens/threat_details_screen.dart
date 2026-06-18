import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ThreatDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> threat;

  const ThreatDetailsScreen({super.key, required this.threat});

  Color _getSeverityColor(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'CRITICAL': return Colors.red.shade900;
      case 'HIGH': return Colors.red.shade400;
      case 'MEDIUM': return Colors.orange.shade400;
      default: return Colors.green.shade400;
    }
  }

  Future<void> _launchNVDLookup(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch repository entry';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to open link: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final severity = threat["severity"] ?? "HIGH";
    final severityColor = _getSeverityColor(severity);
    final cveId = threat["cve"] ?? "Unknown CVE";

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(cveId),
        backgroundColor: const Color(0xFF111827),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP CORE OVERVIEW CARD ──
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cveId,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                        ),
                        Chip(
                          backgroundColor: severityColor,
                          label: Text(
                            severity,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30, color: Colors.white10),
                    _metadataRow(Icons.business, "Vendor", threat["vendor"]),
                    _metadataRow(Icons.layers, "Product", threat["product"]),
                    _metadataRow(Icons.calendar_today, "CISA Feed Date", threat["dateAdded"]),
                    _metadataRow(Icons.gavel, "Remediation Due", threat["dueDate"]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── DETAILED THREAT SUMMARY ──
            const Text("VULNERABILITY SUMMARY", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
              child: Text(
                threat["summary"] ?? (threat["title"] ?? "No deep narrative summary data log trace available."),
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),

            // ── REQUIRED REMEDIATION ACTIONS ──
            const Text("REQUIRED REMEDIATION ACTION", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.15)),
              ),
              child: Text(
                threat["requiredAction"] ?? "Apply corresponding system patches or isolate asset partitions immediately.",
                style: TextStyle(color: Colors.red.shade200, fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 30),

            // ── EXTERNAL OSINT CROSS-LOOKUP BUTTON ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueGrey.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _launchNVDLookup(context, threat["referenceUrl"] ?? "https://nvd.nist.gov/"),
                icon: const Icon(Icons.open_in_new, color: Colors.blueAccent, size: 18),
                label: const Text(
                  "Launch NVD Deep Lookup",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metadataRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(color: Colors.white38, fontSize: 13)),
          Expanded(
            child: Text(
              value ?? 'N/A',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}