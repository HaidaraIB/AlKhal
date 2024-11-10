import 'dart:convert';

import 'package:alkhal/models/user.dart';

import 'package:http/http.dart' as http;

class ApiCalls {
  static String baseUrl = "http://haidaraib.pythonanywhere.com";

  static Future<http.Response> addUser(User user) async {
    var r = await http.post(
      Uri.parse("$baseUrl/addUser/"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        {
          "email": user.email,
          "password": user.password,
          "username": user.username,
        },
      ),
    );
    return r;
  }

  static Future<http.Response> login(String username, String password) async {
    var r = await http.post(
      Uri.parse("$baseUrl/login/"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        {
          "username": username,
          "password": password,
        },
      ),
    );
    return r;
  }

  static Future<http.Response> updateUserInfo(
      {required int id,
      required String userName,
      required String email,
      required String password}) async {
    var url = Uri.parse("$baseUrl/updateUserInfo/");
    var r = await http.post(url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'id': id,
          "email": email,
          'password': password,
          'username': userName
        }));
    return r;
  }
}
