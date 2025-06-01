// transaction.dart
enum TransactionType { entrada, saida, investimento }

class FinanceTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final TransactionType type;
  final bool isFutureGoal;
  final int month; // Novo campo para o mês
  final int year;  // Novo campo para o ano

  FinanceTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.isFutureGoal = false,
    int? month, // Parâmetro opcional
    int? year,  // Parâmetro opcional
  }) : month = month ?? date.month, // Usa o mês da data se não for fornecido
        year = year ?? date.year;    // Usa o ano da data se não for fornecido

  Map<String, dynamic> toDatabaseMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category,
    'typeIndex': type.index,
    'isFutureGoalInt': isFutureGoal ? 1 : 0,
    'month': month, // Novo campo
    'year': year,   // Novo campo
  };

  factory FinanceTransaction.fromDatabaseMap(Map<String, dynamic> map) {
    return FinanceTransaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      type: TransactionType.values[map['typeIndex']],
      isFutureGoal: map['isFutureGoalInt'] == 1,
      month: map['month'] ?? DateTime.parse(map['date']).month, // Compatibilidade com versões antigas
      year: map['year'] ?? DateTime.parse(map['date']).year,    // Compatibilidade com versões antigas
    );
  }
}