import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/financial_summary.dart';
import '../models/transaction.dart';

class SaidaScreen extends StatelessWidget {
  const SaidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saidas = Provider.of<TransactionProvider>(context).saidas;

    return Scaffold(
      appBar: AppBar(title: const Text('Saídas')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const FinancialSummary(),
              const SaidaForm(),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: saidas.length,
                itemBuilder: (ctx, index) {
                  return const SizedBox.shrink(); // ou TransactionItem(...)
                },
                separatorBuilder: (context, index) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SaidaForm extends StatefulWidget {
  const SaidaForm({super.key});

  @override
  State<SaidaForm> createState() => _SaidaFormState();
}

class _SaidaFormState extends State<SaidaForm> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Alimentação';
  final List<String> _saidaCategories = [
    'Alimentação',
    'Transporte',
    'Saúde',
    'Lazer',
    'Educação',
    'Outros',
  ];

  void _submit() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final now = DateTime.now();

    // ✅ Validação: só permite adicionar se o período selecionado for o mês e ano atual
    if (provider.currentMonth != now.month || provider.currentYear != now.year) {
      print('Só é possível adicionar despesas no mês e ano atual.');
      return;  // Bloqueia a adição
    }

    // ✅ Calcula o saldo atual
    final saldoAtual = provider.calculateBalance();

    // ✅ Validação do saldo
    if (amount > saldoAtual) {
      _showSaldoInsuficienteDialog(saldoAtual);
      return;
    }

    if (title.isEmpty || amount <= 0) return;

    final newTx = FinanceTransaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: now,
      category: _selectedCategory,
      type: TransactionType.saida,
      isFutureGoal: false,
    );

    provider.addTransaction(newTx);
    _titleController.clear();
    _amountController.clear();
  }
  void _showSaldoInsuficienteDialog(double saldoAtual) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Saldo Insuficiente'),
        content: Text(
          'Você não possui saldo suficiente para esta despesa.\n'
              'Saldo disponível: R\$ ${saldoAtual.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Ex: Supermercado, Uber, etc.',
                filled: true,
                fillColor: Color(0xFFF7F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Valor (R\$)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '0,00',
                filled: true,
                fillColor: Color(0xFFF7F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _saidaCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFF7F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submit,
                icon: const Icon(Icons.remove, color: Colors.white),
                label: const Text(
                  'Adicionar Despesa',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class TransactionItem extends StatelessWidget {
  final FinanceTransaction transaction;
  final VoidCallback onDelete;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(transaction.title),
        subtitle: Text(
          '${transaction.date.day}/${transaction.date.month}/${transaction.date.year} - ${transaction.category}',
        ),
        trailing: Text(
          '- R\$${transaction.amount.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.red),
        ),
        leading: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}