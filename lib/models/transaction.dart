import 'package:alkhal/models/model.dart';

class Transaction extends Model {
  static const String tableName = 'transaction';

  final double discount;
  final double totalPrice;
  final double totalProfit;
  final String date;
  final int isSale;

  Transaction({
    super.id,
    required this.discount,
    required this.date,
    required this.isSale,
    required this.totalPrice,
    required this.totalProfit,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'discount': discount,
      'date': date,
      'is_sale': isSale,
      'total_price': totalPrice,
      'total_profit': totalProfit
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      discount: map['discount'],
      date: map['date'],
      isSale: map['is_sale'],
      totalPrice: map['total_price'],
      totalProfit: map['total_profit'],
    );
  }
}
