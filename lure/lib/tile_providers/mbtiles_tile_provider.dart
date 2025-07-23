// lib/tile_providers/mbtiles_tile_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class MbTilesTileProvider extends TileProvider {
  final String mbtilesAssetPath;
  Database? _db;

  MbTilesTileProvider({required this.mbtilesAssetPath});

  Future<void> initialize() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = '${documentsDirectory.path}/$mbtilesAssetPath';
    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      await dbFile.parent.create(recursive: true);
      final ByteData data = await rootBundle.load(mbtilesAssetPath);
      await dbFile.writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    }

    _db = sqlite3.open(dbPath);
  }

  // --- FIX #1: The method signature is updated here ---
  // It now takes a `TileLayer` object instead of `TileUpdateEvent?`.
  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    if (_db == null) {
      throw Exception('MBTiles database not initialized. Call initialize() first.');
    }

    try {
      final flippedY = (1 << coords.z) - 1 - coords.y;

      final ResultSet resultSet = _db!.select(
        'SELECT tile_data FROM tiles WHERE zoom_level = ? AND tile_column = ? AND tile_row = ?',
        [coords.z, coords.x, flippedY],
      );

      if (resultSet.isNotEmpty) {
        final Uint8List tileBytes = resultSet.first['tile_data'];
        return MemoryImage(tileBytes);
      }
    } catch (e) {
      // If any error occurs, we can just re-throw it.
      // The TileLayer will handle it.
      rethrow;
    }

    // --- FIX #2: Replaced `CantLoadTileException` with a standard `Exception` ---
    // This is for the case where the tile is not found in the database.
    throw Exception('Tile not found in MBTiles for coordinates: $coords');
  }

  void dispose() {
    _db?.dispose();
  }
}