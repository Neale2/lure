// lib/services/preference_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const _recentsKey = 'recent_orgs';
  static const _maxRecents = 2;

  // Fetches the list of recent organization names from memory.
  Future<List<String>> getRecents() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentsKey) ?? [];
  }

  // Adds an organization to the recents list, ensuring no duplicates and respecting the max limit.
  Future<void> addRecent(String orgName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recents = await getRecents();

    // Remove the name if it already exists to move it to the top.
    recents.remove(orgName);

    // Add the new name to the beginning of the list.
    recents.insert(0, orgName);

    // Trim the list to the maximum allowed size.
    if (recents.length > _maxRecents) {
      recents = recents.sublist(0, _maxRecents);
    }

    // Save the updated list back to memory.
    await prefs.setStringList(_recentsKey, recents);
  }
}