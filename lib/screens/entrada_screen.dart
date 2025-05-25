import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/financial_summary.dart';

class EntradaScreen extends StatelessWidget {
  const EntradaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entradas = Provider.of<TransactionProvider>(context).entradas;

    return Scaffold(
      appBar: AppBar(title: const Text('Entradas')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FinancialSummary(),
                  const EntradaForm(),
                  entradas.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text('Nenhuma entrada registrada.'),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: entradas.length,
                    itemBuilder: (ctx, index) {
                      // Implemente seu item de lista aqui
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}