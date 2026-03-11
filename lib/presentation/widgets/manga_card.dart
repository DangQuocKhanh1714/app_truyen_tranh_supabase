import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import '../../data/models/manga_model.dart';
import '../../logic/favorite_bloc/favorite_bloc.dart'; 
import '../../logic/favorite_bloc/favorite_event.dart';
import '../screens/manga_detail_screen.dart';

class MangaCard extends StatelessWidget {
  final MangaModel manga;
  final String? customSubtitle;

  const MangaCard({
    super.key, 
    required this.manga, 
    this.customSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () async {
        // 1. Chờ kết quả từ trang Detail quay về
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaDetailScreen(manga: manga),
          ),
        );

        // 2. Nếu trang con báo có thay đổi (result == true)
        if (result == true && context.mounted) {
          // Ép FavoriteBloc tải lại danh sách ngay lập tức
          context.read<FavoriteBloc>().add(LoadFavoritesEvent());
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.cardColor, 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  manga.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.textTheme.bodyLarge?.color, 
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customSubtitle ?? manga.latestChapter,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}