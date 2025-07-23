// lib/home_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/map_page.dart';
import 'pages/cards_page.dart';
import 'caching_service.dart';
import 'organization.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const String _prefsKey = 'last_tab_index';

  // Data State Management
  String _status = "Initializing...";
  List<Organization>? _organizations;
  final CachingService _cachingService = CachingService();

  @override
  void initState() {
    super.initState();
    _initialize(); // Call the single, robust initialization method.
  }

  // A single method to safely handle all async startup logic.
  Future<void> _initialize() async {
    // First async gap: load saved tab preferences.
    final prefs = await SharedPreferences.getInstance();

    // IMPORTANT: After any 'await', check if the widget is still on screen.
    if (!mounted) return;

    // Now it's safe to call setState to update the tab and show a loading status.
    setState(() {
      _selectedIndex = prefs.getInt(_prefsKey) ?? 0;
      if (_organizations == null) {
        _status = "Loading data...";
      }
    });

    // Second async gap: load the organization data.
    await _loadOrganizationData();
  }

  // This function is now used for both initial load and pull-to-refresh.
  Future<void> _loadOrganizationData() async {
    final orgs = await _cachingService.getOrganizations();

    // IMPORTANT: Another check after the data fetching.
    if (!mounted) return;

    setState(() {
      if (orgs != null && orgs.isNotEmpty) {
        _organizations = orgs;
      } else {
        _status = "No data available. Pull to refresh.";
      }
    });
  }

  Future<void> _handleClearCache() async {
    await _cachingService.clearCache();
    
    // Guard after await
    if (!mounted) return; 

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

  Future<void> _saveLastTabIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_prefsKey, index);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _saveLastTabIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    // The list of pages is built here with the latest data.
    final List<Widget> widgetOptions = <Widget>[
      const MapPage(),
      CardsPage(
        organizations: _organizations,
        status: _status,
        onRefresh: _loadOrganizationData,
        onClearCache: _handleClearCache,
      ),
    ];

    return Scaffold(
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'Cards',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}