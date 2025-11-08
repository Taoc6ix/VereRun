import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vererun.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE runs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        distance REAL NOT NULL,
        duration INTEGER NOT NULL,
        pace TEXT NOT NULL,
        calories INTEGER,
        avg_pace_spm INTEGER,
        elevation_gain INTEGER,
        run_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE current_user (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // User Methods
  Future<int> createUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<bool> checkUsernameExists(String username) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return results.isNotEmpty;
  }

  // Current User Session
  Future<void> setCurrentUser(int userId) async {
    final db = await database;
    await db.delete('current_user'); // Clear previous session
    await db.insert('current_user', {'user_id': userId});
  }

  Future<int?> getCurrentUserId() async {
    final db = await database;
    final results = await db.query('current_user');
    return results.isNotEmpty ? results.first['user_id'] as int : null;
  }

  Future<void> clearCurrentUser() async {
    final db = await database;
    await db.delete('current_user');
  }

  // Run Methods
  Future<int> createRun(Map<String, dynamic> run) async {
    final db = await database;
    return await db.insert('runs', run);
  }

  Future<List<Map<String, dynamic>>> getRunsByUser(int userId) async {
    final db = await database;
    return await db.query(
      'runs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'run_date DESC, created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getRunById(int id) async {
    final db = await database;
    final results = await db.query(
      'runs',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> deleteRun(int runId) async {
    final db = await database;
    return await db.delete(
      'runs',
      where: 'id = ?',
      whereArgs: [runId],
    );
  }

  Future<Map<String, dynamic>> getUserStats(int userId) async {
    final runs = await getRunsByUser(userId);

    if (runs.isEmpty) {
      return {
        'total_distance': 0.0,
        'total_runs': 0,
        'average_pace': "0'00\"",
        'total_time': '0h 0m',
      };
    }

    double totalDistance = 0.0;
    int totalDuration = 0;
    int totalPaceSeconds = 0;

    for (var run in runs) {
      totalDistance += run['distance'] as double;
      totalDuration += run['duration'] as int;

      // Parse pace
      final pace = run['pace'] as String;
      final parts = pace.replaceAll('"', '').split("'");
      final minutes = int.parse(parts[0]);
      final seconds = int.parse(parts[1]);
      totalPaceSeconds += (minutes * 60 + seconds);
    }

    final avgPaceSeconds = totalPaceSeconds / runs.length;
    final avgMinutes = (avgPaceSeconds ~/ 60);
    final avgSeconds = (avgPaceSeconds % 60).round();

    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;

    return {
      'total_distance': totalDistance,
      'total_runs': runs.length,
      'average_pace': "$avgMinutes'${avgSeconds.toString().padLeft(2, '0')}\"",
      'total_time': '${hours}h ${minutes}m',
    };
  }

  Future<void> close() async {
    await (await database).close();
  }
}