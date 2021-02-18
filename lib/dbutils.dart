import 'dart:io';

import 'package:qrcode_scanner/models/qrcode.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DBUtils {
  static const _dbname = 'qrcode_scanner.db';
  static const _version = 2;

  DBUtils._();
  static final DBUtils instance = DBUtils._();

  Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initializeDB();
    return _database;
  }

  _initializeDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, _dbname);
    print(dbPath);
    return await openDatabase(dbPath, onCreate: _onCreate, version: _version);
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${QRCode.tblName} (
        ${QRCode.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${QRCode.colTitle} TEXT NOT NULL,
        ${QRCode.colCode} TEXT NOT NULL
      )
    ''');
  }

  Future<QRCode> getQRCode(int id) async {
    Database db = await database;
    List<Map> res = await db.query(QRCode.tblName, where: '${QRCode.colId} = ?', whereArgs: [
      id
    ]);
    return res.length == 0 ? null : res.map((e) => QRCode.fromMap(e)).first;
  }

  Future<List<QRCode>> getQRCodes() async {
    Database db = await database;
    print(db);
    List<Map> res = await db.query(QRCode.tblName);
    return res.length == 0 ? [] : res.map((e) => QRCode.fromMap(e)).toList();
  }

  Future<int> insertQRCode(QRCode qrcode) async {
    Database db = await database;
    return await db.insert(QRCode.tblName, qrcode.toMap());
  }

  Future<int> updateQRCode(QRCode qrcode) async {
    Database db = await database;
    return await db.update(QRCode.tblName, qrcode.toMap(), where: '${QRCode.colId} = ?', whereArgs: [
      qrcode.id
    ]);
  }

  Future<int> deleteQRCode(int id) async {
    Database db = await database;
    return await db.delete(QRCode.tblName, where: '${QRCode.colId} = ?', whereArgs: [
      id
    ]);
  }
}
