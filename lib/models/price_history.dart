import 'package:alkhal/models/model.dart';

class PriceHistory extends Model {
  static const String tableName = 'price_history';

  final int itemId;
  final double price;
  final DateTime date;

  PriceHistory({
    super.id,
    required this.itemId,
    required this.price,
    required this.date,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,
      'price': price,
      'date': date,
    };
  }

  factory PriceHistory.fromMap(Map<String, dynamic> map) {
    return PriceHistory(
      id: map['id'],
      itemId: map['item_id'],
      price: map['price'],
      date: map['date'],
    );
  }
}
