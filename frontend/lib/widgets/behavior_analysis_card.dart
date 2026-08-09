import 'package:flutter/material.dart';

class BehaviorAnalysisCard extends StatelessWidget {
  final String status;
  final int riskScore;
  final List<String> anomalies;
  final Map<String, dynamic> metrics;

  const BehaviorAnalysisCard({
    super.key,
    required this.status,
    required this.riskScore,
    required this.anomalies,
    required this.metrics,
  });

  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAnomalies = anomalies.isNotEmpty;

    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Behavioral Analysis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      hasAnomalies
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                Text(
                  'Risk Score: $riskScore',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            if (!hasAnomalies)
              const Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: Colors.green,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No behavioral anomalies detected',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detected Anomalies',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...anomalies.map(
                        (anomaly) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(color: Colors.red),
                          ),
                          Expanded(
                            child: Text(
                              anomaly,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            const Divider(
              color: Colors.white12,
              height: 30,
            ),

            _metric(
              'Failed Logins',
              metrics['failed_logins'],
            ),
            _metric(
              'Docker Events',
              metrics['docker_events'],
            ),
            _metric(
              'Network Events',
              metrics['network_events'],
            ),
            _metric(
              'CPU Usage',
              '${metrics['cpu']}%',
            ),
            _metric(
              'Memory Usage',
              '${metrics['memory']}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white60,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}