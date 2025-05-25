import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filtroAtual = 'Todas'; // Pode ser 'Todas', 'Entradas' ou 'Saídas'

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    // Filtra as transações conforme seleção
    List<Transaction> transacoesFiltradas = [];
    if (_filtroAtual == 'Entradas') {
      transacoesFiltradas = provider.entradas;
    } else if (_filtroAtual == 'Saídas') {
      transacoesFiltradas = provider.saidas;
    } else {
      transacoesFiltradas = [...provider.entradas, ...provider.saidas];
    }

    // Ordena por data (mais recente primeiro)
    transacoesFiltradas.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Transações'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt),
            onSelected: (String value) {
              setState(() {
                _filtroAtual = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'Todas',
                child: Text('Mostrar Todas'),
              ),
              const PopupMenuItem<String>(
                value: 'Entradas',
                child: Text('Apenas Entradas'),
              ),
              const PopupMenuItem<String>(
                value: 'Saídas',
                child: Text('Apenas Saídas'),
              ),
            ],
          ),
        ],
      ),
      body: transacoesFiltradas.isEmpty
          ? Center(
        child: Text(
          'Nenhuma transação ${_filtroAtual == 'Todas' ? 'registrada' : 'do tipo $_filtroAtual'}.',
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Filtro: $_filtroAtual',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: transacoesFiltradas.length,
              itemBuilder: (ctx, index) {
                final tx = transacoesFiltradas[index];
                final isEntrada = provider.entradas.contains(tx);

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Icon(
                      isEntrada ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isEntrada ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      tx.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${tx.category} • ${tx.date.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: Text(
                      'R\$ ${tx.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isEntrada ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
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