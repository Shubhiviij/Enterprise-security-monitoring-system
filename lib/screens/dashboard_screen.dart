import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';
import '../widgets/alert_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Security Dashboard"),
        ),
        drawer: Drawer(
          child: ListView(
            children: const [
              DrawerHeader(
                child: Text(
                  "Enterprise Security",
                  style: TextStyle(fontSize: 22),
                ),
              ),
              ListTile(
                leading: Icon(Icons.dashboard),
                title: Text("Dashboard"),
              ),
              ListTile(
                leading: Icon(Icons.security),
                title: Text("Threat Logs"),
              ),
              ListTile(
                leading: Icon(Icons.warning),
                title: Text("Alerts"),
              ),
              ListTile(
                leading: Icon(Icons.link),
                title: Text("Phishing Scanner"),
              ),
              ListTile(
              leading: Icon(Icons.link),
              title: Text("Reports"),
              ),
              ListTile(
              leading: Icon(Icons.link),
              title: Text("Settings"),
              ),
              ListTile(
              leading: Icon(Icons.link),
              title: Text("Logout"),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(
                  height: 400,
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: const [
                      StatCard(
                        title: "Threats",
                        value: "35",
                        color: Colors.red,
                      ),
                      StatCard(
                        title: "Alerts",
                        value: "12",
                        color: Colors.orange,
                      ),

                      StatCard(
                        title: "Users",
                        value: "120",
                        color: Colors.blue,
                      ),

                      StatCard(
                        title: "High Risk",
                        value: "8",
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Security Overview",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Text(
                  "Real-time monitoring of security events",
                ),

                const Text(
                  "Recent Alerts",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const AlertTile(
                  title: "Multiple Failed Login Attempts",
                  risk: "HIGH",
                ),

                const AlertTile(
                  title: "Suspicious URL Detected",
                  risk: "MEDIUM",
                ),

                const AlertTile(
                  title: "Unauthorized Access Attempt",
                  risk: "HIGH",
                ),
              ],
            ),
          ),
        )
    );
  }
}
