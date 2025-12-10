import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DbHelper {

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'expense_tracker.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },);
  }

  // create table
  static Future<void> createTables(sql.Database database) async{
    await database.execute(
      """CREATE TABLE item(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      amount REAL NOT NULL,
      notes TEXT,
      type TEXT NOT NULL,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )"""
    );
  }

  // insert item
  static Future<int> addItem(double amount, String notes, String type) async{
      final db = await DbHelper.db();
      final data = {
        'amount' : amount,
        'notes' : notes,
        'type' : type,
        'createdAt': DateTime.now().toIso8601String(),
      };
      return db.insert(
        'item',
        data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace
      );
  }

  // read all item
  static Future<List<Map<String, dynamic>>> readItems() async{
    final db = await DbHelper.db();
    return db.query('item', orderBy: 'id DESC');
  }

  // search items
  static Future<List<Map<String, dynamic>>> searchItems(String query) async {
    final db = await DbHelper.db();
    if (query.isEmpty) {
      return db.query('item', orderBy: 'id DESC');
    }
    return db.query(
      'item',
      where: 'notes LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'id DESC',
    );
  }

  // update item
  static Future<int> updateItem(int id, double amount, String notes, String type) async{
    final db = await DbHelper.db();
    final data = {
      'amount' : amount,
      'notes' : notes,
      'type' : type
    };
    return db.update(
        'item',
        data,
      where: "id = ?",
      whereArgs: [id]
    );
  }

  // delete item
  static Future<void> deleteItem(int id) async{
    final db = await DbHelper.db();
    try{
      await db.delete(
          'item',
        where: "id = ?",
        whereArgs: [id]
      );
    } catch(err) {
      debugPrint("$err");
    }
  }


}