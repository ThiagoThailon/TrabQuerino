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
    final totalInvestido = txProvider.totalInvestido;
    // final saldo = txProvider.saldo;
    final saldoDisponivel = txProvider.saldoDisponivelInvestimento;

    return Scaffold(
      appBar: AppBar(title: const Text('Investimentos')),
      body: Column(
        children: [
          // Card com informações financeiras
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
            child: Column(
              children: [
                Row(
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

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saldo Disponível:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'R\$ ${saldoDisponivel.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: saldoDisponivel >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
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
                  child: Text(
                    'Meus Investimentos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: investimentos.length,
                    itemBuilder: (ctx, index) {
                      final tx = investimentos[index];
                      return ListTile(
                        leading: const Icon(
                            Icons.trending_up, color: Colors.blue),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(320, 48), // Azul no lugar do verde
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      12), // Mesmo arredondamento
                ),
              ),
              onPressed: () => _showAddInvestimentoDialog(context),
              // Sua função
              icon: const Icon(Icons.add, color: Colors.white),
              // Ícone branco
              label: const Text(
                'Novo Investimento',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
  Widget _buildInvestimentoChart(List<FinanceTransaction> investimentos) {
    if (investimentos.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum investimento registrado',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

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
            title: '${entry.key}\nR\$${entry.value.toStringAsFixed(2)}',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final saldoDisponivel = txProvider.saldoDisponivelInvestimento;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar Investimento'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  validator: (value) =>
                  value!.isEmpty ? 'Informe a descrição' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Valor (R\$)',
                    hintText:
                    'Saldo disponível: R\$${saldoDisponivel.toStringAsFixed(2)}',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Informe o valor';
                    final amount = double.tryParse(value) ?? 0;
                    if (amount <= 0) return 'Valor deve ser positivo';
                    if (amount > saldoDisponivel) {
                      return 'Saldo insuficiente. Disponível: R\$${saldoDisponivel.toStringAsFixed(2)}';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: ['Ações', 'Fundos', 'Tesouro Direto', 'Criptomoedas']
                      .map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  ))
                      .toList(),
                  onChanged: (value) => _selectedCategory = value!,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final now = DateTime.now();
                // ✅ Validação: só permite adicionar se o período selecionado for o mês e ano atual
                if (txProvider.currentMonth != now.month ||
                    txProvider.currentYear != now.year) {
                  print('Só é possível adicionar investimentos no mês e ano atual.');
                  return;  // Bloqueia a adição
                }

                try {
                  final newTx = FinanceTransaction(
                    id: DateTime.now().toString(),
                    title: _titleController.text,
                    amount: double.parse(_amountController.text),
                    date: now,
                    category: _selectedCategory,
                    type: TransactionType.investimento,
                    isFutureGoal: true,
                  );

                  await txProvider.addTransaction(newTx);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
