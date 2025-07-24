// lib/pages/map_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import '../models/organization.dart';
import '../tile_providers/mbtiles_tile_provider.dart';
import '../hero_dialog_route.dart';
import '../widgets/organization_slab.dart';

class MapPage extends StatefulWidget {
  final List<Organization>? organizations;
  final Function(Organization) onCardOpened;

  const MapPage({
    super.key,
    this.organizations,
    required this.onCardOpened,
  });

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

  final LatLng _initialCenter = const LatLng(-41.27244, 173.28393);
  final double _initialZoom = 16.0;
  final LatLngBounds _mapBounds = LatLngBounds(
    const LatLng(-41.28724, 173.25946),
    const LatLng(-41.25392, 173.29798),
  );

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
      child: GestureDetector(
        onTap: () {
          widget.onCardOpened(org);
          Navigator.of(context).push(HeroDialogRoute(
            builder: (context) => OrganizationSlab(org: org),
          ));
        },
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
      ),
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
  
  Widget _buildAttributionWidget() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '© OpenStreetMap contributors, © MapTiler',
            style: TextStyle(color: Colors.black54, fontSize: 10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- UPDATED ---
      appBar: AppBar(title: const Text('Nelson Loyalty')),
      body: !_tileProviderReady
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialCenter,
                initialZoom: _initialZoom,
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

                _buildAttributionWidget(),
              ],
            ),
    );
  }
}