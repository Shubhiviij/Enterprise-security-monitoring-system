import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LiveLogsScreen extends StatefulWidget {
  const LiveLogsScreen({super.key});

  @override
  State<LiveLogsScreen> createState() =>
      _LiveLogsScreenState();
}

class _LiveLogsScreenState
    extends State<LiveLogsScreen> {

  late Future<List<String>> logs;

  @override
  void initState() {
    super.initState();
    logs = ApiService.getLogs();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Linux Logs"),
      ),

      body: FutureBuilder(
        future: logs,

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final logList =
          snapshot.data as List<String>;

          return ListView.builder(
            itemCount: logList.length,

            itemBuilder: (context, index) {

              return Card(
                child: Padding(
                  padding:
                  const EdgeInsets.all(8),

                  child: Text(
                    logList[index],
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}