import 'package:alkhal/models/model.dart';

class CashResult extends Model {
  static const String tableName = "cash_result";
  final double cash;
  final double profit;
  final String resultDate;

  CashResult({
    super.id,
    required this.cash,
    required this.profit,
    required this.resultDate,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cash': cash,
      'profit': profit,
      'result_date': resultDate,
    };
  }

  factory CashResult.fromMap(Map<String, dynamic> map) {
    return CashResult(
      id: map['id'],
      cash: map['cash'],
      profit: map['profit'],
      resultDate: map['result_date'],
    );
  }
}
