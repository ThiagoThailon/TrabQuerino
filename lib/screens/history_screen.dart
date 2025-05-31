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
              const PopupMenuItem<String>(value: 'Todas', child: Text('Mostrar Todas')),
              const PopupMenuItem<String>(value: 'Entradas', child: Text('Apenas Entradas')),
              const PopupMenuItem<String>(value: 'Saídas', child: Text('Apenas Saídas')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<FinanceTransaction>>(
        future: _getFilteredTransactions(provider),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar histórico'));
          } else {
            final transacoesFiltradas = snapshot.data ?? [];
            return _buildTransactionList(transacoesFiltradas, provider);
          }
        },
      ),
    );
  }

  Future<List<FinanceTransaction>> _getFilteredTransactions(TransactionProvider provider) async {
    if (_filtroAtual == 'Entradas') {
      return await provider.entradas;
    } else if (_filtroAtual == 'Saídas') {
      return await provider.saidas;
    } else {
      final entradas = await provider.entradas;
      final saidas = await provider.saidas;
      return [...entradas, ...saidas]..sort((a, b) => b.date.compareTo(a.date));
    }
  }

  Widget _buildTransactionList(List<FinanceTransaction> transacoes, TransactionProvider provider) {
    return transacoes.isEmpty
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
            itemCount: transacoes.length,
            itemBuilder: (ctx, index) {
              final tx = transacoes[index];
              final isEntrada = tx.type == TransactionType.entrada;

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
                  subtitle: Text('${tx.category} • ${tx.date.toLocal().toString().split(' ')[0]}'),
                  trailing: Text(
                    'R\$ ${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(color: isEntrada ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
          ),
        ),
      ],
    );
  }
}
