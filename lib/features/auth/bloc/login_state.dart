import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final String email;
  final String password;
  final bool passwordVisible;
  final LoginStatus status;
  final String? errorMessage;

  const LoginState({
    this.email = '',
    this.password = '',
    this.passwordVisible = false,
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  bool get isEmailValid => email.contains('@') && email.contains('.');
  bool get isPasswordValid => password.length >= 6;
  bool get isFormValid => isEmailValid && isPasswordValid;

  LoginState copyWith({
    String? email,
    String? password,
    bool? passwordVisible,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    passwordVisible,
    status,
    errorMessage,
  ];
}
