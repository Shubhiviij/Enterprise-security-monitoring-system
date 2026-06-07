import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  const ChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Threat Activity",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Icon(
              Icons.show_chart,
              size: 80,
              color: Colors.red,
            ),

            Text("Threat trend monitoring"),
          ],
        ),
      ),
    );
  }
}