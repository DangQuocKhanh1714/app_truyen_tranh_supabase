import 'package:app_truyen_tranh/logic/auth_bloc/auth_bloc.dart';
import 'package:app_truyen_tranh/logic/auth_bloc/auth_state.dart';
import 'package:app_truyen_tranh/logic/auth_bloc/auth_event.dart';
import 'package:app_truyen_tranh/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  
  // Giữ màn hình không bị load lại khi chuyển Tab
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Bắt buộc phải có
    final authService = AuthService();

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool isLoggedIn = state is AuthAuthenticated;
        String? currentUid = state is AuthAuthenticated ? state.uid : null;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // --- CARD THÔNG TIN CÁ NHÂN ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.redAccent, Color(0xFFD32F2F)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 40, color: Colors.redAccent),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isLoggedIn && currentUid != null)
                                // Lưu ý: Để hết chớp hoàn toàn, nên đưa Username vào AuthState của Bloc.
                                // Dưới đây là cách dùng FutureBuilder nhưng tối ưu hơn.
                                FutureBuilder<Map<String, dynamic>?>(
                                  future: authService.getUserProfile(),
                                  builder: (context, snapshot) {
                                    // Trong lúc đợi, hiện tên mặc định thay vì để trống hoặc hiện Loading
                                    final String name = snapshot.data?['username'] ?? "Thành viên";
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 5),
                                        const Text("Đã xác thực",
                                            style: TextStyle(
                                                color: Colors.white70, fontSize: 12)),
                                      ],
                                    );
                                  },
                                )
                              else
                                const Text(
                                  "Khách ẩn danh",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // --- MENU TÙY CHỌN ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(Icons.history, "Lịch sử đọc truyện", () {}),
                        const Divider(color: Colors.white10, height: 1, indent: 50),
                        _buildMenuItem(Icons.favorite_border, "Truyện đang theo dõi", () {}),
                        const Divider(color: Colors.white10, height: 1, indent: 50),
                        _buildMenuItem(Icons.settings, "Cài đặt ứng dụng", () {}),
                        const Divider(color: Colors.white10, height: 1, indent: 50),
                        _buildMenuItem(Icons.help_outline, "Hỗ trợ & Góp ý", () {}),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // --- NÚT ĐĂNG XUẤT / ĐĂNG NHẬP ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: ListTile(
                    onTap: () async {
                      if (isLoggedIn) {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      }
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    tileColor: isLoggedIn
                        ? Colors.redAccent.withOpacity(0.1)
                        : Colors.blueAccent.withOpacity(0.1),
                    leading: Icon(
                      isLoggedIn ? Icons.logout : Icons.login,
                      color: isLoggedIn ? Colors.redAccent : Colors.blueAccent,
                    ),
                    title: Text(
                      isLoggedIn ? "Đăng xuất" : "Đăng nhập ngay",
                      style: TextStyle(
                        color: isLoggedIn ? Colors.redAccent : Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100), // Khoảng cách cho BottomNav
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    );
  }
}