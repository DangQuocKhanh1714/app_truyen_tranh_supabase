import 'package:app_truyen_tranh/data/models/manga_model.dart';
import 'package:app_truyen_tranh/data/services/database_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Events ---
abstract class MangaEvent {}
class LoadMangaEvent extends MangaEvent {}

// --- States ---
abstract class MangaState {}
class MangaLoading extends MangaState {}
class MangaLoaded extends MangaState {
  final List<MangaModel> mangas;
  MangaLoaded(this.mangas);
}
class MangaError extends MangaState {
  final String message;
  MangaError(this.message);
}

// --- Bloc ---
class MangaBloc extends Bloc<MangaEvent, MangaState> {
  final DatabaseHelper dbHelper;

  MangaBloc(this.dbHelper) : super(MangaLoading()) {
    on<LoadMangaEvent>((event, emit) async {
      // TỐI ƯU: Nếu đã có dữ liệu rồi thì không load lại nữa
      if (state is MangaLoaded) return;

      print("Bắt đầu tải dữ liệu...");
      emit(MangaLoading());
      try {
        final data = await dbHelper.fetchMangas();
        print("Dữ liệu nhận được: ${data.length} dòng");
        final listManga = data.map((m) => MangaModel.fromMap(m)).toList();
        emit(MangaLoaded(listManga));
      } catch (e) {
        print("Lỗi xảy ra tại BLoC: $e");
        emit(MangaError(e.toString()));
      }
    });
  } 
}