// lib/main.dart

import 'package:flutter/material.dart';
import 'caching_service.dart';
import 'organization.dart';
import 'organization_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Business Directory',
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

    if (mounted) {
      if (orgs != null && orgs.isNotEmpty) {
        setState(() => _organizations = orgs);
      } else {
        setState(() => _status = "No data available. Check connection and pull to refresh.");
      }
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
        title: const Text("Business Directory"),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_status),
          ],
        ),
      );
    }
    if (_organizations!.isEmpty) {
      return Center(child: Text(_status));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _organizations!.length,
        itemBuilder: (context, index) {
          final org = _organizations![index];
          
          return OrganizationCard(
            name: org.name,
            logoPath: org.localLogoPath,
            iconPath: org.localIconPath,
            backgroundPath: org.localBackgroundPath,
          );
        },
      ),
    );
  }
}