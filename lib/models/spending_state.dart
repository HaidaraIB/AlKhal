enum SpendingStatus {
  canceled("canceled"),
  active("active");

  const SpendingStatus(this.value);
  final String value;
  static SpendingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'canceled':
        return SpendingStatus.canceled;
      case 'active':
        return SpendingStatus.active;
      default:
        throw ArgumentError('Invalid SpendingStatus string: $value');
    }
  }

  static String toArabic(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return "فعال";
      case 'piece':
        return 'ملغى';
      default:
        throw ArgumentError('Invalid SpendingStatus string: $value');
    }
  }
}
