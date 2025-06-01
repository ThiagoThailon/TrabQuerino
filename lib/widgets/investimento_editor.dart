import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

void showEditDialog(BuildContext context, FinanceTransaction tx) {
  final titleController = TextEditingController(text: tx.title);
  final amountController = TextEditingController(text: tx.amount.toString());

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Editar Investimento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = titleController.text.trim();
              final newAmount = double.tryParse(amountController.text) ?? 0.0;

              if (newTitle.isEmpty || newAmount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos corretamente.')),
                );
                return;
              }

              final updatedTx = FinanceTransaction(
                id: tx.id,
                title: newTitle,
                amount: newAmount,
                date: tx.date,
                category: tx.category,
                type: tx.type,
                isFutureGoal: tx.isFutureGoal,
                month: tx.date.month,  // Mantém o mês original
                year: tx.date.year,    // Mantém o ano original
              );


              Provider.of<TransactionProvider>(context, listen: false)
                  .updateTransaction(tx.id, updatedTx);

              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Investimento atualizado com sucesso.')),
              );
            },
            child: const Text('Salvar'),
          )
        ],
      );
    },
  );
}
