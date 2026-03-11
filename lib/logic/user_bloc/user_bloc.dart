import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../../data/services/database_helper.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final DatabaseHelper dbHelper;

  UserBloc(this.dbHelper) : super(UserInitial()) {
    on<LoadUserDataEvent>((event, emit) async {
      emit(UserLoading());
      try {
        final history = await dbHelper.fetchHistory();
        final favorites = await dbHelper.fetchFavorites();
        emit(UserDataLoaded(history: history, favorites: favorites));
      } catch (e) {
        emit(UserError("Lỗi tải dữ liệu người dùng: $e"));
      }
    });

    on<RemoveHistoryEvent>((event, emit) async {
      try {
        await dbHelper.deleteHistory(event.mangaId);
        add(LoadUserDataEvent()); 
      } catch (e) {
        emit(UserError("Không thể xóa lịch sử: $e"));
      }
    });
  }
}