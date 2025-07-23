// lib/pages/cards_page.dart

import 'package:flutter/material.dart';
import '../organization.dart';
import '../widgets/organization_card.dart';

class CardsPage extends StatelessWidget {
  // It receives all the data and functions it needs to operate.
  final List<Organization>? organizations;
  final String status;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onClearCache;

  const CardsPage({
    super.key,
    required this.organizations,
    required this.status,
    required this.onRefresh,
    required this.onClearCache,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Business Directory"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Cache',
            onPressed: onClearCache, // Use the passed-in function
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (organizations == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(status),
          ],
        ),
      );
    }
    if (organizations!.isEmpty) {
      return Center(child: Text(status));
    }

    return RefreshIndicator(
      onRefresh: onRefresh, // Use the passed-in function
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        itemCount: organizations!.length,
        itemBuilder: (context, index) {
          final org = organizations![index];
          return OrganizationCard(org: org);
        },
      ),
    );
  }
}