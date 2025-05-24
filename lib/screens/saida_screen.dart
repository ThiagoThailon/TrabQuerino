import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/financial_summary.dart';
import '../models/transaction.dart';

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
      body: Column(
        children: [
          const FinancialSummary(),
          const SaidaForm(),
          Expanded(
            child: saidas.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text('Nenhuma saída registrada.'),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: saidas.length,
              itemBuilder: (ctx, index) {
                final tx = saidas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.arrow_upward, color: Colors.red),
                    title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${tx.category} • ${tx.date.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: Text(
                      'R\$ ${tx.amount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 8),
            ),
          ),
        ],
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
  String _selectedCategory = 'Alimentação'; // Categoria padrão

  // Lista de categorias para despesas
  final List<String> _saidaCategories = [
    'Alimentação',
    'Transporte',
    'Lazer',
    'Educação',
    'Outros',
  ];

  void _submit() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (title.isEmpty || amount <= 0) return;

    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: _selectedCategory, // Usa a categoria selecionada
      type: TransactionType.saida,
      isFutureGoal: false,
    );

    Provider.of<TransactionProvider>(context, listen: false).addTransaction(newTx);
    _titleController.clear();
    _amountController.clear();
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