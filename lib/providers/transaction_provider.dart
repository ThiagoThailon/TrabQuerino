import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  final List<FinanceTransaction> _transactions = [];

  List<FinanceTransaction> get transactions => [..._transactions];

  List<FinanceTransaction> get entradas => _transactions
      .where((t) => t.type == TransactionType.entrada && !t.isFutureGoal)
      .toList();

  List<FinanceTransaction> get saidas => _transactions
      .where((t) => t.type == TransactionType.saida && !t.isFutureGoal)
      .toList();

  List<FinanceTransaction> get investimentos =>
      _transactions.where((t) => t.isFutureGoal).toList();

  double get totalEntradas => entradas.fold(0.0, (sum, tx) => sum + tx.amount);
  double get totalSaidas => saidas.fold(0.0, (sum, tx) => sum + tx.amount);
  double get saldo => totalEntradas - totalSaidas - totalInvestido;
  double get saldoDisponivelInvestimento => totalEntradas - totalSaidas - totalInvestido;
  double get totalInvestido => investimentos.fold(0.0, (sum, tx) => sum + tx.amount);

  double calculateBalance() {
    final totalEntradas = entradas.fold(0.0, (sum, tx) => sum + tx.amount);
    final totalSaidas = saidas.fold(0.0, (sum, tx) => sum + tx.amount);
    final totalInvestimentos = investimentos.fold(0.0, (sum, tx) => sum + tx.amount);
    return totalEntradas - totalSaidas - totalInvestimentos;
  }

  TransactionProvider() {
    loadTransactions();
  }

  Future<void> addTransaction(FinanceTransaction tx) async {
    final id = await DatabaseHelper.instance.insertTransaction(tx);
    if (id > 0) {
      _transactions.add(tx);
      notifyListeners();
    }
  }

  Future<void> updateTransaction(String id, FinanceTransaction updatedTx) async {
    final result = await DatabaseHelper.instance.updateTransaction(updatedTx);
    if (result > 0) {
      final index = _transactions.indexWhere((tx) => tx.id == id);
      if (index >= 0) {
        _transactions[index] = updatedTx;
        notifyListeners();
      }
    }
  }

  Future<void> loadTransactions() async {
    final txList = await DatabaseHelper.instance.getTransactions();
    _transactions.clear();
    _transactions.addAll(txList);
    notifyListeners();
  }

  Future<void> removeTransaction(String id) async {
    final result = await DatabaseHelper.instance.deleteTransaction(id);
    if (result > 0) {
      _transactions.removeWhere((tx) => tx.id == id);
      notifyListeners();
    }
  }

  Future<void> clearAllTransactions() async {
    await DatabaseHelper.instance.clearDatabase();
    _transactions.clear();
    notifyListeners();
  }
}
