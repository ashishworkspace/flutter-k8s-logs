import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kubernetes Logs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LogScreen(),
    );
  }
}

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  TextEditingController podNameController = TextEditingController();
  TextEditingController namespaceController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  List<String> logs = [];
  bool isLoading = false;

  void fetchLogs() async {
    final String podName = podNameController.text;
    final String namespace = namespaceController.text;

    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'http://localhost:5000/get_logs?pod_name=$podName&namespace=$namespace'));

    if (response.statusCode == 200) {
      setState(() {
        logs = List<String>.from(json.decode(response.body));
        isLoading = false;
      });
    } else {
      setState(() {
        logs = ['Error: ${response.statusCode}'];
        isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    // Simulate a network request delay
    await Future.delayed(const Duration(seconds: 2));

    // Here you would typically fetch your new data and update the state
    setState(() {
      fetchLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Logs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: podNameController,
              decoration: const InputDecoration(labelText: 'Pod Name'),
            ),
            TextField(
              controller: namespaceController,
              decoration: const InputDecoration(labelText: 'Namespace'),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: fetchLogs,
                    child: const Text('Get Logs'),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      _refreshIndicatorKey.currentState?.show();
                    },
                    icon: const Icon(Icons.refresh))
              ],
            ),
            const SizedBox(height: 16.0),
            const SizedBox(height: 16.0),
            Expanded(
              child: Container(
                color: Colors.black,
                child: RefreshIndicator(
                  key: _refreshIndicatorKey,
                  color: Colors.white,
                  backgroundColor: Colors.black38,
                  strokeWidth: 4.0,
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        child: Text(
                          logs[index],
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
