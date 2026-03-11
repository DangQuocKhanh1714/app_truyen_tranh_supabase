abstract class CategoryEvent {}

class FetchMangasByCategory extends CategoryEvent {
  final String categoryName;
  final String? query; // Thêm dòng này

  // Cập nhật Constructor để nhận query
  FetchMangasByCategory(this.categoryName, {this.query}); 
}