abstract class MangaEvent {}

class FetchMangas extends MangaEvent {}

class SearchManga extends MangaEvent {
  final String query;
  SearchManga(this.query);
}