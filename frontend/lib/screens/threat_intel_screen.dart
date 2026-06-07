import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ThreatIntelScreen extends StatelessWidget {
  const ThreatIntelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Threat Intelligence"),
        backgroundColor: Colors.blueGrey,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getThreats(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final threats = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: threats.length,
            itemBuilder: (context, index) {

              final threat = threats[index];

              Color color = Colors.green;

              if (threat["severity"] == "CRITICAL") {
                color = Colors.red;
              } else if (threat["severity"] == "HIGH") {
                color = Colors.orange;
              } else if (threat["severity"] == "MEDIUM") {
                color = Colors.yellow;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    Icons.warning,
                    color: color,
                  ),

                  title: Text(
                    threat["cve"],
                  ),

                  subtitle: Text(
                    "${threat["title"]}\nCVSS: ${threat["cvss"]}",
                  ),

                  trailing: Chip(
                    label: Text(
                      threat["severity"],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}