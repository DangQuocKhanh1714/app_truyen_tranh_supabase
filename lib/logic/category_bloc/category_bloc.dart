import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/database_helper.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final DatabaseHelper dbHelper;

  CategoryBloc(this.dbHelper) : super(CategoryInitial()) {
    on<FetchMangasByCategory>((event, emit) async {
      emit(CategoryLoading());
      try {
        final mangas = await dbHelper.fetchMangasByCategory(event.categoryName);
        emit(CategoryLoaded(mangas));
      } catch (e) {
        emit(CategoryError("Không thể tải danh sách truyện: $e"));
      }
    });
  }
}