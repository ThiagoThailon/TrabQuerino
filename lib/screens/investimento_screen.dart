import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class InvestimentoScreen extends StatelessWidget {
  const InvestimentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final investimentos = txProvider.investimentos;
    final totalInvestido = investimentos.fold(0.0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Investimentos')),
      body: Column(
        children: [
          // Card de total investido (estilo idêntico ao do saldo)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.shade100,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Investido:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'R\$ ${totalInvestido.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
    // Gráfico de investimentos
    Expanded(
     flex: 2,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildInvestimentoChart(investimentos),
          ),
    ),

    // Lista de investimentos
    Expanded(
    flex: 3,
    child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
            child: Text('Meus Investimentos',
              style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: investimentos.length,
                itemBuilder: (ctx, index) {
                  final tx = investimentos[index];
                  return ListTile(
                    leading: const Icon(Icons.trending_up, color: Colors.blue),
                    title: Text(tx.title),
                    subtitle: Text(tx.category),
                    trailing: Text('R\$ ${tx.amount.toStringAsFixed(2)}'),
          );
          },
          ),
          ),
          ],
    ),
    ),

    // Botão para novo investimento
    Padding(
    padding: const EdgeInsets.all(16.0),
    child: ElevatedButton.icon(
    icon: const Icon(Icons.add),
    label: const Text('Novo Investimento'),
    onPressed: () => _showAddInvestimentoDialog(context),
    style: ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),
    ),
    ),
    ),
    ],
    ),
    );
    }


  Widget _buildInvestimentoChart(List<Transaction> investimentos) {
    if (investimentos.isEmpty) {
      return const Center(child: Text('Nenhum investimento registrado'));
    }

    // Agrupa por categoria
    final categorias = <String, double>{};
    for (var tx in investimentos) {
      categorias.update(
        tx.category,
            (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }

    final colors = [Colors.blue, Colors.green, Colors.purple, Colors.orange];
    int colorIndex = 0;

    return PieChart(
      PieChartData(
        sections: categorias.entries.map((entry) {
          final color = colors[colorIndex % colors.length];
          colorIndex++;
          return PieChartSectionData(
            color: color,
            value: entry.value,
            title: entry.key,
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),
          );
        }).toList(),
        centerSpaceRadius: 30,
      ),
    );
  }

  void _showAddInvestimentoDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _amountController = TextEditingController();
    String _selectedCategory = 'Ações';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar Investimento'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) => value!.isEmpty ? 'Informe a descrição' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Informe o valor' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: ['Ações', 'Fundos', 'Tesouro Direto', 'Criptomoedas']
                    .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                )).toList(),
                onChanged: (value) => _selectedCategory = value!,
                decoration: const InputDecoration(labelText: 'Categoria'),
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
              if (_formKey.currentState!.validate()) {
                final newTx = Transaction(
                  id: DateTime.now().toString(),
                  title: _titleController.text,
                  amount: double.parse(_amountController.text),
                  date: DateTime.now(),
                  category: _selectedCategory,
                  type: TransactionType.investimento,
                  isFutureGoal: true,
                );

                Provider.of<TransactionProvider>(context, listen: false)
                    .addTransaction(newTx);

                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}