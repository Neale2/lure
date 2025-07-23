// lib/home_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/map_page.dart';
import 'pages/cards_page.dart';
import 'caching_service.dart';
import 'models/app_data.dart';
import 'models/organization.dart';
import 'services/preference_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const String _prefsKey = 'last_tab_index';

  // State Management
  String _status = "Initializing...";
  AppData? _appData;
  List<String> _recentOrgNames = [];
  
  // Services
  final CachingService _cachingService = CachingService();
  final PreferenceService _preferenceService = PreferenceService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Load saved preferences first
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final lastTabIndex = prefs.getInt(_prefsKey) ?? 0;
    
    // Load recents from memory
    final recents = await _preferenceService.getRecents();
    if (!mounted) return;

    setState(() {
      _selectedIndex = lastTabIndex;
      _recentOrgNames = recents;
      if (_appData == null) {
        _status = "Loading data...";
      }
    });

    await _loadAppData();
  }
  
  Future<void> _loadAppData() async {
    final data = await _cachingService.getAppData();
    if (!mounted) return;

    setState(() {
      if (data != null) {
        _appData = data;
      } else {
        _status = "No data available. Pull to refresh.";
      }
    });
  }

  Future<void> _handleCardOpened(Organization org) async {
    await _preferenceService.addRecent(org.name);
    // Reload the recents from memory to update the UI
    final recents = await _preferenceService.getRecents();
    if (!mounted) return;
    setState(() {
      _recentOrgNames = recents;
    });
  }

  Future<void> _handleClearCache() async {
    await _cachingService.clearCache();
    if (!mounted) return;

    setState(() {
      _appData = null;
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
    final List<Widget> widgetOptions = <Widget>[
      const MapPage(),
      CardsPage(
        appData: _appData,
        status: _status,
        recentOrgNames: _recentOrgNames,
        onCardOpened: _handleCardOpened,
        onRefresh: _loadAppData,
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
        onTap: _onItemTapped,
      ),
    );
  }
}