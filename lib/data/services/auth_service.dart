import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- LẤY THÔNG TIN USER TỪ SUPABASE (Dùng cho giao diện) ---
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return await _supabase
            .from('users')
            .select()
            .eq('firebase_uid', user.uid)
            .maybeSingle();
      }
    } catch (e) {
      print("Lỗi lấy Profile: $e");
    }
    return null;
  }

  // --- ĐĂNG KÝ ---
  Future<void> signUp({required String email, required String password, required String username}) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );

    if (credential.user != null) {
      await _supabase.from('users').insert({
        'firebase_uid': credential.user!.uid,
        'email': email,
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // --- QUÊN MẬT KHẨU ---
  Future<void> sendPasswordReset(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // --- ĐĂNG NHẬP ---
  Future<fb.UserCredential> signIn(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // --- ĐĂNG XUẤT ---
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Lấy User hiện tại của Firebase
  fb.User? get currentUser => _firebaseAuth.currentUser;
}