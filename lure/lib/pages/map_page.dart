// lib/pages/map_page.dart

import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
      ),
      body: const Center(
        child: Text(
          'Map placeholder',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}