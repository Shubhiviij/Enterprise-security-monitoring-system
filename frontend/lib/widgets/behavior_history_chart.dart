import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BehaviorHistoryChart extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const BehaviorHistoryChart({
    super.key,
    required this.history,
  });

  double _number(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  Widget _buildLineChart({
    required String title,
    required List<FlSpot> spots1,
    required List<FlSpot> spots2,
    required String label1,
    required String label2,
    required double maxY,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE5E7EB),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _legend(label1),
              const SizedBox(width: 20),
              _legend(label2),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.blueGrey.withOpacity(0.25),
                      strokeWidth: 1,
                      dashArray: [6, 6],
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      interval: maxY / 4,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: history.length > 5
                          ? (history.length / 5).ceilToDouble()
                          : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= history.length) {
                          return const SizedBox();
                        }

                        return Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots1,
                    isCurved: true,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: spots2,
                    isCurved: true,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(String text) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.cyan,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.timeline,
              color: Colors.blueGrey,
              size: 42,
            ),
            SizedBox(height: 10),
            Text(
              'No behavior history available',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    final cpuSpots = <FlSpot>[];
    final memorySpots = <FlSpot>[];

    final failedLoginSpots = <FlSpot>[];
    final dockerSpots = <FlSpot>[];
    final networkSpots = <FlSpot>[];

    for (int i = 0; i < history.length; i++) {
      final item = history[i];

      cpuSpots.add(
        FlSpot(
          i.toDouble(),
          _number(item['cpu']),
        ),
      );

      memorySpots.add(
        FlSpot(
          i.toDouble(),
          _number(item['memory']),
        ),
      );

      failedLoginSpots.add(
        FlSpot(
          i.toDouble(),
          _number(item['failed_logins']),
        ),
      );

      dockerSpots.add(
        FlSpot(
          i.toDouble(),
          _number(item['docker_events']),
        ),
      );

      networkSpots.add(
        FlSpot(
          i.toDouble(),
          _number(item['network_events']),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Behavior History',
          style: TextStyle(
            color: Color(0xFFE5E7EB),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Historical system behavior across recent monitoring snapshots',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 16),

        _buildLineChart(
          title: 'System Resource Usage',
          spots1: cpuSpots,
          spots2: memorySpots,
          label1: 'CPU',
          label2: 'Memory',
          maxY: 100,
        ),

        const SizedBox(height: 16),

        _buildLineChart(
          title: 'Security Activity',
          spots1: failedLoginSpots,
          spots2: dockerSpots,
          label1: 'Failed Logins',
          label2: 'Docker Events',
          maxY: 100,
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.network_check,
                color: Colors.cyan,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Latest network activity: '
                      '${_number(history.last['network_events']).toInt()} events',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}