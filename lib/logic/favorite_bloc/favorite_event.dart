import 'package:equatable/equatable.dart';

abstract class FavoriteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFavoritesEvent extends FavoriteEvent {}

class ToggleFavoriteEvent extends FavoriteEvent {
  final int mangaId;
  ToggleFavoriteEvent(this.mangaId);

  @override
  List<Object?> get props => [mangaId];
}