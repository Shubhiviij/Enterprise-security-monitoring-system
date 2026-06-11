import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  final Map<String, dynamic> severity;
  final List<dynamic> alerts;

  const ChartCard({
    super.key,
    required this.severity,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    final high = (severity["high"] ?? 0) as int;
    final medium = (severity["medium"] ?? 0) as int;
    final low = (severity["low"] ?? 0) as int;
    final total = (high + medium + low).toDouble();

    return Card(
      color: const Color(0xFF1E293B),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Threat Trend",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 8),
                      SizedBox(width: 5),
                      Text(
                        "LIVE",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Bar chart
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBar("HIGH", high, total, Colors.red),
                _buildBar("MED", medium, total, Colors.orange),
                _buildBar("LOW", low, total, Colors.green),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 12),

            // Recent threat feed
            const Text(
              "Recent Threat Feed",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 10),

            if (alerts.isEmpty)
              const Text(
                "No recent threats detected",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              )
            else
              ...alerts.take(3).map((alert) => _buildFeedItem(alert)),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, int value, double total, Color color) {
    final barHeight = total == 0 ? 0.0 : (value / total) * 120;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "$value",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          width: 48,
          height: barHeight.clamp(6.0, 120.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.85),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildFeedItem(dynamic alert) {
    final severity = alert["severity"] ?? "LOW";
    Color color;
    IconData icon;

    switch (severity) {
      case "HIGH":
        color = Colors.red;
        icon = Icons.dangerous_outlined;
        break;
      case "MEDIUM":
        color = Colors.orange;
        icon = Icons.warning_amber_outlined;
        break;
      default:
        color = Colors.green;
        icon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              alert["message"] ?? "",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              severity,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}