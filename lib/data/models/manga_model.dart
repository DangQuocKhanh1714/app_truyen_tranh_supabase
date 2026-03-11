class MangaModel {
  final int id;
  final String title;
  final String imageUrl;
  final String author;
  final String description;
  final String latestChapter;

  MangaModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.author,
    required this.description,
    required this.latestChapter,
  });

  factory MangaModel.fromMap(Map<String, dynamic> map) {
    String lastChap = "Đang cập nhật";
    
    if (map['chapters'] != null) {
      final List chaps = map['chapters'] as List;
      if (chaps.isNotEmpty) {
        // Lấy phần tử đầu tiên vì database_helper đã sắp xếp giảm dần theo ID
        lastChap = chaps.first['chapter_name']?.toString() ?? "Chương mới";
      }
    }

    return MangaModel(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      imageUrl: map['image_url'] ?? '',
      author: map['author'] ?? 'Đang cập nhật',
      description: map['description'] ?? '',
      latestChapter: lastChap,
    );
  }
}