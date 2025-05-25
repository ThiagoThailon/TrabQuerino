import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class GraficoScreen extends StatelessWidget {
  const GraficoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final saidas = txProvider.saidas;
    final saldo = txProvider.saldo;

    // Cores fixas para cada categoria
    final Map<String, Color> categoryColors = {
      'Alimentação': Colors.red[400]!,
      'Transporte': Colors.blue[400]!,
      'Lazer': Colors.green[400]!,
      'Educação': Colors.purple[400]!,
      'Outros': Colors.orange[400]!,
      'Saúde': Colors.teal[400]!,

    };

    if (saidas.isEmpty) {
      return const Center(
        child: Text('Nenhuma despesa registrada ainda.'),
      );
    }

    // Agrupa por categoria e soma os valores
    final Map<String, double> categorias = {};
    for (var tx in saidas) {
      categorias.update(
        tx.category,
            (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }

    // Ordena categorias por valor (maior para menor)
    final sortedCategories = categorias.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Prepara os dados para o gráfico
    final List<PieChartSectionData> pieChartSections = [];
    final totalSaidas = saidas.fold(0.0, (sum, tx) => sum + tx.amount);

    for (var i = 0; i < sortedCategories.length; i++) {
      final entry = sortedCategories[i];
      pieChartSections.add(
        PieChartSectionData(
          color: categoryColors[entry.key] ?? Colors.grey,
          value: entry.value,
          title: '${(entry.value / totalSaidas * 100).toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico de Despesas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card de saldo mais compacto
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: saldo >= 0 ? Colors.green.shade100 : Colors.red.shade100,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'R\$ ${saldo.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18, // Tamanho reduzido
                      fontWeight: FontWeight.bold,
                      color: saldo >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Gráfico com mais espaço
            Expanded(
              flex: 3, // Mais espaço para o gráfico
              child: PieChart(
                PieChartData(
                  sections: pieChartSections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Legenda mais compacta
            Expanded(
              flex: 2, // Menos espaço para a legenda
              child: ListView.builder(
                itemCount: sortedCategories.length,
                itemBuilder: (context, index) {
                  final category = sortedCategories[index].key;
                  final amount = sortedCategories[index].value;
                  final percentage = (amount / totalSaidas * 100).toStringAsFixed(1);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: const VisualDensity(vertical: -2), // Mais compacto
                    leading: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: categoryColors[category] ?? Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      category,
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Text(
                      'R\$ ${amount.toStringAsFixed(2)} ($percentage%)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}