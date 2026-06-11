import 'package:flutter/material.dart';

class AlertTile extends StatelessWidget {
  final String title;
  final String risk;

  const AlertTile({
    super.key,
    required this.title,
    required this.risk,
  });

  Color _riskColor() {
    switch (risk.toUpperCase()) {
      case "HIGH":
        return Colors.red;
      case "MEDIUM":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _riskIcon() {
    switch (risk.toUpperCase()) {
      case "HIGH":
        return Icons.dangerous_outlined;
      case "MEDIUM":
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _riskColor();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_riskIcon(), color: color, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.white),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(
            risk.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}