import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService authService;

  AuthRepository(this.authService);

  // Kiểm tra trạng thái đăng nhập khi mở app
  fb.User? get currentUser => authService.currentUser;

  Future<fb.UserCredential> signIn(String email, String password) => 
      authService.signIn(email, password);

  Future<void> signOut() => authService.signOut();

  Future<void> signUp({required String email, required String password, required String username}) =>
      authService.signUp(email: email, password: password, username: username);
}