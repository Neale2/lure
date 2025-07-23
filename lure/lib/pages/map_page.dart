// lib/pages/map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../tile_providers/mbtiles_tile_provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MbTilesTileProvider _tileProvider = MbTilesTileProvider(
    mbtilesAssetPath: 'assets/map.mbtiles',
  );

  late Future<void> _initializationFuture;

  // --- FIX #1: Define the boundaries for your map here ---
  // These coordinates define the rectangle the user can pan within.
  // You will need to find the correct values for your specific .mbtiles file.
  final LatLngBounds _mapBounds = LatLngBounds(
    const LatLng(-41.45, 173.10), // South-West corner
    const LatLng(-41.15, 173.45), // North-East corner
  );

  @override
  void initState() {
    super.initState();
    _initializationFuture = _tileProvider.initialize();
  }

  @override
  void dispose() {
    _tileProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Map'),
      ),
      body: FutureBuilder<void>(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error initializing map: ${snapshot.error}'));
          }

          return FlutterMap(
            options: MapOptions(
              // --- FIX #2: Use the correct coordinates you provided ---
              initialCenter: const LatLng(-41.304794, 173.240397),

              // --- FIX #3: Set zoom levels and camera constraint ---
              initialZoom: 13.0,
              minZoom: 10.0, // As requested
              maxZoom: 16.0, // Adjust to match your mbtiles file
              
              // This is the crucial part that locks the map view.
              cameraConstraint: CameraConstraint.contain(
                bounds: _mapBounds,
              ),
            ),
            children: [
              TileLayer(
                tileProvider: _tileProvider,
                // This prevents flutter_map from trying to load tiles outside the defined zoom range.
                minNativeZoom: 12,
                maxNativeZoom: 16,
                errorTileCallback: (tile, error, stackTrace) {
                  // This will now be called much less often, if at all.
                },
              ),
            ],
          );
        },
      ),
    );
  }
}