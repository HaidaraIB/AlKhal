import 'dart:convert';
import 'dart:io';

import 'package:alkhal/models/user.dart';
import 'package:alkhal/services/api_calls.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  Future signUp(User user) async {
    var result = await (Connectivity().checkConnectivity());
    if (result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile)) {
      emit(Loading());
      try {
        http.Response response = await ApiCalls.addUser(user);
        if (response.statusCode == 200) {
          Map bodyMap = jsonDecode(response.body);
          bodyMap['me']['password'] = user.password;
          await User.cacheInfo(User.fromMap(bodyMap['me']));
          emit(SignUpSuccess());
        } else {
          emit(SignUpFailed());
        }
      } on SocketException {
        emit(NoInternet());
      }
    } else {
      emit(NoInternet());
    }
  }

  Future login(String username, String password) async {
    var result = await (Connectivity().checkConnectivity());
    if (result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile)) {
      emit(Loading());
      try {
        http.Response r = await ApiCalls.login(username, password);
        if (r.statusCode == 200) {
          Map bodyMap = jsonDecode(r.body);
          bodyMap['me']['password'] = password;
          await User.cacheInfo(User.fromMap(bodyMap['me']));
          if (bodyMap['db'] != null) {
            emit(ConfirmRestoreDb(dbAsBytes: bodyMap['db']));
            return;
          }
          emit(LoginSuccess());
        } else {
          emit(LoginFailed());
        }
      } on SocketException {
        emit(NoInternet());
      }
    } else {
      emit(NoInternet());
    }
  }

  Future<void> updateUserInfo({
    required int id,
    required String username,
    required String email,
    required String password,
  }) async {
    var result = await Connectivity().checkConnectivity();
    if (result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile)) {
      emit(Loading());
      try {
        var r = await ApiCalls.updateUserInfo(
          id: id,
          password: password,
          email: email,
          userName: username,
        );
        if (r.statusCode == 200) {
          Map bodyMap = jsonDecode(r.body);
          bodyMap['me']['password'] = password;
          await User.cacheInfo(User.fromMap(bodyMap['me']));
          emit(UserInfoUpdated(
            id: id,
            email: email,
            password: password,
            username: username,
          ));
        } else {
          emit(UpdateUserInfoFailed());
        }
      } on SocketException {
        emit(NoInternet());
      }
    } else {
      emit(NoInternet());
    }
  }
}
