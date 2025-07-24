// lib/caching_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'models/app_data.dart';
import 'models/organization.dart';

class CachingService {
  final String _baseUrl = 'https://neale2.github.io/lure/data/';
  final String _jsonUrl = 'https://neale2.github.io/lure/data/data.json';
  
  // Define constants for the new asset paths.
  static const String _mapAssetPath = 'assets/city.map';
  static const String _themeAssetPath = 'assets/theme.xml';

  // --- File System Helpers ---

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localJsonFile async {
    final path = await _localPath;
    return File('$path/cached_data.json');
  }

  Future<Directory> get _localImagesDir async {
    final path = await _localPath;
    final dir = Directory('$path/images');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  // --- Public Methods ---

  Future<AppData?> getAppData() async {
    await _checkForJsonUpdates();

    final jsonFile = await _localJsonFile;
    if (!await jsonFile.exists()) return null;

    try {
      final jsonString = await jsonFile.readAsString();
      final jsonData = json.decode(jsonString);
      
      final appData = AppData.fromJson(jsonData);
      
      await _cacheOrganizationAssets(appData.organizations);

      return appData;
    } catch (e) {
      print("Error reading or parsing JSON: $e");
      return null;
    }
  }

  Future<void> clearCache() async {
    await _clearAppDataCache();
    await _clearMapCache();
    print("Full application cache cleared successfully.");
  }
  
  // --- Internal Caching Logic ---
  
  Future<void> _clearAppDataCache() async {
    try {
      final jsonFile = await _localJsonFile;
      if (await jsonFile.exists()) await jsonFile.delete();
      
      final imagesDir = await _localImagesDir;
      if (await imagesDir.exists()) await imagesDir.delete(recursive: true);
      
      print("App data cache (JSON, images) cleared.");
    } catch (e) {
      print("Error clearing app data cache: $e");
    }
  }

  // UPDATED: This method now deletes the .map and .xml files.
  Future<void> _clearMapCache() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      
      // Delete the copied .map file
      final mapPath = '${documentsDirectory.path}/$_mapAssetPath';
      final mapFile = File(mapPath);
      if (await mapFile.exists()) {
        await mapFile.delete();
        print("Map cache (copied .map file) cleared.");
      }

      // Delete the copied .xml theme file
      final themePath = '${documentsDirectory.path}/$_themeAssetPath';
      final themeFile = File(themePath);
      if (await themeFile.exists()) {
        await themeFile.delete();
        print("Map theme cache (copied .xml file) cleared.");
      }

    } catch (e) {
      print("Error clearing map cache: $e");
    }
  }
  
  Future<void> _checkForJsonUpdates() async {
    try {
      final response = await http.get(Uri.parse(_jsonUrl));
      if (response.statusCode == 200) {
        await (await _localJsonFile).writeAsString(response.body);
        print("JSON data updated from server.");
      }
    } catch (e) {
      print("Could not fetch JSON updates (might be offline): $e");
    }
  }

  Future<void> _cacheOrganizationAssets(List<Organization> organizations) async {
    final imagesDir = await _localImagesDir;
    for (var org in organizations) {
      await _cacheAsset(org.logo, imagesDir, (localPath) => org.localLogoPath = localPath);
      await _cacheAsset(org.icon, imagesDir, (localPath) => org.localIconPath = localPath);
      await _cacheAsset(org.background, imagesDir, (localPath) => org.localBackgroundPath = localPath);
    }
  }

  Future<void> _cacheAsset(String remotePath, Directory imageDir, Function(String) onSetLocalPath) async {
      if (remotePath.isEmpty) return;
      final fileName = remotePath.split('/').last;
      final localFile = File('${imageDir.path}/$fileName');
      onSetLocalPath(localFile.path);
      if (!await localFile.exists()) {
        try {
          final imageUrl = '$_baseUrl$remotePath';
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode == 200) {
            await localFile.writeAsBytes(response.bodyBytes);
            print("Cached asset: $fileName");
          }
        } catch (e) {
          print("Could not cache asset $fileName: $e");
        }
      }
  }
}