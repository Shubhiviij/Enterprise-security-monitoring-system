import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PhishingScannerScreen extends StatefulWidget {
  const PhishingScannerScreen({super.key});

  @override
  State<PhishingScannerScreen> createState() =>
      _PhishingScannerScreenState();
}

class _PhishingScannerScreenState
    extends State<PhishingScannerScreen> {

  final TextEditingController urlController =
  TextEditingController();

  Map<String, dynamic>? result;
  bool isLoading = false;
  String? errorMessage;

  Future<void> scanUrl() async {
    if (urlController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      result = null;
    });

    try {
      final response =
      await ApiService.scanUrl(urlController.text.trim());

      setState(() {
        result = response.isNotEmpty ? response : null;
        errorMessage = response.isEmpty ? "Scan failed. Check your connection." : null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  Color getRiskColor(String risk) {
    switch (risk) {
      case "HIGH":
        return Colors.red;
      case "MEDIUM":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Color getVerdictColor(String verdict) {
    switch (verdict) {
      case "PHISHING":
        return Colors.red;
      case "SUSPICIOUS":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  // Normalize raw score (0–9 max) to a 0–100 percentage
  int normalizeScore(int raw) {
    const int maxScore = 9;
    return ((raw / maxScore) * 100).round().clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phishing URL Scanner"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: "Enter URL to scan",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : scanUrl,
                icon: const Icon(Icons.search),
                label: const Text("Scan URL"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (isLoading)
              const CircularProgressIndicator(),

            if (errorMessage != null)
              Card(
                color: Colors.red.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (result != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Verdict badge
                      Row(
                        children: [
                          const Text(
                            "Verdict: ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: getVerdictColor(result!["verdict"])
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: getVerdictColor(result!["verdict"]),
                              ),
                            ),
                            child: Text(
                              result!["verdict"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: getVerdictColor(result!["verdict"]),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Risk level
                      Text(
                        "Risk Level: ${result!["risk"]}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: getRiskColor(result!["risk"]),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Score as proper percentage
                      LinearProgressIndicator(
                        value: normalizeScore(result!["score"] as int) / 100,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        color: getRiskColor(result!["risk"]),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Risk Score: ${normalizeScore(result!["score"] as int)}%",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),

                      // Reasons — only show section if there are any
                      // Replace the reasons section with this:
                      if ((result!["reasons"] as List).isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          "Why this URL is suspicious:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...((result!["reasons"] as List).map((reason) {
                          // Map reason type to icon + color
                          IconData icon;
                          Color iconColor;

                          switch (reason["type"]) {
                            case "keyword":
                              icon = Icons.text_fields;
                              iconColor = Colors.orange;
                              break;
                            case "symbol":
                              icon = Icons.alternate_email;
                              iconColor = Colors.red;
                              break;
                            case "ip":
                              icon = Icons.dns;
                              iconColor = Colors.red;
                              break;
                            case "structure":
                              icon = Icons.account_tree;
                              iconColor = Colors.orange;
                              break;
                            case "info":
                              icon = Icons.info_outline;
                              iconColor = Colors.blue;
                              break;
                            default:
                              icon = Icons.warning_amber_rounded;
                              iconColor = Colors.orange;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: iconColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(icon, color: iconColor, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    reason["description"],
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          );
                        })),
                      ] else ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 18),
                              SizedBox(width: 10),
                              Text(
                                "No suspicious indicators found",
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}