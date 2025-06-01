import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    return _initDB();
  }

  Future<Database> _initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'transactions.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id TEXT PRIMARY KEY,
            title TEXT,
            amount REAL,
            date TEXT,
            category TEXT,
            typeIndex INTEGER,
            isFutureGoalInt INTEGER,
            month INTEGER,  -- Novo campo
            year INTEGER   -- Novo campo
          )
        ''');
      },
    );
  }

  Future<int> insertTransaction(FinanceTransaction tx) async {
    final db = await database;
    return await db.insert('transactions', tx.toDatabaseMap()); // Nome atualizado
  }

  Future<List<FinanceTransaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');

    return maps.map((map) => FinanceTransaction.fromDatabaseMap(map)).toList(); // Nome atualizado
  }

  Future<int> updateTransaction(FinanceTransaction tx) async {
    final db = await database;
    return await db.update(
      'transactions',
      tx.toDatabaseMap(), // Nome atualizado
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('transactions');
  }
}
