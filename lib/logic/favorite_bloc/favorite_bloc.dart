import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/database_helper.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final DatabaseHelper dbHelper;

  FavoriteBloc(this.dbHelper) : super(FavoriteInitial()) {
    // Xử lý sự kiện tải danh sách truyện đã thích
    on<LoadFavoritesEvent>((event, emit) async {
      emit(FavoriteLoading());
      try {
        final favorites = await dbHelper.fetchFavorites();
        // Luôn phát Loaded, dù danh sách có 0 phần tử
        emit(FavoriteLoaded(favorites));
      } catch (e) {
        // Nếu dbHelper throw Exception, nó sẽ nhảy vào đây và hiện lỗi lên màn hình như ảnh bạn gửi
        emit(FavoriteError("Không thể kết nối danh sách: ${e.toString()}"));
      }
    });

    // Xử lý bật/tắt yêu thích và tự động làm mới danh sách
    on<ToggleFavoriteEvent>((event, emit) async {
      try {
        // 1. Thực hiện thay đổi trong DB
        await dbHelper.toggleFavorite(event.mangaId);

        // 2. Lấy lại danh sách mới nhất ngay lập tức
        final updatedFavorites = await dbHelper.fetchFavorites();

        // 3. Phát lại trạng thái Loaded kèm danh sách mới
        emit(FavoriteLoaded(updatedFavorites));
      } catch (e) {
        emit(FavoriteError("Lỗi: $e"));
      }
    });
  }
}
