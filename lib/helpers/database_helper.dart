import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE table_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        method TEXT,
        species TEXT,
        grade TEXT,
        length REAL,
        diameter REAL,
        quantity INTEGER,
        price REAL,
        volume REAL,
        total_price REAL
      )
    ''');
  }

  Future<int> insertRow(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('table_data', row);
  }

  Future<List<Map<String, dynamic>>> fetchAllRows() async {
    final db = await instance.database;
    return await db.query('table_data');
  }

  Future<int> deleteAllRows() async {
    final db = await instance.database;
    return await db.delete('table_data');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}