import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/database_helper.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final DatabaseHelper dbHelper;

  SearchBloc(this.dbHelper) : super(SearchInitial()) {
    on<OnQueryChanged>((event, emit) async {
      final query = event.query.trim();

      // Nếu ô tìm kiếm trống, quay về trạng thái Initial để hiện danh sách gốc
      if (query.isEmpty) {
        emit(SearchInitial());
        return;
      }

      emit(SearchLoading());

      try {
        // Gọi hàm searchMangas mà chúng ta vừa thêm vào DatabaseHelper
        final results = await dbHelper.searchMangas(query);
        emit(SearchLoaded(results));
      } catch (e) {
        emit(SearchError("Không thể lấy dữ liệu tìm kiếm"));
      }
    });

    on<ClearSearch>((event, emit) => emit(SearchInitial()));
  }
}