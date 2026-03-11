import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/manga_model.dart';
import '../../data/services/database_helper.dart';
import '../../core/constants.dart'; // IMPORT HẰNG SỐ Ở ĐÂY
import '../widgets/custom_app_bar.dart';
import 'manga_detail_screen.dart';

// Bloc Imports
import '../../logic/category_bloc/category_bloc.dart';
import '../../logic/category_bloc/category_event.dart';
import '../../logic/category_bloc/category_state.dart';

class CategoryResultScreen extends StatefulWidget {
  final String categoryName;

  const CategoryResultScreen({super.key, required this.categoryName});

  @override
  State<CategoryResultScreen> createState() => _CategoryResultScreenState();
}

class _CategoryResultScreenState extends State<CategoryResultScreen> {
  final TextEditingController _searchController = TextEditingController();
  late String _currentCategory;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.categoryName;
    _loadData();
  }

  void _loadData() {
    context.read<CategoryBloc>().add(FetchMangasByCategory(_currentCategory));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCategoryBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      useSafeArea: true,
      // GIỚI HẠN ĐỘ RỘNG BOTTOM SHEET
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
              Text(
                "Đổi thể loại nhanh",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
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
                          selected: category == _currentCategory,
                          selectedColor: Colors.redAccent,
                          title: Text(
                            category,
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _currentCategory = category;
                            });
                            context.read<CategoryBloc>().add(FetchMangasByCategory(category));
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // CĂN GIỮA VÀ GIỚI HẠN ĐỘ RỘNG TOÀN BỘ TRANG
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Column(
            children: [
              CustomAppBar(
                searchController: _searchController,
                onSearchChanged: (value) {
                  context.read<CategoryBloc>().add(
                    FetchMangasByCategory(_currentCategory, query: value),
                  );
                },
                onCategoryTap: () => _showCategoryBottomSheet(context),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        "Thể loại: $_currentCategory",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoading) {
                      return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                    }

                    if (state is CategoryLoaded) {
                      final mangas = state.mangas;
                      if (mangas.isEmpty) {
                        return const Center(child: Text("Không tìm thấy truyện nào"));
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: mangas.length,
                        itemBuilder: (context, index) => _buildMangaItem(context, mangas[index], theme),
                      );
                    }
                    
                    if (state is CategoryError) {
                      return Center(child: Text(state.message));
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMangaItem(BuildContext context, MangaModel manga, ThemeData theme) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MangaDetailScreen(manga: manga)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  manga.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => 
                    Container(color: theme.cardColor, child: const Icon(Icons.broken_image)),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),

          SizedBox(
            height: 38,
            child: Text(
              manga.title,
              maxLines: 2, 
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}