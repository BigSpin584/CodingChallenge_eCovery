/*
Datendeklaration
*/
class Expense {
  final String id;
  final double amount;
  final String category;   
  final String title;      
  final String? notes;     
  final DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.title,
    required this.date,
    this.notes,
  });

  Expense copyWith({
    String? id,
    double? amount,
    String? category,
    String? title,
    String? notes,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      date: date ?? this.date,
    );
  }
}
