import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
// trans
//
// action_list.dart
class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final transactions = txProvider.currentPeriodTransactions; // Usa currentPeriodTransactions

    if (transactions.isEmpty) {
      return const Center(
        child: Text('Nenhuma transação registrada para este período.'),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (ctx, index) {
        final tx = transactions[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          elevation: 3,
          child: ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text(tx.title),
            subtitle: Text('${tx.category} - ${tx.date.toLocal().toString().split(' ')[0]}'),
            trailing: Text('R\$ ${tx.amount.toStringAsFixed(2)}'),
          ),
        );
      },
    );
  }
}