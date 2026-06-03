import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';
import '../widgets/alert_tile.dart';
import 'live_logs_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Security Dashboard"),
        backgroundColor: Colors.blueGrey,
      ),

      drawer: Drawer(
        child: ListView(
          children: [

            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.security,
                    size: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Enterprise Security",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const ListTile(
              leading: Icon(Icons.dashboard),
              title: Text("Dashboard"),
            ),

            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text("Live Logs"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LiveLogsScreen(),
                  ),
                );
              },
            ),

            const ListTile(
              leading: Icon(Icons.warning),
              title: Text("Alerts"),
            ),

            const ListTile(
              leading: Icon(Icons.link),
              title: Text("Phishing Scanner"),
            ),

            const ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text("Reports"),
            ),

            const ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            ),

            const Divider(),

            const ListTile(
              leading: Icon(Icons.logout),
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

              const Text(
                "Security Overview",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Real-time monitoring of security events",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

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

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  icon: const Icon(Icons.storage),
                  label: const Text("View Live Logs"),

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LiveLogsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}