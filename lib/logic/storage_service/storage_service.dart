import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/barcode_model.dart';

class StorageService {
  static const String _historyKey = 'scan_history';

  // Save a new result to the existing list
  // lib/logic/services/storage_service.dart

  Future<void> deleteScanById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];

    // Filter out the item that matches the ID
    history.removeWhere((item) {
      final Map<String, dynamic> decoded = jsonDecode(item);
      return decoded['id'] == id;
    });

    await prefs.setStringList(_historyKey, history);
  }

  // Update your saveScan to ensure every new entry gets a unique ID
  Future<void> saveScan(String? text, List<BarcodeModel> barcodes) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];

    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
      'timestamp': DateTime.now().toIso8601String(),
      'text': text,
      'barcodes': barcodes.map((b) => b.toJson()).toList(),
    };

    history.insert(0, jsonEncode(entry));
    await prefs.setStringList(_historyKey, history);
  }

  // Load all history
  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    return history
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  // --- NEW: Delete a specific item by index ---

  // --- NEW: Delete everything ---
  Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
