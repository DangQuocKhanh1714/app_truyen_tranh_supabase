import '../../data/models/manga_model.dart';

abstract class MangaState {}

class MangaInitial extends MangaState {}
class MangaLoading extends MangaState {}
class MangaLoaded extends MangaState {
  final List<MangaModel> mangas;
  MangaLoaded(this.mangas);
}
class MangaError extends MangaState {
  final String message;
  MangaError(this.message);
}