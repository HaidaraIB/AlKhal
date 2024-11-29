import 'package:alkhal/models/model.dart';

class Spending extends Model {
  static const String tableName = "spending";

  final double amount;
  final String notes;
  final String spendingDate;

  Spending({
    super.id,
    required this.amount,
    required this.notes,
    required this.spendingDate,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'notes': notes,
      'spending_date': spendingDate
    };
  }

  factory Spending.fromMap(Map<String, dynamic> map) {
    return Spending(
      id: map['id'],
      amount: map['amount'],
      notes: map['notes'],
      spendingDate: map['spending_date'],
    );
  }
}