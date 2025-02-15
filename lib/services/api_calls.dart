import 'dart:convert';
import 'dart:io';

import 'package:alkhal/models/user.dart';
import 'package:alkhal/utils/functions.dart';

import 'package:http/http.dart' as http;

class ApiCalls {
  // static String baseUrl = "http://127.0.0.1:8000";
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

  static Future<http.Response> updateUserInfo({
    required int id,
    required String userName,
    required String email,
    required String password,
  }) async {
    var url = Uri.parse("$baseUrl/updateUserInfo/");
    var r = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        {
          'id': id,
          "email": email,
          'password': password,
          'username': userName,
        },
      ),
    );
    return r;
  }

  static Future<http.StreamedResponse> remoteBackupDatabase(File db) async {
    final uri = Uri.parse('$baseUrl/uploadDb/');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', db.path));
    final response = await request.send();
    return response;
  }

  static Future<http.Response> syncPendingOperations(
    String username,
    List pendingOperations,
  ) async {
    String body = jsonEncode({
      "username": username,
      "operations": pendingOperations,
    });
    final response = await http.post(
      Uri.parse('$baseUrl/syncPendingOperations/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    return response;
  }

  static Future<http.Response> getPendingOperations(
    String username,
    int lastPendingOperationId,
  ) async {
    try {
      var url = Uri.parse(
          "$baseUrl/getPendingOperations/$username/$lastPendingOperationId/${await getOrCreateUUID()}/");
      var r = await http.get(url);
      return r;
    } on SocketException {
      return http.Response("No Internet", 503);
    }
  }

  static Future<http.Response> getRemoteDb(String username) async {
    try {
      var url = Uri.parse("$baseUrl/getDb/$username/");
      var r = await http.get(url);
      return r;
    } on SocketException {
      return http.Response("No Internet", 503);
    }
  }
}
