import 'dart:convert';

import 'package:alkhal/models/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User extends Model {
  static const tableName = 'user';
  final String email;
  final String password;
  final String username;

  User({
    super.id,
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  String toString() {
    return "User($id, $email, $username)";
  }

  static Future<Map<String, dynamic>> userInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? info = preferences.getString('user');
    if (info == null) {
      return {};
    }
    Map<String, dynamic> userInfo = jsonDecode(info);
    return userInfo;
  }

  static Future cacheInfo(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('signed', true);
    await prefs.setString('user', jsonEncode(user.toMap()));
  }

  static Future clearInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("signed");
    await prefs.remove("user");
  }

  static Future<bool> checkSigned() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('signed') ?? false;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      username: map['username'],
      password: map['password'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "username": username,
      "password": password,
    };
  }
}
