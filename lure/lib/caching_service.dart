// lib/caching_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'organization.dart'; // Import the new model

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
    // Create the directory if it doesn't exist
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  // --- Public Methods ---

  // UPDATED: This is the main method the UI will call
  Future<List<Organization>?> getOrganizations() async {
    await _checkForJsonUpdates();

    final jsonFile = await _localJsonFile;
    if (!await jsonFile.exists()) {
      return null; // No data available
    }

    try {
      final jsonString = await jsonFile.readAsString();
      final jsonData = json.decode(jsonString);
      
      final List<dynamic> orgsJson = jsonData['orgs'];
      final organizations = orgsJson.map((json) => Organization.fromJson(json)).toList();
      
      // After parsing, trigger image caching
      await _cacheImages(organizations);

      return organizations;
    } catch (e) {
      print("Error reading or parsing JSON: $e");
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      final jsonFile = await _localJsonFile;
      if (await jsonFile.exists()) {
        await jsonFile.delete();
      }
      
      final imagesDir = await _localImagesDir;
      if (await imagesDir.exists()) {
        await imagesDir.delete(recursive: true); // Delete the whole images folder
      }
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
        final remoteJson = response.body;
        final file = await _localJsonFile;
        await file.writeAsString(remoteJson);
        print("JSON data updated from server.");
      }
    } catch (e) {
      print("Could not fetch JSON updates (might be offline): $e");
    }
  }

  // NEW: Handles downloading and saving images
  Future<void> _cacheImages(List<Organization> organizations) async {
    final imagesDir = await _localImagesDir;

    for (var org in organizations) {
      final fileName = org.logo.split('/').last; // "images/peter_logo.png" -> "peter_logo.png"
      final localFile = File('${imagesDir.path}/$fileName');
      
      // Set the local path on the model regardless of whether it exists
      // The UI will use this path to load the image
      org.localLogoPath = localFile.path;

      if (!await localFile.exists()) {
        try {
          final imageUrl = '$_baseUrl${org.logo}';
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode == 200) {
            await localFile.writeAsBytes(response.bodyBytes);
            print("Cached image: $fileName");
          }
        } catch (e) {
          print("Could not cache image for ${org.name}: $e");
        }
      }
    }
  }
}