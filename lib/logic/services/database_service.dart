import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  // Singleton pattern: Ensures only one instance exists throughout the app
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  /// Returns the existing database or initializes a new one if it doesn't exist.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Sets up the database file path and creates the 'scans' table.
  Future<Database> _initDatabase() async {
    // Get the default databases location (e.g., /data/user/0/com.example.ai_partner/databases)
    String path = join(await getDatabasesPath(), 'ai_partner.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  /// Defines the schema for the database.
  /// We use INTEGER for 'isFavorite' because SQLite does not have a native BOOLEAN type.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE scans (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_string TEXT NOT NULL, 
      title TEXT,
      content TEXT NOT NULL,
      type TEXT NOT NULL,
      dateTime TEXT NOT NULL,
      isFavorite INTEGER DEFAULT 0
    )
  ''');
  }
  Future<void> resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null; // This is the most important line
    }
    
    String path = join(await getDatabasesPath(), 'ai_partner.db');
    await deleteDatabase(path);
    debugPrint("Database file deleted and Singleton reset.");
  }

  /// Closes the database connection (Useful for testing or cleanup).
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
  