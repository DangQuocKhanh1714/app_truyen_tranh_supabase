import 'package:equatable/equatable.dart';
import '../../data/models/manga_model.dart';

abstract class FavoriteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<MangaModel> favoriteMangas;
  FavoriteLoaded(this.favoriteMangas);

  @override
  List<Object?> get props => [favoriteMangas];
}

class FavoriteError extends FavoriteState {
  final String message;
  FavoriteError(this.message);

  @override
  List<Object?> get props => [message];
}