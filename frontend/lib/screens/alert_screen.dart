import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {

  late Future<List<dynamic>> alertsFuture;

  @override
  @override
  void initState() {
    super.initState();

    print("Alerts screen opened");

    alertsFuture = ApiService.getAlerts();
  }

  Color getColor(String severity) {
    switch (severity) {
      case "HIGH":
        return Colors.red;

      case "MEDIUM":
        return Colors.orange;

      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Security Alerts"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: alertsFuture,
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final alerts = snapshot.data!;

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {

              final alert = alerts[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Icon(
                    Icons.warning,
                    color: getColor(alert["severity"]),
                  ),
                  title: Text(alert["message"]),
                  subtitle:
                  Text(alert["severity"]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}