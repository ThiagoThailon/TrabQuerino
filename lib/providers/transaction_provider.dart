import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => [..._transactions];

  List<Transaction> get entradas => _transactions
      .where((t) => t.type == TransactionType.entrada && !t.isFutureGoal)
      .toList();

  List<Transaction> get saidas => _transactions
      .where((t) => t.type == TransactionType.saida && !t.isFutureGoal)
      .toList();

  List<Transaction> get investimentos =>
      _transactions.where((t) => t.isFutureGoal).toList();

  double get totalEntradas => entradas.fold(0.0, (sum, tx) => sum + tx.amount);
  double get totalSaidas => saidas.fold(0.0, (sum, tx) => sum + tx.amount);
  double get saldo => totalEntradas - totalSaidas;

  TransactionProvider() {
    loadTransactions();
  }

  Future<void> addTransaction(Transaction tx) async {
    _transactions.add(tx);
    await saveTransactions();
    notifyListeners();
  }

  Future<void> updateTransaction(String id, Transaction updatedTx) async {
    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index >= 0) {
      _transactions[index] = updatedTx;
      await saveTransactions();
      notifyListeners();
    }
  }

  Future<void> saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final txListJson = _transactions.map((tx) => tx.toJson()).toList();
    prefs.setString('transactions', jsonEncode(txListJson));
  }

  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('transactions')) {
      final data = prefs.getString('transactions');
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        _transactions.clear();
        _transactions.addAll(
          jsonList.map((item) => Transaction.fromJson(item)).toList(),
        );
        notifyListeners();
      }
    }
  }

  Future<void> clearAllTransactions() async {
    _transactions.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('transactions');
    notifyListeners();
  }

  Future<void> removeTransaction(String id) async {
    _transactions.removeWhere((tx) => tx.id == id);
    await saveTransactions();
    notifyListeners();
  }
}
