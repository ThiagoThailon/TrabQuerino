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


  double get saldo => totalEntradas - totalSaidas - totalInvestido;

  double get saldoDisponivelInvestimento => totalEntradas - totalSaidas - totalInvestido;

  double get totalInvestido => investimentos.fold(0.0, (sum, tx) => sum + tx.amount);


  double calculateBalance() {
    final totalEntradas = entradas.fold(0.0, (sum, tx) => sum + tx.amount);
    final totalSaidas = saidas.fold(0.0, (sum, tx) => sum + tx.amount);
    final totalInvestimentos = investimentos.fold(0.0, (sum, tx) => sum + tx.amount);
    return totalEntradas - totalSaidas - totalInvestimentos;}

  TransactionProvider() {
    loadTransactions();
  }

  Future<void> addTransaction(Transaction tx) async {
    if (tx.isFutureGoal && tx.amount > (totalEntradas - totalSaidas - totalInvestido + (tx.id != null ? 0 : tx.amount))) {
      throw Exception('Valor do investimento (R\$${tx.amount.toStringAsFixed(2)}) '
          'excede o saldo disponível (R\$${(totalEntradas - totalSaidas - totalInvestido).toStringAsFixed(2)})');
    }

    _transactions.add(tx);
    await saveTransactions();
    notifyListeners();
  }

  Future<void> updateTransaction(String id, Transaction updatedTx) async {
    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index >= 0) {
      final oldTx = _transactions[index];
      final available = totalEntradas - totalSaidas - totalInvestido + oldTx.amount;

      if (updatedTx.isFutureGoal && updatedTx.amount > available) {
        throw Exception('Valor atualizado excede o saldo disponível');
      }

      _transactions[index] = updatedTx;
      await saveTransactions();
      notifyListeners();
    }
  }

  Future<void> saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final txListJson = _transactions.map((tx) => tx.toJson()).toList();
    await prefs.setString('transactions', jsonEncode(txListJson));
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