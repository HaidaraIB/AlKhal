import 'package:alkhal/models/model.dart';

class Category extends Model {
  static const String tableName = "category";
  final String name;

  Category({super.id, required this.name});

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
    );
  }
}
