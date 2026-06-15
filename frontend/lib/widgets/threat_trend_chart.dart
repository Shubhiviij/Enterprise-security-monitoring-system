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
    // Find highest value to calculate the dynamic headroom ceiling threshold maximums safely
    double maxCeiling = [high, medium, low].map((e) => e.toDouble()).reduce((a, b) => a > b ? a : b);
    if (maxCeiling < 10) maxCeiling = 10;

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          maxY: maxCeiling + (maxCeiling * 0.15),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38, // Fixes structural overlapping layout issue
                interval: (maxCeiling / 4).roundToDouble().clamp(1, double.infinity),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70);
                  switch (value.toInt()) {
                    case 0: return const Padding(padding: EdgeInsets.only(top: 8), child: Text("High", style: style));
                    case 1: return const Padding(padding: EdgeInsets.only(top: 8), child: Text("Medium", style: style));
                    case 2: return const Padding(padding: EdgeInsets.only(top: 8), child: Text("Low", style: style));
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
                  color: Colors.red.shade400,
                  width: 24,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: medium.toDouble(),
                  color: Colors.orange.shade400,
                  width: 24,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: low.toDouble(),
                  color: Colors.green.shade400,
                  width: 24,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}