// lib/pages/map_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import '../models/organization.dart';
import '../tile_providers/mbtiles_tile_provider.dart';

class MapPage extends StatefulWidget {
  final List<Organization>? organizations;
  const MapPage({super.key, this.organizations});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  bool _tileProviderReady = false;
  bool _markersReady = false;

  final MbTilesTileProvider _tileProvider = MbTilesTileProvider(
    mbtilesAssetPath: 'assets/map.mbtiles',
  );

  // --- UPDATED COORDINATES AND ZOOM ---
  final LatLng _initialCenter = const LatLng(-41.27244, 173.28393);
  final double _initialZoom = 18.0;
  final LatLngBounds _mapBounds = LatLngBounds(
    const LatLng(-41.3112, 173.2035), // South-West corner
    const LatLng(-41.2518, 173.3086), // North-East corner
  );
  // --- END OF UPDATES ---

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _tileProvider.initialize();
    if (mounted) {
      setState(() {
        _tileProviderReady = true;
      });
    }
  }

  @override
  void dispose() {
    _tileProvider.dispose();
    _mapController.dispose();
    super.dispose();
  }

  List<Marker> _buildIconMarkers() {
    if (widget.organizations == null) return [];
    return widget.organizations!.map((org) => _buildIconMarker(org)).toList();
  }
  
  List<Marker> _buildLabelMarkers(BuildContext context) {
    if (widget.organizations == null) return [];
    return widget.organizations!.map((org) => _buildLabelMarker(org, context)).toList();
  }

  Marker _buildIconMarker(Organization org) {
    final hasIcon = org.localIconPath != null && File(org.localIconPath!).existsSync();
    final pinSize = 40.0;

    return Marker(
      point: LatLng(org.address.lat, org.address.long),
      width: pinSize,
      height: pinSize,
      alignment: Alignment.center,
      child: hasIcon
          ? Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: org.cardColour, shape: BoxShape.circle),
                ),
                ClipOval(
                  child: Image.file(
                    File(org.localIconPath!),
                    width: 28, height: 28, fit: BoxFit.cover,
                  ),
                ),
              ],
            )
          : Icon(Icons.location_pin, size: pinSize, color: org.cardColour),
    );
  }

  Marker _buildLabelMarker(Organization org, BuildContext context) {
    final point = LatLng(org.address.lat, org.address.long);
    Alignment alignment = const Alignment(0.0, -1.5);

    if (_mapController.camera != null) {
      final mapCamera = _mapController.camera;
      final screenPoint = mapCamera.project(point);
      final screenWidth = MediaQuery.of(context).size.width;

      if (screenPoint.x > screenWidth / 2) {
        alignment = const Alignment(1.2, 0.0);
      } else {
        alignment = const Alignment(-1.2, 0.0);
      }
    }

    return Marker(
      point: point,
      width: 120,
      height: 40,
      alignment: alignment,
      child: Text(
        org.name,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade900,
          shadows: const [
            Shadow(color: Colors.white, blurRadius: 2.5),
            Shadow(color: Colors.white, blurRadius: 2.5),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Map')),
      body: !_tileProviderReady
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialCenter,
                initialZoom: _initialZoom,
                // --- UPDATED ZOOM LEVELS ---
                minZoom: 14.0,
                maxZoom: 18.0,
                cameraConstraint: CameraConstraint.contain(bounds: _mapBounds),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onMapReady: () {
                  setState(() {
                    _markersReady = true;
                  });
                },
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    setState(() {});
                  }
                },
              ),
              children: [
                TileLayer(
                  tileProvider: _tileProvider,
                  // --- UPDATED NATIVE ZOOM ---
                  minNativeZoom: 14,
                  maxNativeZoom: 18,
                  errorTileCallback: (tile, error, stackTrace) {},
                ),
                
                if (_markersReady) ...[
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 45,
                      size: const Size(120, 40),
                      markers: _buildLabelMarkers(context),
                      builder: (context, markers) {
                        return Container();
                      },
                      spiderfyCluster: false,
                    ),
                  ),
                  MarkerLayer(
                    markers: _buildIconMarkers(),
                  ),
                ],
              ],
            ),
    );
  }
}