import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _historyKey = 'scan_history';

  /// Saves a new scan session.
  /// The 'label' and 'isFavorite' fields should be part of the [resultsJson] maps.
  Future<void> saveScan(List<Map<String, dynamic>> resultsJson) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];

    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'results': resultsJson,
    };

    history.insert(0, jsonEncode(entry));
    await prefs.setStringList(_historyKey, history);
  }

  /// Retrieves all saved scans from storage.
  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    return history
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  /// NEW: Overwrites the entire history list.
  /// Essential for toggling favorites or updating labels via the Cubit.
  Future<void> saveFullHistory(List<Map<String, dynamic>> fullHistory) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyStrings = fullHistory
        .map((item) => jsonEncode(item))
        .toList();

    await prefs.setStringList(_historyKey, historyStrings);
  }

  /// Updates the label of a specific scan by its ID.
  Future<void> updateScanLabel(String id, String newLabel) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];

    List<String> updatedHistory = history.map((item) {
      Map<String, dynamic> entry = jsonDecode(item);
      if (entry['id'] == id) {
        if (entry['results'] != null && (entry['results'] as List).isNotEmpty) {
          entry['results'][0]['label'] = newLabel;
        }
      }
      return jsonEncode(entry);
    }).toList();

    await prefs.setStringList(_historyKey, updatedHistory);
  }

  /// Deletes a specific scan session by its ID.
  Future<void> deleteScanById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];

    history.removeWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == id;
    });

    await prefs.setStringList(_historyKey, history);
  }

  /// Clears all history from the device.
  Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
