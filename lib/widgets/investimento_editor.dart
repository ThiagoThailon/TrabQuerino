import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

void showEditInvestmentDialog(BuildContext context, FinanceTransaction tx) {
  // Verifica se a transação é realmente um investimento
  assert(tx.type == TransactionType.investimento,
  'Esta função só deve ser usada para editar investimentos');

  final titleController = TextEditingController(text: tx.title);
  final amountController = TextEditingController(text: tx.amount.toStringAsFixed(2));

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
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  // Formatação automática do valor
                  if (value.isNotEmpty) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) {
                      amountController.value = TextEditingValue(
                        text: parsed.toStringAsFixed(2),
                        selection: amountController.selection,
                      );
                    }
                  }
                },
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () async {
              final newTitle = titleController.text.trim();
              final newAmount = double.tryParse(amountController.text) ?? 0.0;

              // Validação melhorada
              if (newTitle.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, insira um título válido.')),
                );
                return;
              }

              if (newAmount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('O valor deve ser maior que zero.')),
                );
                return;
              }

              final updatedTx = FinanceTransaction(
                id: tx.id,
                title: newTitle,
                amount: newAmount,
                date: tx.date,
                category: tx.category,
                type: TransactionType.investimento, // Garante que permaneça como investimento
                isFutureGoal: tx.isFutureGoal,
                month: tx.date.month,
                year: tx.date.year,
              );

              try {
                await Provider.of<TransactionProvider>(context, listen: false)
                    .updateTransaction(tx.id, updatedTx);

                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Investimento atualizado com sucesso!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao atualizar: ${e.toString()}'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Salvar Alterações',
                style: TextStyle(color: Colors.white)),
          )
        ],
      );
    },
  );
}