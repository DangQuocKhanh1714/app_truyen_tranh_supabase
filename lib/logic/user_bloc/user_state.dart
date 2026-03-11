import '../../data/models/history_model.dart';
import '../../data/models/manga_model.dart';

abstract class UserState {}
class UserInitial extends UserState {}
class UserLoading extends UserState {}

class UserDataLoaded extends UserState {
  final List<HistoryModel> history;  // Đã sửa thành Model
  final List<MangaModel> favorites;  // Đã sửa thành Model
  UserDataLoaded({required this.history, required this.favorites});
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}