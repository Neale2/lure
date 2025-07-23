// lib/main.dart

import 'dart:io'; // Required for File
import 'package:flutter/material.dart';
import 'caching_service.dart';
import 'organization.dart'; // Import the model

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
  List<Organization>? _organizations; // UPDATED: Use a typed list
  final CachingService _cachingService = CachingService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // UPDATED: Renamed to be more descriptive
  Future<void> _loadData() async {
    setState(() {
      _status = "Loading data...";
      _organizations = null; // Clear old data
    });

    final orgs = await _cachingService.getOrganizations();

    if (orgs != null && orgs.isNotEmpty) {
      setState(() {
        _organizations = orgs;
        _status = "Data loaded successfully.";
      });
    } else {
      setState(() => _status = "No data available. Pull to refresh.");
    }
  }

  Future<void> _handleClearCache() async {
    await _cachingService.clearCache();
    setState(() {
      _organizations = null;
      _status = "Cache cleared. Restart or pull to refresh.";
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cache Cleared!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cached Businesses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Cache',
            onPressed: _handleClearCache,
          ),
        ],
      ),
      body: _buildBody(), // UPDATED: Use a builder method for the body
    );
  }

  // NEW: Widget builder for the main content
  Widget _buildBody() {
    // If the list is null or empty, show the status message
    if (_organizations == null || _organizations!.isEmpty) {
      return Center(child: Text(_status));
    }

    // Otherwise, build the list view
    return ListView.builder(
      itemCount: _organizations!.length,
      itemBuilder: (context, index) {
        final org = _organizations![index];
        
        // Check if the local image path is valid and the file exists
        final imageFile = (org.localLogoPath != null) ? File(org.localLogoPath!) : null;
        final canDisplayImage = imageFile != null && imageFile.existsSync();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Display the image
                SizedBox(
                  width: 80,
                  height: 80,
                  child: canDisplayImage
                      ? Image.file(imageFile!) // Load image from the local file
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                ),
                const SizedBox(width: 16),
                // Display the name
                Expanded(
                  child: Text(
                    org.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}