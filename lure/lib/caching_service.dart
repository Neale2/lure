// lib/caching_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'organization.dart';

class CachingService {
  final String _baseUrl = 'https://neale2.github.io/lure/data/';
  final String _jsonUrl = 'https://neale2.github.io/lure/data/data.json';

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

  Future<List<Organization>?> getOrganizations() async {
    await _checkForJsonUpdates();

    final jsonFile = await _localJsonFile;
    if (!await jsonFile.exists()) return null;

    try {
      final jsonString = await jsonFile.readAsString();
      final jsonData = json.decode(jsonString);
      
      final List<dynamic> orgsJson = jsonData['orgs'];
      final organizations = orgsJson.map((json) => Organization.fromJson(json)).toList();
      
      await _cacheOrganizationAssets(organizations); // UPDATED method call

      return organizations;
    } catch (e) {
      print("Error reading or parsing JSON: $e");
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      final jsonFile = await _localJsonFile;
      if (await jsonFile.exists()) await jsonFile.delete();
      
      final imagesDir = await _localImagesDir;
      if (await imagesDir.exists()) await imagesDir.delete(recursive: true);
      
      print("Cache cleared successfully.");
    } catch (e) {
      print("Error clearing cache: $e");
    }
  }

  // --- Internal Caching Logic ---

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

  // UPDATED: Now caches both logo and icon
  Future<void> _cacheOrganizationAssets(List<Organization> organizations) async {
    final imagesDir = await _localImagesDir;

    for (var org in organizations) {
      // Cache logo
      await _cacheAsset(org.logo, imagesDir, (localPath) {
        org.localLogoPath = localPath;
      });
      // Cache icon
      await _cacheAsset(org.icon, imagesDir, (localPath) {
        org.localIconPath = localPath;
      });
    }
  }

  // NEW: Helper function to avoid duplicating caching logic
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