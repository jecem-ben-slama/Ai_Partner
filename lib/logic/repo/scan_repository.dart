import 'package:sqflite/sqflite.dart';
import 'package:ai_partner/logic/services/database_service.dart';
import 'package:ai_partner/models/scan_result_model.dart';

class ScanRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<void> insertScan(VisionResult result) async {
    final db = await _dbService.database;

    await db.insert('scans', {
      'id_string': result.id,
      'title': result.label ?? "New Scan",
      'content': result.content,
      'type': result.type.name,
      'dateTime': DateTime.now().toIso8601String(),
      'isFavorite': result.isFavorite ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<VisionResult>> getScans() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scans',
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return VisionResult(
        id: maps[i]['id_string'],
        content: maps[i]['content'],
        label: maps[i]['title'],
        type: VisionType.values.byName(maps[i]['type']),
        isFavorite: maps[i]['isFavorite'] == 1,
      );
    });
  }

  Future<void> updateScanTitle(String uuid, String newTitle) async {
    final db = await _dbService.database;
    await db.update(
      'scans',
      {'title': newTitle},
      where: 'id_string = ?',
      whereArgs: [uuid],
    );
  }

  // ← NEW
  Future<void> updateScanContent(String uuid, String newContent) async {
    final db = await _dbService.database;
    await db.update(
      'scans',
      {'content': newContent},
      where: 'id_string = ?',
      whereArgs: [uuid],
    );
  }

  Future<void> toggleFavorite(String uuid, bool isFavorite) async {
    final db = await _dbService.database;
    await db.update(
      'scans',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id_string = ?',
      whereArgs: [uuid],
    );
  }

  Future<void> deleteScan(String uuid) async {
    final db = await _dbService.database;
    await db.delete('scans', where: 'id_string = ?', whereArgs: [uuid]);
  }

  Future<void> deleteAll() async {
    final db = await _dbService.database;
    await db.delete('scans');
  }
}
