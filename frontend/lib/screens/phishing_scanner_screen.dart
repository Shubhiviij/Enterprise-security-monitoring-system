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

  Future<void> scanUrl() async {

    if (urlController.text.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    final response =
    await ApiService.scanUrl(urlController.text);

    setState(() {
      result = response;
      isLoading = false;
    });
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
                labelText: "Enter URL",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: scanUrl,
              icon: const Icon(Icons.search),
              label: const Text("Scan URL"),
            ),

            const SizedBox(height: 20),

            if (isLoading)
              const CircularProgressIndicator(),

            if (result != null)
              Card(
                elevation: 4,

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(
                        "Risk Level: ${result!["risk"]}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: getRiskColor(
                            result!["risk"],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Score: ${result!["score"]}%",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Reasons:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      ...(result!["reasons"] as List)
                          .map(
                            (reason) => ListTile(
                          leading: const Icon(
                            Icons.warning,
                          ),
                          title: Text(reason),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}