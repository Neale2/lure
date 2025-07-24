// lib/pages/cards_page.dart

import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../models/organization.dart';
import '../widgets/organization_card.dart';

class CardsPage extends StatefulWidget {
  final AppData? appData;
  final String status;
  final List<String> recentOrgNames;
  final Function(Organization) onCardOpened;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onClearCache;

  const CardsPage({
    super.key,
    required this.appData,
    required this.status,
    required this.recentOrgNames,
    required this.onCardOpened,
    required this.onRefresh,
    required this.onClearCache,
  });

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  static const String _recentsCategoryKey = 'recents';
  String? _currentlyExpandedCategory;

  @override
  void initState() {
    super.initState();
    _setDefaultExpanded();
  }

  @override
  void didUpdateWidget(CardsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appData != oldWidget.appData || widget.recentOrgNames != oldWidget.recentOrgNames) {
      _setDefaultExpanded();
    }
  }

  void _setDefaultExpanded() {
    if (widget.recentOrgNames.isNotEmpty) {
      _currentlyExpandedCategory = _recentsCategoryKey;
      return;
    }
    if (widget.appData != null && widget.appData!.categories.isNotEmpty) {
      _currentlyExpandedCategory = widget.appData!.categories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- UPDATED ---
      appBar: AppBar(
        title: const Text("Nelson Loyalty"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Cache',
            onPressed: widget.onClearCache,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.appData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(widget.status),
          ],
        ),
      );
    }

    final allOrgs = widget.appData!.organizations;
    final groupedOrgs = <String, List<Organization>>{};
    for (var org in allOrgs) {
      (groupedOrgs[org.cat] ??= []).add(org);
    }
    
    final categoryPanels = widget.appData!.categories.map<ExpansionPanelRadio>((String category) {
      final orgsInCategory = groupedOrgs[category] ?? [];
      return _buildExpansionPanel(
        categoryKey: category,
        title: '${category[0].toUpperCase()}${category.substring(1)}',
        orgs: orgsInCategory,
      );
    }).toList();

    final recentOrgs = widget.recentOrgNames
        .map((name) => allOrgs.firstWhere((org) => org.name == name, orElse: () => null!))
        .where((org) => org != null)
        .toList();

    if (recentOrgs.isNotEmpty) {
      categoryPanels.insert(
        0,
        _buildExpansionPanel(
          categoryKey: _recentsCategoryKey,
          title: 'Recent',
          orgs: recentOrgs,
        ),
      );
    }

    final allPanelKeys = [
      if (recentOrgs.isNotEmpty) _recentsCategoryKey,
      ...widget.appData!.categories
    ];

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ExpansionPanelList.radio(
          initialOpenPanelValue: _currentlyExpandedCategory,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              if (isExpanded) {
                _currentlyExpandedCategory = allPanelKeys[index];
              }
            });
          },
          children: categoryPanels,
        ),
      ),
    );
  }

  ExpansionPanelRadio _buildExpansionPanel({
    required String categoryKey,
    required String title,
    required List<Organization> orgs,
  }) {
    return ExpansionPanelRadio(
      value: categoryKey,
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text(
            '$title (${orgs.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        );
      },
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: orgs.map((org) => OrganizationCard(org: org, onOpened: widget.onCardOpened)).toList(),
        ),
      ),
    );
  }
}