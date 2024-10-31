import 'package:alkhal/models/model.dart';

class Transaction extends Model {
  static const String tableName = 'transaction';

  final double discount;
  final double totalPrice;
  final double totalProfit;
  final String transactionDate;
  final int isSale;

  Transaction({
    super.id,
    required this.discount,
    required this.transactionDate,
    required this.isSale,
    required this.totalPrice,
    required this.totalProfit,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'discount': discount,
      'transaction_date': transactionDate,
      'is_sale': isSale,
      'total_price': totalPrice,
      'total_profit': totalProfit
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      discount: map['discount'],
      transactionDate: map['transaction_date'],
      isSale: map['is_sale'],
      totalPrice: map['total_price'],
      totalProfit: map['total_profit'] ?? 0,
    );
  }
}
