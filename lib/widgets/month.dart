import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class MonthYearPicker extends StatelessWidget {
  const MonthYearPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final currentMonth = provider.currentMonth;
    final currentYear = provider.currentYear;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<int>(
            value: currentMonth,
            items: List.generate(12, (index) => index + 1)
                .map((month) => DropdownMenuItem<int>(
              value: month,
              child: Text(_getMonthName(month)),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                provider.setCurrentPeriod(value, currentYear);
              }
            },
          ),
          DropdownButton<int>(
            value: currentYear,
            items: List.generate(5, (index) => DateTime.now().year - 2 + index)
                .map((year) => DropdownMenuItem<int>(
              value: year,
              child: Text(year.toString()),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                provider.setCurrentPeriod(currentMonth, value);
              }
            },
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }
}
