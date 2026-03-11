abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// Khi đăng nhập/đăng ký thành công
class AuthAuthenticated extends AuthState {
  final String uid;
  final String username; // Thêm để ProfileScreen sử dụng
  AuthAuthenticated(this.uid, this.username);
}

// Khi chưa đăng nhập hoặc đã đăng xuất
class AuthUnauthenticated extends AuthState {}

// Trạng thái riêng cho Quên mật khẩu thành công
class AuthForgotPasswordEmailSent extends AuthState {}

// Khi có lỗi xảy ra
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}