import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: JsonHomePage(),
    );
  }
}

class JsonHomePage extends StatefulWidget {
  const JsonHomePage({super.key});

  @override
  State<JsonHomePage> createState() => _JsonHomePageState();
}

class _JsonHomePageState extends State<JsonHomePage> {
  String _status = "Initializing...";
  dynamic _jsonData;

  final String jsonUrl = 'https://neale2.github.io/lure/data/data.json'; // Replace with your real URL

  @override
  void initState() {
    super.initState();
    initializeJsonData();
  }

  // Get the local file path
  Future<File> getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/cached_data.json');
  }

  // Save JSON to the local file
  Future<void> saveJsonToFile(String jsonData) async {
    final file = await getLocalFile();
    await file.writeAsString(jsonData);
  }

  // Read JSON from the local file
  Future<String?> readJsonFromFile() async {
    try {
      final file = await getLocalFile();
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check for updates from the server
  Future<void> checkForUpdates() async {
    try {
      final response = await http.get(Uri.parse(jsonUrl));
      if (response.statusCode == 200) {
        final remoteJson = response.body;
        final localJson = await readJsonFromFile();
        if (localJson != remoteJson) {
          await saveJsonToFile(remoteJson);
        }
      }
    } catch (_) {
      // No internet or error; use cached data
    }
  }

  // Initialize JSON data: check for update, then read from file
  Future<void> initializeJsonData() async {
    setState(() => _status = "Checking for updates...");
    await checkForUpdates();

    setState(() => _status = "Reading cached data...");
    final cachedJson = await readJsonFromFile();

    if (cachedJson != null) {
      setState(() {
        _jsonData = json.decode(cachedJson);
        _status = "Data loaded successfully.";
      });
    } else {
      setState(() => _status = "No cached data available.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("JSON Cache Example")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _jsonData != null
            ? Text("JSON Data:\n${json.encode(_jsonData)}")
            : Text(_status),
      ),
    );
  }
}
