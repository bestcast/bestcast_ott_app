// Dart imports:
import 'dart:async';

// Package imports:
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Project imports:
import 'db_movies_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<void> _initDatabase() async {
    _database ??= await _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'bestcast.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE moviesTable (
        id INTEGER PRIMARY KEY,
        movieUrl TEXT,
        movieID TEXT,
        movieThumnail TEXT,
        movieTitle TEXT
      )
    ''');
  }

  Future<int?> insertData(Map<String, dynamic> data) async {
    await _initDatabase();
    return await _database?.insert('moviesTable', data);
  }

  Future<List<Map<String, dynamic>>> getData() async {
    await _initDatabase();
    return await _database!.query('moviesTable');
  }

  Future<List<DbMovieModel>> getItems() async {
    await _initDatabase();
    final List<Map<String, dynamic>> queryResult = await _database!.query(
      'moviesTable',
    );
    return queryResult.map((e) => DbMovieModel.fromMap(e)).toList();
  }

  Future<int?> updateData(Map<String, dynamic> data) async {
    await _initDatabase();
    return await _database?.update(
      'moviesTable',
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  Future<int?> deleteData(int id) async {
    await _initDatabase();
    return await _database?.delete(
      'moviesTable',
      where: 'movieID = ?',
      whereArgs: [id],
    );
  }

  Future<String> getMovieId(String id) async {
    await _initDatabase();
    // var result = await _database?.rawQuery("SELECT * FROM moviesTable where movieID = "+id);
    //
    final List<Map<String, dynamic>> result = await _database!.query(
      'moviesTable',
      columns: ['movieID'],
      where: 'movieID = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first['movieID'].toString();
    } else {
      return '';
    }
  }

  Future<String> getMoviePath(String id) async {
    await _initDatabase();
    // var result = await _database?.rawQuery("SELECT * FROM moviesTable where movieID = "+id);
    //
    final List<Map<String, dynamic>> result = await _database!.query(
      'moviesTable',
      columns: ['movieUrl'],
      where: 'movieID = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first['movieUrl'].toString();
    } else {
      return '';
    }
  }

  Future<String> getMovieTitle(String id) async {
    await _initDatabase();
    // var result = await _database?.rawQuery("SELECT * FROM moviesTable where movieID = "+id);
    //
    final List<Map<String, dynamic>> result = await _database!.query(
      'moviesTable',
      columns: ['movieTitle'],
      where: 'movieID = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first['movieTitle'].toString();
    } else {
      return '';
    }
  }
}
