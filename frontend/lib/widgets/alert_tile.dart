import 'package:flutter/material.dart';

class AlertTile extends StatelessWidget {
  final String title;
  final String risk;

  const AlertTile({
    super.key,
    required this.title,
    required this.risk,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
        ),
        title: Text(title),
        subtitle: Text("Risk: $risk"),
      ),
    );
  }
}