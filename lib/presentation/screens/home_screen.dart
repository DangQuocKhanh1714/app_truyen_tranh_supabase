import 'package:app_truyen_tranh/data/models/manga_model.dart';
import 'package:app_truyen_tranh/data/services/database_helper.dart';
import 'package:app_truyen_tranh/logic/search_bloc/search_event.dart';
import 'package:app_truyen_tranh/presentation/screens/category_result_screen.dart';
import 'package:app_truyen_tranh/presentation/screens/favorite_screen.dart';
import 'package:app_truyen_tranh/presentation/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_state.dart';
import '../../core/constants.dart'; // IMPORT HẰNG SỐ Ở ĐÂY
import '../../logic/manga_bloc/manga_bloc.dart';
import '../../logic/search_bloc/search_bloc.dart'; 
import '../../logic/search_bloc/search_state.dart'; 
import '../widgets/manga_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppState.navigationIndex.addListener(_updateUI);
  }

  @override
  void dispose() {
    AppState.navigationIndex.removeListener(_updateUI);
    _searchController.dispose();
    super.dispose();
  }

  void _updateUI() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final currentIndex = AppState.navigationIndex.value;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Dùng AppConstants.maxContentWidth để giới hạn toàn bộ Body
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: IndexedStack(
            index: currentIndex,
            children: [
              _buildHomeContent(),
              const FavoriteScreen(),
              const HistoryScreen(),
              const ProfileScreen(),
            ],
          ),
        ),
      ),
      // Căn giữa Bottom Nav và bóp độ rộng theo hằng số
      // SỬA LẠI ĐOẠN NÀY TRONG HOME_SCREEN.DART
      bottomNavigationBar: Container(
        color: theme.cardColor, // Đảm bảo màu nền liền mạch
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Quan trọng: Chỉ chiếm không gian cần thiết
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
              child: SizedBox(
                width: MediaQuery.of(context).size.width, // Lấy theo chiều rộng màn hình thực tế
                child: CustomBottomNav(
                  currentIndex: currentIndex,
                  onTap: (index) => AppState.navigationIndex.value = index,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, searchState) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: false,
              elevation: 0,
              toolbarHeight: 70,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: CustomAppBar(
                  searchController: _searchController,
                  onCategoryTap: () => _showCategoryBottomSheet(context),
                ),
              ),
            ),
            
            if (searchState is SearchLoaded && _searchController.text.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text("Tìm thấy ", style: TextStyle(color: Colors.grey[600])),
                      Text(
                        "${searchState.results.length}",
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        " kết quả cho '${_searchController.text}'",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 10)),

            if (searchState is SearchLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: Colors.red)),
              )
            else if (searchState is SearchLoaded && _searchController.text.isNotEmpty)
              searchState.results.isEmpty 
                ? _buildEmptySearch() 
                : _buildMangaGrid(searchState.results)
            else
              BlocBuilder<MangaBloc, MangaState>(
                builder: (context, mangaState) {
                  if (mangaState is MangaLoaded) {
                    return _buildMangaGrid(mangaState.mangas);
                  }
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptySearch() {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Ối! Không tìm thấy truyện rồi",
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _searchController.clear();
              context.read<SearchBloc>().add(OnQueryChanged(""));
            },
            child: const Text("Xóa tìm kiếm", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildMangaGrid(List<MangaModel> mangas) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, 
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => MangaCard(manga: mangas[index]),
          childCount: mangas.length,
        ),
      ),
    );
  }

  void _showCategoryBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      useSafeArea: true,
      // Sử dụng hằng số ở đây để BottomSheet không bị quá rộng trên Web
      constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth), 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Chọn thể loại",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Flexible(
                child: FutureBuilder<List<String>>(
                  future: DatabaseHelper().fetchCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Không có thể loại nào"),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final category = snapshot.data![index];
                        return ListTile(
                          title: Text(category),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryResultScreen(categoryName: category),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}