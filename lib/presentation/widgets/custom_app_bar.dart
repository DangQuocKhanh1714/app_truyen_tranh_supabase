import 'package:app_truyen_tranh/logic/search_bloc/search_bloc.dart';
import 'package:app_truyen_tranh/logic/search_bloc/search_event.dart';
import 'package:app_truyen_tranh/logic/theme_bloc/theme_bloc.dart';
import 'package:app_truyen_tranh/logic/theme_bloc/theme_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final VoidCallback? onCategoryTap;

  const CustomAppBar({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.primaryColor,
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Row(
            children: [
              // ĐÃ SỬA: Dùng Image.network cho link Pinterest
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      'https://api.dicebear.com/7.x/bottts/png?seed=Paimon&backgroundColor=ff4d4d',
                      height: 45,
                      width: 45,
                      fit: BoxFit.cover,
                      // Hiển thị vòng xoay rõ ràng khi đang tải
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          width: 45,
                          height: 45,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        );
                      },
                      // Nếu vẫn lỗi, nó sẽ hiện màu xám để bạn biết là link không tải được
                      errorBuilder: (context, error, stackTrace) {
                        print(
                          "Lỗi tải ảnh: $error",
                        ); // In lỗi ra console để kiểm tra
                        return Container(
                          width: 45,
                          height: 45,
                          color: Colors.grey,
                          child: const Icon(Icons.error, color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 5,
              ), // Khoảng cách nhỏ giữa logo và thanh tìm kiếm

              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: searchController,
                    // Khi người dùng gõ, thực hiện đẩy event vào Bloc
                    onChanged: (value) {
                      context.read<SearchBloc>().add(OnQueryChanged(value));
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "Tìm truyện...",
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white70,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.format_list_bulleted_rounded,
                  color: Colors.white,
                ),
                onPressed: onCategoryTap,
              ),
              BlocBuilder<ThemeBloc, ThemeMode>(
                builder: (context, mode) {
                  return IconButton(
                    icon: Icon(
                      mode == ThemeMode.dark
                          ? Icons.lightbulb
                          : Icons.lightbulb_outline,
                      color: mode == ThemeMode.dark
                          ? Colors.yellow
                          : Colors.white,
                    ),
                    onPressed: () {
                      context.read<ThemeBloc>().add(ToggleThemeEvent());
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65.0);
}
