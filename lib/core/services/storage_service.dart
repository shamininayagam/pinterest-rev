import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _pinsKey = 'pinterest_pins_cache';
  static const String _likesKey = 'pinterest_liked_ids';
  static const String _savedKey = 'pinterest_saved_ids';
  static const String _boardsKey = 'pinterest_boards_cache';
  static const String _searchHistoryKey = 'pinterest_search_history';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Raw List Storage
  List<Map<String, dynamic>>? getJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return null;
    }
  }

  Future<bool> setJsonList(String key, List<Map<String, dynamic>> list) {
    return _prefs.setString(key, jsonEncode(list));
  }

  Set<String> getStringSet(String key) {
    final list = _prefs.getStringList(key);
    return list != null ? list.toSet() : <String>{};
  }

  Future<bool> setStringSet(String key, Set<String> set) {
    return _prefs.setStringList(key, set.toList());
  }

  // Getters & Setters for specific keys
  List<Map<String, dynamic>>? getPins() => getJsonList(_pinsKey);
  Future<bool> savePins(List<Map<String, dynamic>> pins) => setJsonList(_pinsKey, pins);

  Set<String> getLikedIds() => getStringSet(_likesKey);
  Future<bool> saveLikedIds(Set<String> ids) => setStringSet(_likesKey, ids);

  Set<String> getSavedIds() => getStringSet(_savedKey);
  Future<bool> saveSavedIds(Set<String> ids) => setStringSet(_savedKey, ids);

  List<Map<String, dynamic>>? getBoards() => getJsonList(_boardsKey);
  Future<bool> saveBoards(List<Map<String, dynamic>> boards) => setJsonList(_boardsKey, boards);

  List<String> getSearchHistory() {
    return _prefs.getStringList(_searchHistoryKey) ??
        ['Sports', 'Tokyo Neon', 'Minimalist Desk', 'Ceramics', 'Coffee'];
  }

  Future<bool> saveSearchHistory(List<String> history) {
    return _prefs.setStringList(_searchHistoryKey, history);
  }
}
