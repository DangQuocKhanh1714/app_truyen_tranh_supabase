import '../../data/models/manga_model.dart';

abstract class SearchState {}

// Trạng thái ban đầu: Hiển thị danh sách truyện mặc định từ MangaBloc
class SearchInitial extends SearchState {}

// Trạng thái đang tải: Khi đang đợi dữ liệu từ Supabase trả về
class SearchLoading extends SearchState {}

// Trạng thái thành công: Chứa danh sách truyện khớp với từ khóa
class SearchLoaded extends SearchState {
  final List<MangaModel> results;
  SearchLoaded(this.results);
}

// Trạng thái lỗi: Khi kết nối mạng hoặc server có vấn đề
class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}