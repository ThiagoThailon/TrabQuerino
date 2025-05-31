enum TransactionType { entrada, saida, investimento }

class FinanceTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final TransactionType type;
  final bool isFutureGoal;

  FinanceTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.isFutureGoal = false,
  });

  Map<String, dynamic> toDatabaseMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category,
    'typeIndex': type.index, // Nome diferente para evitar conflitos
    'isFutureGoalInt': isFutureGoal ? 1 : 0, // Nome ajustado
  };

  factory FinanceTransaction.fromDatabaseMap(Map<String, dynamic> map) {
    return FinanceTransaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      type: TransactionType.values[map['typeIndex']], // Nome ajustado
      isFutureGoal: map['isFutureGoalInt'] == 1, // Nome ajustado
    );
  }
}
