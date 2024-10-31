enum TransactionFilter {
  all,
  buy,
  sell;

  static String toArabic(String value) {
    switch (value.toLowerCase()) {
      case 'all':
        return "الكل";
      case 'buy':
        return 'شراء';
      case 'sell':
        return 'مبيع';
      default:
        throw ArgumentError('Invalid TransactionFilter string: $value');
    }
  }
}
