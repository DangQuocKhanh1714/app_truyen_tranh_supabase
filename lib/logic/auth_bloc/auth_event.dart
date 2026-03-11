import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Sự kiện kiểm tra trạng thái khi mở App (Rất quan trọng)
class AuthCheckRequested extends AuthEvent {}

// Sự kiện Đăng ký
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;

  AuthSignUpRequested({
    required this.email, 
    required this.password, 
    required this.username
  });

  @override
  List<Object?> get props => [email, password, username];
}

// Sự kiện Đăng nhập
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

// Sự kiện Quên mật khẩu
class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  AuthForgotPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthLogoutRequested extends AuthEvent {}