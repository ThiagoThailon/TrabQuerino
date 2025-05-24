import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  static const routeName = '/add-transaction';

  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _selectedType = TransactionType.saida;
  String _selectedCategory = 'Alimentação';

  final List<String> _saidaCategories = [
    'Alimentação',
    'Transporte',
    'Lazer',
    'Educação',
    'Outros',
  ];

  final List<String> _entradaCategories = [
    'Salário',
    'Freela',
    'Rendimentos',
    'Outros'
  ];

  void _submitForm() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (title.isEmpty || amount <= 0) return;

    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: _selectedCategory,
      type: _selectedType,
    );

    Provider.of<TransactionProvider>(context, listen: false)
        .addTransaction(newTx);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _selectedType == TransactionType.saida
        ? _saidaCategories
        : _entradaCategories;

    return Scaffold(
      appBar: AppBar(title: const Text('Nteste')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              DropdownButton<TransactionType>(
                value: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    _selectedCategory = _selectedType == TransactionType.saida
                        ? _saidaCategories[0]
                        : _entradaCategories[0];
                  });
                },
                items: TransactionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type == TransactionType.entrada
                        ? 'Entrada'
                        : 'Saída'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: categories.map((cat) {
                  return ChoiceChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Salvar Transação'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}