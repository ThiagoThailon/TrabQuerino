import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';
import '../widgets/transaction_list.dart';

class HomeScreen extends StatelessWidget {
  final String title;
  const HomeScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const TransactionList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddTransactionScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
