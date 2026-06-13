import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ThreatTrendChart extends StatelessWidget {
  final int high;
  final int medium;
  final int low;

  const ThreatTrendChart({
    super.key,
    required this.high,
    required this.medium,
    required this.low,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),

          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text("High");
                    case 1:
                      return const Text("Medium");
                    case 2:
                      return const Text("Low");
                  }
                  return const Text("");
                },
              ),
            ),
          ),

          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: high.toDouble(),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: medium.toDouble(),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: low.toDouble(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}