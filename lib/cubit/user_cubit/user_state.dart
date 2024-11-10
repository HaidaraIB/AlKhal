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
