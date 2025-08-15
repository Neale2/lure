// lib/pages/map_page.dart

import 'dart:io';
import 'package:flutter/material.dart';

// bring in all the core FlutterMap widgets & providers
import 'package:flutter_map/flutter_map.dart';

// explicitly import the built-in cache provider
import 'package:flutter_map/flutter_map.dart';

import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../models/organization.dart';
import '../hero_dialog_route.dart';
import '../widgets/organization_slab.dart';

class MapPage extends StatefulWidget {
  final List<Organization>? organizations;
  final Function(Organization) onCardOpened;

  const MapPage({super.key, this.organizations, required this.onCardOpened});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  bool _mapReady = false;

  static const _tileUrl =
      'https://api.maptiler.com/maps/basic-v2/256/{z}/{x}/{y}.png?key=XOkTAzhDBxSmpsyvXvhw';

  final LatLng _initialCenter = const LatLng(-41.27244, 173.28393);
  final double _initialZoom = 16.0;
  final LatLngBounds _mapBounds = LatLngBounds(
    const LatLng(-47.65, 165.87), // southernmost & westernmost corner
    const LatLng(-33.89, 179.27), // northernmost & easternmost corner
  );

  @override
  void initState() {
    super.initState();
    // Wait until after the first frame so the cachingProvider
    // can be created before FlutterMap loads tiles.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _mapReady = true);
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<Marker> _buildIconMarkers() {
    if (widget.organizations == null) return [];
    return widget.organizations!.map(_buildIconMarker).toList();
  }

  List<Marker> _buildLabelMarkers(BuildContext ctx) {
    if (widget.organizations == null) return [];
    return widget.organizations!
        .map((org) => _buildLabelMarker(org, ctx))
        .toList();
  }

  Marker _buildIconMarker(Organization org) {
    final hasIcon =
        org.localIconPath != null && File(org.localIconPath!).existsSync();
    const pinSize = 40.0;

    return Marker(
      point: LatLng(org.address.lat, org.address.long),
      width: pinSize,
      height: pinSize,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          widget.onCardOpened(org);
          Navigator.of(
            context,
          ).push(HeroDialogRoute(builder: (_) => OrganizationSlab(org: org)));
        },
        child: hasIcon
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: org.cardColour,
                      shape: BoxShape.circle,
                    ),
                  ),
                  ClipOval(
                    child: Image.file(
                      File(org.localIconPath!),
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              )
            : Icon(Icons.location_pin, size: pinSize, color: org.cardColour),
      ),
    );
  }

  Marker _buildLabelMarker(Organization org, BuildContext ctx) {
    final pt = LatLng(org.address.lat, org.address.long);
    var align = const Alignment(0.0, -1.5);

    // Hardcode left/right based on longitude
    align = org.address.long > _initialCenter.longitude
        ? const Alignment(1.2, 0.0)
        : const Alignment(-1.2, 0.0);

    return Marker(
      point: pt,
      width: 120,
      height: 40,
      alignment: align,
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

  Widget _buildAttribution() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(8),
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
    if (!_mapReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Shop Nelson')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _initialCenter,
          initialZoom: _initialZoom,
          minZoom: 14,
          maxZoom: 18,
          cameraConstraint: CameraConstraint.contain(bounds: _mapBounds),
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          onPositionChanged: (_, hasGesture) {
            if (hasGesture) setState(() {});
          },
        ),
        children: [
          TileLayer(
            urlTemplate: _tileUrl,
            userAgentPackageName: 'dev.lure.app', // set your package here
            tileProvider: NetworkTileProvider(
              cachingProvider: BuiltInMapCachingProvider.getOrCreateInstance(
                maxCacheSize: 500 * 1024 * 1024, // 500 MB cap
                overrideFreshAge: const Duration(days: 30),
              ),
            ),
            minNativeZoom: 14,
            maxNativeZoom: 18,
            errorTileCallback: (tile, err, st) =>
                debugPrint('Tile error: $err'),
          ),

          if (widget.organizations != null) ...[
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 45,
                size: const Size(120, 40),
                markers: _buildLabelMarkers(context),
                builder: (_, __) => Container(),
                spiderfyCluster: false,
              ),
            ),
            MarkerLayer(markers: _buildIconMarkers()),
          ],

          _buildAttribution(),
        ],
      ),
    );
  }
}
