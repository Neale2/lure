// lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'caching_service.dart';
import 'organization.dart';

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
  List<Organization>? _organizations;
  final CachingService _cachingService = CachingService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _status = "Loading data...";
      _organizations = null;
    });

    final orgs = await _cachingService.getOrganizations();

    if (orgs != null && orgs.isNotEmpty) {
      setState(() => _organizations = orgs);
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_organizations == null) {
      return Center(child: Text(_status));
    }
    if (_organizations!.isEmpty) {
      return Center(child: Text(_status));
    }

    return ListView.builder(
      itemCount: _organizations!.length,
      itemBuilder: (context, index) {
        final org = _organizations![index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                _buildCachedImage(org.localLogoPath, isLogo: true), // Logo
                const SizedBox(width: 16),
                Expanded(
                  child: Column( // Use a Column for name and icon
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        org.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _buildCachedImage(org.localIconPath, isLogo: false), // Icon
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // NEW: Refactored image loading into a helper widget
  Widget _buildCachedImage(String? path, {required bool isLogo}) {
    final double size = isLogo ? 80.0 : 24.0;
    final iconOnFail = isLogo ? Icons.business : Icons.info_outline;

    if (path == null) {
      return SizedBox(width: size, height: size);
    }

    final imageFile = File(path);
    final canDisplayImage = imageFile.existsSync();

    return SizedBox(
      width: size,
      height: size,
      child: canDisplayImage
          ? Image.file(imageFile)
          : Container(
              color: Colors.grey[200],
              child: Icon(iconOnFail, color: Colors.grey[600]),
            ),
    );
  }
}