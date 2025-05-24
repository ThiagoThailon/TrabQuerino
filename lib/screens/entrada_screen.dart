import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/financial_summary.dart';

class EntradaScreen extends StatelessWidget {
  const EntradaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entradas = Provider.of<TransactionProvider>(context).entradas;

    return Scaffold(
      appBar: AppBar(title: const Text('Entradas')),
      body: Column(
        children: [
          const FinancialSummary(),
          const EntradaForm(),
          Expanded(
            child: entradas.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text('Nenhuma entrada registrada.'),
              ),
            )
                : ListView.builder(
              itemCount: entradas.length,
              itemBuilder: (ctx, index) {
                final tx = entradas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.arrow_downward,
                        color: Colors.green),
                    title: Text(tx.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${tx.category} • ${tx.date.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: Text(
                      'R\$ ${tx.amount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}