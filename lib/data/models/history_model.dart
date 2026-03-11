import 'manga_model.dart';

class HistoryModel {
  final int id;
  final String userId;
  final int mangaId;
  final int lastChapterId;
  final DateTime updatedAt;
  final MangaModel? manga;
  final String? lastChapterName; // Tên chương lấy từ bảng chapters

  HistoryModel({
    required this.id,
    required this.userId,
    required this.mangaId,
    required this.lastChapterId,
    required this.updatedAt,
    this.manga,
    this.lastChapterName,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['id'] as int,
      userId: map['user_id'] as String, // Ép kiểu String cho Firebase UID
      mangaId: map['manga_id'] as int,
      lastChapterId: map['last_chapter_id'] as int,
      updatedAt: DateTime.parse(map['updated_at'] as String),
      
      // Map dữ liệu manga từ join table 'mangas(*)'
      manga: map['mangas'] != null 
          ? MangaModel.fromMap(map['mangas'] as Map<String, dynamic>) 
          : null,
          
      // Map tên chương từ join table 'chapters(chapter_name)'
      lastChapterName: map['chapters'] != null 
          ? map['chapters']['chapter_name'] as String? 
          : null,
    );
  }
}