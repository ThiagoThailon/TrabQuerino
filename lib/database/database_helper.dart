import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'transactions.db');

    // Para desenvolvimento: descomente para recriar o banco
    // await deleteDatabase(path);

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
            month INTEGER,
            year INTEGER
          )
        ''');
      },
    ).then((db) async {
      await _verifyAndSeedData(db);
      return db;
    });
  }

  Future<void> _verifyAndSeedData(Database db) async {
    try {
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM transactions')) ?? 0;

      if (count == 0) {
        await _seedTestTransactions(db);
      }
    } catch (e) {
      print('Erro ao verificar/inserir dados iniciais: $e');
    }
  }

  Future<void> _seedTestTransactions(Database db) async {
    try {
      final transactions = [
        FinanceTransaction(
          id: '1',
          title: 'Salário Maio',
          amount: 5000,
          date: DateTime(2025, 5, 15),
          category: 'Salário',
          type: TransactionType.entrada,
          month: 5,
          year: 2025,
        ),
        FinanceTransaction(
          id: '2',
          title: 'Aluguel Maio',
          amount: 1200,
          date: DateTime(2025, 5, 1),
          category: 'Moradia',
          type: TransactionType.saida,
          month: 5,
          year: 2025,
        ),
        FinanceTransaction(
          id: '3',
          title: 'Ifood',
          amount: 127.90,
          date: DateTime(2025, 5, 1),
          category: 'Alimentação',
          type: TransactionType.saida,
          month: 5,
          year: 2025,
        ),
        FinanceTransaction(
          id: '4',
          title: 'Investimento em Ações',
          amount: 127.90,
          date: DateTime(2025, 5, 1),
          category: 'Investimentos',
          type: TransactionType.investimento,
          month: 5,
          year: 2025,
        ),
        FinanceTransaction(
          id: '5',
          title: 'Investimento em Cripto',
          amount: 600,
          date: DateTime(2025, 5, 1),
          category: 'Investimentos',
          type: TransactionType.investimento,
          month: 5,
          year: 2025,
        ),
        FinanceTransaction(
          id: '6',
          title: 'Freelance Abril',
          amount: 1500,
          date: DateTime(2025, 4, 20),
          category: 'Trabalho',
          type: TransactionType.entrada,
          month: 4,
          year: 2025,
        ),
        FinanceTransaction(
          id: '7',
          title: 'Aluguel Abril',
          amount: 1200,
          date: DateTime(2025, 4, 1),
          category: 'Moradia',
          type: TransactionType.saida,
          month: 4,
          year: 2025,
        ),
      ];

      await db.transaction((txn) async {
        for (final tx in transactions) {
          await txn.insert(
            'transactions',
            tx.toDatabaseMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      print('Dados de teste inseridos com sucesso');
    } catch (e) {
      print('Erro ao inserir dados de teste: $e');
    }
  }

  Future<int> insertTransaction(FinanceTransaction tx) async {
    final db = await database;
    return await db.insert('transactions', tx.toDatabaseMap());
  }

  Future<List<FinanceTransaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    return List.generate(maps.length, (i) {
      return FinanceTransaction.fromDatabaseMap(maps[i]);
    });
  }

  Future<List<FinanceTransaction>> getTransactionsByMonthYear(int month, int year) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
    return maps.map((map) => FinanceTransaction.fromDatabaseMap(map)).toList();
  }


  Future<List<FinanceTransaction>> getInvestments() async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'typeIndex = ?',
      whereArgs: [TransactionType.investimento.index],
    );
    return maps.map((map) => FinanceTransaction.fromDatabaseMap(map)).toList();
  }


  Future<List<FinanceTransaction>> getTransactionsByType(TransactionType type) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'typeIndex = ?',
      whereArgs: [type.index],
    );
    return maps.map((map) => FinanceTransaction.fromDatabaseMap(map)).toList();
  }

  Future<int> updateTransaction(FinanceTransaction tx) async {
    final db = await database;
    return await db.update(
      'transactions',
      tx.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('transactions');
  }

  Future<void> debugPrintAllTransactions() async {
    final db = await database;
    final all = await db.query('transactions');
    print('=== TRANSACTIONS IN DATABASE ===');
    print('Total: ${all.length}');
    for (final tx in all) {
      print(tx);
    }
    print('===============================');
  }
}

// Função para seed via provider
Future<void> seedTestTransactions(TransactionProvider txProvider) async {
  final transactions = [
    FinanceTransaction(
      id: '1',
      title: 'Salário Maio',
      amount: 5000,
      date: DateTime(2025, 5, 15),
      category: 'Salário',
      type: TransactionType.entrada,
      month: 5,
      year: 2025,
    ),
    FinanceTransaction(
      id: '2',
      title: 'Aluguel Maio',
      amount: 1200,
      date: DateTime(2025, 5, 1),
      category: 'Moradia',
      type: TransactionType.saida,
      month: 5,
      year: 2025,
    ),
    FinanceTransaction(
      id: '3',
      title: 'Ifood',
      amount: 127.90,
      date: DateTime(2025, 5, 1),
      category: 'Alimentação',
      type: TransactionType.saida,
      month: 5,
      year: 2025,
    ),
    FinanceTransaction(
      id: '4',
      title: 'Investimento em Ações',
      amount: 127.90,
      date: DateTime(2025, 5, 1),
      category: 'Investimentos',
      type: TransactionType.investimento,
      month: 5,
      year: 2025,
    ),
    FinanceTransaction(
      id: '5',
      title: 'Investimento em Cripto',
      amount: 600,
      date: DateTime(2025, 5, 1),
      category: 'Investimentos',
      type: TransactionType.investimento,
      month: 5,
      year: 2025,
    ),
    FinanceTransaction(
      id: '6',
      title: 'Freelance Abril',
      amount: 1500,
      date: DateTime(2025, 4, 20),
      category: 'Trabalho',
      type: TransactionType.entrada,
      month: 4,
      year: 2025,
    ),
    FinanceTransaction(
      id: '7',
      title: 'Aluguel Abril',
      amount: 1200,
      date: DateTime(2025, 4, 1),
      category: 'Moradia',
      type: TransactionType.saida,
      month: 4,
      year: 2025,
    ),
  ];

  for (final tx in transactions) {
    await txProvider.addTransaction(tx);
  }
}