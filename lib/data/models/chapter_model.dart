class ChapterModel {
  final int id;
  final int mangaId;
  final String chapterName;
  final List<String> contentImages;
  final String createdAt;

  ChapterModel({
    required this.id,
    required this.mangaId,
    required this.chapterName,
    required this.contentImages,
    required this.createdAt,
  });

  // Chuyển đổi từ Map (dữ liệu Supabase) sang Model
  factory ChapterModel.fromMap(Map<String, dynamic> map) {
    // Xử lý an toàn cho cột jsonb content_images
    List<String> images = [];
    if (map['content_images'] != null) {
      try {
        // Ép kiểu về List<String> từ dữ liệu động của Supabase
        images = List<String>.from(map['content_images']);
      } catch (e) {
        print("Lỗi parse content_images: $e");
      }
    }

    return ChapterModel(
      id: map['id'] ?? 0,
      mangaId: map['manga_id'] ?? 0,
      chapterName: map['chapter_name'] ?? 'Không có tên chương',
      contentImages: images,
      createdAt: map['created_at'] ?? '',
    );
  }

  // Phương thức helper nếu bạn cần chuyển ngược lại thành Map để insert/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'manga_id': mangaId,
      'chapter_name': chapterName,
      'content_images': contentImages,
      'created_at': createdAt,
    };
  }
}