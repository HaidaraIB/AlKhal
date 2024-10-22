enum MeasurementUnit {
  kg("kg"),
  piece("piece");

  const MeasurementUnit(this.value);
  final String value;
  static MeasurementUnit fromString(String value) {
    switch (value.toLowerCase()) {
      case 'kg':
        return MeasurementUnit.kg;
      case 'piece':
        return MeasurementUnit.piece;
      default:
        throw ArgumentError('Invalid MeasurementUnit string: $value');
    }
  }

  static String toArabic(String value) {
    switch (value.toLowerCase()) {
      case 'kg':
        return "كيلو غرام";
      case 'piece':
        return 'قطعة';
      default:
        throw ArgumentError('Invalid MeasurementUnit string: $value');
    }
  }
}
