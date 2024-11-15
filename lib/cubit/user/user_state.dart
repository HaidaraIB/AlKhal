part of 'user_cubit.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}

final class Loading extends UserState {}

final class LoginSuccess extends UserState {}

final class LoginFailed extends UserState {}

final class SignUpSuccess extends UserState {}

final class SignUpFailed extends UserState {}

final class NoInternet extends UserState {}

final class ConfirmRestoreDb extends UserState {
  final String dbAsBytes;

  ConfirmRestoreDb({
    required this.dbAsBytes,
  });
}

final class UserInfoUpdated extends UserState {
  final int id;
  final String email;

  final String password;
  final String username;

  UserInfoUpdated({
    required this.id,
    required this.email,
    required this.password,
    required this.username,
  });
}

final class UpdateUserInfoFailed extends UserState {}
