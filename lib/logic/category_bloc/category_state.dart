import '../../data/models/manga_model.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}
class CategoryLoading extends CategoryState {}
class CategoryLoaded extends CategoryState {
  final List<MangaModel> mangas;
  CategoryLoaded(this.mangas);
}
class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}