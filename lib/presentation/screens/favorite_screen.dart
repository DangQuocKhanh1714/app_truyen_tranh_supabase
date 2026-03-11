import 'package:app_truyen_tranh/core/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth_bloc/auth_bloc.dart';
import '../../logic/auth_bloc/auth_state.dart';
import '../../logic/favorite_bloc/favorite_bloc.dart';
import '../../logic/favorite_bloc/favorite_event.dart';
import '../../logic/favorite_bloc/favorite_state.dart';
import '../../presentation/widgets/manga_card.dart';
import '../widgets/custom_app_bar.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; 

  @override
  void initState() {
    super.initState();
    // Gọi load dữ liệu ngay khi khởi tạo
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // Đảm bảo luôn lấy dữ liệu mới nhất từ Server/DB
      context.read<FavoriteBloc>().add(LoadFavoritesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      // Sử dụng BlocListener bên ngoài để lắng nghe sự thay đổi của Auth (Đăng nhập/Đăng xuất)
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthAuthenticated) {
            _loadData();
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthAuthenticated) {
              return BlocConsumer<FavoriteBloc, FavoriteState>(
                listener: (context, state) {
                  if (state is FavoriteError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message), 
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, favoriteState) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadData();
                      // Chờ Bloc xử lý xong để hoàn thành hiệu ứng quay của RefreshIndicator
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    color: Colors.redAccent,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverAppBar(
                          floating: true,
                          snap: true,
                          backgroundColor: const Color(0xFFFF5252),
                          expandedHeight: 65,
                          // Giữ nguyên CustomAppBar của bạn
                          flexibleSpace: const CustomAppBar(),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        
                        // Xử lý các trạng thái hiển thị của FavoriteBloc
                        if (favoriteState is FavoriteLoading)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
                          )
                        else if (favoriteState is FavoriteLoaded) ...[
                          if (favoriteState.favoriteMangas.isEmpty)
                            _buildEmptyState()
                          else
                            _buildFavoriteGrid(favoriteState.favoriteMangas),
                        ] else ...[
                          // Trường hợp mặc định hoặc lỗi
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: Text("Có lỗi xảy ra, vui lòng thử lại.", style: TextStyle(color: Colors.grey))),
                          )
                        ],
                      ],
                    ),
                  );
                },
              );
            }
            // Nếu chưa đăng nhập
            return _buildLoginNotice(context, "Yêu thích");
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text(
              "Chưa có truyện nào trong danh sách", 
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteGrid(List favoriteMangas) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Bao bọc trong Key để Flutter nhận diện sự thay đổi danh sách tốt hơn
            return MangaCard(
              key: ValueKey(favoriteMangas[index].id),
              manga: favoriteMangas[index],
            );
          },
          childCount: favoriteMangas.length,
        ),
      ),
    );
  }

  Widget _buildLoginNotice(BuildContext context, String feature) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            "Vui lòng đăng nhập để xem\ndanh sách $feature",
            textAlign: TextAlign.center, 
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, 
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => AppState.changeTab(3, context),
            child: const Text("Đăng nhập ngay", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}